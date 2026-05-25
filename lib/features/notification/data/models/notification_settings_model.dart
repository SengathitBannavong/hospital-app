// lib/features/notification/data/models/notification_settings_model.dart
//
// Matches UserSetting schema from user.go:
//   voice_guidance_enabled bool
//   notification_enabled   bool
//   travel_mode            string (walk/wheelchair/stretcher)
//   language               string
//   theme                  string

class NotificationSettingsModel {
  final bool notificationEnabled; // notification_enabled
  final bool voiceGuidanceEnabled; // voice_guidance_enabled
  final String travelMode; // travel_mode
  final String language; // language
  final String theme; // theme

  const NotificationSettingsModel({
    required this.notificationEnabled,
    required this.voiceGuidanceEnabled,
    required this.travelMode,
    required this.language,
    required this.theme,
  });

  factory NotificationSettingsModel.defaults() {
    return const NotificationSettingsModel(
      notificationEnabled: true,
      voiceGuidanceEnabled: true,
      travelMode: 'walk',
      language: 'vi',
      theme: 'light',
    );
  }

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    // Backend wraps in { code, message, data: { ... } }
    final dataMap = json['data'] as Map<String, dynamic>? ?? json;
    return NotificationSettingsModel(
      notificationEnabled: dataMap['notification_enabled'] as bool? ?? true,
      voiceGuidanceEnabled: dataMap['voice_guidance_enabled'] as bool? ?? true,
      travelMode: dataMap['travel_mode'] as String? ?? 'walk',
      language: dataMap['language'] as String? ?? 'vi',
      theme: dataMap['theme'] as String? ?? 'light',
    );
  }

  Map<String, dynamic> toJson() => {
    'notification_enabled': notificationEnabled,
    'voice_guidance_enabled': voiceGuidanceEnabled,
    'travel_mode': travelMode,
    'language': language,
    'theme': theme,
  };

  NotificationSettingsModel copyWith({
    bool? notificationEnabled,
    bool? voiceGuidanceEnabled,
    String? travelMode,
    String? language,
    String? theme,
  }) {
    return NotificationSettingsModel(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      voiceGuidanceEnabled: voiceGuidanceEnabled ?? this.voiceGuidanceEnabled,
      travelMode: travelMode ?? this.travelMode,
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }
}
