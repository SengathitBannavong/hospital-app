import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _handleRemoveAvatar() async {
    final currentProfile = ref.read(profileProvider).profile;
    if (currentProfile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ảnh đại diện'),
        content: const Text('Bạn có chắc chắn muốn xóa ảnh đại diện không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
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
      AppToast.showSuccess('Đã xóa ảnh đại diện.');
    } else if (!success && mounted) {
      AppToast.showError(
        ref.read(profileProvider).errorMessage ?? 'Không thể xóa ảnh đại diện.',
      );
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
              tooltip: 'Cài đặt',
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
                              AppToast.showError(
                                'Ảnh vượt quá 10MB. Vui lòng chọn ảnh nhỏ hơn.',
                              );
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
                                  'Không thể tải ảnh lên: $msg',
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
                              AppToast.showSuccess(
                                'Cập nhật ảnh đại diện thành công.',
                              );
                            } else if (!success && mounted) {
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
                            initialProfile: profile,
                            isSubmitting: profileState.isSaving,
                            onCancel: () => setState(() => _isEditing = false),
                            onSave: (request) async {
                              final success = await ref
                                  .read(profileProvider.notifier)
                                  .updateProfile(request);
                              if (success && mounted) {
                                setState(() => _isEditing = false);
                                AppToast.showSuccess(
                                  'Cập nhật hồ sơ thành công.',
                                );
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
