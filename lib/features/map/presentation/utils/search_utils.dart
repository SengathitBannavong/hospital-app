final _vnA = RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]');
final _vnE = RegExp(r'[èéẹẻẽêềếệểễ]');
final _vnI = RegExp(r'[ìíịỉĩ]');
final _vnO = RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]');
final _vnU = RegExp(r'[ùúụủũưừứựửữ]');
final _vnY = RegExp(r'[ỳýỵỷỹ]');
final _whitespace = RegExp(r'\s+');

String normalizeForSearch(String value) {
  return value
      .toLowerCase()
      .replaceAll(_vnA, 'a')
      .replaceAll(_vnE, 'e')
      .replaceAll(_vnI, 'i')
      .replaceAll(_vnO, 'o')
      .replaceAll(_vnU, 'u')
      .replaceAll(_vnY, 'y')
      .replaceAll('đ', 'd')
      .replaceAll(_whitespace, ' ')
      .trim();
}
