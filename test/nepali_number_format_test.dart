import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  group('supports formatting num and String types:', () {
    test('integer', () => expect(_format(12345), '12,345'));
    test('double', () => expect(_format(12345.05), '12,345.05'));
    test('String', () => expect(_format('12345.05'), '12,345.05'));

    test(
      'throws error on bool',
      () => expect(() => _format(true), throwsArgumentError),
    );
  });

  group('language tests:', () {
    test(
      'default is english',
      () => expect(NepaliNumberFormat().format(1234), '1,234'),
    );
    test(
      'formats in nepali',
      () => expect(
        NepaliNumberFormat(language: Language.nepali).format(1234),
        '१,२३४',
      ),
    );
  });

  group('decimal digit tests:', () {
    test(
      'default is 0 for integer input',
      () => expect(NepaliNumberFormat().format(1234), '1,234'),
    );

    test(
      'default is 2 for input type other than integer',
      () => expect(NepaliNumberFormat().format('1234'), '1,234.00'),
    );

    test(
      'formats decimal digits as per the decimalDigits value',
      () => expect(
        NepaliNumberFormat(decimalDigits: 4).format(1234),
        '1,234.0000',
      ),
    );
  });

  group('monetary format tests:', () {
    test('symbol is only visible when isMonetory is true', () {
      expect(
        NepaliNumberFormat(
          isMonetory: true,
          symbol: 'Rs.',
        ).format(1234),
        'Rs. 1,234',
      );
      expect(
        NepaliNumberFormat(symbol: 'Rs.').format(1234),
        '1,234',
      );
    });

    test('symbol will always be on right if symbolOnLeft is false', () {
      expect(
        NepaliNumberFormat(
          isMonetory: true,
          symbol: 'rupees',
          symbolOnLeft: false,
        ).format(1234),
        '1,234 rupees',
      );
      expect(
        NepaliNumberFormat(
          isMonetory: true,
          symbol: 'rupees',
        ).format(1234),
        'rupees 1,234',
      );
    });

    test('spacing between symbol and amount', () {
      expect(
        NepaliNumberFormat(
          isMonetory: true,
          symbol: 'Rs.',
          spaceBetweenAmountAndSymbol: false,
        ).format(123456),
        'Rs.1,23,456',
      );
      expect(
        NepaliNumberFormat(
          isMonetory: true,
          symbol: 'Rs.',
        ).format(123456),
        'Rs. 1,23,456',
      );
    });
  });

  group('Formats in word tests:', () {
    test(
      'english language',
      () => expect(
        NepaliNumberFormat(
          language: Language.english,
          inWords: true,
        ).format(123456),
        '1 lakh 23 thousand 4 hundred 56',
      ),
    );

    test(
      'nepali language',
      () => expect(
        NepaliNumberFormat(
          isMonetory: true,
          language: Language.nepali,
          inWords: true,
        ).format(123456789.6548),
        '१२ करोड ३४ लाख ५६ हजार ७ सय ८९ रुपैया ६५ पैसा',
      ),
    );
  });

  group('delimiter default tests:', () {
    test(
      'in english',
      () => expect(NepaliNumberFormat().format(1234), '1,234'),
    );
    test(
      'in nepali',
      () => expect(
        NepaliNumberFormat(language: Language.nepali).format(1234),
        '१,२३४',
      ),
    );
  });

  group('delimiter tests:', () {
    test(
      'using empty delimiter in English',
      () => expect(NepaliNumberFormat(delimiter: '').format(1234), '1234'),
    );
    test(
      'using empty delimiter in English',
      () => expect(
        NepaliNumberFormat(language: Language.nepali, delimiter: '')
            .format(1234),
        '१२३४',
      ),
    );
    test(
      'using . delimiter in English',
      () => expect(NepaliNumberFormat(delimiter: '.').format(1234), '1.234'),
    );
    test(
      'using . delimiter in Nepali',
      () => expect(
        NepaliNumberFormat(language: Language.nepali, delimiter: '.')
            .format(1234),
        '१.२३४',
      ),
    );
  });
}

String _format(Object number) => NepaliNumberFormat().format(number);
