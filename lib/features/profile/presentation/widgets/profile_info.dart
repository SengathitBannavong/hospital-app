import 'package:flutter/material.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../data/models/user_profile.dart';

class ProfileInfo extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;
  final VoidCallback? onFeedback;
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onLogout;

  const ProfileInfo({
    super.key,
    required this.profile,
    required this.onEdit,
    this.onFeedback,
    this.onDeleteAccount,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoTile(
          context,
          label: 'Họ và tên',
          value: profile.fullName,
          icon: Icons.person_outline,
        ),
        const Divider(height: 1),
        _buildInfoTile(
          context,
          label: 'Số điện thoại',
          value: profile.phoneNumber,
          icon: Icons.phone_outlined,
        ),
        const Divider(height: 1),
        _buildInfoTile(
          context,
          label: 'Ngày sinh',
          value: profile.dob ?? 'Chưa cập nhật',
          icon: Icons.calendar_today_outlined,
        ),
        const Divider(height: 1),
        _buildInfoTile(
          context,
          label: 'Giới tính',
          value: _getGenderText(profile.gender),
          icon: Icons.wc_outlined,
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Chỉnh sửa hồ sơ'),
        ),
        if (onFeedback != null) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onFeedback,
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Đánh giá ứng dụng'),
          ),
        ],
        if (onDeleteAccount != null) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onDeleteAccount,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Xóa tài khoản'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.emergency,
              side: const BorderSide(color: AppColors.emergency),
            ),
          ),
        ],
        if (onLogout != null) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Đăng xuất'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer.withValues(
                alpha: 0.4,
              ),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, size: 20, color: context.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGenderText(int? gender) {
    switch (gender) {
      case 0:
        return 'Nam';
      case 1:
        return 'Nữ';
      case 2:
        return 'Khác';
      default:
        return 'Chưa cập nhật';
    }
  }
}
