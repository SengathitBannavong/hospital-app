import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/delete_account_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    await ref.read(authStateProvider.notifier).logout();

    if (!mounted) return;

    AppToast.showSuccess('Đã đăng xuất thành công.');
    context.go('/login');
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await DeleteAccountService.showDeleteAccountConfirmation(
      context,
    );

    if (confirmed == true && mounted) {
      final password = await DeleteAccountService.showPasswordConfirmation(
        context,
      );

      if (password == null || password.isEmpty) return;

      if (!mounted) return;

      final rootNavigator = Navigator.of(context, rootNavigator: true);
      var loadingDialogOpen = false;

      // Show loading indicator
      showDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      loadingDialogOpen = true;

      try {
        await ref
            .read(authStateProvider.notifier)
            .deleteAccount(password: password);

        if (mounted) {
          DeleteAccountService.showDeleteAccountSuccess(context);
        }
      } catch (e) {
        if (mounted) {
          DeleteAccountService.showError(
            context,
            e.toString().replaceFirst('Exception: ', ''),
          );
        }
      } finally {
        if (loadingDialogOpen && rootNavigator.canPop()) {
          rootNavigator.pop();
          loadingDialogOpen = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa hồ sơ' : 'Hồ sơ người dùng'),
        actions: [
          if (!_isEditing)
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
        ],
      ),
      body: profile == null && profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null && profileState.errorMessage != null
          ? _buildErrorState(profileState.errorMessage!)
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
                          imageUrl: profile?.avatar,
                          isReadOnly: !_isEditing || profileState.isSaving,
                          onImagePicked: (path) async {
                            final currentProfile = ref
                                .read(profileProvider)
                                .profile;
                            if (currentProfile == null) return;

                            final success = await ref
                                .read(profileProvider.notifier)
                                .updateProfile(
                                  ProfileUpdateRequest(
                                    fullName: currentProfile.fullName,
                                    dob: currentProfile.dob,
                                    gender: currentProfile.gender,
                                    avatar: path,
                                  ),
                                );

                            if (!success && mounted) {
                              AppToast.showError(
                                ref.read(profileProvider).errorMessage ??
                                    'Không thể cập nhật ảnh đại diện.',
                              );
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (_isEditing)
                          ProfileForm(
                            key: ValueKey(profile),
                            initialProfile: profile!,
                            isSubmitting: profileState.isSaving,
                            onCancel: () => setState(() => _isEditing = false),
                            onSave: (request) async {
                              final success = await ref
                                  .read(profileProvider.notifier)
                                  .updateProfile(request);
                              if (success && mounted) {
                                setState(() => _isEditing = false);
                              }
                              if (!success && mounted) {
                                AppToast.showError(
                                  ref.read(profileProvider).errorMessage ??
                                      'Không thể cập nhật hồ sơ.',
                                );
                              }
                            },
                          )
                        else
                          ProfileInfo(
                            profile: profile!,
                            onEdit: () => setState(() => _isEditing = true),
                            onDeleteAccount: _handleDeleteAccount,
                            onLogout: _handleLogout,
                          ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                  if (profileState.isSaving)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.08),
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
            const Text('Không thể tải hồ sơ'),
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
              label: const Text('Thử lại'),
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
