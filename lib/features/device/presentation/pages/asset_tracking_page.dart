import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
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
        title: Text(context.l10n.trackTitle(assetId)),
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
                  child: Text(context.l10n.commonRetry),
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
                        context.l10n.trackInfoTitle,
                        style: context.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _InfoRow(
                    label: context.l10n.trackAssetCode,
                    value: info.assetId,
                  ),
                  _InfoRow(
                    label: context.l10n.trackStatus,
                    value: info.status,
                  ),
                  if (info.movingStatus != null)
                    _InfoRow(
                      label: context.l10n.trackMoving,
                      value: info.movingStatus!,
                    ),
                  if (info.currentNodeId != null)
                    _InfoRow(
                      label: context.l10n.trackCurrentPos,
                      value: info.currentNodeId.toString(),
                    ),
                  if (info.condition != null)
                    _InfoRow(
                      label: context.l10n.trackCondition,
                      value: info.condition!,
                    ),
                  if (info.batteryLevel != null)
                    _InfoRow(
                      label: context.l10n.trackBattery,
                      value: info.batteryLevel!,
                    ),
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
