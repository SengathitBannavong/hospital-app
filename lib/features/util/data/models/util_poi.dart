/// Generic POI info returned by pharmacy / canteen / parking / wifi endpoints.
/// Backend returns the same MapPoi structure for all these utility queries.
class UtilPoi {
  const UtilPoi({
    required this.poiId,
    required this.poiName,
    required this.poiType,
    this.details,
    this.openHours,
    this.gridLocation,
    this.isAccessible,
    this.capacity,
  });

  final int poiId;
  final String poiName;
  final String poiType;
  final String? details;
  final String? openHours;
  final int? gridLocation;
  final bool? isAccessible;
  final int? capacity;

  factory UtilPoi.fromJson(Map<String, dynamic> json) {
    return UtilPoi(
      poiId: _parseInt(json['poi_id'] ?? json['id']),
      poiName:
          json['poi_name']?.toString() ??
          json['name']?.toString() ??
          'Không rõ tên',
      poiType: json['poi_type']?.toString() ?? json['type']?.toString() ?? '',
      details: json['details']?.toString(),
      openHours: json['open_hours']?.toString(),
      gridLocation:
          json['grid_location'] == null
              ? null
              : _parseInt(json['grid_location']),
      isAccessible: json['is_accessible'] as bool?,
      capacity:
          json['capacity'] == null ? null : _parseInt(json['capacity']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
