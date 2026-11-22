// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:nepali_utils/src/unicode/phonetic_engine.dart';
import 'package:nepali_utils/src/unicode/schemes/key_layout.dart';
import 'package:nepali_utils/src/unicode/schemes/phonetic_scheme.dart';

/// How `NepaliUnicode` maps Latin text to Devanagari.
enum NepaliUnicodeStyle {
  /// The phonetic rules of earlier versions of this package.
  ///
  /// A consonant takes a halant until a vowel follows, so `ram` gives राम्
  /// and `rama` gives राम; before a space the halant is dropped. `aa`/`A`
  /// gives ा, `ii`/`I` ी, `uu`/`U` ू, `E`/`ai` ै, `au` ौ; `T`, `D`, `N` and
  /// `S` give ट, ड, ण and ष, and an `h` after a consonant aspirates it
  /// (`kh` ख, `sh` श). `'` gives ं, `''` ँ, `:` ः and `.`, `|`, `/` or `\` ।.
  classic,

  /// Phonetic romanization in the style of Google Input Tools and Easy
  /// Nepali typing.
  ///
  /// A consonant at the end of a word keeps its inherent vowel
  /// (`nepaal` gives नेपाल); `~` forces a halant (`bhagawaan~` gives
  /// भगवान्). `ch` gives च, `chh` छ, `sh` श, `Sh` ष, `ksh` क्ष, `gy` ज्ञ,
  /// `ee`/`ii` ी, `oo`/`uu` ू; `M` gives ं, `^` ँ, `H` ः, `R` ृ and `.` ।.
  google,

  /// Madan Puraskar Pustakalaya's *Nepali Unicode Romanized* keyboard.
  ///
  /// Each key writes one character with no composition, e.g. `k` क,
  /// `K` ख, `a` ा, `i` ि, `/` ्, so `nepaal` is typed `nepal`.
  mppRomanized,

  /// Madan Puraskar Pustakalaya's *Nepali Unicode Traditional* keyboard,
  /// which has the same keys as the Preeti font, e.g. `g]kfn` for नेपाल.
  ///
  /// Each key writes one character or a fixed conjunct, with no
  /// composition. To read text written in the Preeti font, use `Preeti`.
  mppTraditional,
}

/// Converts Latin text into Nepali Unicode (Devanagari), and back.
///
/// ```dart
/// const unicode = NepaliUnicode();
/// unicode.convert("sayau' thu''gaa fUlakaa haamii"); // सयौं थुँगा फूलका हामी
/// unicode.convert('mero naam {Sarbagya} ho');       // मेरो नाम Sarbagya हो
/// unicode.toRoman('नेपाली');                        // nepaalii
///
/// const NepaliUnicode(style: .google).convert('nepaal ko maayaa'); // नेपाल को माया
/// const NepaliUnicode(style: .mppRomanized).convert('nepal');      // नेपाल
/// ```
///
/// For the phonetic styles ([NepaliUnicodeStyle.classic] and
/// [NepaliUnicodeStyle.google]):
///
/// * Text inside `{` and `}` is kept as it is, without the braces.
/// * Text that is already Devanagari is kept, and romanized text right
///   after it joins its last syllable, so `कमल` + `aa` gives कमला. This is
///   what makes converting a text field after every keystroke work; see
///   [convertLive].
///
/// Instances are immutable, and as a [Converter] they work with streams:
/// `stream.transform(const NepaliUnicode())`.
final class NepaliUnicode extends Converter<String, String> {
  /// Creates a converter for [style].
  ///
  /// When [nepaliDigits] is false, ASCII digits are kept.
  const new({this.style = .classic, this.nepaliDigits = true});

  /// How Latin text maps to Devanagari.
  final NepaliUnicodeStyle style;

  /// Whether ASCII digits become Devanagari digits.
  final bool nepaliDigits;

  PhoneticEngine? get _engine => switch (style) {
    .classic => PhoneticEngine(classicScheme, digits: nepaliDigits),
    .google => PhoneticEngine(googleScheme, digits: nepaliDigits),
    .mppRomanized || .mppTraditional => null,
  };

  KeyLayout get _layout =>
      style == .mppRomanized ? mppRomanized : mppTraditional;

  /// Converts [input] into Devanagari.
  @override
  String convert(String input) =>
      _engine?.convert(input) ?? _convertKeys(input);

  /// Converts [input], the content of a text field the user is typing into.
  ///
  /// Call it after every change and put the result back in the field. The
  /// word being typed keeps its halant until it is finished, a halant left
  /// before whitespace is dropped and `{}` escapes keep their braces, so
  /// letters typed later still join the right syllable. Call [convert] on
  /// the final text to remove the braces.
  ///
  /// ```dart
  /// const unicode = NepaliUnicode(style: .google);
  /// unicode.convertLive('k');      // क्
  /// unicode.convertLive('क्a');    // क
  /// unicode.convertLive('कm');     // कम्
  /// unicode.convertLive('कम् ');   // कम
  /// ```
  ///
  /// While typing in the [NepaliUnicodeStyle.google] style, a halant forced
  /// with `~` at the end of a word is dropped by the space typed after it.
  ///
  /// For the keyboard styles, this is the same as [convert].
  String convertLive(String input) =>
      _engine?.convert(input, live: true) ?? _convertKeys(input);

  /// Romanizes the Devanagari in [input], so that [convert] gives it back.
  ///
  /// The phonetic styles use the first spelling of each letter, write a
  /// separator between letters that would otherwise read as another letter
  /// (`{}` for [NepaliUnicodeStyle.classic], `~` for
  /// [NepaliUnicodeStyle.google]) and escape Latin text in `{}`. The
  /// keyboard styles give the keys to press.
  ///
  /// ```dart
  /// const NepaliUnicode(style: .google).toRoman('नेपाल'); // nepaal
  /// const NepaliUnicode().toRoman('नेपाल');               // nepaala
  /// ```
  ///
  /// Characters the style can't write, e.g. ळ in the phonetic styles, are
  /// kept as they are.
  String toRoman(String input) => _engine?.toRoman(input) ?? _keysOf(input);

  /// Converts chunks of text as they arrive.
  ///
  /// A chunk is converted up to its last whitespace outside an escape; the
  /// rest waits for the next chunk, since letters after it may still change
  /// how it converts.
  @override
  StringConversionSink startChunkedConversion(Sink<String> sink) =>
      _ChunkedConversionSink(this, sink);

  String _convertKeys(String input) {
    final layout = _layout;
    final out = StringBuffer();
    for (final unit in input.codeUnits) {
      final isDigit = unit >= 0x30 && unit <= 0x39;
      final key = isDigit && !nepaliDigits ? null : layout[unit];
      if (key == null) {
        out.writeCharCode(unit);
      } else {
        out.write(key);
      }
    }
    return out.toString();
  }

  String _keysOf(String input) {
    final reverse = _layout.reverse;
    final out = StringBuffer();
    var i = 0;
    while (i < input.length) {
      final unit = input.codeUnitAt(i);
      final isDigit = unit >= 0x0966 && unit <= 0x096F;
      final match = isDigit && !nepaliDigits ? null : reverse.match(input, i);
      if (match == null) {
        out.writeCharCode(unit);
        i++;
      } else {
        out.write(match.$2);
        i += match.$1;
      }
    }
    return out.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is NepaliUnicode &&
      other.style == style &&
      other.nepaliDigits == nepaliDigits;

  @override
  int get hashCode => Object.hash(style, nepaliDigits);

  @override
  String toString() =>
      'NepaliUnicode(style: ${style.name}, nepaliDigits: $nepaliDigits)';
}

final class _ChunkedConversionSink extends StringConversionSink {
  new(this._converter, this._sink);

  final NepaliUnicode _converter;
  final Sink<String> _sink;
  String _carry = '';

  bool get _composes =>
      _converter.style == .classic || _converter.style == .google;

  @override
  void addSlice(String chunk, int start, int end, bool isLast) {
    final text = '$_carry${chunk.substring(start, end)}';
    if (isLast) {
      _carry = '';
      if (text.isNotEmpty) _sink.add(_converter.convert(text));
      close();
      return;
    }
    if (!_composes) {
      if (text.isNotEmpty) _sink.add(_converter.convert(text));
      return;
    }
    final split = _lastSplit(text);
    _carry = text.substring(split);
    if (split > 0) _sink.add(_converter.convert(text.substring(0, split)));
  }

  /// The index after the last whitespace that isn't inside an escape.
  static int _lastSplit(String text) {
    var split = 0;
    var escaped = false;
    for (var i = 0; i < text.length; i++) {
      final unit = text.codeUnitAt(i);
      if (escaped) {
        if (unit == 0x7D) escaped = false;
      } else if (unit == 0x7B) {
        escaped = true;
      } else if (unit == 0x20 || (unit >= 0x09 && unit <= 0x0D)) {
        split = i + 1;
      }
    }
    return split;
  }

  @override
  void close() {
    if (_carry.isNotEmpty) {
      _sink.add(_converter.convert(_carry));
      _carry = '';
    }
    _sink.close();
  }
}
