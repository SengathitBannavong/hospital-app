class AssetTrack {
  const AssetTrack({
    required this.assetId,
    required this.status,
    this.movingStatus,
    this.currentNodeId,
    this.batteryLevel,
    this.condition,
  });

  final String assetId;
  final String status;
  final String? movingStatus;
  final dynamic currentNodeId;
  final String? batteryLevel;
  final String? condition;

  factory AssetTrack.fromJson(Map<String, dynamic> json) {
    return AssetTrack(
      assetId: json['asset_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unknown',
      movingStatus: json['moving_status']?.toString(),
      currentNodeId: json['current_node_id'],
      batteryLevel: json['battery_level']?.toString(),
      condition: json['condition']?.toString(),
    );
  }
}
