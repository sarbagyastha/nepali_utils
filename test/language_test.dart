import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  test('locale identifiers', () {
    expect(Language.nepali.languageCode, 'ne');
    expect(Language.nepali.localeName, 'ne_NP');
    expect(Language.nepali.toLanguageTag(), 'ne-NP');
    expect(Language.english.localeName, 'en_US');
  });

  test('tryParse accepts common locale formats', () {
    for (final locale in [
      'ne',
      'ne_NP',
      'ne-NP',
      'NE',
      'NE-np',
      'ne_Deva_NP',
    ]) {
      expect(Language.tryParse(locale), Language.nepali, reason: locale);
    }
    for (final locale in ['en', 'en_US', 'en-GB', 'EN']) {
      expect(Language.tryParse(locale), Language.english, reason: locale);
    }
    expect(Language.tryParse('hi_IN'), isNull);
    expect(Language.tryParse(''), isNull);
  });

  test('round-trips through localeName and toLanguageTag', () {
    for (final language in Language.values) {
      expect(Language.parse(language.localeName), language);
      expect(Language.parse(language.toLanguageTag()), language);
    }
  });

  test('parse and fromLocale', () {
    expect(() => Language.parse('fr'), throwsArgumentError);
    expect(Language.fromLocale('fr'), Language.english);
    expect(Language.fromLocale('fr', orElse: Language.nepali), Language.nepali);
  });

  group('NepaliUtils', () {
    tearDown(() => NepaliUtils.defaultLanguage = .english);

    test('defaultLanguage is English and settable', () {
      expect(NepaliUtils.defaultLanguage, Language.english);
      expect(NepaliUtils.currentLanguage, Language.english);
      NepaliUtils.defaultLanguage = Language.fromLocale('ne-NP');
      expect(NepaliUtils.defaultLanguage, Language.nepali);
      expect(NepaliUtils.currentLanguage, Language.nepali);
    });

    test('withLanguage overrides only inside the body', () {
      final result = NepaliUtils.withLanguage(.nepali, () {
        expect(NepaliUtils.currentLanguage, Language.nepali);
        expect(NepaliUtils.defaultLanguage, Language.english);
        return 42;
      });
      expect(result, 42);
      expect(NepaliUtils.currentLanguage, Language.english);
    });

    test('withLanguage nests', () {
      NepaliUtils.withLanguage(.nepali, () {
        NepaliUtils.withLanguage(.english, () {
          expect(NepaliUtils.currentLanguage, Language.english);
        });
        expect(NepaliUtils.currentLanguage, Language.nepali);
      });
    });

    test('withLanguage carries across async gaps', () async {
      final language = await NepaliUtils.withLanguage(.nepali, () async {
        await Future<void>.delayed(Duration.zero);
        return NepaliUtils.currentLanguage;
      });
      expect(language, Language.nepali);
      expect(NepaliUtils.currentLanguage, Language.english);
    });

    test('withLanguage wins over defaultLanguage', () {
      NepaliUtils.defaultLanguage = .nepali;
      NepaliUtils.withLanguage(.english, () {
        expect(NepaliUtils.currentLanguage, Language.english);
      });
    });
  });

  group('NepaliMoment language', () {
    final reference = DateTime.utc(2024, 1, 10);
    final date = DateTime.utc(2024, 1, 7);

    test('defaults to the current language', () {
      expect(NepaliMoment.fromAD(date, referenceDate: reference), '3 days ago');
      expect(
        NepaliUtils.withLanguage(
          .nepali,
          () => NepaliMoment.fromAD(date, referenceDate: reference),
        ),
        '३ दिन पहिले',
      );
    });

    test('accepts an explicit language', () {
      expect(
        NepaliMoment.fromAD(date, referenceDate: reference, language: .nepali),
        '३ दिन पहिले',
      );
      expect(
        NepaliMoment.fromBS(
          date.toNepaliDateTime(),
          referenceDate: reference.toNepaliDateTime(),
          language: .nepali,
        ),
        '३ दिन पहिले',
      );
    });
  });
}
