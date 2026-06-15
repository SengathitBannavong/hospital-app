import 'package:flutter/material.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';

Future<void> showLogoutSheet(
  BuildContext context, {
  required Future<void> Function() onConfirm,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: false,
    useSafeArea: true,
    builder: (context) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.settingsLogout,
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.logoutSheetMessage,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emergency,
                    foregroundColor: AppColors.onEmergency,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: Text(context.l10n.settingsLogout),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.commonCancel),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      );
    },
  );
}
