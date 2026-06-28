import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
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
  late ProviderContainer _container;
  bool _showNewMessagesPill = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container = ProviderScope.containerOf(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setActiveRoom(widget.roomId);
      _markReadIfUnread();
    });
  }

  @override
  void didUpdateWidget(covariant ChatMessagesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomId != widget.roomId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _setActiveRoom(widget.roomId);
      });
    }
  }

  @override
  void dispose() {
    _clearActiveRoomAfterDispose(widget.roomId);
    _inputController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setActiveRoom(int roomId) {
    ref.read(activeChatRoomProvider.notifier).state = roomId;
    _clearChatActivity(roomId);
  }

  void _clearActiveRoomAfterDispose(int roomId) {
    Future<void>(() {
      final activeRoom = _container.read(activeChatRoomProvider);
      if (activeRoom == roomId) {
        _container.read(activeChatRoomProvider.notifier).state = null;
      }
    });
  }

  void _clearChatActivity(int roomId) {
    final notifier = ref.read(chatActivityRoomIdsProvider.notifier);
    if (!notifier.state.contains(roomId)) return;
    notifier.state = {
      for (final id in notifier.state)
        if (id != roomId) id,
    };
  }

  void _markReadIfUnread() {
    if (ref.read(activeChatRoomProvider) != widget.roomId) return;
    final room = ref
        .read(chatRoomsProvider)
        .rooms
        .where((room) => room.id == widget.roomId)
        .firstOrNull;
    if (room == null || room.unreadCount <= 0) return;

    ref.read(chatMessagesProvider(widget.roomId).notifier).markRead();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // Reversed list: pixel 0 = bottom (newest), maxScrollExtent = top (oldest).
    // Once the user scrolls back to the newest, drop the new-messages pill.
    if (_showNewMessagesPill && pos.pixels <= pos.minScrollExtent + 80) {
      setState(() => _showNewMessagesPill = false);
    }
    // Guard: only trigger when the list actually has scrollable content.
    if (pos.maxScrollExtent <= 0) return;
    // Fire loadMore when the user is within 300px of the top (oldest end).
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(chatMessagesProvider(widget.roomId).notifier).loadMore();
    }
  }

  // True when the viewport shows the newest messages (reverse-list bottom).
  bool _isAtBottom() {
    if (!_scrollController.hasClients) return true;
    final pos = _scrollController.position;
    return pos.pixels <= pos.minScrollExtent + 80;
  }

  // Reacts to message-list changes. Auto-scrolls to the newest message only
  // when the user is already at the bottom or sent the message themselves;
  // otherwise it preserves their reading position and shows the pill.
  void _onMessagesChanged(ChatMessagesState? prev, ChatMessagesState next) {
    final nextNewest = next.messages.isNotEmpty ? next.messages.first : null;
    if (nextNewest == null) return;
    final prevNewest = (prev?.messages.isNotEmpty ?? false)
        ? prev!.messages.first
        : null;
    final isNewArrival = prevNewest == null || nextNewest.id != prevNewest.id;
    if (!isNewArrival) return;

    final authUser = ref.read(authStateProvider);
    final mine = isMineChatMessage(
      nextNewest,
      authUser?.userId ?? 0,
      authUser?.role,
    );

    if (mine || _isAtBottom()) {
      if (_showNewMessagesPill) {
        setState(() => _showNewMessagesPill = false);
      }
      _scrollToBottomSoon();
    } else {
      // Keep the old-message view from shifting when items are added at the
      // bottom of the reversed list, then signal that something arrived.
      _preserveScrollAfterInsert();
      if (!_showNewMessagesPill) {
        setState(() => _showNewMessagesPill = true);
      }
    }
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  // In a reversed list, inserting at index 0 (the visual bottom) grows
  // maxScrollExtent; re-anchoring to the same distance-from-top keeps the
  // messages the user is reading perfectly still.
  void _preserveScrollAfterInsert() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final oldPixels = pos.pixels;
    final oldMax = pos.maxScrollExtent;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final newPos = _scrollController.position;
      final delta = newPos.maxScrollExtent - oldMax;
      if (delta.abs() < 0.5) return;
      newPos.jumpTo(
        (oldPixels + delta).clamp(
          newPos.minScrollExtent,
          newPos.maxScrollExtent,
        ),
      );
    });
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
    return room?.name ?? appL10n.chatRoomDefault;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatMessagesProvider(widget.roomId));
    final authUser = ref.watch(authStateProvider);
    final myId = authUser?.userId ?? 0;
    final myRole = authUser?.role;
    final cs = Theme.of(context).colorScheme;
    final isClosed =
        ref
            .watch(chatRoomsProvider)
            .rooms
            .where((room) => room.id == widget.roomId)
            .firstOrNull
            ?.status ==
        'closed';

    ref
      ..listen<ChatMessagesState>(chatMessagesProvider(widget.roomId), (
        prev,
        next,
      ) {
        if (next.errorMessage != null &&
            next.errorMessage != prev?.errorMessage) {
          AppToast.showError(next.errorMessage!);
        }
        _onMessagesChanged(prev, next);
      })
      ..listen(chatRoomsProvider, (prev, next) {
        final previousUnread = prev?.rooms
            .where((room) => room.id == widget.roomId)
            .firstOrNull
            ?.unreadCount;
        final currentUnread = next.rooms
            .where((room) => room.id == widget.roomId)
            .firstOrNull
            ?.unreadCount;
        if (currentUnread != null &&
            currentUnread > 0 &&
            currentUnread != previousUnread) {
          _markReadIfUnread();
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
          Expanded(
            child: Stack(
              children: [
                _buildMessageList(state, myId, myRole),
                if (_showNewMessagesPill) _buildNewMessagesPill(),
              ],
            ),
          ),
          isClosed ? _buildClosedBanner() : _buildInputBar(state),
        ],
      ),
    );
  }

  /// Shown in place of the input bar when the conversation is closed, so the
  /// patient cannot keep chatting. The backend also rejects sends to a closed
  /// room; this just makes that state visible instead of a failed send.
  Widget _buildClosedBanner() {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                context.l10n.chatClosed,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
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
      return Center(child: Text(context.l10n.chatNoMessagesYet));
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
      label: Text(
        context.l10n.chatLoadOlder,
        style: const TextStyle(fontSize: 13),
      ),
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
              tooltip: context.l10n.chatSendImage,
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
                  hintText: context.l10n.chatInputHint,
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

  Widget _buildNewMessagesPill() {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      bottom: AppSpacing.md,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          color: cs.primary,
          borderRadius: AppRadius.borderFull,
          elevation: 3,
          child: InkWell(
            borderRadius: AppRadius.borderFull,
            onTap: () {
              setState(() => _showNewMessagesPill = false);
              _scrollToBottomSoon();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: 16,
                    color: cs.onPrimary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.l10n.chatNewMessages,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
