import 'package:flutter/material.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../data/models/queue_status.dart';

class QueueItem extends StatelessWidget {
  const QueueItem({super.key, required this.status});

  final QueueStatus status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POI #${status.poiId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Số hiện tại',
                    value: status.currentNumber.toString(),
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    label: 'Đang chờ',
                    value: status.waitingCount.toString(),
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    label: 'Chờ TB (phút)',
                    value: status.avgWaitMinutes.toStringAsFixed(0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
