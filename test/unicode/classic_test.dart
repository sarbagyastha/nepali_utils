import 'dart:convert';
import 'dart:io';

import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  const unicode = NepaliUnicode();

  group('matches 3.x', () {
    // Outputs of the 3.x converter, with its zero width spaces removed.
    final fixture = (jsonDecode(
      File('test/fixtures/unicode_classic.json').readAsStringSync(),
    ) as Map<String, dynamic>).cast<String, String>();

    // 3.x bugs that 4.0 fixes.
    const fixed = {
      'kathamaaDau': 'कथमाडौ', // was कथयाडौ: `am` gave य
      'kamal': 'कमल्', // was कयल्
      'chhoraa': 'छोरा', // was छ्ोरा
      'chhorii': 'छोरी', // was छ्ोरी
      'gyaan': 'ज्ञान्', // was ज्ञ्ान्
    };

    for (final MapEntry(:key, :value) in fixture.entries) {
      test(key, () => expect(unicode.convert(key), fixed[key] ?? value));
    }
  });

  test('is the default style', () {
    expect(const NepaliUnicode().style, NepaliUnicodeStyle.classic);
  });

  test('never writes a zero width space', () {
    for (final text in ['sa', 'saa', 'kai', 'sayau', 'ka ma', 'am']) {
      expect(unicode.convert(text), isNot(contains('​')), reason: text);
    }
  });

  test('national anthem', () {
    expect(
      unicode.convert(
        "sayau' thu''gaa fUlakaa haamii, euTai maalaa nepaalii\n"
        'saarwabhauma bhai failiekaa, mecii-mahaakaalii',
      ),
      'सयौं थुँगा फूलका हामी, एउटै माला नेपाली\n'
      'सार्वभौम भै फैलिएका, मेची-महाकाली',
    );
  });

  group('consonants', () {
    test('keep the halant until a vowel', () {
      expect(unicode.convert('raam'), 'राम्');
      expect(unicode.convert('raama'), 'राम');
    });
    test('drop the halant before whitespace', () {
      expect(unicode.convert('raam ho'), 'राम हो');
      expect(unicode.convert('raam\nho'), 'राम\nहो');
    });
    test('keep it before punctuation', () {
      expect(unicode.convert('raam.'), 'राम्।');
    });
    test('are aspirated by h', () {
      expect(
        unicode.convert('kha gha cha jha Tha Dha tha dha pha bha'),
        'ख घ छ झ ठ ढ थ ध फ भ',
      );
      expect(unicode.convert('sha Sha'), 'श श');
      expect(unicode.convert('chha'), 'छ');
    });
    test('clusters', () {
      expect(unicode.convert('ngaa'), 'ङा');
      expect(unicode.convert('gyaana'), 'ज्ञान');
      expect(unicode.convert('xetra'), 'क्सेत्र');
      expect(unicode.convert('singha'), 'सिंह');
    });
  });

  test('vowel letters and signs', () {
    expect(
      unicode.convert('a aa A i ii I u uu U e ai E o au'),
      'अ आ आ इ ई ई उ ऊ ऊ ए ऐ ऐ ओ औ',
    );
    expect(unicode.convert('-r k-r'), 'ऋ कृ');
    expect(unicode.convert("ma'gala aa''khaa du:kha"), 'मंगल आँखा दुःख');
    expect(unicode.convert('om'), 'ॐ');
    expect(unicode.convert('kom'), 'कोम्');
  });

  test('dandas', () {
    expect(unicode.convert(r'ho. ho| ho/ ho\'), 'हो। हो। हो। हो।');
    expect(unicode.convert('ho.. ho|| ho./'), 'हो॥ हो॥ हो॥');
  });

  group('toRoman', () {
    test('spells words', () {
      expect(unicode.toRoman('नेपाल'), 'nepaala');
      expect(unicode.toRoman('राम्'), 'raam');
      expect(unicode.toRoman('राम हो'), 'raam ho');
      expect(unicode.toRoman('सिंह'), "si'ha");
    });
    test('separates letters that would merge', () {
      expect(unicode.toRoman('भाग्य'), 'bhaag{}ya');
      expect(unicode.toRoman('कइ'), 'ka{}i');
    });
  });
}
