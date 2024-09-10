import 'package:nepali_utils/src/nepali_date_time.dart';
import 'package:test/test.dart';

void main() {
  bool dateEquals(NepaliDateTime actual, NepaliDateTime expected) {
    return actual.year == expected.year &&
        actual.month == expected.month &&
        actual.day == expected.day;
  }

  group('supports days arithmetic', () {
    test('forward same year', () {
      expect(
        dateEquals(
          NepaliDateTime(2081, 5, 37),
          NepaliDateTime(2081, 5).add(const Duration(days: 36)),
        ),
        isTrue,
      );
      expect(
        dateEquals(
          NepaliDateTime(2070, 12, 365),
          NepaliDateTime(2070, 12).add(const Duration(days: 364)),
        ),
        isTrue,
      );
    });
    test('forward next year', () {
      expect(
        dateEquals(
          NepaliDateTime(2081, 5, 1000),
          NepaliDateTime(2081, 5).add(const Duration(days: 999)),
        ),
        isTrue,
      );
      expect(
        dateEquals(
          NepaliDateTime(2065, 12, 36),
          NepaliDateTime(2065, 12).add(const Duration(days: 35)),
        ),
        isTrue,
      );
    });
    test('backward same year', () {
      expect(
        dateEquals(
          NepaliDateTime(2081, 5, -37),
          NepaliDateTime(2081, 5).subtract(const Duration(days: 38)),
        ),
        isTrue,
      );
      expect(
        NepaliDateTime(2081, 5, -37).toString(),
        NepaliDateTime(2081, 5).subtract(const Duration(days: 38)).toString(),
      );
      expect(
        dateEquals(
          NepaliDateTime(2070, 12, -330),
          NepaliDateTime(2070, 12).subtract(const Duration(days: 331)),
        ),
        isTrue,
      );
    });
    test('backward previous year', () {
      expect(
        dateEquals(
          NepaliDateTime(2023, 1, 0),
          NepaliDateTime(2023).subtract(const Duration(days: 1)),
        ),
        isTrue,
      );
      expect(
        dateEquals(
          NepaliDateTime(2081, 1, -37),
          NepaliDateTime(2081).subtract(const Duration(days: 38)),
        ),
        isTrue,
      );
      expect(
        dateEquals(
          NepaliDateTime(2070, 12, -568),
          NepaliDateTime(2070, 12).subtract(const Duration(days: 569)),
        ),
        isTrue,
      );
    });
    test('throws range error', () {
      expect(
        () => NepaliDateTime(2248, 12, 876),
        throwsRangeError,
      );
      expect(
        () => NepaliDateTime(1970, 3, -1234),
        throwsRangeError,
      );
    });
  });

  group('supports month arithmetic', () {
    test('forward next years', () {
      expect(
        dateEquals(
          NepaliDateTime(2081, 16, 5),
          NepaliDateTime(2082, 4, 5),
        ),
        isTrue,
      );
      expect(
        dateEquals(
          NepaliDateTime(1998, 123, 25),
          NepaliDateTime(2008, 3, 25),
        ),
        isTrue,
      );
    });
    test('backward previous years', () {
      expect(
        dateEquals(
          NepaliDateTime(2081, 0, 5),
          NepaliDateTime(2080, 12, 5),
        ),
        isTrue,
      );
      expect(
        dateEquals(
          NepaliDateTime(2056, -107, 5),
          NepaliDateTime(2047, 1, 5),
        ),
        isTrue,
      );
      expect(
        dateEquals(
          NepaliDateTime(2008, -123, 25),
          NepaliDateTime(1997, 9, 25),
        ),
        isTrue,
      );
    });
    test('throws range error', () {
      expect(
        () => NepaliDateTime(2248, 65, 4),
        throwsRangeError,
      );
      expect(
        () => NepaliDateTime(1973, -243, 23),
        throwsRangeError,
      );
    });
  });
  group('supports combined month and day arithmetic', () {
    test('both positive', () {
      expect(
        dateEquals(
          NepaliDateTime(2081, 16, 45),
          NepaliDateTime(2082, 5, 13),
        ),
        isTrue,
      );
    });
    test('both negative', () {
      expect(
        dateEquals(
          NepaliDateTime(2056, -107, -1),
          NepaliDateTime(2046, 12, 30),
        ),
        isTrue,
      );
    });
    test('mixed positive and negative', () {
      expect(
        dateEquals(
          NepaliDateTime(2065, 13, -30),
          NepaliDateTime(2065, 12),
        ),
        isTrue,
      );
      expect(
        dateEquals(
          NepaliDateTime(2065, -11, 1825),
          NepaliDateTime(2068, 12, 29),
        ),
        isTrue,
      );
    });
  });
}
