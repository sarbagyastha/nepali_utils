// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/unicode/token_trie.dart';

/// A keyboard layout where each key writes fixed text, with no composition.
final class KeyLayout {
  /// Compiles [keys], a map of single ASCII characters to their output.
  factory(Map<String, String> keys) {
    final table = List<String?>.filled(128, null);
    final reverse = TokenTrie<String>();
    for (final MapEntry(:key, :value) in keys.entries) {
      table[key.codeUnitAt(0)] = value;
      reverse.add(value, key);
    }
    return ._(table, reverse);
  }

  new _(this._table, this.reverse);

  final List<String?> _table;

  /// Output text → the key that types it.
  final TokenTrie<String> reverse;

  /// The output of the key [unit], or `null` if the key isn't mapped.
  String? operator [](int unit) => unit < 128 ? _table[unit] : null;
}

/// Madan Puraskar Pustakalaya's *Nepali Unicode Romanized* layout.
///
/// Keys from nepalify (ISC license, © 2020 Suvash Thapaliya).
final KeyLayout mppRomanized = .new({
  'a': 'ा', 'b': 'ब', 'c': 'छ', 'd': 'द', 'e': 'े', 'f': 'उ', 'g': 'ग', //
  'h': 'ह', 'i': 'ि', 'j': 'ज', 'k': 'क', 'l': 'ल', 'm': 'म', 'n': 'न',
  'o': 'ो', 'p': 'प', 'q': 'ट', 'r': 'र', 's': 'स', 't': 'त', 'u': 'ु',
  'v': 'व', 'w': 'ौ', 'x': 'ड', 'y': 'य', 'z': 'ष',
  'A': 'आ', 'B': 'भ', 'C': 'च', 'D': 'ध', 'E': 'ै', 'F': 'ऊ', 'G': 'घ',
  'H': 'अ', 'I': 'ी', 'J': 'झ', 'K': 'ख', 'L': 'ळ', 'M': 'ं', 'N': 'ण',
  'O': 'ओ', 'P': 'फ', 'Q': 'ठ', 'R': 'ृ', 'S': 'श', 'T': 'थ', 'U': 'ू',
  'V': 'ँ', 'W': 'औ', 'X': 'ढ', 'Y': 'ञ', 'Z': 'ऋ',
  ..._digits,
  '`': 'ऽ', '~': '़', '_': '॒', '+': '‌', '=': '‍',
  '[': 'इ', '{': 'ई', ']': 'ए', '}': 'ऐ', r'\': 'ॐ', '|': 'ः', '<': 'ङ',
  '.': '।', '>': '॥', '/': '्',
});

/// Madan Puraskar Pustakalaya's *Nepali Unicode Traditional* layout.
///
/// Keys from nepalify (ISC license, © 2020 Suvash Thapaliya).
final KeyLayout mppTraditional = .new({
  'a': 'ब', 'b': 'द', 'c': 'अ', 'd': 'म', 'e': 'भ', 'f': 'ा', 'g': 'न', //
  'h': 'ज', 'i': 'ष', 'j': 'व', 'k': 'प', 'l': 'ि', 'm': 'ः', 'n': 'ल',
  'o': 'य', 'p': 'उ', 'q': 'त्र', 'r': 'च', 's': 'क', 't': 'त', 'u': 'ग',
  'v': 'ख', 'w': 'ध', 'x': 'ह', 'y': 'थ', 'z': 'श',
  'A': 'आ', 'B': 'ौ', 'C': 'ऋ', 'D': 'ङ्ग', 'E': 'ऐ', 'F': 'ँ', 'G': 'द्द',
  'H': 'झ', 'I': 'क्ष', 'J': 'ो', 'K': 'फ', 'L': 'ी', 'M': 'ड्ड', 'N': 'द्य',
  'O': 'इ', 'P': 'ए', 'Q': 'त्त', 'R': 'द्व', 'S': 'ङ्क', 'T': 'ट्ट', 'U': 'ऊ',
  'V': 'ॐ', 'W': 'ड्ढ', 'X': 'ह्य', 'Y': 'ठ्ठ', 'Z': 'क्क',
  ..._digits,
  '!': 'ज्ञ', '@': 'ई', '#': 'घ', r'$': 'द्ध', '%': 'छ', '^': 'ट', '&': 'ठ',
  '*': 'ड', '(': 'ढ', ')': 'ण', '`': 'ञ', '-': 'औ', '=': '‍',
  '+': '‌', '[': 'र्', ']': 'े', r'\': '्', ';': 'स', "'": 'ु',
  ',': 'ऽ', '.': '।', '/': 'र', '~': '॥', '_': 'ओ', '{': 'ृ', '}': 'ै',
  '|': 'ं', '<': 'ङ', '>': 'श्र', '?': 'रु', ':': 'ट्ठ', '"': 'ू',
});

const _digits = {
  '0': '०', '1': '१', '2': '२', '3': '३', '4': '४', //
  '5': '५', '6': '६', '7': '७', '8': '८', '9': '९',
};
