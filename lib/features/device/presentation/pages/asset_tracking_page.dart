import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/device/presentation/providers/asset_providers.dart';

class AssetTrackingPage extends ConsumerWidget {
  const AssetTrackingPage({super.key, required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(assetTrackProvider(assetId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text('Vị trí $assetId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(assetTrackProvider(assetId)),
          ),
        ],
      ),
      body: track.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: AppSpacing.cardPaddingLarge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 40),
                const SizedBox(height: AppSpacing.md),
                Text(
                  err.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => ref.invalidate(assetTrackProvider(assetId)),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
        data: (info) => SingleChildScrollView(
          padding: AppSpacing.pageWithTop,
          child: Card(
            child: Padding(
              padding: AppSpacing.cardPaddingLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: context.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Thông tin theo dõi',
                        style: context.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _InfoRow(label: 'Mã thiết bị', value: info.assetId),
                  _InfoRow(label: 'Trạng thái', value: info.status),
                  if (info.movingStatus != null)
                    _InfoRow(label: 'Chuyển động', value: info.movingStatus!),
                  if (info.currentNodeId != null)
                    _InfoRow(
                      label: 'Vị trí hiện tại',
                      value: info.currentNodeId.toString(),
                    ),
                  if (info.condition != null)
                    _InfoRow(label: 'Tình trạng', value: info.condition!),
                  if (info.batteryLevel != null)
                    _InfoRow(label: 'Pin', value: info.batteryLevel!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
