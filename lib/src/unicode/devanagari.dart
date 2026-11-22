// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/nepali_digits.dart' as digits;
import 'package:nepali_utils/src/unicode/devanagari_chars.dart';

/// Helpers for text in the Devanagari script.
///
/// ```dart
/// Devanagari.isDevanagari('नमस्ते, संसार!'); // true
/// Devanagari.containsDevanagari('Hello नेपाल'); // true
/// Devanagari.toNepaliDigits('2081/01/15');   // २०८१/०१/१५
/// Devanagari.toEnglishDigits('२०८१');        // 2081
/// Devanagari.aksharas('क्षमा');              // [क्ष, मा]
/// ```
abstract final class Devanagari {
  /// Whether [text] is written in Devanagari.
  ///
  /// True when [text] has at least one Devanagari character and every other
  /// character is whitespace, punctuation (ASCII or general punctuation such
  /// as `–` or `…`) or a zero width joiner or non-joiner.
  static bool isDevanagari(String text) {
    var found = false;
    for (final unit in text.codeUnits) {
      if (isDevanagariUnit(unit)) {
        found = true;
      } else if (!_isNeutral(unit)) {
        return false;
      }
    }
    return found;
  }

  /// Whether [text] has at least one Devanagari character.
  static bool containsDevanagari(String text) =>
      text.codeUnits.any(isDevanagariUnit);

  /// Replaces ASCII digits in [text] with Devanagari digits, e.g. `2081` with
  /// `२०८१`.
  static String toNepaliDigits(String text) => digits.toNepaliDigits(text);

  /// Replaces Devanagari digits in [text] with ASCII digits, e.g. `२०८१` with
  /// `2081`.
  static String toEnglishDigits(String text) => digits.toEnglishDigits(text);

  /// Splits [text] into aksharas, the syllables Devanagari is written in.
  ///
  /// A consonant cluster stays together with its vowel sign and marks, so
  /// `क्षमा` gives `[क्ष, मा]` and `संस्कृति` gives `[सं, स्कृ, ति]`.
  /// Every other character, including spaces, is an item of its own.
  ///
  /// This is the unit to use when counting, truncating or reversing
  /// Devanagari text, since cutting inside one breaks how it renders.
  static List<String> aksharas(String text) {
    final units = text.codeUnits;
    final result = <String>[];
    var start = 0;
    while (start < units.length) {
      final end = aksharaEnd(units, start);
      result.add(text.substring(start, end));
      start = end;
    }
    return result;
  }

  static bool _isNeutral(int unit) =>
      unit == zwj ||
      unit == zwnj ||
      (unit >= 0x09 && unit <= 0x0D) ||
      (unit >= 0x20 && unit <= 0x2F) ||
      (unit >= 0x3A && unit <= 0x40) ||
      (unit >= 0x5B && unit <= 0x60) ||
      (unit >= 0x7B && unit <= 0x7E) ||
      unit == 0xA0 ||
      (unit >= 0x2000 && unit <= 0x206F) ||
      unit == 0x3000 ||
      unit == 0xFEFF;
}
