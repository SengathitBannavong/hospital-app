// lib/features/notification/data/models/notification_settings_model.dart
//
class NotificationSettingsModel {
  final bool notification;
  final String language;
  final String theme;

  const NotificationSettingsModel({
    required this.notification,
    required this.language,
    required this.theme,
  });

  factory NotificationSettingsModel.defaults() {
    return const NotificationSettingsModel(
      notification: true,
      language: 'vi',
      theme: 'light',
    );
  }

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    // Backend wraps in { code, message, data: { ... } }
    final dataMap = json['data'] as Map<String, dynamic>? ?? json;
    return NotificationSettingsModel(
      notification: dataMap['notification'] as bool? ?? true,
      language: dataMap['language'] as String? ?? 'vi',
      theme: dataMap['theme'] as String? ?? 'light',
    );
  }

  Map<String, dynamic> toJson() => {
    'notification': notification,
    'language': language,
    'theme': theme,
  };

  NotificationSettingsModel copyWith({
    bool? notification,
    String? language,
    String? theme,
  }) {
    return NotificationSettingsModel(
      notification: notification ?? this.notification,
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }
}
