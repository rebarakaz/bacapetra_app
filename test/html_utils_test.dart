// test/html_utils_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:baca_petra/lib/utils/html_utils.dart';

void main() {
  group('calculateReadingTime', () {
    test('should return "0 min baca" for empty content', () {
      expect(calculateReadingTime(''), '0 min baca');
    });
  });
}
