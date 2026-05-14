import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/presentation/utils/search_utils.dart';

void main() {
  group('normalizeForSearch', () {
    test('strips Vietnamese accents and lowers case', () {
      expect(normalizeForSearch('Cổng Chính'), 'cong chinh');
      expect(normalizeForSearch('Phòng Khám Nội Khoa'), 'phong kham noi khoa');
      expect(normalizeForSearch('Đường'), 'duong');
    });

    test('collapses runs of whitespace and trims', () {
      expect(normalizeForSearch('  phòng   khám  '), 'phong kham');
    });

    test('is idempotent', () {
      final once = normalizeForSearch('Phòng Khám Nội Khoa');
      expect(normalizeForSearch(once), once);
    });

    test('empty input returns empty', () {
      expect(normalizeForSearch(''), '');
      expect(normalizeForSearch('   '), '');
    });
  });
}
