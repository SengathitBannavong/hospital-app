import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/util/data/models/util_poi.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';

class CanteenPage extends ConsumerWidget {
  const CanteenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canteens = ref.watch(canteenProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/info'),
        ),
        title: const Text('Căng-tin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: () => ref.invalidate(canteenProvider),
          ),
        ],
      ),
      body: canteens.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(canteenProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Không có thông tin căng-tin.'));
          }
          return ListView.separated(
            padding: AppSpacing.pageWithTop,
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => _CanteenCard(poi: list[index]),
          );
        },
      ),
    );
  }
}

class _CanteenCard extends StatelessWidget {
  const _CanteenCard({required this.poi});

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
                  backgroundColor: context.colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: context.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    poi.poiName,
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (poi.openHours != null) ...[
              const SizedBox(height: AppSpacing.md),
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
