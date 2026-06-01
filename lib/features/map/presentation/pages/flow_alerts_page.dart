import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/flow_alert.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

class FlowAlertsPage extends ConsumerWidget {
  const FlowAlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(flowAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Cảnh báo giao thông'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: () => ref.invalidate(flowAlertsProvider),
          ),
        ],
      ),
      body: alerts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(flowAlertsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 56,
                    color: Colors.green,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Không có cảnh báo nào hiện tại',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: AppSpacing.pageWithTop,
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) =>
                _AlertCard(alert: list[index]),
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final FlowAlert alert;

  Color _levelColor(String level, ColorScheme cs) {
    return switch (level.toLowerCase()) {
      'high' || 'critical' || 'error' => cs.error,
      'warning' || 'medium' => Colors.orange.shade700,
      _ => cs.primary,
    };
  }

  IconData _levelIcon(String level) {
    return switch (level.toLowerCase()) {
      'high' || 'critical' || 'error' => Icons.error_rounded,
      'warning' || 'medium' => Icons.warning_amber_rounded,
      _ => Icons.info_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(alert.level, context.colorScheme);

    return Card(
      child: ListTile(
        contentPadding: AppSpacing.cardPadding,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(_levelIcon(alert.level), color: color),
        ),
        title: Text(
          alert.message,
          style: context.textTheme.bodyMedium,
        ),
        subtitle: alert.location != null
            ? Text(
                'Vị trí: ${alert.location}',
                style: context.textTheme.bodySmall,
              )
            : null,
        trailing: _LevelChip(level: alert.level, color: color),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level, required this.color});

  final String level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        level.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
