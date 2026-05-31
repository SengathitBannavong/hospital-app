import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/notification/presentation/pages/notification_page.dart';
import 'package:hospital_app/features/notification/presentation/widgets/notification_card.dart';
import 'package:hospital_app/features/notification/presentation/providers/notification_provider.dart';
import 'package:hospital_app/features/notification/data/models/notification_settings_model.dart';
import 'package:hospital_app/features/notification/data/repository/notification_repository.dart';
import 'package:hospital_app/features/notification/data/models/notification_page_response.dart';
import 'package:hospital_app/features/notification/data/models/app_notification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NotificationPage shows loading then list and supports delete', (
    tester,
  ) async {
    final mockRepo = _WidgetMockNotificationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [notificationRepositoryProvider.overrideWithValue(mockRepo)],
        child: const MaterialApp(home: NotificationPage()),
      ),
    );

    // Initial state: loading indicator since provider triggers load on init
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for async loadNotifications to complete
    await tester.pumpAndSettle();

    // Two notification cards should appear
    expect(find.byType(NotificationCard), findsNWidgets(2));

    // Tap delete on the first card and verify it disappears
    final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
    expect(deleteButtons, findsNWidgets(2));

    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // After delete, one card should remain
    expect(find.byType(NotificationCard), findsOneWidget);
  });
}

class _WidgetMockNotificationRepository implements NotificationRepository {
  bool deleteCalled = false;

  @override
  Future<void> deleteNotifications({required List<int> notificationIds}) async {
    deleteCalled = true;
  }

  @override
  Future<void> markAsRead({required int notificationId}) async {}

  @override
  Future<NotificationPageResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    return NotificationPageResponse(
      total: 2,
      page: 1,
      limit: limit,
      data: const [
        AppNotification(
          id: 1,
          title: 'One',
          message: 'm1',
          createdAt: 't1',
          isRead: false,
        ),
        AppNotification(
          id: 2,
          title: 'Two',
          message: 'm2',
          createdAt: 't2',
          isRead: false,
        ),
      ],
    );
  }

  @override
  Future<void> registerDeviceToken(String fcmToken, String platform) async {}

  @override
  Future<void> saveSettings(NotificationSettingsModel settings) async {}

  @override
  Future<NotificationSettingsModel> getSettings() async =>
      NotificationSettingsModel.defaults();
}
