import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/device/data/models/asset_station.dart';
import 'package:hospital_app/features/device/presentation/providers/asset_providers.dart';

class AssetStationsPage extends ConsumerWidget {
  const AssetStationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(assetStationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Trạm thiết bị'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: () => ref.invalidate(assetStationsProvider),
          ),
        ],
      ),
      body: stations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(assetStationsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Không có trạm thiết bị nào.'));
          }
          return ListView.separated(
            padding: AppSpacing.pageWithTop,
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => _StationCard(station: list[index]),
          );
        },
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard({required this.station});

  final AssetStation station;

  @override
  Widget build(BuildContext context) {
    final available = station.availableWheelchairs;
    final capacity = station.capacity;
    final ratio = capacity > 0 ? available / capacity : 0.0;
    final color = ratio > 0.5
        ? Colors.green
        : ratio > 0.2
        ? Colors.orange
        : Colors.red;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.accessible_rounded,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    station.stationName,
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _InfoChip(label: '$available xe trống', color: color),
                const SizedBox(width: AppSpacing.sm),
                _InfoChip(
                  label: 'Sức chứa: $capacity',
                  color: context.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: AppRadius.borderFull,
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        label,
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
