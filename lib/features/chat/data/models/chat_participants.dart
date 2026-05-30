class ChatPatient {
  const ChatPatient({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.userType,
    this.avatarUrl,
  });

  final int userId;
  final String fullName;
  final String phoneNumber;
  final String userType;
  final String? avatarUrl;

  factory ChatPatient.fromJson(Map<String, dynamic> json) {
    return ChatPatient(
      userId: _parseInt(json['user_id'] ?? json['userId']),
      fullName: _parseString(json['full_name'] ?? json['fullName']),
      phoneNumber: _parseString(json['phone_number'] ?? json['phoneNumber']),
      userType: _parseString(json['user_type'] ?? json['userType']),
      avatarUrl: _parseNullableString(json['avatar_url'] ?? json['avatarUrl']),
    );
  }
}

class ChatStaff {
  const ChatStaff({
    required this.staffId,
    required this.userId,
    required this.staffCode,
    required this.role,
    required this.isActive,
  });

  final int staffId;
  final int userId;
  final String staffCode;
  final String role;
  final bool isActive;

  factory ChatStaff.fromJson(Map<String, dynamic> json) {
    return ChatStaff(
      staffId: _parseInt(json['staff_id'] ?? json['staffId']),
      userId: _parseInt(json['user_id'] ?? json['userId']),
      staffCode: _parseString(json['staff_code'] ?? json['staffCode']),
      role: _parseString(json['role']),
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
    );
  }
}

class ChatParticipants {
  const ChatParticipants({required this.patients, required this.staffs});

  final List<ChatPatient> patients;
  final List<ChatStaff> staffs;

  factory ChatParticipants.fromJson(Map<String, dynamic> json) {
    return ChatParticipants(
      patients: _parseList(json['patients']).map(ChatPatient.fromJson).toList(),
      staffs: _parseList(json['staffs']).map(ChatStaff.fromJson).toList(),
    );
  }
}

List<Map<String, dynamic>> _parseList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList();
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _parseString(dynamic value) => value?.toString() ?? '';

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}
