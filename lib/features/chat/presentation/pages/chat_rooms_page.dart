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
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRoomDialog(context),
        tooltip: 'Tạo cuộc trò chuyện mới',
        child: const Icon(Icons.edit_rounded),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ChatRoomsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.hasRooms && state.errorMessage != null) {
      return _buildError(state.errorMessage!);
    }

    if (!state.hasRooms) {
      return _buildEmpty();
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
          return ChatRoomCard(
            room: room,
            onTap: () => context.push(
              '/chat/${room.id}',
              extra: {'room_name': room.name},
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCreateRoomDialog(BuildContext context) async {
    bool isCreating = false;
    final staffIdController = TextEditingController();
    final topicController = TextEditingController();
    String? staffIdError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tạo cuộc trò chuyện'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: staffIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ID nhân viên hỗ trợ *',
                  hintText: 'Nhập ID nhân viên',
                  errorText: staffIdError,
                ),
                onChanged: (_) {
                  if (staffIdError != null) {
                    setDialogState(() => staffIdError = null);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(
                  labelText: 'Chủ đề (tuỳ chọn)',
                  hintText: 'Hỗ trợ bệnh nhân',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isCreating ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: isCreating
                  ? null
                  : () async {
                      final staffIdText = staffIdController.text.trim();
                      final staffId = int.tryParse(staffIdText);
                      if (staffId == null || staffId <= 0) {
                        setDialogState(() => staffIdError = 'Vui lòng nhập ID hợp lệ');
                        return;
                      }
                      setDialogState(() => isCreating = true);
                      final ok = await ref
                          .read(chatRoomsProvider.notifier)
                          .createRoom(
                            staffId: staffId,
                            topic: topicController.text.trim(),
                          );
                      if (!ctx.mounted) return;
                      Navigator.of(ctx).pop();
                      if (ok) {
                        AppToast.showSuccess('Đã tạo cuộc trò chuyện');
                      }
                    },
              child: isCreating
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
    staffIdController.dispose();
    topicController.dispose();
  }

  Widget _buildEmpty() {
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
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Nhấn nút bút để tạo mới',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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
