import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../data/models/medical_task.dart';
import '../providers/medical_providers.dart';
import '../widgets/task_card.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    Future<bool> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      if (!context.mounted) return;
      _showSnackBar(context, successMessage);
      ref
        ..invalidate(medicalTasksProvider)
        ..invalidate(medicalHistoryProvider);
    } catch (error) {
      if (!context.mounted) return;
      _showSnackBar(context, _cleanError(error), isError: true);
    }
  }

  Future<void> _showResultStatus(
    BuildContext context,
    WidgetRef ref,
    int treatmentId,
  ) async {
    try {
      // เช็คผลตรวจจาก treatment_id
      final result = await ref
          .read(medicalRepositoryProvider)
          .getResultStatus(treatmentId: treatmentId);

      if (!context.mounted) return;

      if (result == null) {
        _showSnackBar(context, 'Không có dữ liệu kết quả');
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kết quả'),
          content: Text(
            'Treatment: ${result.treatmentId}\n'
            'Trạng thái: ${result.status}\n'
            'Có kết quả: ${result.hasResult ? 'Có' : 'Chưa'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      _showSnackBar(context, _cleanError(error), isError: true);
    }
  }

  Future<void> _refreshAll(WidgetRef ref) async {
    ref
      ..invalidate(medicalTasksProvider)
      ..invalidate(medicalHistoryProvider);
    await Future.wait([
      ref.read(medicalTasksProvider.future),
      ref.read(medicalHistoryProvider.future),
    ]);
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    WidgetRef ref,
    List<MedicalTask> tasks,
  ) {
    if (tasks.isEmpty) {
      return _buildEmptyState(context, 'Chưa có chỉ định nào');
    }

    return Column(
      children: [
        for (final task in tasks) ...[
          TaskCard(
            task: task,
            onCheckin: () => _runAction(
              context,
              ref,
              () => ref
                  .read(medicalRepositoryProvider)
                  .checkinRoom(treatmentId: task.treatmentId),
              'Check-in thành công',
            ),
            onCheckout: () => _runAction(
              context,
              ref,
              () => ref
                  .read(medicalRepositoryProvider)
                  .checkoutRoom(treatmentId: task.treatmentId),
              'Check-out thành công',
            ),
            onCancel: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hủy chỉ định'),
                  content: const Text('Bạn có chắc chắn muốn hủy không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Không'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Có'),
                    ),
                  ],
                ),
              );

              if (!context.mounted) return;

              if (confirmed == true) {
                await _runAction(
                  context,
                  ref,
                  () => ref
                      .read(medicalRepositoryProvider)
                      .cancelTask(treatmentId: task.treatmentId),
                  'Đã hủy chỉ định',
                );
              }
            },
            onCheckResult: () =>
                _showResultStatus(context, ref, task.treatmentId),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(medicalHistoryProvider);

    return ExpansionTile(
      title: const Text('Lịch sử hôm nay'),
      childrenPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        historyAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return _buildEmptyState(context, 'Chưa có lịch sử');
            }
            return Column(
              children: [
                for (final task in items) ...[
                  TaskCard(task: task),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              _cleanError(error),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: 'Hàng đợi',
            subtitle: 'Xem số thứ tự',
            icon: Icons.people_outline,
            color: Colors.blue,
            onTap: () => context.push('/medical/queue'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionCard(
            title: 'Đơn thuốc',
            subtitle: 'Lịch sử đơn thuốc',
            icon: Icons.receipt_long,
            color: Colors.orange,
            onTap: () => context.push('/medical/prescription'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(medicalTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉ định khám'),
        actions: [
          IconButton(
            onPressed: () async {
              await _runAction(
                context,
                ref,
                // เรียก API เพื่อ sync dữ liệu HIS
                () => ref.read(medicalRepositoryProvider).syncNow(),
                'Đã đồng bộ HIS',
              );
            },
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync HIS',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshAll(ref),
        child: ListView(
          padding: AppSpacing.pagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: AppSpacing.md),
            _buildQuickActions(context),
            const SizedBox(height: AppSpacing.lg),
            tasksAsync.when(
              data: (tasks) => _buildTaskList(context, ref, tasks),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) =>
                  _buildEmptyState(context, _cleanError(error)),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildHistorySection(context, ref),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
