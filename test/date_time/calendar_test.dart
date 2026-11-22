import 'dart:io';

import 'package:nepali_utils/src/date_time/calendar/bs_calendar.dart';
import 'package:nepali_utils/src/date_time/calendar/bs_calendar_data.dart';
import 'package:nepali_utils/src/date_time/calendar/epoch_day.dart';
import 'package:nepali_utils/src/date_time/calendar/gregorian.dart';
import 'package:test/test.dart';

void main() {
  group('Gregorian', () {
    test('matches DateTime for every day from 1900 to 2200', () {
      var expected = DateTime.utc(1900);
      final end = DateTime.utc(2200);
      while (expected.isBefore(end)) {
        final day = EpochDay(
          expected.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay,
        );
        expect(
          Gregorian.toEpochDay(expected.year, expected.month, expected.day),
          day,
        );
        expect(Gregorian.fromEpochDay(day), (
          expected.year,
          expected.month,
          expected.day,
        ));
        expected = expected.add(const Duration(days: 1));
      }
    });

    test('weekday of epoch days follows Sunday = 1', () {
      // 2026-11-22 is a Sunday.
      expect(Gregorian.toEpochDay(2026, 11, 22).weekday, 1);
      // 1970-01-01 is a Thursday.
      expect(const EpochDay(0).weekday, 5);
      expect(const EpochDay(-1).weekday, 4);
    });
  });

  group('BsCalendar', () {
    test('matches the month starts of the previous implementation', () {
      final rows = File('test/fixtures/bs_month_starts.csv')
          .readAsLinesSync()
          .skip(1);
      expect(rows, hasLength((2250 - 1970 + 1) * 12));
      for (final row in rows) {
        final [y, m, ad] = row.split(',');
        final [ay, am, ad2] = ad.split('-').map(int.parse).toList();
        final epochDay = Gregorian.toEpochDay(ay, am, ad2);
        final year = int.parse(y);
        final month = int.parse(m);
        expect(BsCalendar.toEpochDay(year, month), epochDay, reason: row);
        expect(BsCalendar.fromEpochDay(epochDay), (year, month, 1));
      }
    });

    test('known reference dates', () {
      void check(int y, int m, int d, int ay, int am, int ad) {
        expect(Gregorian.fromEpochDay(BsCalendar.toEpochDay(y, m, d)), (
          ay,
          am,
          ad,
        ), reason: '$y-$m-$d BS');
      }

      check(1970, 1, 1, 1913, 4, 13);
      check(2072, 6, 3, 2015, 9, 20); // Constitution Day.
      check(2080, 1, 1, 2023, 4, 14);
      check(2081, 1, 1, 2024, 4, 13);
      check(2082, 1, 1, 2025, 4, 14);
    });

    test('round-trips every supported day', () {
      final first = BsCalendar.firstDay.value;
      final end = BsCalendar.endDay.value;
      var (year, month, day) = (BsCalendar.minYear, 1, 1);
      for (var e = first; e < end; e++) {
        expect(BsCalendar.fromEpochDay(EpochDay(e)), (year, month, day));
        expect(BsCalendar.toEpochDay(year, month, day).value, e);
        if (++day > BsCalendar.daysInMonth(year, month)) {
          day = 1;
          if (++month > 12) {
            month = 1;
            year++;
          }
        }
      }
      expect(year, BsCalendar.maxYear + 1);
    });

    test('month lengths and year totals come from the data table', () {
      for (var y = BsCalendar.minYear; y <= BsCalendar.maxYear; y++) {
        final months = bsMonthLengths[y - bsDataFirstYear];
        for (var m = 1; m <= 12; m++) {
          expect(BsCalendar.daysInMonth(y, m), months[m - 1]);
        }
        final total = months.reduce((a, b) => a + b);
        expect(BsCalendar.daysInYear(y), total);
        if (y != 2200) expect(total, anyOf(365, 366), reason: '$y BS');
      }
    });

    test('normalises out-of-range months and days', () {
      final base = BsCalendar.toEpochDay(2080);
      expect(BsCalendar.toEpochDay(2080, 1, 35), base + 34);
      expect(BsCalendar.toEpochDay(2080, 13), BsCalendar.toEpochDay(2081));
      expect(BsCalendar.toEpochDay(2080, 0), BsCalendar.toEpochDay(2079, 12));
      expect(BsCalendar.toEpochDay(2080, -11), BsCalendar.toEpochDay(2079));
      expect(BsCalendar.toEpochDay(2080, 25), BsCalendar.toEpochDay(2082));
      expect(BsCalendar.toEpochDay(2080, 2, 0), base + 30);
      expect(BsCalendar.toEpochDay(2080, 1, -1), base + -2);
    });

    test('rejects dates outside the supported range', () {
      expect(() => BsCalendar.toEpochDay(1968), throwsRangeError);
      expect(() => BsCalendar.toEpochDay(2251), throwsRangeError);
      expect(
        () => BsCalendar.fromEpochDay(BsCalendar.endDay),
        throwsRangeError,
      );
      expect(
        () => BsCalendar.fromEpochDay(BsCalendar.firstDay + -1),
        throwsRangeError,
      );
      expect(() => BsCalendar.daysInMonth(2080, 13), throwsRangeError);
    });
  });
}
