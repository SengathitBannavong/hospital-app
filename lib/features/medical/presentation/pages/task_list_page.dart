import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/locale_controller.dart';
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
      return _buildEmptyState(context, context.l10n.mlEmptyTasks);
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
      title: Text(context.l10n.mlHistoryToday),
      childrenPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        historyAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return _buildEmptyState(context, context.l10n.mlNoHistory);
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
    final l10n = context.l10n;
    final cards = <_ActionCard>[
      _ActionCard(
        title: l10n.homeActionQueue,
        subtitle: l10n.mlQueueSubtitle,
        icon: Icons.people_outline,
        color: AppColors.taskInProgress,
        onTap: () => context.push('/medical/queue'),
      ),
      _ActionCard(
        title: l10n.homeActionPrescription,
        subtitle: l10n.mlPrescriptionSubtitle,
        icon: Icons.receipt_long,
        color: AppColors.taskWaiting,
        onTap: () => context.push('/medical/prescription'),
      ),
      _ActionCard(
        title: l10n.mlStationsTitle,
        subtitle: l10n.mlStationsSubtitle,
        icon: Icons.local_parking_rounded,
        color: AppColors.secondary,
        onTap: () => context.push('/asset/stations'),
      ),
      _ActionCard(
        title: l10n.mlFindNearbyTitle,
        subtitle: l10n.mlFindNearbySubtitle,
        icon: Icons.accessible_rounded,
        color: AppColors.deptNeurology,
        onTap: () => context.push('/asset/search'),
      ),
      _ActionCard(
        title: l10n.mlStaffTitle,
        subtitle: l10n.staffTitle,
        icon: Icons.support_agent_rounded,
        color: AppColors.success,
        onTap: () => context.push('/staff'),
      ),
      _ActionCard(
        title: l10n.mlObstacleTitle,
        subtitle: l10n.mlObstacleSubtitle,
        icon: Icons.report_rounded,
        color: AppColors.warning,
        onTap: () => context.push('/flow/report-obstacle'),
      ),
      _ActionCard(
        title: l10n.mlInfoTitle,
        subtitle: l10n.mlInfoSubtitle,
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
        title: Text(context.l10n.mlTitle),
        actions: [
          IconButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final scheme = Theme.of(context).colorScheme;
              final l10n = context.l10n;
              try {
                // เรียก API เพื่อ sync dữ liệu HIS
                await ref.read(medicalRepositoryProvider).syncNow();
                ref
                  ..invalidate(medicalTasksProvider)
                  ..invalidate(medicalHistoryProvider);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.mlSyncSuccess),
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
            tooltip: context.l10n.mlSyncTooltip,
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
