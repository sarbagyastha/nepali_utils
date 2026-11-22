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

  test('NepaliUtils.fromLocale', () {
    addTearDown(() => NepaliUtils(Language.english));
    expect(NepaliUtils.fromLocale('ne-NP').language, Language.nepali);
    expect(NepaliUtils.fromLocale('fr').language, Language.nepali);
    expect(NepaliUtils.fromLocale('en').language, Language.english);
  });
}
