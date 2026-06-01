import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

/// Displays the raw heatmap data returned by /flow/get_heatmap.
/// The data is rendered as a sorted list since a canvas-based grid
/// is already available on the main MapPage via the flow overlay.
class FlowHeatmapPage extends ConsumerWidget {
  const FlowHeatmapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmap = ref.watch(flowHeatmapProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Bản đồ nhiệt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: () => ref.invalidate(flowHeatmapProvider),
          ),
        ],
      ),
      body: heatmap.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(flowHeatmapProvider),
        ),
        data: (cells) {
          if (cells.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.grid_off_rounded,
                    size: 56,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Không có dữ liệu bản đồ nhiệt',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final sorted = [...cells]
            ..sort((a, b) => b.density.compareTo(a.density));
          final maxDensity = sorted.first.density;

          return Column(
            children: [
              _LegendBar(),
              Expanded(
                child: ListView.separated(
                  padding: AppSpacing.pageWithTop,
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _HeatCell(cell: sorted[index], maxDensity: maxDensity),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LegendBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Text(
            'Thấp',
            style: context.textTheme.labelSmall?.copyWith(color: Colors.green),
          ),
          Expanded(
            child: Container(
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: const BoxDecoration(
                borderRadius: AppRadius.borderFull,
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.orange, Colors.red],
                ),
              ),
            ),
          ),
          Text(
            'Cao',
            style: context.textTheme.labelSmall?.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.cell, required this.maxDensity});

  final FlowCell cell;
  final double maxDensity;

  Color _heatColor(double ratio) {
    if (ratio > 0.7) return Colors.red;
    if (ratio > 0.4) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = maxDensity > 0
        ? (cell.density / maxDensity).clamp(0.0, 1.0)
        : 0.0;
    final color = _heatColor(ratio);
    final pct = (ratio * 100).round();

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              width: 12,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppRadius.borderFull,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ô ${cell.location}',
                    style: context.textTheme.bodyMedium,
                  ),
                  ClipRRect(
                    borderRadius: AppRadius.borderFull,
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 4,
                      backgroundColor:
                          context.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '$pct%',
              style: context.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
