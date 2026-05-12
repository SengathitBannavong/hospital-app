// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_department.freezed.dart';
part 'map_department.g.dart';

@freezed
class MapDepartment with _$MapDepartment {
  const factory MapDepartment({
    @JsonKey(name: 'ward_id') required int wardId,
    @JsonKey(name: 'ward_name') required String wardName,
    @JsonKey(name: 'poi_count') required int poiCount,
  }) = _MapDepartment;

  factory MapDepartment.fromJson(Map<String, dynamic> json) =>
      _$MapDepartmentFromJson(json);
}
