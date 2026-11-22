import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  final decimal = NepaliNumberFormat.decimalPattern(.english);
  final nepali = NepaliNumberFormat.decimalPattern(.nepali);

  group('input types', () {
    test('int', () => expect(decimal.format(12345), '12,345'));
    test('double', () => expect(decimal.format(12345.05), '12,345.05'));
    test('String', () => expect(decimal.format('12345.05'), '12,345.05'));
    test(
      'BigInt beyond 64 bits',
      () => expect(
        decimal.format(BigInt.parse('123456789012345678901')),
        '12,34,56,78,90,12,34,56,78,901',
      ),
    );
    test(
      'String keeps every digit',
      () => expect(
        NepaliNumberFormat.decimalPatternDigits(
          language: .english,
          decimalDigits: 2,
        ).format('12345678901234567890.125'),
        '1,23,45,67,89,01,23,45,67,890.13',
      ),
    );
    test('scientific doubles', () {
      expect(decimal.format(1e21), '1,00,00,00,00,00,00,00,00,00,000');
      expect(
        decimal.copyWith(maximumFractionDigits: 10).format(1.5e-7),
        '0.00000015',
      );
    });
    test('NaN and infinity', () {
      expect(decimal.format(double.nan), 'NaN');
      expect(decimal.format(double.infinity), '∞');
      expect(decimal.format(double.negativeInfinity), '-∞');
    });
    test(
      'throws on bool',
      () => expect(() => decimal.format(true), throwsArgumentError),
    );
    test(
      'throws on non-numeric String',
      () => expect(() => decimal.format('12a'), throwsArgumentError),
    );
  });

  group('language', () {
    test('Devanagari digits', () => expect(nepali.format(1234), '१,२३४'));
    test(
      'follows NepaliUtils.currentLanguage',
      () => expect(
        NepaliUtils.withLanguage(
          .nepali,
          () => NepaliNumberFormat().format(1234),
        ),
        '१,२३४',
      ),
    );
  });

  group('grouping', () {
    test('Nepali 3-2-2 by default', () {
      expect(decimal.format(123), '123');
      expect(decimal.format(1234), '1,234');
      expect(decimal.format(123456), '1,23,456');
      expect(decimal.format(123456789), '12,34,56,789');
    });
    test(
      'international 3-3 with #,##0',
      () => expect(
        NepaliNumberFormat('#,##0.##', .english).format(1234567.891),
        '1,234,567.89',
      ),
    );
    test(
      'no grouping without a comma',
      () =>
          expect(NepaliNumberFormat('0', .english).format(1234567), '1234567'),
    );
    test('custom separator', () {
      expect(decimal.copyWith(groupSeparator: '').format(1234), '1234');
      expect(decimal.copyWith(groupSeparator: '.').format(1234), '1.234');
      expect(nepali.copyWith(groupSeparator: ' ').format(123456), '१ २३ ४५६');
    });
  });

  group('negative numbers', () {
    test('decimal', () => expect(decimal.format(-1234.5), '-1,234.5'));
    test(
      'currency',
      () => expect(
        NepaliNumberFormat.simpleCurrency(language: .english).format(-12),
        '-Rs. 12.00',
      ),
    );
    test(
      'negative subpattern',
      () => expect(
        NepaliNumberFormat('#,##0.00;(#,##0.00)', .english).format(-1234.5),
        '(1,234.50)',
      ),
    );
    test(
      'rounding to zero drops the sign',
      () => expect(decimal.format(-0.0001), '0'),
    );
  });

  group('rounding', () {
    test('rounds instead of truncating', () {
      expect(decimal.format(2.9999), '3');
      expect(
        NepaliNumberFormat.decimalPatternDigits(
          language: .english,
          decimalDigits: 2,
        ).format(2.999),
        '3.00',
      );
    });
    test(
      'rounds doubles as written',
      () => expect(
        NepaliNumberFormat.decimalPatternDigits(
          language: .english,
          decimalDigits: 2,
        ).format(1.005),
        '1.01',
      ),
    );
    test('half away from zero', () {
      final format = NepaliNumberFormat('0', .english);
      expect(format.format(2.5), '3');
      expect(format.format(-2.5), '-3');
    });
    test('significant digits', () {
      final format = decimal.copyWith(
        minimumSignificantDigits: 3,
        maximumSignificantDigits: 3,
      );
      expect(format.format(123456), '1,23,000');
      expect(format.format(1.5), '1.50');
      expect(format.format(0.0012345), '0.00123');
      expect(format.significantDigitsInUse, isTrue);
    });
  });

  group('digits', () {
    test('decimalPattern shows up to 3 fraction digits', () {
      expect(decimal.format(1234), '1,234');
      expect(decimal.format(1234.5), '1,234.5');
      expect(decimal.format(1234.56789), '1,234.568');
    });
    test(
      'decimalPatternDigits',
      () => expect(
        NepaliNumberFormat.decimalPatternDigits(
          language: .english,
          decimalDigits: 4,
        ).format(1234),
        '1,234.0000',
      ),
    );
    test(
      'minimumIntegerDigits',
      () => expect(decimal.copyWith(minimumIntegerDigits: 3).format(5), '005'),
    );
    test('includeDecimalIfZero', () {
      final format = NepaliNumberFormat.simpleCurrency(language: .english)
          .copyWith(includeDecimalIfZero: false);
      expect(format.format(2), 'Rs. 2');
      expect(format.format(2.5), 'Rs. 2.50');
    });
    test('copyWith keeps min <= max', () {
      final raised = decimal.copyWith(minimumFractionDigits: 5);
      expect(raised.maximumFractionDigits, 5);
      final lowered = NepaliNumberFormat.currency(language: .english)
          .copyWith(maximumFractionDigits: 0);
      expect(lowered.minimumFractionDigits, 0);
      expect(lowered.format(12.5), 'NPR 13');
    });
    test('decimalDigits', () {
      expect(decimal.decimalDigits, isNull);
      expect(NepaliNumberFormat.currency().decimalDigits, 2);
    });
  });

  group('percent', () {
    test(
      'percentPattern',
      () => expect(
        NepaliNumberFormat.percentPattern(.english).format(0.1234),
        '12%',
      ),
    );
    test(
      'decimalPercentPattern',
      () => expect(
        NepaliNumberFormat.decimalPercentPattern(
          language: .nepali,
          decimalDigits: 2,
        ).format(0.12345),
        '१२.३५%',
      ),
    );
    test(
      'per mille',
      () => expect(NepaliNumberFormat('0‰', .english).format(0.012), '12‰'),
    );
  });

  group('currency', () {
    test('currency shows the code', () {
      expect(
        NepaliNumberFormat.currency(language: .english).format(123456),
        'NPR 1,23,456.00',
      );
      expect(
        NepaliNumberFormat.currency(language: .nepali).format(123456),
        'NPR १,२३,४५६.००',
      );
    });
    test('simpleCurrency shows the symbol', () {
      expect(
        NepaliNumberFormat.simpleCurrency(language: .english).format(123456),
        'Rs. 1,23,456.00',
      );
      expect(
        NepaliNumberFormat.simpleCurrency(language: .nepali).format(123456),
        'रु. १,२३,४५६.००',
      );
    });
    test(
      'custom symbol',
      () => expect(
        NepaliNumberFormat.currency(
          language: .english,
          symbol: 'Rs.',
          decimalDigits: 0,
        ).format(1234),
        'Rs. 1,234',
      ),
    );
    test('symbol on the right without a space', () {
      expect(
        NepaliNumberFormat.currency(
          language: .english,
          symbol: ' rupees',
          customPattern: '#,##,##0¤',
        ).format(1234),
        '1,234 rupees',
      );
      expect(
        NepaliNumberFormat.currency(
          language: .english,
          symbol: 'Rs.',
          customPattern: '¤#,##,##0',
        ).format(123456),
        'Rs.1,23,456',
      );
    });
    test(
      'quoted literals',
      () => expect(
        NepaliNumberFormat("'Rs' #,##0.00", .english).format(5),
        'Rs 5.00',
      ),
    );
  });

  group('compact', () {
    final short = NepaliNumberFormat.compact(language: .english);
    final long = NepaliNumberFormat.compactLong(language: .english);

    test('short', () {
      expect(short.format(999), '999');
      expect(short.format(1000), '1K');
      expect(short.format(1234), '1.23K');
      expect(short.format(12345), '12.3K');
      expect(short.format(123456), '1.23L');
      expect(short.format(12345678), '1.23Cr');
      expect(short.format(1234567890), '1.23Arab');
      expect(short.format(123456789012), '1.23Kharab');
      expect(short.format(-2500000), '-25L');
    });
    test('rounding moves to the next place value', () {
      expect(short.format(99999), '1L');
      expect(short.format(999.9), '1K');
    });
    test(
      'digits before the decimal point are kept',
      () => expect(short.format(1.2345e16), '1,23,450Kharab'),
    );
    test('long', () {
      expect(long.format(1234), '1.23 thousand');
      expect(long.format(1e7), '1 crore');
    });
    test('Nepali', () {
      expect(
        NepaliNumberFormat.compact(language: .nepali).format(1234567),
        '१२.३ लाख',
      );
      expect(
        NepaliNumberFormat.compactLong(language: .nepali).format(1234567),
        '१२.३ लाख',
      );
    });
    test(
      'explicit sign',
      () => expect(
        NepaliNumberFormat.compact(
          language: .english,
          explicitSign: true,
        ).format(1234),
        '+1.23K',
      ),
    );
    test('currency', () {
      expect(
        NepaliNumberFormat.compactSimpleCurrency(language: .english)
            .format(1234567),
        'Rs. 12.3L',
      );
      expect(
        NepaliNumberFormat.compactCurrency(language: .nepali).format(1234567),
        'NPR १२.३ लाख',
      );
    });
  });

  test('throws FormatException on a malformed pattern', () {
    expect(() => NepaliNumberFormat('abc'), throwsFormatException);
    expect(() => NepaliNumberFormat("'0"), throwsFormatException);
    expect(() => NepaliNumberFormat('0;0;0'), throwsFormatException);
  });
}
