import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  final decimal = NepaliNumberFormat.decimalPattern(.english);

  group('parse', () {
    test('returns int for integral values', () {
      final value = decimal.parse('1,23,456');
      expect(value, 123456);
      expect(value, isA<int>());
    });
    test('returns double for fractions', () {
      final value = decimal.parse('1,234.5');
      expect(value, 1234.5);
      expect(value, isA<double>());
    });
    test(
      'Devanagari digits',
      () => expect(decimal.parse('१२,३४,५६७.८९'), 1234567.89),
    );
    test('signs', () {
      expect(decimal.parse('-1,234'), -1234);
      expect(decimal.parse('−१२३'), -123);
      expect(decimal.parse('+5'), 5);
    });
    test(
      'grouping in any position',
      () => expect(decimal.parse('1,234,567'), 1234567),
    );
    test('negative subpattern', () {
      expect(NepaliNumberFormat('#,##0;(#,##0)').parse('(1,234)'), -1234);
    });
    test('percent', () {
      expect(NepaliNumberFormat.percentPattern().parse('12%'), 0.12);
      expect(NepaliNumberFormat('0‰').parse('12‰'), 0.012);
    });
    test('currency, with or without the symbol', () {
      final currency = NepaliNumberFormat.simpleCurrency(language: .nepali);
      expect(currency.parse('रु. १,२३,४५६.५०'), 123456.5);
      expect(currency.parse('-रु. १२'), -12);
      expect(currency.parse('१२३'), 123);
    });
    test('compact', () {
      expect(NepaliNumberFormat.compact().parse('1.23L'), 123000);
      expect(NepaliNumberFormat.compact().parse('12.3k'), 12300);
      expect(
        NepaliNumberFormat.compactLong(language: .nepali).parse('१२.३ करोड'),
        123000000,
      );
      expect(
        NepaliNumberFormat.compact(explicitSign: true).parse('+1.5K'),
        1500,
      );
    });
    test('NaN and infinity', () {
      expect(decimal.parse('NaN'), isNaN);
      expect(decimal.parse('∞'), double.infinity);
      expect(decimal.parse('-∞'), double.negativeInfinity);
    });
    test('big integers become doubles', () {
      expect(decimal.parse('1,00,00,00,00,00,00,00,00,00,000'), 1e21);
    });
  });

  group('invalid input', () {
    for (final input in ['', 'abc', '1,2a', '1.2.3', ',123', '123,', '--1']) {
      test('"$input"', () {
        expect(decimal.tryParse(input), isNull);
        expect(() => decimal.parse(input), throwsFormatException);
      });
    }
    test(
      'currency symbol is not accepted by decimal format',
      () => expect(decimal.tryParse('Rs. 12'), isNull),
    );
  });

  group('round trip', () {
    const values = <num>[0, 7, -7, 1234, -98765.4, 123456789.25, 0.125];
    for (final language in Language.values) {
      final formats = {
        'decimalPattern': NepaliNumberFormat.decimalPattern(language),
        'decimalPatternDigits': NepaliNumberFormat.decimalPatternDigits(
          language: language,
          decimalDigits: 3,
        ),
        'decimalPercentPattern': NepaliNumberFormat.decimalPercentPattern(
          language: language,
          decimalDigits: 1,
        ),
        'currency': NepaliNumberFormat.currency(
          language: language,
          decimalDigits: 3,
        ),
        'simpleCurrency': NepaliNumberFormat.simpleCurrency(
          language: language,
          decimalDigits: 3,
        ),
        'international': NepaliNumberFormat('#,##0.###', language),
      };
      for (final MapEntry(key: name, value: format) in formats.entries) {
        test('$name in ${language.name}', () {
          for (final value in values) {
            expect(
              format.parse(format.format(value)),
              closeTo(value, 1e-9),
              reason: format.format(value),
            );
          }
        });
      }
    }
  });
}
