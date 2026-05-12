// Helpers สำหรับแปลง number จาก API ให้เป็นชนิดที่ใช้งานง่าย
// (กันกรณี backend ส่งเป็น int หรือ double ปะปนกัน)
int parseInt(Object? value) {
  if (value == null) return 0;
  return (value as num).toInt();
}

int? parseNullableInt(Object? value) {
  if (value == null) return null;
  return (value as num).toInt();
}

double parseDouble(Object? value) {
  if (value == null) return 0.0;
  return (value as num).toDouble();
}

String parseString(Object? value) {
  if (value == null) return '';
  return value.toString();
}

bool parseBool(Object? value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}
