import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/services/firebase_notification_service.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/delete_account_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../notification/data/models/app_notification.dart';
import '../../../notification/data/models/notification_settings_model.dart';
import '../../../notification/presentation/providers/notification_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String? _syncedTheme;
  String? _syncedLanguage;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationSettingsProvider.notifier).loadSettings();
    });
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() => _appVersion = info.version);
  }

  Future<void> _save(NotificationSettingsModel settings) async {
    final success = await ref
        .read(notificationSettingsProvider.notifier)
        .saveSettings(settings);
    if (!mounted || success) {
      return;
    }
    AppToast.showError(context.l10n.settingsSaveError);
  }

  Future<void> _saveLanguage(
    NotificationSettingsModel settings,
    String code,
  ) async {
    localeController.setLanguageCode(code);
    await _save(settings.copyWith(language: code));
  }

  /// Fires an on-device (local) notification. Works offline and online since
  /// it doesn't depend on the network or a server push. Also drops a matching
  /// entry into the in-app notification list so it shows up there too.
  Future<void> _sendTestNotification() async {
    final l10n = context.l10n;
    final shown = await FirebaseNotificationService.instance
        .showTestNotification(
          title: l10n.testNotificationTitle,
          body: l10n.testNotificationBody,
        );
    if (!mounted) {
      return;
    }

    ref
        .read(notificationProvider.notifier)
        .addFirebaseNotification(
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: l10n.testNotificationTitle,
            message: l10n.testNotificationBody,
            createdAt: DateTime.now().toIso8601String(),
            isRead: false,
          ),
        );

    if (shown) {
      AppToast.showSuccess(l10n.testNotificationSent);
    } else {
      AppToast.showError(l10n.testNotificationFailed);
    }
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
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(error),
        data: (settings) {
          _syncTheme(settings.theme);
          _syncLanguage(settings.language);
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
            Text(context.l10n.settingsLoadError),
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
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(NotificationSettingsModel settings, ColorScheme cs) {
    final l10n = context.l10n;
    return ListView(
      padding: AppSpacing.pageWithTop,
      children: [
        _SectionHeader(title: l10n.settingsSectionAccount),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.lock_outline_rounded, color: cs.primary),
                title: Text(l10n.settingsChangePassword),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/change-password'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                ),
                title: Text(
                  l10n.settingsLogout,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () => _confirmLogout(context),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                title: Text(
                  l10n.settingsDeleteAccount,
                  style: const TextStyle(color: AppColors.error),
                ),
                subtitle: Text(l10n.settingsDeleteAccountSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _handleDeleteAccount,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        _SectionHeader(title: l10n.settingsSectionAppearance),
        _ThemeTile(
          current: _themeFromString(settings.theme),
          onChanged: (mode) => _saveTheme(settings, mode),
        ),

        const SizedBox(height: AppSpacing.xl),

        _SectionHeader(title: l10n.settingsSectionNotification),
        _SettingsTile(
          icon: Icons.notifications_active_rounded,
          iconColor: cs.primary,
          title: l10n.settingsEnableNotification,
          subtitle: l10n.settingsEnableNotificationSubtitle,
          value: settings.notification,
          onChanged: (value) {
            _save(settings.copyWith(notification: value));
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.notifications_paused_rounded,
                  color: cs.primary,
                ),
                title: Text(l10n.settingsTestNotification),
                subtitle: Text(l10n.settingsTestNotificationSubtitle),
                trailing: const Icon(Icons.send_rounded),
                onTap: _sendTestNotification,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        _SectionHeader(title: l10n.settingsSectionLanguage),
        _DropdownTile(
          icon: Icons.language_rounded,
          iconColor: cs.tertiary,
          title: l10n.settingsDisplayLanguage,
          value: settings.language,
          items: {
            'vi': l10n.settingsLanguageVietnamese,
            'en': l10n.settingsLanguageEnglish,
          },
          onChanged: (value) => _saveLanguage(settings, value),
        ),

        const SizedBox(height: AppSpacing.xl),

        _SectionHeader(title: l10n.settingsSectionOffline),
        Card(
          child: ListTile(
            leading: Icon(Icons.cleaning_services_rounded, color: cs.primary),
            title: Text(l10n.settingsClearMapCache),
            subtitle: Text(l10n.settingsClearMapCacheSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _confirmClearMapCache(context),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        _SectionHeader(title: l10n.settingsSectionAppInfo),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.help_outline_rounded, color: cs.primary),
                title: Text(l10n.settingsHelp),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/help'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.info_outline_rounded, color: cs.primary),
                title: Text(l10n.settingsAbout),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.verified_outlined, color: cs.primary),
                title: Text(l10n.settingsVersion),
                trailing: Text(
                  _appVersion,
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

  void _syncLanguage(String language) {
    if (_syncedLanguage == language) {
      return;
    }
    _syncedLanguage = language;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      localeController.setLanguageCode(language);
    });
  }

  void _confirmLogout(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsLogoutConfirmTitle),
        content: Text(l10n.settingsLogoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              ctx.pop();
              ref.read(authStateProvider.notifier).logout();
            },
            child: Text(l10n.settingsLogout),
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
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Text(context.l10n.commonProcessing),
          ],
        ),
      ),
    );
    loadingDialogOpen = true;

    try {
      await ref
          .read(authStateProvider.notifier)
          .deleteAccount(password: password);

      if (loadingDialogOpen && rootNavigator.canPop()) {
        rootNavigator.pop();
        loadingDialogOpen = false;
      }

      if (mounted) {
        DeleteAccountService.showDeleteAccountSuccess(context);
      }
    } catch (e) {
      debugPrint('Delete Account Error: $e');

      if (loadingDialogOpen && rootNavigator.canPop()) {
        rootNavigator.pop();
        loadingDialogOpen = false;
      }

      if (mounted) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        if (errorMessage.toLowerCase().contains('password') ||
            errorMessage.toLowerCase().contains('incorrect')) {
          errorMessage = context.l10n.settingsDeletePasswordIncorrect;
        } else {
          errorMessage = context.l10n.commonError;
        }
        DeleteAccountService.showError(context, errorMessage);
      }
    }
  }

  Future<void> _confirmClearMapCache(BuildContext context) async {
    final l10n = context.l10n;
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsClearMapCache),
        content: Text(l10n.settingsClearMapCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(l10n.commonDelete),
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
    AppToast.showSuccess(l10n.settingsClearMapCacheSuccess);
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Hospital App',
      applicationVersion: _appVersion,
      applicationLegalese: '© 2025 Hospital App Team',
      children: [
        const SizedBox(height: 16),
        Text(context.l10n.settingsAboutDescription),
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
          segments: [
            ButtonSegment(
              value: ThemeMode.light,
              icon: const Icon(Icons.light_mode_outlined),
              label: Text(context.l10n.settingsThemeLight),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              icon: const Icon(Icons.brightness_auto_outlined),
              label: Text(context.l10n.settingsThemeSystem),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: const Icon(Icons.dark_mode_outlined),
              label: Text(context.l10n.settingsThemeDark),
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
