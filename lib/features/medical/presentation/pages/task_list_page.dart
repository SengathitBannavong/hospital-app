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
            onTap: () => context.push('/medical/task', extra: task),
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
    final cards = <_ActionCard>[
      _ActionCard(
        title: 'Hàng đợi',
        subtitle: 'Xem số thứ tự',
        icon: Icons.people_outline,
        color: AppColors.taskInProgress,
        onTap: () => context.push('/medical/queue'),
      ),
      _ActionCard(
        title: 'Đơn thuốc',
        subtitle: 'Lịch sử đơn thuốc',
        icon: Icons.receipt_long,
        color: AppColors.taskWaiting,
        onTap: () => context.push('/medical/prescription'),
      ),
      _ActionCard(
        title: 'Trạm xe lăn',
        subtitle: 'Các trạm xe lăn',
        icon: Icons.local_parking_rounded,
        color: AppColors.secondary,
        onTap: () => context.push('/asset/stations'),
      ),
      _ActionCard(
        title: 'Tìm xe lăn gần đây',
        subtitle: 'Xe lăn còn trống',
        icon: Icons.accessible_rounded,
        color: AppColors.deptNeurology,
        onTap: () => context.push('/asset/search'),
      ),
      _ActionCard(
        title: 'Hỗ trợ nhân viên',
        subtitle: 'Yêu cầu hỗ trợ',
        icon: Icons.support_agent_rounded,
        color: AppColors.success,
        onTap: () => context.push('/staff'),
      ),
      _ActionCard(
        title: 'Báo cáo vật cản',
        subtitle: 'Báo lối đi bị chặn',
        icon: Icons.report_rounded,
        color: AppColors.warning,
        onTap: () => context.push('/flow/report-obstacle'),
      ),
      _ActionCard(
        title: 'Thông tin & FAQ',
        subtitle: 'Hướng dẫn, câu hỏi',
        icon: Icons.info_outline_rounded,
        color: AppColors.statusOffline,
        onTap: () => context.push('/info'),
      ),
    ];

    // Lay the cards out two-per-row so every service is visible at a glance.
    return Column(
      children: [
        for (var i = 0; i < cards.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          // IntrinsicHeight gives the stretched Row a bounded height inside
          // the scrollable ListView so both cards share the taller's height.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards[i]),
                const SizedBox(width: AppSpacing.md),
                if (i + 1 < cards.length)
                  Expanded(child: cards[i + 1])
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ],
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
              final messenger = ScaffoldMessenger.of(context);
              final scheme = Theme.of(context).colorScheme;
              try {
                // เรียก API เพื่อ sync dữ liệu HIS
                await ref.read(medicalRepositoryProvider).syncNow();
                ref
                  ..invalidate(medicalTasksProvider)
                  ..invalidate(medicalHistoryProvider);
                messenger.showSnackBar(
                  SnackBar(
                    content: const Text('Đã đồng bộ HIS'),
                    backgroundColor: scheme.primary,
                  ),
                );
              } catch (error) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(_cleanError(error)),
                    backgroundColor: scheme.error,
                  ),
                );
              }
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
