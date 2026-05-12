// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'medical_json_helpers.dart';

part 'room_open.freezed.dart';
part 'room_open.g.dart';

@freezed
class RoomOpen with _$RoomOpen {
  const factory RoomOpen({
    @JsonKey(name: 'poi_id', fromJson: parseInt) required int poiId,
    @JsonKey(name: 'poi_name', fromJson: parseString) required String poiName,
    @JsonKey(name: 'open_hours', fromJson: parseString) String? openHours,
    @JsonKey(name: 'is_open', fromJson: parseBool) required bool isOpen,
  }) = _RoomOpen;

  factory RoomOpen.fromJson(Map<String, dynamic> json) =>
      _$RoomOpenFromJson(json);
}
