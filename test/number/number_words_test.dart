import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  final english = NepaliNumberFormat.words(language: .english);
  final nepali = NepaliNumberFormat.words(language: .nepali);

  group('English', () {
    test('below hundred', () {
      expect(english.format(0), 'zero');
      expect(english.format(7), 'seven');
      expect(english.format(19), 'nineteen');
      expect(english.format(20), 'twenty');
      expect(english.format(56), 'fifty-six');
      expect(english.format(99), 'ninety-nine');
    });
    test('skips zero groups', () {
      expect(english.format(105), 'one hundred five');
      expect(english.format(100000), 'one lakh');
      expect(english.format(10000001), 'one crore one');
    });
    test(
      'place values',
      () => expect(
        english.format(123456),
        'one lakh twenty-three thousand four hundred fifty-six',
      ),
    );
    test(
      'beyond sankha',
      () => expect(
        english.format(BigInt.parse('1200000000000000000')),
        'twelve sankha',
      ),
    );
    test(
      'large counts of sankha',
      () => expect(
        english.format(BigInt.parse('100000000000000000000')),
        'one thousand sankha',
      ),
    );
    test('negative and fraction', () {
      expect(english.format(-12.05), 'minus twelve point zero five');
      expect(english.format(0.5), 'zero point five');
    });
    test('currency', () {
      final currency = NepaliNumberFormat.words(
        language: .english,
        currency: true,
      );
      expect(
        currency.format(123.45),
        'one hundred twenty-three rupees forty-five paisa',
      );
      expect(currency.format(0.5), 'fifty paisa');
      expect(currency.format(0), 'zero rupees');
      expect(currency.format(10), 'ten rupees');
      expect(currency.format(1.999), 'two rupees');
    });
    test(
      'useDigits',
      () => expect(
        NepaliNumberFormat.words(
          language: .english,
          useDigits: true,
        ).format(123456),
        '1 lakh 23 thousand 4 hundred 56',
      ),
    );
  });

  group('Nepali', () {
    test('below hundred', () {
      expect(nepali.format(0), 'शून्य');
      expect(nepali.format(23), 'तेइस');
      expect(nepali.format(56), 'छपन्न');
      expect(nepali.format(99), 'उनान्सय');
    });
    test(
      'place values',
      () => expect(nepali.format(123456), 'एक लाख तेइस हजार चार सय छपन्न'),
    );
    test(
      'negative and fraction',
      () => expect(nepali.format(-1.25), 'ऋण एक दशमलव दुई पाँच'),
    );
    test(
      'currency',
      () => expect(
        NepaliNumberFormat.words(
          language: .nepali,
          currency: true,
        ).format(123456789.6548),
        'बाह्र करोड चौंतीस लाख छपन्न हजार सात सय उनान्नब्बे रुपैयाँ '
        'पैंसट्ठी पैसा',
      ),
    );
    test(
      'currency with digits',
      () => expect(
        NepaliNumberFormat.words(
          language: .nepali,
          currency: true,
          useDigits: true,
        ).format(123456789.6548),
        '१२ करोड ३४ लाख ५६ हजार ७ सय ८९ रुपैयाँ ६५ पैसा',
      ),
    );
  });

  test('throws on NaN', () {
    expect(() => english.format(double.nan), throwsArgumentError);
  });

  test('parse is unsupported', () {
    expect(() => english.parse('one'), throwsUnsupportedError);
  });
}
