import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

typedef _Factory = NepaliDateTime Function(
  int year, [
  int month,
  int day,
  int hour,
  int minute,
  int second,
  int millisecond,
  int microsecond,
]);

const _npt = Duration(hours: 5, minutes: 45);

void _expectFields(
  NepaliDateTime d,
  int year,
  int month,
  int day, [
  int hour = 0,
  int minute = 0,
  int second = 0,
  int millisecond = 0,
  int microsecond = 0,
]) {
  expect(
    [
      d.year,
      d.month,
      d.day,
      d.hour,
      d.minute,
      d.second,
      d.millisecond,
      d.microsecond,
    ],
    [year, month, day, hour, minute, second, millisecond, microsecond],
    reason: '$d',
  );
}

void main() {
  final zones = <String, _Factory>{
    'local': NepaliDateTime.new,
    'utc': NepaliDateTime.utc,
    'nepal': NepaliDateTime.nepal,
  };

  group('construction', () {
    for (final MapEntry(key: zone, value: create) in zones.entries) {
      group(zone, () {
        test('keeps the given fields', () {
          _expectFields(
            create(2080, 5, 17, 13, 45, 30, 123, 456),
            2080,
            5,
            17,
            13,
            45,
            30,
            123,
            456,
          );
        });

        test('normalises overflowing components like DateTime', () {
          _expectFields(create(2080, 1, 35), 2080, 2, 4);
          _expectFields(create(2080, 13), 2081, 1, 1);
          _expectFields(create(2080, 0), 2079, 12, 1);
          _expectFields(create(2080, 2, 0), 2080, 1, 31);
          _expectFields(create(2080, 1, -1), 2079, 12, 29);
          _expectFields(create(2080, 1, 1, 25), 2080, 1, 2, 1);
          _expectFields(create(2080, 1, 1, 0, -1), 2079, 12, 30, 23, 59);
          _expectFields(create(2080, 1, 1, 0, 0, 90), 2080, 1, 1, 0, 1, 30);
          _expectFields(
            create(2080, 1, 1, 0, 0, 0, 1500),
            2080,
            1,
            1,
            0,
            0,
            1,
            500,
          );
          _expectFields(
            create(2080, 1, 1, 0, 0, 0, 0, -1),
            2079,
            12,
            30,
            23,
            59,
            59,
            999,
            999,
          );
        });

        test('day overflow equals adding days', () {
          final base = create(2080, 6, 15, 10);
          for (var n = -800; n <= 800; n += 7) {
            final viaDay = create(2080, 6, 15 + n, 10);
            final viaCalendar = base.copyWith(day: base.day + n);
            expect(viaDay, viaCalendar);
            if (zone != 'local') {
              expect(viaDay, base.add(Duration(days: n)));
            }
          }
        });

        test('month overflow follows calendar months', () {
          for (var n = -30; n <= 30; n++) {
            final d = create(2080, 1 + n, 1);
            final expectedYear =
                2080 + ((n >= 0) ? n ~/ 12 : -((-n + 11) ~/ 12));
            expect(d.year, expectedYear, reason: 'n=$n');
            expect(d.month, n % 12 + 1, reason: 'n=$n');
            expect(d.day, 1);
          }
        });

        test('throws RangeError outside the supported range', () {
          expect(() => create(1968), throwsRangeError);
          expect(() => create(2251), throwsRangeError);
          expect(() => create(2250, 12, 40), throwsRangeError);
        });
      });
    }

    test('weekday uses Sunday = 1', () {
      // 2083-08-06 BS is Sunday 2026-11-22 AD.
      final d = NepaliDateTime.utc(2083, 8, 6);
      expect(d.toDateTime(), DateTime.utc(2026, 11, 22));
      expect(d.weekday, NepaliDateTime.sunday);
      expect(d.add(const Duration(days: 6)).weekday, NepaliDateTime.saturday);
      for (final create in zones.values) {
        expect(create(2083, 8, 6, 23, 59).weekday, NepaliDateTime.sunday);
      }
    });

    test('totalDays and totalDaysInYear', () {
      final d = NepaliDateTime(2080, 2, 10);
      expect(d.totalDays, 32);
      expect(d.totalDaysInYear, 365);
    });
  });

  group('time zones', () {
    test('utc and nepal differ by +05:45 at the same instant', () {
      final utc = NepaliDateTime.utc(2080, 1, 1, 18, 15);
      final npt = utc.toNepalTime();
      _expectFields(npt, 2080, 1, 2);
      expect(npt.isAtSameMomentAs(utc), isTrue);
      expect(npt.isNepalTime, isTrue);
      expect(npt.isUtc, isFalse);
      expect(npt.timeZoneOffset, _npt);
      expect(npt.timeZoneName, 'NPT');
      expect(utc.timeZoneOffset, Duration.zero);
      expect(utc.timeZoneName, 'UTC');
      expect(NepaliDateTime.nepal(2080, 1, 2), npt);
    });

    test('local matches DateTime local wall clock', () {
      final ad = DateTime(2023, 7, 20, 9, 30);
      final bs = ad.toNepaliDateTime();
      expect(bs.isUtc, isFalse);
      expect(bs.isNepalTime, isFalse);
      expect(bs.timeZoneOffset, ad.timeZoneOffset);
      expect(bs.timeZoneName, ad.timeZoneName);
      expect([bs.hour, bs.minute], [9, 30]);
      expect(bs.toDateTime(), ad);
    });

    test('zone conversions preserve the instant', () {
      final local = NepaliDateTime(2081, 9, 9, 12, 34, 56, 789, 12);
      for (final d in [local.toUtc(), local.toNepalTime(), local.toLocal()]) {
        expect(d.microsecondsSinceEpoch, local.microsecondsSinceEpoch);
        expect(d.toLocal(), local);
      }
      expect(identical(local.toLocal(), local), isTrue);
    });

    test('nepalNow and now are the current instant', () {
      final before = DateTime.now();
      final npt = NepaliDateTime.nepalNow();
      final local = NepaliDateTime.now();
      final after = DateTime.now();
      for (final d in [npt, local]) {
        expect(d.isBefore(before), isFalse);
        expect(d.isAfter(after), isFalse);
      }
      expect(npt.isNepalTime, isTrue);
      expect(local.isUtc || local.isNepalTime, isFalse);
    });
  });

  group('DateTime compatibility', () {
    test('toDateTime / toNepaliDateTime keep instant and zone', () {
      final utc = DateTime.utc(2015, 4, 25, 6, 11, 25);
      final bs = utc.toNepaliDateTime();
      expect(bs.isUtc, isTrue);
      _expectFields(bs, 2072, 1, 12, 6, 11, 25);
      expect(bs.toNepalTime().hour, 11);
      expect(bs.toNepalTime().minute, 56);
      expect(bs.toDateTime(), utc);
      expect(bs.toDateTime().isUtc, isTrue);
      expect(identical(bs.toNepaliDateTime(), bs), isTrue);
    });

    test('epoch accessors and constructors', () {
      final d = NepaliDateTime.utc(2080, 1, 1, 0, 0, 0, 1, 1);
      final ad = d.toDateTime();
      expect(d.millisecondsSinceEpoch, ad.millisecondsSinceEpoch);
      expect(d.microsecondsSinceEpoch, ad.microsecondsSinceEpoch);
      expect(
        NepaliDateTime.fromMicrosecondsSinceEpoch(
          d.microsecondsSinceEpoch,
          isUtc: true,
        ),
        d,
      );
      expect(
        NepaliDateTime.fromMillisecondsSinceEpoch(
          d.millisecondsSinceEpoch,
          isUtc: true,
        ),
        d.copyWith(microsecond: 0),
      );
      // Floors like DateTime for instants before 1970.
      final old = NepaliDateTime.fromMicrosecondsSinceEpoch(-1, isUtc: true);
      expect(old.millisecondsSinceEpoch, -1);
      _expectFields(old, 2026, 9, 16, 23, 59, 59, 999, 999);
    });

    test('comparisons work against any DateTime', () {
      final bs = NepaliDateTime.utc(2080);
      final same = bs.toDateTime();
      final later = same.add(const Duration(hours: 1));
      expect(bs.isAtSameMomentAs(same), isTrue);
      expect(bs.isBefore(later), isTrue);
      expect(bs.isAfter(later), isFalse);
      expect(bs.compareTo(later), -1);
      expect(bs.compareTo(same), 0);
      expect(bs.difference(later), const Duration(hours: -1));
      expect(later.difference(bs), const Duration(hours: 1));
      final sorted = [later.toNepaliDateTime(), bs]..sort();
      expect(sorted.first, bs);
    });

    test('add and subtract keep the zone', () {
      final d = NepaliDateTime.nepal(2080, 12, 30, 23);
      final next = d.add(const Duration(hours: 2));
      expect(next.isNepalTime, isTrue);
      _expectFields(next, 2081, 1, 1, 1);
      expect(next.subtract(const Duration(hours: 2)), d);
    });

    test('equality and hashCode consider instant and zone', () {
      final a = NepaliDateTime.utc(2080, 5, 5);
      final b = NepaliDateTime.utc(2080, 5, 5);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == a.toNepalTime(), isFalse);
      expect({a, b, a.toNepalTime()}, hasLength(2));
    });

    test('copyWith shadows the DateTime.copyWith extension', () {
      final d = NepaliDateTime.nepal(2080, 5, 5, 10);
      final copy = d.copyWith(month: 6, hour: 11);
      expect(copy, isA<NepaliDateTime>());
      expect(copy.isNepalTime, isTrue);
      _expectFields(copy, 2080, 6, 5, 11);
      _expectFields(d.copyWith(day: 40), 2080, 6, 9, 10);
    });

    test('mergeTime replaces the time of day', () {
      final d = NepaliDateTime(2080, 5, 5, 10, 11, 12, 13, 14);
      _expectFields(d.mergeTime(20, 21, 22), 2080, 5, 5, 20, 21, 22);
    });
  });

  group('parse & toString', () {
    test('toString and toIso8601String follow DateTime formats', () {
      final local = NepaliDateTime(2080, 1, 5, 7, 8, 9, 10);
      expect(local.toString(), '2080-01-05 07:08:09.010');
      expect(local.toIso8601String(), '2080-01-05T07:08:09.010');
      final utc = NepaliDateTime.utc(2080, 1, 5, 7, 8, 9, 10, 11);
      expect(utc.toString(), '2080-01-05 07:08:09.010011Z');
      expect(utc.toIso8601String(), '2080-01-05T07:08:09.010011Z');
      final npt = NepaliDateTime.nepal(2080, 1, 5);
      expect(npt.toString(), '2080-01-05 00:00:00.000');
      expect(npt.toIso8601String(), '2080-01-05T00:00:00.000+05:45');
    });

    test('round-trips through parse', () {
      for (final d in [
        NepaliDateTime(2080, 1, 5, 7, 8, 9, 10, 11),
        NepaliDateTime.utc(2080, 1, 5, 7, 8, 9, 10, 11),
        NepaliDateTime.nepal(2080, 1, 5, 7, 8, 9, 10, 11),
      ]) {
        expect(NepaliDateTime.parse(d.toIso8601String()), d);
      }
      final local = NepaliDateTime(2080, 1, 5, 7, 8, 9);
      expect(NepaliDateTime.parse(local.toString()), local);
    });

    test('parses formats accepted by DateTime.parse', () {
      _expectFields(NepaliDateTime.parse('2072-01-12'), 2072, 1, 12);
      _expectFields(
        NepaliDateTime.parse('2072-01-12T11:56:25'),
        2072,
        1,
        12,
        11,
        56,
        25,
      );
      _expectFields(
        NepaliDateTime.parse('20720112 115625,1234567'),
        2072,
        1,
        12,
        11,
        56,
        25,
        123,
        456,
      );
      final utc = NepaliDateTime.parse('2072-01-12T11:56:25Z');
      expect(utc.isUtc, isTrue);
      _expectFields(utc, 2072, 1, 12, 11, 56, 25);
      final offset = NepaliDateTime.parse('2072-01-12T11:56:25-01:30');
      expect(offset.isUtc, isTrue);
      _expectFields(offset, 2072, 1, 12, 13, 26, 25);
      final npt = NepaliDateTime.parse('2072-01-12T11:56:25+0545');
      expect(npt.isNepalTime, isTrue);
      _expectFields(npt, 2072, 1, 12, 11, 56, 25);
      // Normalised like DateTime.parse.
      _expectFields(NepaliDateTime.parse('2080-01-35'), 2080, 2, 4);
    });

    test('rejects invalid input', () {
      expect(() => NepaliDateTime.parse('2080/01/01'), throwsFormatException);
      expect(() => NepaliDateTime.parse('3000-01-01'), throwsFormatException);
      expect(NepaliDateTime.tryParse('not a date'), isNull);
      expect(NepaliDateTime.tryParse('1900-01-01'), isNull);
      expect(NepaliDateTime.tryParse('2080-01-01'), isNotNull);
    });
  });

  group('AD <-> BS over the full range', () {
    test('every AD day maps to the same BS day in UTC and back', () {
      var ad = DateTime.utc(1912, 4, 12);
      final end = DateTime.utc(2194, 4, 14);
      var (y, m, d) = (1969, 1, 1);
      while (ad.isBefore(end)) {
        final bs = ad.toNepaliDateTime();
        expect([bs.year, bs.month, bs.day], [y, m, d], reason: '$ad');
        expect(bs.toDateTime(), ad);
        ad = ad.add(const Duration(days: 1));
        if (++d > bs.totalDays) {
          d = 1;
          if (++m > 12) {
            m = 1;
            y++;
          }
        }
      }
    });

    test('Nepal midnight maps to the same BS date in Nepal Time', () {
      for (var i = 0; i < 40000; i += 13) {
        final bs = NepaliDateTime.nepal(2000, 1, 1 + i);
        final ad = bs.toUtc().toDateTime().add(_npt);
        expect([ad.hour, ad.minute], [0, 0]);
        final back = DateTime.utc(
          ad.year,
          ad.month,
          ad.day,
        ).subtract(_npt).toNepaliDateTime().toNepalTime();
        expect(back, bs);
      }
    });
  });
}
