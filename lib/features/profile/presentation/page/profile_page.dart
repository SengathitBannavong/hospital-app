import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../util/presentation/providers/util_providers.dart';
import '../../data/models/profile_update_request.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_form.dart';
import '../widgets/profile_info.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  bool _isUploadingAvatar = false;

  Future<void> _handleLogout() async {
    final l10n = context.l10n;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsLogout),
        content: Text(l10n.profileLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.settingsLogout),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    await ref.read(authStateProvider.notifier).logout();

    if (!mounted) return;

    AppToast.showSuccess(l10n.welcomeLogoutSuccess);
    context.go('/login');
  }

  Future<void> _handleRemoveAvatar() async {
    final l10n = context.l10n;
    final currentProfile = ref.read(profileProvider).profile;
    if (currentProfile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileRemoveAvatarTitle),
        content: Text(l10n.profileRemoveAvatarConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isUploadingAvatar = true);

    // Send avatar: '' so the backend clears avatar_url (and deletes the old
    // upload). Other fields are re-sent unchanged; set_profile is partial.
    final success = await ref
        .read(profileProvider.notifier)
        .updateProfile(
          ProfileUpdateRequest(
            fullName: currentProfile.fullName,
            dob: currentProfile.dob,
            gender: currentProfile.gender,
            avatar: '',
          ),
        );

    if (mounted) {
      setState(() => _isUploadingAvatar = false);
    }

    if (success && mounted) {
      AppToast.showSuccess(l10n.profileAvatarRemoved);
    } else if (!success && mounted) {
      AppToast.showError(
        ref.read(profileProvider).errorMessage ?? l10n.profileAvatarRemoveError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.profileEditTitle : l10n.aboutFeatureProfile,
        ),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: profileState.isBusy
                  ? null
                  : () => ref
                        .read(profileProvider.notifier)
                        .fetchProfile(isRefresh: true)
                        .catchError((error) {
                          AppToast.showError(_formatError(error));
                        }),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.settingsTitle,
              onPressed: () => context.push('/settings'),
            ),
          ],
        ],
      ),
      body: profile == null
          ? (profileState.errorMessage != null
                ? _buildErrorState(profileState.errorMessage!)
                : const Center(child: CircularProgressIndicator()))
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(profileProvider.notifier)
                  .fetchProfile(isRefresh: true)
                  .catchError((error) {
                    AppToast.showError(_formatError(error));
                  }),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.pageWithTop,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProfileAvatar(
                          imageUrl: profile.avatar,
                          isReadOnly:
                              !_isEditing ||
                              profileState.isSaving ||
                              _isUploadingAvatar,
                          onRemove: _handleRemoveAvatar,
                          onImagePicked: (XFile picked) async {
                            final currentProfile = ref
                                .read(profileProvider)
                                .profile;
                            if (currentProfile == null) return;

                            final sizeBytes = await picked.length();
                            const maxBytes = 10 * 1024 * 1024;
                            if (sizeBytes > maxBytes) {
                              AppToast.showError(l10n.profileImageTooLarge);
                              return;
                            }

                            setState(() => _isUploadingAvatar = true);

                            String uploadedUrl;
                            try {
                              final bytes = await picked.readAsBytes();
                              final file = MultipartFile.fromBytes(
                                bytes,
                                filename: picked.name,
                              );
                              final result = await ref
                                  .read(utilRepositoryProvider)
                                  .uploadFile(file);
                              uploadedUrl = result.fileUrl;
                            } catch (error) {
                              if (mounted) {
                                setState(() => _isUploadingAvatar = false);
                                final msg = error.toString().replaceFirst(
                                  'Exception: ',
                                  '',
                                );
                                AppToast.showError(
                                  l10n.profileUploadError(msg),
                                );
                              }
                              return;
                            }

                            final success = await ref
                                .read(profileProvider.notifier)
                                .updateProfile(
                                  ProfileUpdateRequest(
                                    fullName: currentProfile.fullName,
                                    dob: currentProfile.dob,
                                    gender: currentProfile.gender,
                                    avatar: uploadedUrl,
                                  ),
                                );

                            if (mounted) {
                              setState(() => _isUploadingAvatar = false);
                            }

                            if (success && mounted) {
                              AppToast.showSuccess(l10n.profileAvatarUpdated);
                            } else if (!success && mounted) {
                              AppToast.showError(
                                ref.read(profileProvider).errorMessage ??
                                    l10n.profileAvatarUpdateError,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (_isEditing)
                          ProfileForm(
                            key: ValueKey(profile),
                            initialProfile: profile,
                            isSubmitting: profileState.isSaving,
                            onCancel: () => setState(() => _isEditing = false),
                            onSave: (request) async {
                              final success = await ref
                                  .read(profileProvider.notifier)
                                  .updateProfile(request);
                              if (success && mounted) {
                                setState(() => _isEditing = false);
                                AppToast.showSuccess(l10n.profileUpdated);
                              }
                              if (!success && mounted) {
                                AppToast.showError(
                                  ref.read(profileProvider).errorMessage ??
                                      l10n.profileUpdateError,
                                );
                              }
                            },
                          )
                        else
                          ProfileInfo(
                            profile: profile,
                            onEdit: () => setState(() => _isEditing = true),
                            onFeedback: () => context.push('/feedback'),
                            onLogout: _handleLogout,
                          ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                  if (profileState.isSaving || _isUploadingAvatar)
                    Positioned.fill(
                      child: Container(
                        color: context.colorScheme.shadow,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageWithTop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.profileLoadError),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(profileProvider.notifier)
                    .fetchProfile(isRefresh: true)
                    .catchError((error) {
                      AppToast.showError(_formatError(error));
                    });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }

  String _formatError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
