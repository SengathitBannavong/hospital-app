import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/delete_account_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
          if (loadingDialogOpen) {
            Navigator.of(context, rootNavigator: true).pop();
            loadingDialogOpen = false;
          }
          DeleteAccountService.showDeleteAccountSuccess(context);
        }
      } catch (e) {
        if (mounted) {
          if (loadingDialogOpen) {
            Navigator.of(context, rootNavigator: true).pop();
            loadingDialogOpen = false;
          }
          DeleteAccountService.showError(
            context,
            e.toString().replaceFirst('Exception: ', ''),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa hồ sơ' : 'Hồ sơ người dùng'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () =>
                  ref.read(profileProvider.notifier).fetchProfile(),
            ),
        ],
      ),
      body: profileState.when(
        data: (profile) => SingleChildScrollView(
          padding: AppSpacing.pageWithTop,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileAvatar(
                imageUrl: profile.avatar,
                isReadOnly: !_isEditing,
                onImagePicked: (path) {
                  ref
                      .read(profileProvider.notifier)
                      .updateProfile(avatarPath: path);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_isEditing)
                ProfileForm(
                  initialProfile: profile,
                  onCancel: () => setState(() => _isEditing = false),
                  onSave: (fullName, dob, gender) async {
                    await ref
                        .read(profileProvider.notifier)
                        .updateProfile(
                          fullName: fullName,
                          dob: dob,
                          gender: gender,
                        );
                    if (mounted) {
                      setState(() => _isEditing = false);
                    }
                  },
                )
              else
                ProfileInfo(
                  profile: profile,
                  onEdit: () => setState(() => _isEditing = true),
                  onDeleteAccount: _handleDeleteAccount,
                  onLogout: _handleLogout,
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $error'),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () =>
                    ref.read(profileProvider.notifier).fetchProfile(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
