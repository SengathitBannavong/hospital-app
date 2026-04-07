import 'package:flutter/material.dart';
import '../theme/hospital_theme.dart';

class MedicalInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const MedicalInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Using context extension for theme access
    final primaryColor = color ?? context.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderLg,
      child: Container(
        padding: AppSpacing.cardPaddingLarge,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: context.colorScheme.outlineVariant,
            width: 1,
          ),
          // Using shadow tokens
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(icon, color: primaryColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing arrow if clickable
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: context.colorScheme.outline,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
