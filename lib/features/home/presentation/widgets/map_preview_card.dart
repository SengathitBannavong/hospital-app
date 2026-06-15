import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
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
          label: context.l10n.mapPreviewOpen,
          hint: context.l10n.mapPreviewSubtitle,
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
                          context.l10n.mapPreviewTitle,
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.mapPreviewSubtitle,
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
