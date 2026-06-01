import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

class TrafficDensityPage extends ConsumerWidget {
  const TrafficDensityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final floors = ref.watch(floorsProvider);
    final selectedMapId = ref.watch(selectedFloorProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Mật độ đông người'),
        actions: [
          if (selectedMapId != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Làm mới',
              onPressed: () {
                ref
                  ..invalidate(flowSnapshotProvider(selectedMapId))
                  ..invalidate(bottlenecksProvider(selectedMapId));
              },
            ),
        ],
      ),
      body: floors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(floorsProvider),
        ),
        data: (floorList) {
          final mapId = selectedMapId ?? floorList.firstOrNull?.mapId;
          if (mapId == null) {
            return const Center(child: Text('Không có dữ liệu tầng.'));
          }
          return _DensityContent(mapId: mapId, floorList: floorList);
        },
      ),
    );
  }
}

class _DensityContent extends ConsumerWidget {
  const _DensityContent({required this.mapId, required this.floorList});

  final int mapId;
  final List<dynamic> floorList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(flowSnapshotProvider(mapId));
    final bottlenecks = ref.watch(bottlenecksProvider(mapId));

    return ListView(
      padding: AppSpacing.pageWithTop,
      children: [
        Card(
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Tổng quan mật độ',
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                snapshot.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => Text(
                    'Không thể tải dữ liệu mật độ',
                    style: context.textTheme.bodySmall,
                  ),
                  data: (snap) {
                    if (snap.cells.isEmpty) {
                      return Text(
                        'Không có dữ liệu mật độ hiện tại.',
                        style: context.textTheme.bodySmall,
                      );
                    }
                    final total = snap.cells.fold<double>(
                      0,
                      (sum, c) => sum + c.density,
                    );
                    final avg = total / snap.cells.length;
                    return _DensityRow(
                      label: 'Trung bình mật độ khu vực',
                      density: avg,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Điểm tắc nghẽn', style: context.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        bottlenecks.when(
          loading: () => const Center(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Text(
                'Không thể tải điểm tắc nghẽn: '
                '${err.toString().replaceFirst('Exception: ', '')}',
                style: context.textTheme.bodySmall,
              ),
            ),
          ),
          data: (cells) {
            if (cells.isEmpty) {
              return Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.green,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Không có điểm tắc nghẽn',
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }
            final sorted = [...cells]
              ..sort((a, b) => b.density.compareTo(a.density));
            return Column(
              children: sorted
                  .map(
                    (cell) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _BottleneckCard(cell: cell),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _DensityRow extends StatelessWidget {
  const _DensityRow({required this.label, required this.density});

  final String label;
  final double density;

  Color _densityColor(double d) {
    if (d > 0.7) return Colors.red;
    if (d > 0.4) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final color = _densityColor(density);
    final pct = (density * 100).clamp(0, 100).round();
    return Row(
      children: [
        Expanded(child: Text(label, style: context.textTheme.bodySmall)),
        Text(
          '$pct%',
          style: context.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BottleneckCard extends StatelessWidget {
  const _BottleneckCard({required this.cell});

  final FlowCell cell;

  Color _densityColor(double d) {
    if (d > 0.7) return Colors.red;
    if (d > 0.4) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final color = _densityColor(cell.density);
    final pct = (cell.density * 100).clamp(0, 100).round();

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: color, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Vị trí ${cell.location}',
                    style: context.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '$pct%',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.borderFull,
              child: LinearProgressIndicator(
                value: cell.density.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: context.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
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
