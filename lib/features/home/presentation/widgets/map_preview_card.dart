import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';

class MapPreviewCard extends StatelessWidget {
  const MapPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Semantics(
          button: true,
          label: 'Mở bản đồ bệnh viện',
          hint: 'Tìm đường đến phòng ban',
          child: InkWell(
            borderRadius: AppRadius.borderLg,
            onTap: () => context.go('/map'),
            child: Padding(
              padding: AppSpacing.cardPaddingLarge,
              child: Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 56,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bản đồ bệnh viện',
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tìm đường đến phòng ban',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: context.colorScheme.onSurfaceVariant,
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
