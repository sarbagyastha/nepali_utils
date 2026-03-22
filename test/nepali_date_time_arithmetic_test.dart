import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NepaliDateTime.difference', () {
    test('matches microsecond gap between underlying DateTime instants', () {
      final a = NepaliDateTime(2079, 6, 15, 14, 30, 45, 100, 200);
      final b = NepaliDateTime(2078, 3, 1, 8, 0, 0);

      expect(
        a.difference(b).inMicroseconds,
        a.microsecondsSinceEpoch - b.microsecondsSinceEpoch,
      );
    });

    test('is antisymmetric with respect to argument order', () {
      final a = NepaliDateTime(2080, 1, 1);
      final b = NepaliDateTime(2079, 12, 15);

      expect(
        a.difference(b) + b.difference(a),
        Duration.zero,
      );
    });

    test('is zero for the same moment', () {
      final n = NepaliDateTime(2077, 11, 7, 9, 41, 2);
      expect(n.difference(n), Duration.zero);
    });
  });

  group('NepaliDateTime.add', () {
    test('matches DateTime.add on the converted instant', () {
      final n = NepaliDateTime(2079, 11, 20, 10, 30, 0);
      const d = Duration(days: 3, hours: 2, minutes: 15, seconds: 40);

      final expectedMs = n.toDateTime().add(d).millisecondsSinceEpoch;
      expect(n.add(d).millisecondsSinceEpoch, expectedMs);
    });

    test('crosses BS month boundary correctly', () {
      const year = 2079;
      final daysInFirstMonth = NepaliDateTime(year, 1, 1).totalDays;
      final endOfMonth = NepaliDateTime(year, 1, daysInFirstMonth, 12, 0, 0);
      final next = endOfMonth.add(const Duration(days: 1));

      expect(next.year, year);
      expect(next.month, 2);
      expect(next.day, 1);
      expect(next.hour, 12);
    });

    test('Duration.zero is a no-op on the instant', () {
      final n = NepaliDateTime(2081, 5, 5, 18, 0, 0, 500);
      final out = n.add(Duration.zero);
      expect(out.isAtSameMomentAs(n), isTrue);
    });
  });

  group('NepaliDateTime.subtract', () {
    test('matches DateTime.subtract on the converted instant', () {
      final n = NepaliDateTime(2076, 2, 28, 23, 59, 59);
      const d = Duration(days: 10, hours: 5);

      final expectedMs = n.toDateTime().subtract(d).millisecondsSinceEpoch;
      expect(n.subtract(d).millisecondsSinceEpoch, expectedMs);
    });

    test('is inverse of add for the same duration', () {
      final n = NepaliDateTime(2075, 8, 16, 6, 15, 30);
      const d = Duration(days: 17, hours: 4, minutes: 22);

      final restored = n.add(d).subtract(d);
      expect(restored.isAtSameMomentAs(n), isTrue);
    });
  });

  group('NepaliDateTime add / subtract / difference together', () {
    test('difference between values separated by add matches the duration', () {
      final start = NepaliDateTime(2074, 4, 10, 0, 0, 0);
      const step = Duration(days: 45, hours: 12);
      final end = start.add(step);

      expect(end.difference(start), step);
      expect(start.difference(end), -step);
    });
  });
}
