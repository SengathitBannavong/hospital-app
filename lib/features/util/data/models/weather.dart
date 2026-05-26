// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

@freezed
class Weather with _$Weather {
  const factory Weather({
    required String city,
    @JsonKey(name: 'temp_c') required double tempC,
    required int humidity,
    @JsonKey(name: 'description', fromJson: _descriptionFromJson)
    required List<String> descriptions,
    @JsonKey(name: 'wind_speed') required double windSpeed,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}

List<String> _descriptionFromJson(Object? json) {
  if (json is List) {
    return json.map((item) => item.toString()).toList();
  }
  if (json == null) return const <String>[];
  return <String>[json.toString()];
}
