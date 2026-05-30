import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/services/chat_websocket_service.dart';
import 'package:hospital_app/features/util/data/repository/util_repository.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';
import '../../data/models/chat_message.dart';
import '../../data/repository/chat_repository.dart';
import 'chat_messages_state.dart';
import 'chat_rooms_state.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(),
);

// ── Rooms list ────────────────────────────────────────────────────────────────

final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, ChatRoomsState>((ref) {
      final repo = ref.watch(chatRepositoryProvider);
      final notifier = ChatRoomsNotifier(repo);
      notifier.load();
      return notifier;
    });

// Total unread badge derived from rooms.
final chatUnreadTotalProvider = Provider<int>((ref) {
  final roomsState = ref.watch(chatRoomsProvider);
  return roomsState.totalUnread;
});

class ChatRoomsNotifier extends StateNotifier<ChatRoomsState> {
  ChatRoomsNotifier(this._repo) : super(ChatRoomsState.initial());

  final ChatRepository _repo;

  Future<void> load({bool refresh = false}) async {
    state = state.copyWith(
      isLoading: !refresh,
      isRefreshing: refresh,
      clearError: true,
    );

    try {
      final rooms = await _repo.getRooms();
      final totalUnread = rooms.fold<int>(0, (sum, r) => sum + r.unreadCount);

      state = state.copyWith(
        rooms: rooms,
        isLoading: false,
        isRefreshing: false,
        totalUnread: totalUnread,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: _fmt(e),
      );
    }
  }

  Future<void> refresh() => load(refresh: true);

  Future<bool> createRoom({
    required int staffId,
    int? userId,
    String topic = '',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.createRoom(staffId: staffId, userId: userId, topic: topic);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _fmt(e));
      return false;
    }
  }

  void markRoomRead(int roomId) {
    final updated = state.rooms.map((r) {
      if (r.id == roomId) return r.copyWith(unreadCount: 0);
      return r;
    }).toList();
    final total = updated.fold<int>(0, (sum, r) => sum + r.unreadCount);
    state = state.copyWith(rooms: updated, totalUnread: total);
  }

  void updateRoomLastMessage(int roomId, String content, String at) {
    final updated = state.rooms.map((r) {
      if (r.id == roomId) {
        return r.copyWith(lastMessage: content, lastMessageAt: at);
      }
      return r;
    }).toList();
    state = state.copyWith(rooms: updated);
  }

  String _fmt(Object e) => e.toString().replaceFirst('Exception: ', '');
}

// ── Per-room messages ─────────────────────────────────────────────────────────

final chatMessagesProvider =
    StateNotifierProvider.family<ChatMessagesNotifier, ChatMessagesState, int>((
      ref,
      conversationId,
    ) {
      final repo = ref.watch(chatRepositoryProvider);
      final utilRepo = ref.watch(utilRepositoryProvider);
      // Per-room WS connection: backend URL needs conversation_id in query param.
      final ws = ChatWebSocketService(conversationId);
      ws.connect();
      ref.onDispose(ws.dispose);
      final notifier = ChatMessagesNotifier(
        repo,
        utilRepo,
        ws,
        conversationId,
        ref,
      );
      notifier.load();
      return notifier;
    });

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  ChatMessagesNotifier(
    this._repo,
    this._utilRepo,
    this._ws,
    this._conversationId,
    this._ref,
  ) : super(ChatMessagesState.initial()) {
    _wsSub = _ws.messages.listen(_onWsMessage);
  }

  final ChatRepository _repo;
  final UtilRepository _utilRepo;
  final ChatWebSocketService _ws;
  final int _conversationId;
  final Ref _ref;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  static const int _pageSize = 30;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final msgs = await _repo.getMessages(
        conversationId: _conversationId,
        page: 1,
        limit: _pageSize,
      );
      state = state.copyWith(
        messages: msgs,
        isLoading: false,
        page: 1,
        hasMore: msgs.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _fmt(e));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final msgs = await _repo.getMessages(
        conversationId: _conversationId,
        page: nextPage,
        limit: _pageSize,
      );
      final merged = [...state.messages, ...msgs];
      final deduplicated = <int, ChatMessage>{
        for (final m in merged) m.id: m,
      }.values.toList();
      state = state.copyWith(
        messages: deduplicated,
        isLoadingMore: false,
        page: nextPage,
        hasMore: msgs.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: _fmt(e));
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final msg = await _repo.sendMessage(
        conversationId: _conversationId,
        content: content.trim(),
      );
      _upsertMessage(msg, isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, errorMessage: _fmt(e));
    }
  }

  Future<void> sendImage(String path) async {
    if (path.trim().isEmpty) return;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final filename = path.split('/').last;
      final file = await MultipartFile.fromFile(path, filename: filename);
      final upload = await _utilRepo.uploadFile(file);
      final msg = await _repo.sendMessage(
        conversationId: _conversationId,
        type: 'image',
        mediaUrl: upload.fileUrl,
      );
      _upsertMessage(msg, isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, errorMessage: _fmt(e));
    }
  }

  Future<void> markRead() async {
    try {
      await _repo.markRead(conversationId: _conversationId);
      _ref.read(chatRoomsProvider.notifier).markRoomRead(_conversationId);
    } catch (_) {}
  }

  // WS broadcasts: {message_id, sender_id, sender_type, type, text_content, media_url, created_at}
  // No conversation_id in broadcast (per-room connection, so it's implicit).
  void _onWsMessage(Map<String, dynamic> msg) {
    if (msg['message_id'] == null) return;

    try {
      final chatMsg = ChatMessage.fromJson(msg);
      _upsertMessage(chatMsg);
    } catch (_) {}
  }

  void _upsertMessage(ChatMessage msg, {bool? isSending}) {
    final withoutDuplicate = state.messages
        .where((message) => message.id != msg.id)
        .toList();
    state = state.copyWith(
      messages: [msg, ...withoutDuplicate],
      isSending: isSending,
    );
    _ref
        .read(chatRoomsProvider.notifier)
        .updateRoomLastMessage(
          _conversationId,
          _lastMessagePreview(msg),
          msg.createdAt,
        );
  }

  String _lastMessagePreview(ChatMessage msg) {
    if (msg.content.isNotEmpty) return msg.content;
    return switch (msg.type) {
      'image' => '[Hình ảnh]',
      'voice' => '[Tin nhắn thoại]',
      _ => '',
    };
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  String _fmt(Object e) => e.toString().replaceFirst('Exception: ', '');
}
