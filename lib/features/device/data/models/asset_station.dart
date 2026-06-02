class AssetStation {
  const AssetStation({
    required this.stationId,
    required this.stationName,
    required this.capacity,
    required this.availableWheelchairs,
    this.poiId,
  });

  final int stationId;
  final String stationName;
  final int capacity;
  final int availableWheelchairs;
  final int? poiId;

  factory AssetStation.fromJson(Map<String, dynamic> json) {
    return AssetStation(
      stationId: _parseInt(json['station_id'] ?? json['id']),
      stationName: json['station_name']?.toString() ?? 'Trạm thiết bị',
      capacity: _parseInt(json['capacity']),
      availableWheelchairs: _parseInt(
        json['available_wheelchairs'] ?? json['available_count'] ?? 0,
      ),
      poiId: json['poi_id'] == null ? null : _parseInt(json['poi_id']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
