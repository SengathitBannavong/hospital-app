import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_messages_state.dart';
import '../widgets/chat_message_bubble.dart';

bool isMineChatMessage(ChatMessage m, int myId, String? role) {
  if (myId != 0 && m.senderId == myId) return true;
  final iAmPatient = role == null || role == 'patient' || role == 'user';
  final fromPatient = m.senderType == 'user';
  return iAmPatient ? fromPatient : (m.senderType.isNotEmpty && !fromPatient);
}

class ChatMessagesPage extends ConsumerStatefulWidget {
  const ChatMessagesPage({required this.roomId, this.roomName = '', super.key});

  final int roomId;
  final String roomName;

  @override
  ConsumerState<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends ConsumerState<ChatMessagesPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatMessagesProvider(widget.roomId).notifier).markRead();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // Guard: only trigger when the list actually has scrollable content.
    if (pos.maxScrollExtent <= 0) return;
    // Reversed list: pixel 0 = bottom (newest), maxScrollExtent = top (oldest).
    // Fire loadMore when the user is within 300px of the top (oldest end).
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(chatMessagesProvider(widget.roomId).notifier).loadMore();
    }
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    await ref
        .read(chatMessagesProvider(widget.roomId).notifier)
        .sendMessage(text);
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    await ref
        .read(chatMessagesProvider(widget.roomId).notifier)
        .sendImage(picked.path);
  }

  String _resolveRoomName() {
    if (widget.roomName.isNotEmpty) return widget.roomName;
    final rooms = ref.read(chatRoomsProvider).rooms;
    final room = rooms.where((r) => r.id == widget.roomId).firstOrNull;
    return room?.name ?? 'Phòng chat';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatMessagesProvider(widget.roomId));
    final authUser = ref.watch(authStateProvider);
    final myId = authUser?.userId ?? 0;
    final myRole = authUser?.role;
    final cs = Theme.of(context).colorScheme;

    ref.listen<ChatMessagesState>(chatMessagesProvider(widget.roomId), (
      prev,
      next,
    ) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        AppToast.showError(next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/chat');
            }
          },
        ),
        title: Text(
          _resolveRoomName(),
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(state, myId, myRole)),
          _buildInputBar(state),
        ],
      ),
    );
  }

  bool _isMine(ChatMessage msg, int myId, String? role) {
    return isMineChatMessage(msg, myId, role);
  }

  Widget _buildMessageList(ChatMessagesState state, int myId, String? role) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.messages.isEmpty && state.errorMessage != null) {
      return _buildError(state.errorMessage!);
    }

    if (state.messages.isEmpty) {
      return const Center(child: Text('Chưa có tin nhắn nào'));
    }

    // +1 slot for the top footer (older-messages indicator / load-more spinner).
    final showFooter = state.hasMore;
    final itemCount = state.messages.length + (showFooter ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // The footer sits at the highest index → appears at the visual TOP.
        if (showFooter && index == state.messages.length) {
          return _buildPaginationFooter(state);
        }

        final msg = state.messages[index];
        final isMe = _isMine(msg, myId, role);

        // Show sender name when the next-older message has a different sender.
        final prevMsg = index + 1 < state.messages.length
            ? state.messages[index + 1]
            : null;
        final showSenderName =
            !isMe && (prevMsg == null || prevMsg.senderId != msg.senderId);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ChatMessageBubble(
            message: msg,
            isMe: isMe,
            showSenderName: showSenderName,
          ),
        );
      },
    );
  }

  Widget _buildPaginationFooter(ChatMessagesState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    // hasMore but not currently loading → tap-to-load fallback.
    return TextButton.icon(
      onPressed: () =>
          ref.read(chatMessagesProvider(widget.roomId).notifier).loadMore(),
      icon: const Icon(Icons.expand_less_rounded, size: 18),
      label: const Text('Tải tin nhắn cũ hơn', style: TextStyle(fontSize: 13)),
    );
  }

  Widget _buildInputBar(ChatMessagesState state) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            top: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: state.isSending ? null : _pickImage,
              icon: const Icon(Icons.image_outlined),
              tooltip: 'Gửi ảnh',
            ),
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: AppRadius.borderFull,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            state.isSending
                ? const SizedBox(
                    height: 40,
                    width: 40,
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageWithTop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(chatMessagesProvider(widget.roomId).notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
