class SosRequestModel {
  final double latitude;
  final double longitude;
  final String? message;
  final String emergencyType;

  SosRequestModel({
    required this.latitude,
    required this.longitude,
    this.message,
    required this.emergencyType,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'message': message ?? 'Yêu cầu trợ giúp khẩn cấp!',
      'emergency_type': emergencyType,
    };
  }

  factory SosRequestModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value, String fieldName) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value) ??
            (throw ArgumentError.value(
              value,
              fieldName,
              'Giá trị không hợp lệ',
            ));
      }
      throw ArgumentError.value(value, fieldName, 'Giá trị không hợp lệ');
    }

    final emergencyType = (json['emergency_type'] as String?)?.trim();

    return SosRequestModel(
      latitude: parseDouble(json['latitude'], 'latitude'),
      longitude: parseDouble(json['longitude'], 'longitude'),
      message: (json['message'] as String?)?.trim(),
      emergencyType: emergencyType != null && emergencyType.isNotEmpty
          ? emergencyType
          : 'GENERAL',
    );
  }
}

class SosResponseModel {
  final bool success;
  final String message;
  final String? requestId;

  SosResponseModel({
    required this.success,
    required this.message,
    this.requestId,
  });

  factory SosResponseModel.fromJson(Map<String, dynamic> json) {
    final successValue = json['success'];
    final statusValue = json['status'];
    final bool success = successValue is bool
        ? successValue
        : statusValue?.toString().toLowerCase() == 'success';

    String? parseRequestId(dynamic data) {
      if (data is Map<String, dynamic>) {
        return data['id']?.toString();
      }
      return null;
    }

    return SosResponseModel(
      success: success,
      message: json['message']?.toString() ?? 'Yêu cầu SOS đã được ghi nhận',
      requestId: json['request_id']?.toString() ?? parseRequestId(json['data']),
    );
  }
}
