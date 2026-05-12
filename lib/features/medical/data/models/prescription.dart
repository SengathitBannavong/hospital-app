// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'medical_json_helpers.dart';

part 'prescription.freezed.dart';
part 'prescription.g.dart';

@freezed
class Prescription with _$Prescription {
  const factory Prescription({
    @JsonKey(name: 'prescription_id', fromJson: parseInt)
    required int prescriptionId,
    @JsonKey(name: 'pharmacy_poi_id', fromJson: parseNullableInt)
    int? pharmacyPoiId,
    @JsonKey(name: 'pharmacy_name') String? pharmacyName,
    required List<PrescriptionItem> items,
    @JsonKey(fromJson: parseString) required String status,
    @JsonKey(name: 'issued_at', fromJson: parseString) required String issuedAt,
  }) = _Prescription;

  factory Prescription.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionFromJson(json);
}

@freezed
class PrescriptionItem with _$PrescriptionItem {
  const factory PrescriptionItem({
    @JsonKey(fromJson: parseString) required String name,
    @JsonKey(fromJson: parseString) required String dosage,
    @JsonKey(fromJson: parseDouble) required double quantity,
    String? instructions,
  }) = _PrescriptionItem;

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionItemFromJson(json);
}
