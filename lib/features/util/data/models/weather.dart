// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

@freezed
class Weather with _$Weather {
  const factory Weather({
    required String city,
    @JsonKey(name: 'temp_c', fromJson: _doubleFromJson) required double tempC,
    @JsonKey(fromJson: _intFromJson) required int humidity,
    @JsonKey(name: 'description', fromJson: _descriptionFromJson)
    required List<String> descriptions,
    @JsonKey(name: 'wind_speed', fromJson: _doubleFromJson)
    required double windSpeed,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}

List<String> _descriptionFromJson(Object? json) {
  // Actual backend shape is a list of objects: [{"value": "Sunny"}].
  if (json is List) {
    return json.map((item) {
      if (item is Map && item['value'] != null) {
        return item['value'].toString();
      }
      return item.toString();
    }).toList();
  }
  if (json == null) return const <String>[];
  return <String>[json.toString()];
}

double _doubleFromJson(Object? json) {
  if (json is num) return json.toDouble();
  return double.tryParse(json?.toString() ?? '') ?? 0;
}

int _intFromJson(Object? json) {
  if (json is num) return json.toInt();
  return int.tryParse(json?.toString() ?? '') ?? 0;
}
