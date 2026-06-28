import 'package:flutter/material.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../data/models/medical_task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onTap});

  final MedicalTask task;
  final VoidCallback? onTap;

  Color _statusColor(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'pending':
        return scheme.tertiary;
      case 'completed':
        return scheme.primary;
      case 'cancelled':
        return scheme.error;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, task.status);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.taskName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  // Backend tasks carry poi_id but no poi_name, so fall back
                  // to the room id when the name is empty.
                  _InfoChip(
                    label: context.l10n.tcRoom(
                      task.poiName.isNotEmpty
                          ? task.poiName
                          : task.poiId.toString(),
                    ),
                  ),
                  if (task.wardName != null && task.wardName!.isNotEmpty)
                    _InfoChip(label: context.l10n.tcWard(task.wardName!)),
                  _InfoChip(label: context.l10n.tcPriority(task.priority)),
                  _InfoChip(
                    label: context.l10n.tcSequence(task.sequenceNumber),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      task.status,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: statusColor),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    task.hasResult ? Icons.check_circle : Icons.hourglass_top,
                    size: 16,
                    color: task.hasResult
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    task.hasResult
                        ? context.l10n.tcHasResult
                        : context.l10n.tcNoResult,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (task.checkinAt != null || task.completedAt != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.tcCheckinCompleted(
                    task.checkinAt ?? '-',
                    task.completedAt ?? '-',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
