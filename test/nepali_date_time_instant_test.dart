import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  group('DateTime <-> NepaliDateTime instant-based conversion', () {
    test('round-trips AD dates via instant-based conversion for a wide range', () {
      const nepalTzOffset = Duration(hours: 5, minutes: 45);

      // Chosen to cover the full supported Nepali calendar range.
      for (var year = 1913; year <= 2100; year++) {
        for (var month = 1; month <= 12; month++) {
          final maxDay = _daysInGregorianMonth(year, month);
          for (var day = 1; day <= maxDay; day++) {
            // This represents 00:00 in Nepal for the given AD date.
            final adNepalMidnightUtc = DateTime.utc(year, month, day).subtract(nepalTzOffset);

            final bs = adNepalMidnightUtc.toNepaliDateTime();

            final adBack = bs.toDateTime();

            expect(
              adBack.year,
              year,
              reason: 'Year mismatch for AD date $year-$month-$day',
            );
            expect(
              adBack.month,
              month,
              reason: 'Month mismatch for AD date $year-$month-$day',
            );
            expect(
              adBack.day,
              day,
              reason: 'Day mismatch for AD date $year-$month-$day',
            );
          }
        }
      }
    });

    test('round-trips BS dates via AD and instant-based conversion for a wide range', () {
      // Use a broad but bounded range within the supported BS years.
      for (var year = 1970; year <= 2100; year++) {
        for (var month = 1; month <= 12; month++) {
          final daysInMonth = NepaliDateTime(year, month, 1).totalDays;
          for (var day = 1; day <= daysInMonth; day++) {
            final bs = NepaliDateTime(year, month, day);

            final ad = bs.toDateTime();
            final bsBack = ad.toNepaliDateTime();

            expect(
              bsBack.year,
              year,
              reason: 'BS year mismatch for BS date $year-$month-$day',
            );
            expect(
              bsBack.month,
              month,
              reason: 'BS month mismatch for BS date $year-$month-$day',
            );
            expect(
              bsBack.day,
              day,
              reason: 'BS day mismatch for BS date $year-$month-$day',
            );
          }
        }
      }
    });
  });
}

int _daysInGregorianMonth(int year, int month) {
  const monthLengths = <int>[
    31,
    28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  ];

  if (month == 2 && _isLeapYear(year)) {
    return 29;
  }

  return monthLengths[month - 1];
}

bool _isLeapYear(int year) {
  if (year % 400 == 0) return true;
  if (year % 100 == 0) return false;
  return year % 4 == 0;
}
