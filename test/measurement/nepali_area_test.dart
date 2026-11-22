import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  group('unit sizes', () {
    test('hill units', () {
      expect(NepaliArea(1, .ropani).to(.aana), 16);
      expect(NepaliArea(1, .aana).to(.paisa), 4);
      expect(NepaliArea(1, .paisa).to(.daam), 4);
      expect(NepaliArea(1, .ropani).to(.squareFoot), 74 * 74);
    });

    test('Terai units', () {
      expect(NepaliArea(1, .bigha).to(.kattha), 20);
      expect(NepaliArea(1, .kattha).to(.dhur), 20);
      expect(NepaliArea(1, .bigha).to(.squareFoot), 270 * 270);
    });

    test('metric and imperial', () {
      expect(NepaliArea(1, .ropani).to(.squareMeter), closeTo(508.737, 1e-3));
      expect(NepaliArea(1, .bigha).to(.squareMeter), closeTo(6772.632, 1e-3));
      expect(NepaliArea(1, .kattha).to(.squareMeter), closeTo(338.632, 1e-3));
      expect(NepaliArea(1, .bigha).to(.ropani), closeTo(13.3126, 1e-4));
      expect(NepaliArea(1, .acre).to(.squareFoot), 43560);
      expect(NepaliArea(1, .hectare).to(.squareMeter), closeTo(10000, 1e-9));
    });

    test('round trips through every unit', () {
      const value = 1234.5678;
      for (final from in AreaUnit.values) {
        for (final to in AreaUnit.values) {
          final converted = NepaliArea(value, from).to(to);
          expect(
            NepaliArea(converted, to).to(from),
            closeTo(value, 1e-9),
            reason: '$from → $to',
          );
        }
      }
    });
  });

  group('constructors', () {
    test('ropani', () {
      expect(
        NepaliArea.ropani(2, aana: 3, paisa: 1, daam: 2),
        NepaliArea(
          2 * 5476 + 3 * 342.25 + 85.5625 + 2 * 21.390625,
          .squareFoot,
        ),
      );
    });

    test('bigha', () {
      expect(
        NepaliArea.bigha(1, kattha: 5, dhur: 2.5),
        NepaliArea(72900 + 5 * 3645 + 2.5 * 182.25, .squareFoot),
      );
    });

    test('zero', () => expect(NepaliArea.zero.squareFeet, 0));
  });

  group('parts', () {
    test('ropani', () {
      expect(NepaliArea.ropani(2, aana: 15, paisa: 3, daam: 1.5).ropaniParts, (
        ropani: 2,
        aana: 15,
        paisa: 3,
        daam: 1.5,
      ));
    });

    test('bigha', () {
      expect(NepaliArea.bigha(3, kattha: 19, dhur: 7.25).bighaParts, (
        bigha: 3,
        kattha: 19,
        dhur: 7.25,
      ));
    });

    test('carries values just under a boundary after metric conversion', () {
      final ropani = NepaliArea(
        NepaliArea(1, .ropani).to(.squareMeter),
        .squareMeter,
      );
      expect(ropani.ropaniParts, (ropani: 1, aana: 0, paisa: 0, daam: 0.0));
    });

    test('cross system', () {
      expect(NepaliArea(1, .bigha).ropaniParts, (
        ropani: 13,
        aana: 5,
        paisa: 0,
        daam: 0.035062089, // 0.75 sq. ft
      ));
    });

    test('negative', () {
      expect(NepaliArea(-1.5, .ropani).ropaniParts, (
        ropani: -1,
        aana: -8,
        paisa: 0,
        daam: 0.0,
      ));
    });
  });

  group('format', () {
    final plot = NepaliArea.ropani(2, aana: 3, paisa: 1);

    test('short', () {
      expect(plot.format(.ropani, language: .english), '2-3-1-0');
      expect(plot.format(.ropani, language: .nepali), '२-३-१-०');
      expect(plot.format(.bigha, language: .english), '0-3-6.2');
    });

    test('long', () {
      expect(
        plot.format(.ropani, long: true, language: .english),
        '2 ropani 3 aana 1 paisa',
      );
      expect(
        plot.format(.ropani, long: true, language: .nepali),
        '२ रोपनी ३ आना १ पैसा',
      );
      expect(
        NepaliArea.bigha(
          1,
          dhur: 2.5,
        ).format(.bigha, long: true, language: .nepali),
        '१ बिघा २.५ धुर',
      );
      expect(
        NepaliArea.zero.format(.bigha, long: true, language: .english),
        '0 dhur',
      );
    });

    test('rounding carries', () {
      final area = NepaliArea.ropani(0, aana: 15, paisa: 3, daam: 3.999);
      expect(area.format(.ropani, language: .english), '1-0-0-0');
      expect(
        area.format(.ropani, language: .english, fractionDigits: 3),
        '0-15-3-3.999',
      );
    });

    test('negative', () {
      expect(
        NepaliArea(-1.5, .ropani).format(.ropani, language: .english),
        '-1-8-0-0',
      );
    });

    test('defaults to the current language', () {
      expect(
        NepaliUtils.withLanguage(.nepali, () => plot.format(.ropani)),
        '२-३-१-०',
      );
    });

    test('rejects bad fraction digits', () {
      expect(() => plot.format(.ropani, fractionDigits: -1), throwsRangeError);
    });
  });

  group('parse', () {
    test('ASCII and Devanagari digits', () {
      final expected = NepaliArea.ropani(2, aana: 3, paisa: 1);
      expect(NepaliArea.parse('2-3-1-0', .ropani), expected);
      expect(NepaliArea.parse('२-३-१-०', .ropani), expected);
      expect(NepaliArea.parse(' 2 - 3 - 1 ', .ropani), expected);
    });

    test('missing trailing parts are zero', () {
      expect(NepaliArea.parse('1-5', .bigha), NepaliArea.bigha(1, kattha: 5));
    });

    test('decimals', () {
      expect(
        NepaliArea.parse('1-5-2.5', .bigha),
        NepaliArea.bigha(1, kattha: 5, dhur: 2.5),
      );
    });

    test('round trips with format', () {
      final area = NepaliArea.bigha(2, kattha: 7, dhur: 13.5);
      expect(NepaliArea.parse(area.format(.bigha), .bigha), area);
    });

    test('invalid', () {
      for (final text in ['', '1-2-3-4', '1--2', 'a-1', '-1', '1e3', '1.']) {
        expect(NepaliArea.tryParse(text, .bigha), isNull, reason: text);
      }
      expect(() => NepaliArea.parse('x', .ropani), throwsFormatException);
    });
  });

  group('arithmetic and comparison', () {
    final one = NepaliArea(1, .ropani);
    final two = NepaliArea(2, .ropani);

    test('operators', () {
      expect(one + one, two);
      expect(two - one, one);
      expect(one * 2, two);
      expect(two / 2, one);
      expect(-one, NepaliArea(-1, .ropani));
    });

    test('comparison', () {
      expect(one < two, isTrue);
      expect(one <= one, isTrue);
      expect(two > one, isTrue);
      expect(two >= two, isTrue);
      expect(one.compareTo(two), lessThan(0));
      expect([two, one]..sort(), [one, two]);
    });

    test('equality', () {
      expect(NepaliArea(16, .aana), one);
      expect(NepaliArea(16, .aana).hashCode, one.hashCode);
      expect(one, isNot(two));
    });
  });

  test('labels', () {
    expect(AreaUnit.kattha.label(.english), 'kattha');
    expect(AreaUnit.kattha.label(.nepali), 'कट्ठा');
  });
}
