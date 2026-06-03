// lib/core/services/firebase_notification_service.dart
//
// Add to pubspec.yaml:
//   firebase_core: ^3.x.x
//   firebase_messaging: ^15.x.x
//   flutter_local_notifications: ^17.x.x

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/notification/data/models/app_notification.dart';
import 'package:hospital_app/features/notification/presentation/providers/notification_provider.dart';

// Background handler.

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized when this runs.
  debugPrint('[FCM] Background message: ${message.messageId}');
  // No UI interaction here — the system notification is shown automatically.
}

// Service.

class FirebaseNotificationService {
  FirebaseNotificationService._();
  static final FirebaseNotificationService instance =
      FirebaseNotificationService._();

  static const bool isEnabled = bool.fromEnvironment('ENABLE_FIREBASE');

  // Lazy: `FirebaseMessaging.instance` calls `Firebase.app()`, which throws
  // when Firebase was never initialized (e.g. ENABLE_FIREBASE=false). Resolving
  // it eagerly in a field initializer would crash the moment this singleton is
  // constructed — even from guarded callers like getCurrentToken(). Only touch
  // it after the isEnabled/_initialized guards have passed.
  FirebaseMessaging? _messagingInstance;
  FirebaseMessaging get _messaging =>
      _messagingInstance ??= FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'hospital_high_importance',
    'Hospital Notifications',
    description: 'Important notifications from the hospital app',
    importance: Importance.high,
  );

  WidgetRef? _ref; // set after ProviderScope is ready

  void attachRef(WidgetRef ref) => _ref = ref;

  // Initialization.

  Future<void> initialize() async {
    if (!isEnabled) {
      return;
    }

    // 1. Request permission
    await _requestPermission();

    // 2. Setup local notifications (for foreground display on Android)
    await _setupLocalNotifications();

    // 3. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 6. Check if app was opened from a terminated-state notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // 7. Listen for token refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);
    _initialized = true;
  }

  // ─── Get & Register Token ────────────────────────────────────────────────

  Future<String?> getAndRegisterToken() async {
    if (!isEnabled || !_initialized) {
      return null;
    }

    try {
      String? token;

      if (Platform.isIOS) {
        // On iOS, get APNs token first
        await _messaging.getAPNSToken();
      }

      token = await _messaging.getToken();
      debugPrint('[FCM] Token: $token');

      if (token != null) {
        await _registerTokenWithBackend(token);
      }

      return token;
    } catch (e) {
      debugPrint('[FCM] Token error: $e');
      return null;
    }
  }

  /// Returns the current FCM token without (re-)registering it with the
  /// backend. Used at logout to tell the server which device push token to
  /// deactivate. Returns null when Firebase is disabled or not initialized.
  Future<String?> getCurrentToken() async {
    if (!isEnabled || !_initialized) {
      return null;
    }
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('[FCM] getCurrentToken error: $e');
      return null;
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      _ref
          ?.read(notificationProvider.notifier)
          .registerDeviceToken(token, platform);
    } catch (e) {
      debugPrint('[FCM] Token registration failed: $e');
    }
  }

  Future<void> _onTokenRefresh(String token) async {
    debugPrint('[FCM] Token refreshed');
    await _registerTokenWithBackend(token);
  }

  // ─── Permission ──────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // ─── Local Notifications Setup ───────────────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[LocalNotif] Tapped: ${details.payload}');
      },
    );

    // Create Android channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  // ─── Message Handlers ────────────────────────────────────────────────────

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM] Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    // Show local notification (FCM does NOT auto-show on Android foreground)
    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    // Also add to in-memory notification list
    final appNotification = AppNotification(
      id: message.hashCode,
      title: notification.title ?? 'Thông báo',
      message: notification.body ?? '',
      createdAt: DateTime.now().toIso8601String(),
      isRead: false,
    );
    _ref
        ?.read(notificationProvider.notifier)
        .addFirebaseNotification(appNotification);
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped: ${message.data}');
    // Add routing logic here if needed, e.g.:
    // final type = message.data['type'];
    // if (type == 'appointment') router.push('/appointments');
  }
}

// Provider.

final firebaseNotificationServiceProvider =
    Provider<FirebaseNotificationService>(
      (ref) => FirebaseNotificationService.instance,
    );
