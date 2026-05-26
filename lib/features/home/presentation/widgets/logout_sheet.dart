import 'package:flutter/material.dart';
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
              Text('Đăng xuất', style: context.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Bạn sẽ phải đăng nhập lại để tiếp tục.',
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
                  child: const Text('Đăng xuất'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
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
