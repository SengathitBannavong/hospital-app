import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/hospital_theme.dart';
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
                    await ref.read(profileProvider.notifier).updateProfile(
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
