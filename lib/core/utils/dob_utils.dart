DateTime _today() => DateTime.now();

/// Returns the latest allowed birth date for a given minimum age.
DateTime lastAllowedDob({int minAge = 13}) {
  final now = _today();
  return DateTime(now.year - minAge, now.month, now.day);
}

/// Returns true if [dob] makes the user at least [minAge] years old.
bool isAtLeastAge(DateTime dob, int minAge) {
  final now = _today();
  int age = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age -= 1;
  }
  return age >= minAge;
}

/// Formats a DateTime to yyyy-MM-dd used by API and storage.
String formatDobForApi(DateTime dob) {
  return dob.toIso8601String().split('T')[0];
}
