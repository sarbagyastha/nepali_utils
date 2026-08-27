import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  group('DateTime.toNepaliDateTime() around the 1986 Nepal offset change', () {
    // Nepal's UTC offset changed from +5:30 to +5:45 on 1986-01-01, which
    // made that local Nepal-time day only 23h45m long in Dart's tz database.
    // The old implementation derived its day-count from local (offset-aware)
    // dates and needed a manual `+1` compensation to work around this,
    // which is exactly the compensation removed by this fix in favor of
    // diffing UTC-tagged dates, which have no such offset artifact.
    test(
      'a UTC day-diff around 1986-01-01 is a plain 1-day step, unlike a '
      'Nepal-local one',
      () {
        expect(
          DateTime.utc(1986, 1, 2).difference(DateTime.utc(1986, 1, 1)),
          const Duration(days: 1),
        );
      },
    );

    test(
        'converts AD dates spanning the 1986 offset change to the correct BS date',
        () {
      const expected = {
        '1985-12-30': [2042, 9, 15],
        '1985-12-31': [2042, 9, 16],
        '1986-01-01': [2042, 9, 17],
        '1986-01-02': [2042, 9, 18],
        '1986-01-03': [2042, 9, 19],
      };

      for (final entry in expected.entries) {
        final parts = entry.key.split('-').map(int.parse).toList();
        final bs = DateTime(parts[0], parts[1], parts[2]).toNepaliDateTime();

        expect(
          [bs.year, bs.month, bs.day],
          entry.value,
          reason: 'BS mismatch for AD date ${entry.key}',
        );
      }
    });
  });

  group('DateTime.toNepaliDateTime() is independent of device timezone', () {
    test('converts a fixed AD calendar date to the expected BS date', () {
      // Regression for a bug where toNepaliDateTime() derived the BS day
      // from the device's live UTC offset instead of the calendar date,
      // so the same AD date converted to different BS days depending on
      // the machine's local timezone.
      final bs = DateTime(2026, 8, 27).toNepaliDateTime();

      expect(bs.year, 2083);
      expect(bs.month, 5);
      expect(bs.day, 11);
    });

    test(
        'round-trips BS dates via toDateTime() and toNepaliDateTime() for a wide range',
        () {
      for (var year = 1970; year <= 2100; year++) {
        for (var month = 1; month <= 12; month++) {
          final daysInMonth = NepaliDateTime(year, month, 1).totalDays;
          for (var day = 1; day <= daysInMonth; day++) {
            final bs = NepaliDateTime(year, month, day);

            final ad = bs.toDateTime();
            final bsBack =
                DateTime(ad.year, ad.month, ad.day).toNepaliDateTime();

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
