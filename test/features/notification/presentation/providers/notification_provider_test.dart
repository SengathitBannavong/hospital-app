import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/notification/data/models/app_notification.dart';
import 'package:hospital_app/features/notification/data/models/notification_page_response.dart';
import 'package:hospital_app/features/notification/data/models/notification_settings_model.dart';
import 'package:hospital_app/features/notification/data/repository/notification_repository.dart';
import 'package:hospital_app/features/notification/presentation/providers/notification_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationNotifier', () {
    test('loadNotifications success updates state', () async {
      final mockRepo = MockNotificationRepository();
      final notifier = NotificationNotifier(mockRepo);

      await notifier.loadNotifications();

      expect(notifier.state.items.length, 2);
      expect(notifier.state.total, 3);
      expect(notifier.state.isInitialLoading, isFalse);
      expect(notifier.state.unreadCount, 1);
    });

    test('loadNotifications failure sets errorMessage and rethrows', () async {
      final mockRepo = MockNotificationRepository(failOnGet: true);
      final notifier = NotificationNotifier(mockRepo);

      try {
        await notifier.loadNotifications();
        fail('Expected exception');
      } catch (e) {
        // After failure, notifier should have recorded an error message
        expect(notifier.state.isInitialLoading, isFalse);
        expect(notifier.state.errorMessage, contains('Network error'));
      }
    });

    test('loadMore merges pages and deduplicates', () async {
      final mockRepo = MockNotificationRepository();
      final notifier = NotificationNotifier(mockRepo);

      await notifier.loadNotifications();
      await notifier.loadMore();

      expect(notifier.state.page, 2);
      // two from page1 + two from page2, but one duplicate id (2)
      expect(notifier.state.items.map((e) => e.id).toSet().length, 3);
      expect(notifier.state.items.length, 3);
    });

    test('markAsRead calls repository and updates item', () async {
      final mockRepo = MockNotificationRepository();
      final notifier = NotificationNotifier(mockRepo);

      await notifier.loadNotifications();

      // Ensure first item is unread
      final firstId = notifier.state.items.first.id;
      expect(notifier.state.items.first.isRead, isFalse);

      await notifier.markAsRead(firstId);

      expect(mockRepo.markAsReadCalled, isTrue);
      expect(notifier.state.items.first.isRead, isTrue);
    });

    test('deleteNotifications removes items and updates total', () async {
      final mockRepo = MockNotificationRepository();
      final notifier = NotificationNotifier(mockRepo);

      await notifier.loadNotifications();

      final idsToDelete = [notifier.state.items.first.id];

      await notifier.deleteNotifications(idsToDelete);

      expect(mockRepo.deleteCalled, isTrue);
      expect(
        notifier.state.items.any((i) => idsToDelete.contains(i.id)),
        isFalse,
      );
      expect(notifier.state.total, 2);
    });

    test('addFirebaseNotification prepends and deduplicates', () async {
      final mockRepo = MockNotificationRepository();
      final notifier = NotificationNotifier(mockRepo);

      await notifier.loadNotifications();

      final newNotif = const AppNotification(
        id: 99,
        title: 'FCM',
        message: 'New push',
        createdAt: 'now',
        isRead: false,
      );

      notifier.addFirebaseNotification(newNotif);

      expect(notifier.state.items.first.id, 99);
      expect(notifier.state.total, 4);
    });
  });

  group('NotificationSettingsNotifier', () {
    test('loadSettings success returns data', () async {
      final mockRepo = MockNotificationRepository();
      final notifier = NotificationSettingsNotifier(mockRepo);

      await notifier.loadSettings();

      expect(notifier.state.hasValue, isTrue);
      expect(notifier.state.value!.notification, isTrue);
    });

    test('saveSettings success updates state and returns true', () async {
      final mockRepo = MockNotificationRepository();
      final notifier = NotificationSettingsNotifier(mockRepo);

      final settings = NotificationSettingsModel.defaults().copyWith(
        notification: false,
      );

      final result = await notifier.saveSettings(settings);

      expect(result, isTrue);
      expect(notifier.state.hasValue, isTrue);
      expect(notifier.state.value!.notification, isFalse);
    });

    test('saveSettings failure returns false', () async {
      final mockRepo = MockNotificationRepository(failOnSaveSettings: true);
      final notifier = NotificationSettingsNotifier(mockRepo);

      final settings = NotificationSettingsModel.defaults();

      final result = await notifier.saveSettings(settings);

      expect(result, isFalse);
    });
  });
}

class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository({
    this.failOnGet = false,
    this.failOnSaveSettings = false,
  });

  final bool failOnGet;
  final bool failOnSaveSettings;

  bool markAsReadCalled = false;
  bool deleteCalled = false;

  @override
  Future<void> deleteNotifications({required List<int> notificationIds}) async {
    deleteCalled = true;
    // simulate deletion by doing nothing
  }

  @override
  Future<void> markAsRead({required int notificationId}) async {
    markAsReadCalled = true;
  }

  @override
  Future<NotificationPageResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    if (failOnGet) throw Exception('Network error');

    if (page == 1) {
      return NotificationPageResponse(
        total: 3,
        page: 1,
        limit: limit,
        data: [
          const AppNotification(
            id: 1,
            title: 'A',
            message: 'm',
            createdAt: 't1',
            isRead: false,
          ),
          const AppNotification(
            id: 2,
            title: 'B',
            message: 'm2',
            createdAt: 't2',
            isRead: true,
          ),
        ],
      );
    }

    // page 2
    return NotificationPageResponse(
      total: 3,
      page: 2,
      limit: limit,
      data: [
        const AppNotification(
          id: 2,
          title: 'B',
          message: 'm2',
          createdAt: 't2',
          isRead: true,
        ),
        const AppNotification(
          id: 3,
          title: 'C',
          message: 'm3',
          createdAt: 't3',
          isRead: false,
        ),
      ],
    );
  }

  @override
  Future<void> registerDeviceToken(String fcmToken, String platform) async {}

  @override
  Future<NotificationSettingsModel> getSettings() async {
    return NotificationSettingsModel.defaults();
  }

  @override
  Future<void> saveSettings(NotificationSettingsModel settings) async {
    if (failOnSaveSettings) throw Exception('Save failed');
  }
}
