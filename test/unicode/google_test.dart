import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  const unicode = NepaliUnicode(style: .google);

  test('words keep their inherent vowel at the end', () {
    expect(unicode.convert('nepaal'), 'नेपाल');
    expect(unicode.convert('nepaal ko maayaa'), 'नेपाल को माया');
    expect(unicode.convert('kamal.'), 'कमल।');
  });

  test('~ forces a halant', () {
    expect(unicode.convert('bhagawaan~'), 'भगवान्');
    expect(unicode.convert('bhaag~ya'), 'भाग्य');
  });

  test('consonants', () {
    expect(
      unicode.convert('ka kha ga gha ng cha chha ja jha nya'),
      'क ख ग घ ङ च छ ज झ ञ',
    );
    expect(
      unicode.convert('Ta Tha Da Dha Na ta tha da dha na'),
      'ट ठ ड ढ ण त थ द ध न',
    );
    expect(
      unicode.convert('pa pha fa ba bha ma ya ra la wa va'),
      'प फ फ ब भ म य र ल व व',
    );
    expect(unicode.convert('sha Sha shha sa ha'), 'श ष ष स ह');
  });

  test('conjuncts', () {
    expect(unicode.convert('kshatriya'), 'क्षत्रिय');
    expect(unicode.convert('xamaa'), 'क्षमा');
    expect(unicode.convert('gyaan'), 'ज्ञान');
    expect(unicode.convert('shrii'), 'श्री');
    expect(unicode.convert('buddha'), 'बुद्ध');
    expect(unicode.convert('vidyaalaya'), 'विद्यालय');
    expect(unicode.convert('trishuul'), 'त्रिशूल');
  });

  test('vowels', () {
    expect(
      unicode.convert('a aa A i ii ee I u uu oo U e ai o au ou R'),
      'अ आ आ इ ई ई ई उ ऊ ऊ ऊ ए ऐ ओ औ औ ऋ',
    );
    expect(
      unicode.convert('kii kee kuu koo kai kau kRpaa'),
      'की की कू कू कै कौ कृपा',
    );
  });

  test('signs and symbols', () {
    expect(unicode.convert('saMsaar chaa^d duHkha'), 'संसार चाँद दुःख');
    expect(unicode.convert('OM namaH'), 'ॐ नमः');
    expect(unicode.convert('ho. ho| ho.. ho||'), 'हो। हो। हो॥ हो॥');
  });

  test('digits', () {
    expect(unicode.convert('2081 saal'), '२०८१ साल');
    expect(
      const NepaliUnicode(
        style: .google,
        nepaliDigits: false,
      ).convert('2081 saal'),
      '2081 साल',
    );
  });

  group('escapes', () {
    test('keep text as it is', () {
      expect(
        unicode.convert('mero naam {Sarbagya} ho'),
        'मेरो नाम Sarbagya हो',
      );
      expect(unicode.convert('{a}{b}'), 'ab');
    });
    test('an unmatched brace keeps the rest', () {
      expect(unicode.convert('mero {email ho'), 'मेरो email ho');
    });
    test('a word before an escape keeps its vowel', () {
      expect(unicode.convert('kamal{!}'), 'कमल!');
    });
  });

  test('keeps Devanagari and other text', () {
    expect(unicode.convert('नेपाल, 🇳🇵!'), 'नेपाल, 🇳🇵!');
  });

  test('joins Devanagari followed by romanized text', () {
    expect(unicode.convert('कमलa'), 'कमला');
    expect(unicode.convert('कh'), 'कह');
    expect(unicode.convert('क्h'), 'ख');
    expect(unicode.convert('नेपा{l}'), 'नेपाl');
  });

  group('toRoman', () {
    test('spells words', () {
      expect(unicode.toRoman('नेपाल'), 'nepaal');
      expect(unicode.toRoman('क्षत्रिय'), 'kshatriy');
      expect(unicode.toRoman('ज्ञान'), 'gyaan');
      expect(unicode.toRoman('भगवान्'), 'bhagawaan~');
      expect(unicode.toRoman('ॐ नमः।'), 'OM namH.');
    });
    test('separates letters that would merge', () {
      expect(unicode.toRoman('भाग्य'), 'bhaag~y');
      expect(unicode.toRoman('कइ'), 'ka~i');
    });
    test('escapes Latin text', () {
      expect(unicode.toRoman('मेरो email हो'), 'mero {email} ho');
      expect(unicode.toRoman('२०८१ 2081'), '2081 {2081}');
    });
    test('keeps what it cannot write', () {
      expect(unicode.toRoman('ळ'), 'ळ');
    });
  });
}
