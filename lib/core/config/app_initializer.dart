// lib/core/widgets/app_initializer.dart
//
// Wrap your home/authenticated scaffold with this widget.
// It registers the FCM token once the user is logged in.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/services/firebase_notification_service.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';

class AppInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const AppInitializer({super.key, required this.child});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _tokenRegistered = false;

  @override
  void initState() {
    super.initState();
    // Attach ref to the FCM service so it can call providers
    FirebaseNotificationService.instance.attachRef(ref);
    _tryRegisterToken();
  }

  Future<void> _tryRegisterToken() async {
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
      if (next != null && !_tokenRegistered) {
        _tokenRegistered = true;
        FirebaseNotificationService.instance.getAndRegisterToken();
      }
      if (next == null) {
        _tokenRegistered = false;
      }
    });

    return widget.child;
  }
}