import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/chat_participants.dart';
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
    final role = ref.read(authStateProvider)?.role;
    final isPatient = role == null || role == 'patient';

    if (isPatient) {
      await _showPatientCreateRoomDialog(context);
      return;
    }

    await _showStaffCreateRoomDialog(context);
  }

  Future<void> _showPatientCreateRoomDialog(BuildContext context) async {
    final topicController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bắt đầu trò chuyện hỗ trợ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: 'Chủ đề (tuỳ chọn)',
                hintText: 'Hỗ trợ bệnh nhân',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              // TODO(backend): Provide the default support staff_id for
              // patient-initiated rooms so this action can call create_room.
              'Chưa có nhân viên hỗ trợ mặc định. Vui lòng liên hệ lễ tân.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
          const FilledButton(onPressed: null, child: Text('Bắt đầu')),
        ],
      ),
    );
    topicController.dispose();
  }

  Future<void> _showStaffCreateRoomDialog(BuildContext context) async {
    ChatPatient? selectedPatient;
    final topicController = TextEditingController();
    final participantsFuture = ref
        .read(chatRepositoryProvider)
        .getParticipants();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tạo cuộc trò chuyện với bệnh nhân'),
          content: FutureBuilder<ChatParticipants>(
            future: participantsFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Không thể tải danh sách bệnh nhân: ${snapshot.error}',
                );
              }

              final patients = snapshot.data?.patients ?? const [];
              if (patients.isEmpty) {
                return const Text('Không có bệnh nhân để chọn.');
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ChatPatient>(
                    initialValue: selectedPatient,
                    items: patients
                        .map(
                          (patient) => DropdownMenuItem(
                            value: patient,
                            child: Text(patient.fullName),
                          ),
                        )
                        .toList(),
                    onChanged: (patient) {
                      setDialogState(() => selectedPatient = patient);
                    },
                    decoration: const InputDecoration(labelText: 'Bệnh nhân'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: topicController,
                    decoration: const InputDecoration(
                      labelText: 'Chủ đề (tuỳ chọn)',
                      hintText: 'Hỗ trợ bệnh nhân',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    // TODO(backend): Expose the logged-in staff's staff_id on
                    // AuthUser so staff can create rooms with selected
                    // patients.
                    'Tài khoản chưa có mã nhân viên để tạo cuộc trò chuyện.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đóng'),
            ),
            const FilledButton(onPressed: null, child: Text('Tạo')),
          ],
        ),
      ),
    );
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
                Text('Nhấn nút bút để tạo mới', style: TextStyle(fontSize: 12)),
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
