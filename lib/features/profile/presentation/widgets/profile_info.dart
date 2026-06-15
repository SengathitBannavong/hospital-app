import 'package:flutter/material.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../data/models/user_profile.dart';

class ProfileInfo extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;
  final VoidCallback? onFeedback;
  final VoidCallback? onLogout;

  const ProfileInfo({
    super.key,
    required this.profile,
    required this.onEdit,
    this.onFeedback,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoTile(
          context,
          label: context.l10n.registerFullName,
          value: profile.fullName,
          icon: Icons.person_outline,
        ),
        const Divider(height: 1),
        _buildInfoTile(
          context,
          label: context.l10n.authPhone,
          value: profile.phoneNumber,
          icon: Icons.phone_outlined,
        ),
        const Divider(height: 1),
        _buildInfoTile(
          context,
          label: context.l10n.profileDob,
          value: profile.dob ?? context.l10n.profileNotUpdated,
          icon: Icons.calendar_today_outlined,
        ),
        const Divider(height: 1),
        _buildInfoTile(
          context,
          label: context.l10n.profileGender,
          value: _getGenderText(context, profile.gender),
          icon: Icons.wc_outlined,
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: Text(context.l10n.profileEditTitle),
        ),
        if (onFeedback != null) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onFeedback,
            icon: const Icon(Icons.rate_review_outlined),
            label: Text(context.l10n.profileRateApp),
          ),
        ],
        if (onLogout != null) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: Text(context.l10n.settingsLogout),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
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

  String _getGenderText(BuildContext context, int? gender) {
    switch (gender) {
      case 0:
        return context.l10n.genderMale;
      case 1:
        return context.l10n.genderFemale;
      case 2:
        return context.l10n.genderOther;
      default:
        return context.l10n.profileNotUpdated;
    }
  }
}
