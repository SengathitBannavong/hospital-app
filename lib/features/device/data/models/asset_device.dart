class AssetDevice {
  const AssetDevice({
    required this.assetId,
    required this.status,
    this.deviceId,
    this.batteryLevel,
    this.deviceType,
    this.stationId,
    this.distance,
  });

  final String assetId;
  final String status;
  final int? deviceId;
  final int? batteryLevel;
  final String? deviceType;
  final int? stationId;
  final int? distance;

  bool get isAvailable => status.toLowerCase() == 'available';

  factory AssetDevice.fromJson(Map<String, dynamic> json) {
    return AssetDevice(
      assetId:
          json['asset_id']?.toString() ?? json['device_code']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unknown',
      deviceId: json['device_id'] == null ? null : _parseInt(json['device_id']),
      batteryLevel: json['battery_level'] == null
          ? null
          : _parseInt(json['battery_level']),
      deviceType: json['device_type']?.toString() ?? json['type']?.toString(),
      stationId: json['station_id'] == null
          ? null
          : _parseInt(json['station_id']),
      distance: json['distance'] == null ? null : _parseInt(json['distance']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
