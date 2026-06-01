import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/util/data/models/util_poi.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';

class ParkingPage extends ConsumerWidget {
  const ParkingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parkings = ref.watch(parkingProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/info'),
        ),
        title: const Text('Bãi đỗ xe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: () => ref.invalidate(parkingProvider),
          ),
        ],
      ),
      body: parkings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(parkingProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Không có thông tin bãi đỗ xe.'));
          }
          return ListView.separated(
            padding: AppSpacing.pageWithTop,
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => _ParkingCard(poi: list[index]),
          );
        },
      ),
    );
  }
}

class _ParkingCard extends StatelessWidget {
  const _ParkingCard({required this.poi});

  final UtilPoi poi;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.colorScheme.tertiaryContainer,
                  child: Icon(
                    Icons.local_parking_rounded,
                    color: context.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    poi.poiName,
                    style: context.textTheme.titleMedium,
                  ),
                ),
                if (poi.isAccessible == true)
                  const Tooltip(
                    message: 'Có thể tiếp cận',
                    child: Icon(Icons.accessible_rounded, size: 18),
                  ),
              ],
            ),
            if (poi.capacity != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.car_repair_rounded, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Sức chứa: ${poi.capacity} xe',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (poi.openHours != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Text(poi.openHours!, style: context.textTheme.bodySmall),
                ],
              ),
            ],
            if (poi.details != null && poi.details!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      poi.details!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
