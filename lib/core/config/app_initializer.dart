// lib/core/widgets/app_initializer.dart
//
// Wrap your home/authenticated scaffold with this widget.
// It registers the FCM token once the user is logged in.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/services/firebase_notification_service.dart';
import 'package:hospital_app/core/theme/theme_controller.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/notification/presentation/providers/notification_provider.dart';

class AppInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const AppInitializer({super.key, required this.child});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _tokenRegistered = false;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tryRestoreSettings();

    if (FirebaseNotificationService.isEnabled) {
      // Attach ref to the FCM service so it can call providers
      FirebaseNotificationService.instance.attachRef(ref);
      _tryRegisterToken();
    }
  }

  Future<void> _tryRestoreSettings() async {
    final user = ref.read(authStateProvider);
    if (user == null || _settingsLoaded) {
      return;
    }

    _settingsLoaded = true;
    await ref.read(notificationSettingsProvider.notifier).loadSettings();
    if (!mounted) {
      return;
    }

    final settings = ref.read(notificationSettingsProvider).valueOrNull;
    final theme = settings?.theme;
    if (theme != null) {
      themeController.setThemeMode(_themeFromString(theme));
    }
  }

  Future<void> _tryRegisterToken() async {
    if (!FirebaseNotificationService.isEnabled) {
      return;
    }

    final user = ref.read(authStateProvider);
    if (user != null && !_tokenRegistered) {
      _tokenRegistered = true;
      await FirebaseNotificationService.instance.getAndRegisterToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-register token if auth state changes (e.g. after login)
    ref.listen(authStateProvider, (previous, next) {
      if (next != null) {
        _tryRestoreSettings();
        if (FirebaseNotificationService.isEnabled && !_tokenRegistered) {
          _tokenRegistered = true;
          FirebaseNotificationService.instance.getAndRegisterToken();
        }
      }
      if (next == null) {
        _tokenRegistered = false;
        _settingsLoaded = false;
      }
    });

    return widget.child;
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
