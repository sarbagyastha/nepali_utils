import 'dart:io';

import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  final words = File('test/fixtures/nepali_words.txt')
      .readAsLinesSync()
      .where((line) => line.isNotEmpty)
      .toList();
  final sentence = words.join(' ');

  for (final style in NepaliUnicodeStyle.values) {
    final unicode = NepaliUnicode(style: style);
    group(style.name, () {
      test('convert(toRoman(word)) is the word', () {
        for (final word in words) {
          final roman = unicode.toRoman(word);
          expect(unicode.convert(roman), word, reason: '$word → $roman');
        }
      });
      test('works on running text', () {
        expect(unicode.convert(unicode.toRoman(sentence)), sentence);
      });
    });
  }
}
