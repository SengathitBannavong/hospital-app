import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/services/chat_websocket_service.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/util/data/repository/util_repository.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/chat_room.dart';
import '../../data/repository/chat_repository.dart';
import 'chat_messages_state.dart';
import 'chat_rooms_state.dart';

// Repository

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(),
);

final activeChatRoomProvider = StateProvider<int?>((ref) => null);
final chatActivityRoomIdsProvider = StateProvider<Set<int>>((ref) => {});

// Rooms list

final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, ChatRoomsState>((ref) {
      final repo = ref.watch(chatRepositoryProvider);
      final notifier = ChatRoomsNotifier(repo, ref)..load();
      return notifier;
    });

// Total unread badge derived from rooms.
final chatUnreadTotalProvider = Provider<int>((ref) {
  final roomsState = ref.watch(chatRoomsProvider);
  return roomsState.totalUnread;
});

final chatHasActivityProvider = Provider<bool>((ref) {
  return ref.watch(chatActivityRoomIdsProvider).isNotEmpty;
});

final chatWebSocketServiceProvider = Provider.autoDispose
    .family<ChatWebSocketService, int>((ref, conversationId) {
      final ws = ChatWebSocketService(conversationId)..connect();
      ref.onDispose(ws.dispose);
      return ws;
    });

class ChatRoomsNotifier extends StateNotifier<ChatRoomsState>
    with WidgetsBindingObserver {
  ChatRoomsNotifier(this._repo, this._ref) : super(ChatRoomsState.initial()) {
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  final ChatRepository _repo;
  final Ref _ref;
  Timer? _pollTimer;
  bool _wasBackgrounded = false;

  static const Duration roomsPollInterval = Duration(seconds: 60);

  @visibleForTesting
  bool get debugIsPolling => _pollTimer?.isActive ?? false;

  Future<void> load({bool refresh = false}) async {
    state = state.copyWith(
      isLoading: !refresh,
      isRefreshing: refresh,
      clearError: true,
    );

    try {
      final rooms = await _repo.getRooms();
      if (!mounted) return;

      // Preserve the current row order so a room that just received a message
      // does not jump to the top; only its data (unread / last message) is
      // refreshed in place. New rooms are appended at the end.
      final ordered = _mergePreservingOrder(state.rooms, rooms);
      final totalUnread = ordered.fold<int>(0, (sum, r) => sum + r.unreadCount);
      _emitNewMessageRooms(ordered);

      state = state.copyWith(
        rooms: ordered,
        isLoading: false,
        isRefreshing: false,
        totalUnread: totalUnread,
      );
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: _fmt(e),
      );
    }
  }

  Future<void> refresh() => load(refresh: true);

  void markRoomRead(int roomId) {
    final updated = state.rooms.map((r) {
      if (r.id == roomId) return r.copyWith(unreadCount: 0);
      return r;
    }).toList();
    final total = updated.fold<int>(0, (sum, r) => sum + r.unreadCount);
    _clearChatActivity(roomId);
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

  // Refreshes each existing room's data while keeping its current position;
  // rooms missing from [incoming] are dropped, brand-new ones are appended.
  List<ChatRoom> _mergePreservingOrder(
    List<ChatRoom> previous,
    List<ChatRoom> incoming,
  ) {
    if (previous.isEmpty) return incoming;
    final incomingById = {for (final room in incoming) room.id: room};
    final seen = <int>{};
    final merged = <ChatRoom>[];
    for (final room in previous) {
      final updated = incomingById[room.id];
      if (updated != null) {
        merged.add(updated);
        seen.add(room.id);
      }
    }
    for (final room in incoming) {
      if (!seen.contains(room.id)) merged.add(room);
    }
    return merged;
  }

  void _emitNewMessageRooms(List<ChatRoom> rooms) {
    if (state.rooms.isEmpty) {
      return;
    }

    final previousById = {for (final room in state.rooms) room.id: room};
    final activeRoomId = _ref.read(activeChatRoomProvider);
    for (final room in rooms) {
      if (room.id == activeRoomId) {
        continue;
      }

      final previous = previousById[room.id];
      if (previous == null) {
        continue;
      }

      final unreadIncreased = room.unreadCount > previous.unreadCount;
      final messageIsNewer = _isNewer(
        room.lastMessageAt,
        previous.lastMessageAt,
      );
      if (unreadIncreased || messageIsNewer) {
        _flagChatActivity(room.id);
      }
    }
  }

  void _flagChatActivity(int roomId) {
    final notifier = _ref.read(chatActivityRoomIdsProvider.notifier);
    notifier.state = {...notifier.state, roomId};
  }

  void _clearChatActivity(int roomId) {
    final notifier = _ref.read(chatActivityRoomIdsProvider.notifier);
    if (!notifier.state.contains(roomId)) return;
    notifier.state = {
      for (final id in notifier.state)
        if (id != roomId) id,
    };
  }

  bool _isNewer(String current, String previous) {
    final currentDate = DateTime.tryParse(current);
    final previousDate = DateTime.tryParse(previous);
    if (currentDate != null && previousDate != null) {
      return currentDate.isAfter(previousDate);
    }
    if (currentDate != null && previous.isEmpty) return true;
    return current.isNotEmpty && current.compareTo(previous) > 0;
  }

  void _startPolling() {
    _pollTimer ??= Timer.periodic(
      roomsPollInterval,
      (_) => load(refresh: true),
    );
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // ??= keeps an already-running timer so the countdown is NOT reset.
        _startPolling();
        if (_wasBackgrounded) {
          _wasBackgrounded = false;
          unawaited(load(refresh: true));
        }
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _wasBackgrounded = true;
        _stopPolling();
      case AppLifecycleState.inactive:
        // Transient (route transitions, app-switcher peek, keyboard, emulator
        // churn). Do NOT cancel the timer here — cancelling + recreating on the
        // following `resumed` resets Timer.periodic's countdown to zero every
        // cycle, so the poll never fires. Leave it running.
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  String _fmt(Object e) => e.toString().replaceFirst('Exception: ', '');
}

// Per-room messages

final chatMessagesProvider = StateNotifierProvider.autoDispose
    .family<ChatMessagesNotifier, ChatMessagesState, int>((
      ref,
      conversationId,
    ) {
      final repo = ref.watch(chatRepositoryProvider);
      final utilRepo = ref.watch(utilRepositoryProvider);
      final ws = ref.watch(chatWebSocketServiceProvider(conversationId));
      final notifier = ChatMessagesNotifier(
        repo,
        utilRepo,
        ws,
        conversationId,
        ref,
      )..load();
      return notifier;
    });

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState>
    with WidgetsBindingObserver {
  ChatMessagesNotifier(
    this._repo,
    this._utilRepo,
    this._ws,
    this._conversationId,
    this._ref,
  ) : super(ChatMessagesState.initial()) {
    WidgetsBinding.instance.addObserver(this);
    _wsSub = _ws.messages.listen(handleWebSocketMessage);
    _connSub = _ws.connectionStates.listen(_handleConnectionChange);
    _startPolling();
  }

  final ChatRepository _repo;
  final UtilRepository _utilRepo;
  final ChatWebSocketService _ws;
  final int _conversationId;
  final Ref _ref;
  StreamSubscription<Map<String, dynamic>>? _wsSub;
  StreamSubscription<bool>? _connSub;
  bool _hasConnectedOnce = false;
  Timer? _pollTimer;
  final Map<int, String> _senderNames = {};
  final Set<int> _pendingIds = {};
  bool _isMarkingRead = false;
  int _nextTempId = -1;

  static const int _pageSize = 50;
  // Backstop only: realtime comes from the WebSocket, with a catch-up fetch on
  // every reconnect. This slow poll is a safety net for silent WS failures.
  static const Duration messagesPollInterval = Duration(seconds: 25);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _loadLatestMessagesPage();
      if (!mounted) return;
      _pendingIds.clear();
      await _loadSenderNames();
      if (!mounted) return;
      state = state.copyWith(
        messages: _sortedNewestFirst(
          page.messages.map(_withResolvedSenderName),
        ),
        isLoading: false,
        page: page.page,
        hasMore: page.page > 1,
      );
      unawaited(_markUnreadIncomingMessagesRead());
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _fmt(e));
    }
  }

  Future<void> refreshMessages() async {
    if (!mounted) return;
    try {
      final page = await _loadLatestMessagesPage();
      if (!mounted) return;

      await _loadSenderNames();
      if (!mounted) return;

      final serverMessages = page.messages
          .map(_withResolvedSenderName)
          .toList();
      for (final message in serverMessages) {
        _reconcilePendingEcho(message);
      }
      final pendingMessages = state.messages
          .where((message) => _pendingIds.contains(message.id))
          .toList();
      final deduplicated = <int, ChatMessage>{
        for (final message in [...pendingMessages, ...serverMessages])
          message.id: message,
      }.values;
      state = state.copyWith(
        messages: _sortedNewestFirst(deduplicated),
        page: state.page > 0 && state.page < page.page ? state.page : page.page,
        hasMore: (state.page > 0 && state.page < page.page)
            ? state.page > 1
            : page.page > 1,
      );
      unawaited(_markUnreadIncomingMessagesRead());
    } catch (_) {
      // Background refresh — ignore failures; the next poll/WS event retries.
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page - 1;
      final msgs = await _repo.getMessages(
        conversationId: _conversationId,
        page: nextPage,
        limit: _pageSize,
      );
      final merged = [...state.messages, ...msgs];
      final deduplicated = <int, ChatMessage>{
        for (final m in merged) m.id: _withResolvedSenderName(m),
      }.values.toList();
      state = state.copyWith(
        messages: _sortedNewestFirst(deduplicated),
        isLoadingMore: false,
        page: nextPage,
        hasMore: nextPage > 1,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: _fmt(e));
    }
  }

  Future<ChatMessagesPageResult> _loadLatestMessagesPage() async {
    final firstPage = await _repo.getMessagesPage(
      conversationId: _conversationId,
      page: 1,
      limit: _pageSize,
    );
    final lastPage = _lastPageFor(firstPage.total, firstPage.limit);
    if (lastPage <= 1) return firstPage;

    return _repo.getMessagesPage(
      conversationId: _conversationId,
      page: lastPage,
      limit: _pageSize,
    );
  }

  int _lastPageFor(int total, int limit) {
    if (total <= 0) return 1;
    final safeLimit = limit <= 0 ? _pageSize : limit;
    return ((total + safeLimit - 1) ~/ safeLimit).clamp(1, 1 << 31);
  }

  Future<void> sendMessage(String content) async {
    final text = content.trim();
    if (text.isEmpty) return;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      _ws.send({'type': 'text', 'text_content': text, 'media_url': ''});
      _insertPendingMessage(type: 'text', content: text, mediaUrl: '');
      state = state.copyWith(isSending: false);
      unawaited(refreshMessages());
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
      _ws.send({
        'type': 'image',
        'text_content': '',
        'media_url': upload.fileUrl,
      });
      _insertPendingMessage(
        type: 'image',
        content: '',
        mediaUrl: upload.fileUrl,
      );
      state = state.copyWith(isSending: false);
      unawaited(refreshMessages());
    } catch (e) {
      state = state.copyWith(isSending: false, errorMessage: _fmt(e));
    }
  }

  Future<void> markRead() async {
    if (_isMarkingRead) {
      return;
    }
    final activeRoom = _ref.read(activeChatRoomProvider);
    if (activeRoom != _conversationId) {
      return;
    }
    if (!_hasUnreadIncomingMessages()) {
      return;
    }

    _isMarkingRead = true;
    try {
      await _repo.markRead(conversationId: _conversationId);
      if (!mounted) return;
      state = state.copyWith(
        messages: state.messages.map((message) {
          if (_isMine(message) || message.isRead) return message;
          return message.copyWith(isRead: true);
        }).toList(),
      );
      _ref.read(chatRoomsProvider.notifier).markRoomRead(_conversationId);
    } catch (_) {
    } finally {
      _isMarkingRead = false;
    }
  }

  void _handleConnectionChange(bool connected) {
    if (!connected) return;
    // Skip the first connect — the constructor's load() already fetched the
    // latest page. Every reconnect after that backfills messages the broadcast
    // dropped while the socket was down.
    if (!_hasConnectedOnce) {
      _hasConnectedOnce = true;
      return;
    }
    unawaited(refreshMessages());
  }

  // WS broadcasts message_id, sender_id, type, text_content, media_url, etc.
  // No conversation_id in broadcast (per-room connection, so it's implicit).
  void handleWebSocketMessage(Map<String, dynamic> msg) {
    if (!mounted) return;
    if (msg['message_id'] == null) {
      return;
    }

    try {
      final chatMsg = ChatMessage.fromJson(msg);
      if (!mounted) return;
      _reconcilePendingEcho(chatMsg);
      _upsertMessage(chatMsg);
      unawaited(_markUnreadIncomingMessagesRead());
    } catch (e) {
      debugPrint('[chat] failed to handle websocket message: $e');
    }
  }

  void _insertPendingMessage({
    required String type,
    required String content,
    required String mediaUrl,
  }) {
    final tempId = _nextTempId--;
    _pendingIds.add(tempId);
    _upsertMessage(
      ChatMessage(
        id: tempId,
        roomId: _conversationId,
        senderId: _myUserId,
        senderType: _mySenderType,
        senderName: '',
        content: content,
        type: type,
        mediaUrl: mediaUrl,
        isRead: false,
        isDeleted: false,
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  void _reconcilePendingEcho(ChatMessage chatMsg) {
    if (_pendingIds.isEmpty) return;
    final pending = state.messages.where((message) {
      return _pendingIds.contains(message.id) &&
          message.type == chatMsg.type &&
          _matchesPendingPayload(message, chatMsg);
    }).toList();
    if (pending.isEmpty) return;

    final oldest = pending.reduce((a, b) => a.id < b.id ? a : b);
    _pendingIds.remove(oldest.id);
    state = state.copyWith(
      messages: state.messages
          .where((message) => message.id != oldest.id)
          .toList(),
    );
  }

  bool _matchesPendingPayload(ChatMessage pending, ChatMessage real) {
    // TODO(backend): image reconcile relies on echoed media_url
    // matching the sent one.
    if (real.type == 'image') return pending.mediaUrl == real.mediaUrl;
    return pending.content == real.content;
  }

  bool _hasUnreadIncomingMessages() {
    return state.messages.any((message) {
      return !_pendingIds.contains(message.id) &&
          !message.isRead &&
          !_isMine(message);
    });
  }

  Future<void> _markUnreadIncomingMessagesRead() async {
    if (!mounted || !_hasUnreadIncomingMessages()) return;
    await markRead();
  }

  void _upsertMessage(ChatMessage msg, {bool? isSending}) {
    if (!mounted) return;
    final resolvedMsg = _withResolvedSenderName(msg);
    final withoutDuplicate = state.messages
        .where((message) => message.id != resolvedMsg.id)
        .toList();
    state = state.copyWith(
      messages: _sortedNewestFirst([resolvedMsg, ...withoutDuplicate]),
      isSending: isSending,
    );
    _ref
        .read(chatRoomsProvider.notifier)
        .updateRoomLastMessage(
          _conversationId,
          _lastMessagePreview(resolvedMsg),
          resolvedMsg.createdAt,
        );
  }

  Future<void> _loadSenderNames() async {
    if (_senderNames.isNotEmpty) return;
    try {
      final participants = await _repo.getParticipants();
      for (final patient in participants.patients) {
        if (patient.fullName.isNotEmpty) {
          _senderNames[patient.userId] = patient.fullName;
        }
      }
      for (final staff in participants.staffs) {
        final label = staff.staffCode.isNotEmpty ? staff.staffCode : staff.role;
        if (label.isNotEmpty) {
          _senderNames[staff.userId] = label;
          _senderNames[staff.staffId] = label;
        }
      }
    } catch (e) {
      debugPrint('[chat] failed to load sender names: $e');
    }
  }

  ChatMessage _withResolvedSenderName(ChatMessage msg) {
    final senderName = _senderNames[msg.senderId];
    if (senderName == null || senderName.isEmpty) return msg;
    return msg.copyWith(senderName: senderName);
  }

  String _lastMessagePreview(ChatMessage msg) {
    if (msg.content.isNotEmpty) return msg.content;
    return switch (msg.type) {
      'image' => '[Hình ảnh]',
      'voice' => '[Tin nhắn thoại]',
      _ => '',
    };
  }

  List<ChatMessage> _sortedNewestFirst(Iterable<ChatMessage> msgs) {
    final list = msgs.toList()
      ..sort((a, b) {
        final byTime = b.createdAt.compareTo(a.createdAt);
        if (byTime != 0) return byTime;
        return b.id.compareTo(a.id);
      });
    return list;
  }

  void _startPolling() {
    _pollTimer ??= Timer.periodic(
      messagesPollInterval,
      (_) => refreshMessages(),
    );
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      unawaited(refreshMessages());
    } else {
      _stopPolling();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    _wsSub?.cancel();
    _connSub?.cancel();
    super.dispose();
  }

  String _fmt(Object e) => e.toString().replaceFirst('Exception: ', '');

  int get _myUserId => _ref.read(authStateProvider)?.userId ?? 0;

  bool _isMine(ChatMessage message) {
    final myId = _myUserId;
    if (myId != 0 && message.senderId == myId) return true;
    final role = _ref.read(authStateProvider)?.role;
    final iAmPatient = role == null || role == 'patient' || role == 'user';
    final fromPatient = message.senderType == 'user';
    return iAmPatient
        ? fromPatient
        : (message.senderType.isNotEmpty && !fromPatient);
  }

  String get _mySenderType {
    final role = _ref.read(authStateProvider)?.role;
    if (role == null || role == 'patient' || role == 'user') return 'user';
    return role;
  }
}
