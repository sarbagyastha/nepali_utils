import 'dart:io';

import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  const pairs = {
    'g]kfn': 'नेपाल',
    'sf&df*f}+': 'काठमाडौं',
    'lxdfn': 'हिमाल',
    'ljBfno': 'विद्यालय',
    'sfof{no': 'कार्यालय',
    'kfj{tL': 'पार्वती',
    'k|wfgdGqL': 'प्रधानमन्त्री',
    'zld{nf': 'शर्मिला',
    'Ifdf': 'क्षमा',
    'Iff': 'क्षा',
    '!fg': 'ज्ञान',
    'cfdf': 'आमा',
    'cf]v': 'ओख',
    'cf}ifwL': 'औषधी',
    'P]gf': 'ऐना',
    '@Zj/': 'ईश्वर',
    'pmg': 'ऊन',
    "km'n": 'फुल',
    "em'nf": 'झुला',
    'u"F': 'गूँ',
    "b'mv": 'दुःख',
    "/fd'": 'रामु',
    '?k': 'रुप',
    'gd:t]': 'नमस्ते',
    'l:y/': 'स्थिर',
    'k|ltz': 'प्रतिश',
    '2081': '२०८१',
    '@)*! . ': 'ईणडज्ञ । ',
    '-sf7df8f}+_': '(का७मा८ौं)',
  };

  group('toUnicode', () {
    for (final MapEntry(:key, :value) in pairs.entries) {
      test(key, () => expect(Preeti.toUnicode(key), value));
    }
  });

  group('fromUnicode', () {
    const known = {
      'नेपाल': 'g]kfn',
      'कार्यालय': 'sfof{no',
      'पार्वती': 'kfj{tL',
      'हिमाल': 'lxdfn',
      'शर्मिला': 'zld{nf',
      'प्रधानमन्त्री': 'k|wfgdGqL',
      'क्षमा': 'Ifdf',
      'काठमाडौं': 'sf&df*f}+',
      'स्थिर': 'l:y/',
      '२०८१।': '2081.',
    };
    for (final MapEntry(:key, :value) in known.entries) {
      test(key, () => expect(Preeti.fromUnicode(key), value));
    }
  });

  test('Unicode survives a round trip', () {
    final words = File('test/fixtures/nepali_words.txt')
        .readAsLinesSync()
        .where((line) => line.isNotEmpty);
    for (final word in words) {
      final preeti = Preeti.fromUnicode(word);
      expect(Preeti.toUnicode(preeti), word, reason: '$word → $preeti');
    }
  });

  test('keeps characters the font does not draw', () {
    expect(Preeti.toUnicode('g]kfn, 🇳🇵'), 'नेपाल, 🇳🇵');
  });
}
