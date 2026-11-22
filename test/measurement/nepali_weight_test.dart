import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  group('unit sizes', () {
    test('gold', () {
      expect(NepaliWeight(1, .tola).to(.lal), closeTo(100, 1e-12));
      expect(NepaliWeight(1, .tola).to(.gram), 11.6638038);
    });

    test('market', () {
      expect(NepaliWeight(1, .dharni).to(.ser), closeTo(3, 1e-12));
      expect(NepaliWeight(1, .ser).to(.pau), closeTo(4, 1e-12));
      expect(NepaliWeight(1, .pau).to(.chhatak), closeTo(4, 1e-12));
      expect(NepaliWeight(1, .dharni).to(.kilogram), closeTo(2.3934096, 1e-12));
    });

    test('round trips through every unit', () {
      const value = 98.765;
      for (final from in WeightUnit.values) {
        for (final to in WeightUnit.values) {
          final converted = NepaliWeight(value, from).to(to);
          expect(
            NepaliWeight(converted, to).to(from),
            closeTo(value, 1e-9),
            reason: '$from → $to',
          );
        }
      }
    });
  });

  group('parts', () {
    test('tola', () {
      expect(NepaliWeight.tola(2, lal: 50).tolaParts, (tola: 2, lal: 50.0));
      expect(NepaliWeight(1, .kilogram).tolaParts.tola, 85);
    });

    test('dharni', () {
      expect(NepaliWeight.dharni(1, ser: 2, pau: 3, chhatak: 1.5).dharniParts, (
        dharni: 1,
        ser: 2,
        pau: 3,
        chhatak: 1.5,
      ));
    });

    test('carries values just under a boundary', () {
      final weight = NepaliWeight(NepaliWeight(1, .tola).to(.gram), .gram);
      expect(weight.tolaParts, (tola: 1, lal: 0.0));
    });
  });

  group('format', () {
    final gold = NepaliWeight.tola(2, lal: 50);

    test('short', () {
      expect(gold.format(.tola, language: .english), '2-50');
      expect(gold.format(.tola, language: .nepali), '२-५०');
      expect(
        NepaliWeight(5, .kilogram).format(.dharni, language: .english),
        '2-0-1-0.28',
      );
    });

    test('long', () {
      expect(
        gold.format(.tola, long: true, language: .english),
        '2 tola 50 lal',
      );
      expect(
        gold.format(.tola, long: true, language: .nepali),
        '२ तोला ५० लाल',
      );
      expect(
        NepaliWeight.dharni(
          1,
          pau: 2,
        ).format(.dharni, long: true, language: .nepali),
        '१ धार्नी २ पाउ',
      );
    });
  });

  group('parse', () {
    test('valid', () {
      expect(NepaliWeight.parse('२-५०', .tola), NepaliWeight.tola(2, lal: 50));
      expect(
        NepaliWeight.parse('1-2', .dharni),
        NepaliWeight.dharni(1, ser: 2),
      );
    });

    test('invalid', () {
      expect(NepaliWeight.tryParse('1-2-3', .tola), isNull);
      expect(() => NepaliWeight.parse('', .dharni), throwsFormatException);
    });
  });

  test('arithmetic and comparison', () {
    final tola = NepaliWeight(1, .tola);
    expect(tola + tola, tola * 2);
    expect(((tola * 3 - tola) / 2).grams, closeTo(tola.grams, 1e-12));
    expect(tola < NepaliWeight(1, .dharni), isTrue);
    expect(NepaliWeight(1000, .gram), NepaliWeight(1, .kilogram));
  });

  test('labels', () {
    expect(WeightUnit.chhatak.label(.english), 'chhatak');
    expect(WeightUnit.chhatak.label(.nepali), 'छटाक');
  });
}
