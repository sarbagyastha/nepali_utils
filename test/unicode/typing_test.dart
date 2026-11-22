import 'dart:async';
import 'dart:math';

import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

/// Converts [roman] the way a text field does: one keystroke at a time,
/// converting the whole field after each.
String type(NepaliUnicode unicode, String roman) {
  var field = '';
  for (final key in roman.split('')) {
    field = unicode.convertLive('$field$key');
  }
  return field;
}

void main() {
  const phrases = {
    NepaliUnicodeStyle.classic: [
      'nepaalii',
      'mero naam raama ho',
      "sayau' thu''gaa fUlakaa haamii",
      'kathamaaDau',
      'kharaayo',
      'chhoraa ra chhorii',
      'gyaana',
      'bhaashaa.',
      'shrii',
      'ho||',
      'mero {email} ho',
      '2081 saala',
    ],
    NepaliUnicodeStyle.google: [
      'nepaalii',
      'mero naam raam ho',
      'kamal ko phuul',
      'kathamaaDau',
      'chhoraa ra chhorii',
      'kshatriya',
      'gyaan',
      'shrii',
      'shhaTkon',
      'kRpaa',
      'saMsaar chaa^d',
      'ho..',
      'mero {email} ho',
      '2081 saal',
    ],
  };

  for (final MapEntry(key: style, value: list) in phrases.entries) {
    final unicode = NepaliUnicode(style: style);
    group('${style.name} typing', () {
      for (final phrase in list) {
        test(phrase, () {
          // The live field keeps the braces of escapes, and the last word
          // keeps its halant until a space finishes it.
          expect(
            unicode.convert(type(unicode, '$phrase ')),
            unicode.convert('$phrase '),
          );
        });
      }
    });
  }

  test('convertLive keeps the halant of the word being typed', () {
    const google = NepaliUnicode(style: .google);
    expect(google.convertLive('k'), 'क्');
    expect(google.convertLive('क्a'), 'क');
    expect(google.convertLive('कm'), 'कम्');
    expect(google.convertLive('कम् '), 'कम ');
    expect(google.convertLive('{abc} x'), '{abc} क्ष्');
  });

  group('chunked conversion', () {
    final random = Random(42);
    for (final style in NepaliUnicodeStyle.values) {
      test(style.name, () async {
        final unicode = NepaliUnicode(style: style);
        const text =
            "mero naam {Sarbagya Dhaubanjar} ho. sayau' thu''gaa "
            'fUlakaa haamii\nkamal ko phuul 2081 ho|| g]kfn';
        for (var round = 0; round < 50; round++) {
          final chunks = <String>[];
          var i = 0;
          while (i < text.length) {
            final end = min(text.length, i + 1 + random.nextInt(8));
            chunks.add(text.substring(i, end));
            i = end;
          }
          final result = await Stream.fromIterable(chunks)
              .transform(unicode)
              .join();
          expect(result, unicode.convert(text), reason: '$chunks');
        }
      });
    }
  });
}
