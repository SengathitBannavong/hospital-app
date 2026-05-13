import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_station.freezed.dart';
part 'asset_station.g.dart';

@freezed
class AssetStation with _$AssetStation {
  const factory AssetStation({
    @JsonKey(name: 'station_id') required int stationId,
    @JsonKey(name: 'station_name') required String stationName,
    required int capacity,
    @JsonKey(name: 'available_wheelchairs') required int availableWheelchairs,
  }) = _AssetStation;

  factory AssetStation.fromJson(Map<String, dynamic> json) =>
      _$AssetStationFromJson(json);
}
