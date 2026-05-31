import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_rooms_state.dart';
import '../widgets/chat_room_card.dart';

class ChatRoomsPage extends ConsumerStatefulWidget {
  const ChatRoomsPage({super.key});

  @override
  ConsumerState<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends ConsumerState<ChatRoomsPage> {
  @override
  void initState() {
    super.initState();
    _clearActiveRoomAfterFrame();
  }

  void _clearActiveRoomAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final activeRoom = ref.read(activeChatRoomProvider);
      if (activeRoom != null) {
        ref.read(activeChatRoomProvider.notifier).state = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(activeChatRoomProvider) != null) {
      _clearActiveRoomAfterFrame();
    }
    final state = ref.watch(chatRoomsProvider);
    final cs = Theme.of(context).colorScheme;

    ref.listen<ChatRoomsState>(chatRoomsProvider, (prev, next) {
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
        title: Row(
          children: [
            const Text(
              'Tin nhắn',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (state.totalUnread > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  '${state.totalUnread}',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: _buildBody(ref, state),
    );
  }

  Widget _buildBody(WidgetRef ref, ChatRoomsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.hasRooms && state.errorMessage != null) {
      return _buildError(ref, state.errorMessage!);
    }

    if (!state.hasRooms) {
      return _buildEmpty(ref);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(chatRoomsProvider.notifier).refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.rooms.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final room = state.rooms[index];
          final hasActivity = ref
              .watch(chatActivityRoomIdsProvider)
              .contains(room.id);
          return ChatRoomCard(
            room: room,
            hasActivity: hasActivity,
            onTap: () => context.push(
              '/chat/${room.id}',
              extra: {'room_name': room.name},
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(chatRoomsProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.pageWithTop,
        children: const [
          SizedBox(height: AppSpacing.xxl),
          Center(
            child: Column(
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 48),
                SizedBox(height: AppSpacing.md),
                Text('Chưa có cuộc trò chuyện nào'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(WidgetRef ref, String message) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageWithTop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 48),
            const SizedBox(height: AppSpacing.md),
            const Text('Không thể tải tin nhắn'),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => ref.read(chatRoomsProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
