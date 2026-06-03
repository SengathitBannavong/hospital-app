import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/delete_account_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../notification/data/models/notification_settings_model.dart';
import '../../../notification/presentation/providers/notification_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String? _syncedTheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationSettingsProvider.notifier).loadSettings();
    });
  }

  Future<void> _save(NotificationSettingsModel settings) async {
    final success = await ref
        .read(notificationSettingsProvider.notifier)
        .saveSettings(settings);
    if (!mounted || success) {
      return;
    }
    AppToast.showError('Không thể lưu cài đặt');
  }

  Future<void> _saveTheme(
    NotificationSettingsModel settings,
    ThemeMode mode,
  ) async {
    themeController.setThemeMode(mode);
    await _save(settings.copyWith(theme: _themeToString(mode)));
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(error),
        data: (settings) {
          _syncTheme(settings.theme);
          return _buildContent(settings, cs);
        },
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: AppSpacing.md),
            const Text('Không thể tải cài đặt'),
            const SizedBox(height: AppSpacing.xs),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                ref.read(notificationSettingsProvider.notifier).loadSettings();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(NotificationSettingsModel settings, ColorScheme cs) {
    return ListView(
      padding: AppSpacing.pageWithTop,
      children: [
        const _SectionHeader(title: 'Tài khoản'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.lock_outline_rounded, color: cs.primary),
                title: const Text('Đổi mật khẩu'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/change-password'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => _confirmLogout(context),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Xóa tài khoản',
                  style: TextStyle(color: AppColors.error),
                ),
                subtitle: const Text('Xóa vĩnh viễn tài khoản và dữ liệu'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _handleDeleteAccount,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        const _SectionHeader(title: 'Giao diện'),
        _ThemeTile(
          current: _themeFromString(settings.theme),
          onChanged: (mode) => _saveTheme(settings, mode),
        ),

        const SizedBox(height: AppSpacing.xl),

        const _SectionHeader(title: 'Thông báo'),
        _SettingsTile(
          icon: Icons.notifications_active_rounded,
          iconColor: cs.primary,
          title: 'Bật thông báo',
          subtitle: 'Nhận thông báo từ hệ thống',
          value: settings.notification,
          onChanged: (value) {
            _save(settings.copyWith(notification: value));
          },
        ),

        const SizedBox(height: AppSpacing.xl),

        const _SectionHeader(title: 'Ngôn ngữ'),
        _DropdownTile(
          icon: Icons.language_rounded,
          iconColor: cs.tertiary,
          title: 'Ngôn ngữ hiển thị',
          value: settings.language,
          items: const {'vi': 'Tiếng Việt', 'en': 'English'},
          onChanged: (value) => _save(settings.copyWith(language: value)),
        ),

        const SizedBox(height: AppSpacing.xl),

        const _SectionHeader(title: 'Dữ liệu ngoại tuyến'),
        Card(
          child: ListTile(
            leading: Icon(Icons.cleaning_services_rounded, color: cs.primary),
            title: const Text('Xóa bộ nhớ đệm bản đồ'),
            subtitle: const Text(
              'Gỡ dữ liệu bản đồ và lộ trình đã tải về thiết bị',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _confirmClearMapCache(context),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        const _SectionHeader(title: 'Thông tin ứng dụng'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.help_outline_rounded, color: cs.primary),
                title: const Text('Trợ giúp'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/help'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.info_outline_rounded, color: cs.primary),
                title: const Text('Về ứng dụng'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.verified_outlined, color: cs.primary),
                title: const Text('Phiên bản'),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  void _syncTheme(String theme) {
    if (_syncedTheme == theme) {
      return;
    }
    _syncedTheme = theme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      themeController.setThemeMode(_themeFromString(theme));
    });
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Hủy')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              ctx.pop();
              ref.read(authStateProvider.notifier).logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await DeleteAccountService.showDeleteAccountConfirmation(
      context,
    );
    if (confirmed != true || !mounted) return;

    final password = await DeleteAccountService.showPasswordConfirmation(
      context,
    );
    if (password == null || password.isEmpty || !mounted) return;

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var loadingDialogOpen = false;

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

  Future<void> _confirmClearMapCache(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa bộ nhớ đệm bản đồ'),
        content: const Text(
          'Thao tác này gỡ dữ liệu bản đồ và lộ trình đã tải về thiết bị. '
          'Ứng dụng sẽ tải lại khi cần.',
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => dialogContext.pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (!mounted || shouldClear != true) {
      return;
    }

    await ref.read(mapCacheProvider).clearAll();
    if (!mounted) {
      return;
    }
    ref
      ..invalidate(mapMetaProvider)
      ..invalidate(mapNodesProvider)
      ..invalidate(mapEdgesProvider)
      ..invalidate(flowSnapshotProvider)
      ..invalidate(mapObstaclesProvider)
      ..invalidate(mapLastSyncedAtProvider)
      ..invalidate(routeResultProvider);
    AppToast.showSuccess('Đã xóa bộ nhớ đệm bản đồ');
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Hospital App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Hospital App Team',
      children: const [
        SizedBox(height: 16),
        Text(
          'Ứng dụng hỗ trợ bệnh nhân tra cứu thông tin, '
          'điều hướng nội viện và quản lý lịch khám bệnh.',
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeTile({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode_outlined),
              label: Text('Sáng'),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto_outlined),
              label: Text('Hệ thống'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode_outlined),
              label: Text('Tối'),
            ),
          ],
          selected: {current},
          onSelectionChanged: (modes) => onChanged(modes.first),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeValue = items.containsKey(value) ? value : items.keys.first;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title),
        trailing: DropdownButton<String>(
          value: safeValue,
          underline: const SizedBox(),
          items: items.entries
              .map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              })
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

ThemeMode _themeFromString(String value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.system;
  }
}

String _themeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}
