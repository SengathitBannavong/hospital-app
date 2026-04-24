import 'package:flutter/material.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../domain/models/user_profile.dart';

class ProfileInfo extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const ProfileInfo({
    super.key,
    required this.profile,
    required this.onEdit,
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
              color: context.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(
              icon,
              size: 20,
              color: context.colorScheme.primary,
            ),
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
