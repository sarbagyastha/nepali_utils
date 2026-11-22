// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/unicode/devanagari_chars.dart';
import 'package:nepali_utils/src/unicode/token_trie.dart';

/// Converts text written in the legacy Preeti font to Unicode, and back.
///
/// Preeti draws Devanagari over ASCII codes, so a document typed in it
/// reads as gibberish anywhere the font isn't installed. [Preeti] converts it:
///
/// ```dart
/// Preeti.toUnicode('g]kfn');        // नेपाल
/// Preeti.toUnicode('sfof{no');      // कार्यालय
/// Preeti.fromUnicode('हिमाल');      // lxdfn
/// ```
///
/// Preeti stores text in visual order, so ि is typed before its consonant
/// and the reph र् after its syllable; both are reordered. Characters the
/// font doesn't draw are kept as they are.
abstract final class Preeti {
  /// Converts Preeti-encoded [text] to Unicode.
  static String toUnicode(String text) {
    final mapped = StringBuffer();
    var i = 0;
    while (i < text.length) {
      final match = _forward.match(text, i);
      if (match == null) {
        mapped.writeCharCode(text.codeUnitAt(i));
        i++;
      } else {
        mapped.write(match.$2);
        i += match.$1;
      }
    }
    return _toLogicalOrder(mapped.toString());
  }

  /// Converts Unicode [text] to the Preeti encoding.
  static String fromUnicode(String text) {
    final visual = _toVisualOrder(text);
    final out = StringBuffer();
    var i = 0;
    while (i < visual.length) {
      final match = _reverse.match(visual, i);
      if (match == null) {
        out.writeCharCode(visual.codeUnitAt(i));
        i++;
      } else {
        out.write(match.$2);
        i += match.$1;
      }
    }
    return out.toString();
  }
}

// Stands for the reph while text is in visual order.
const int _reph = 0xE000;
const int _iMatra = 0x093F; // ि
const int _aaMatra = 0x093E; // ा

// Glyphs that are written as a sequence of keys.
const _sequences = {
  'cf]': 'ओ', 'cf}': 'औ', 'cf': 'आ', 'P]': 'ऐ', 'O{': 'ई', //
  'km': 'फ', 'Km': 'फ्', 'em': 'झ', 'Em': 'झ्', 'pm': 'ऊ',
};

const _keys = {
  'a': 'ब', 'b': 'द', 'c': 'अ', 'd': 'म', 'e': 'भ', 'f': 'ा', 'g': 'न', //
  'h': 'ज', 'i': 'ष्', 'j': 'व', 'k': 'प', 'l': 'ि', 'm': 'ः', 'n': 'ल',
  'o': 'य', 'p': 'उ', 'q': 'त्र', 'r': 'च', 's': 'क', 't': 'त', 'u': 'ग',
  'v': 'ख', 'w': 'ध', 'x': 'ह', 'y': 'थ', 'z': 'श',
  'A': 'ब्', 'B': 'द्य', 'C': 'ऋ', 'D': 'म्', 'E': 'भ्', 'F': 'ँ', 'G': 'न्',
  'H': 'ज्', 'I': 'क्ष्', 'J': 'व्', 'K': 'प्', 'L': 'ी', 'M': 'ड्ड',
  'N': 'ल्', 'O': 'इ', 'P': 'ए', 'Q': 'त्त', 'R': 'च्', 'S': 'क्', 'T': 'त्',
  'U': 'ग्', 'V': 'ख्', 'W': 'ध्', 'X': 'ह्', 'Y': 'थ्', 'Z': 'श्',
  '0': '०', '1': '१', '2': '२', '3': '३', '4': '४',
  '5': '५', '6': '६', '7': '७', '8': '८', '9': '९',
  '`': 'ञ', '~': 'ञ्', '!': 'ज्ञ', '@': 'ई', '#': 'घ', r'$': 'द्ध',
  '%': 'छ', '^': 'ट', '&': 'ठ', '*': 'ड', '(': 'ढ', ')': 'ण', '-': '(',
  '_': ')', '=': '.', '+': 'ं', '[': 'ृ', ']': 'े', '}': 'ै', r'\': '्',
  '|': '्र', ';': 'स', ':': 'स्', "'": 'ु', '"': 'ू', '<': '?', '.': '।',
  '>': 'श्र', '/': 'र', '?': 'रु',
  // Glyphs typed with Alt codes.
  'å': 'द्व', 'Ë': 'ङ्ग', 'Í': 'ङ्क', 'Ì': 'न्न', '§': 'ट्ट', '¶': 'ठ्ठ',
  '•': 'ड्ढ', 'š': 'द्म', '›': 'ह्य', 'ˆ': 'फ्', '‰': 'झ्', '´': 'झ',
  'ª': 'ङ', 'Å': 'हृ', '¿': 'रू', '˜': 'ऽ', 'Œ': 'त्त्', 'Ý': 'ट्ठ',
  '«': '्र',
};

final TokenTrie<String> _forward = () {
  final trie = TokenTrie<String>();
  for (final MapEntry(:key, :value) in _sequences.entries) {
    trie.add(key, value);
  }
  for (final MapEntry(:key, :value) in _keys.entries) {
    trie.add(key, value);
  }
  trie.add('{', String.fromCharCode(_reph));
  return trie;
}();

final TokenTrie<String> _reverse = () {
  final trie = TokenTrie<String>();
  // Preferred spellings first; the first key added for a glyph wins.
  const preferred = {
    'ई': '@', 'क्ष': 'If', 'ष': 'if', 'ो': 'f]', 'ौ': 'f}', '।': '.', //
    '॥': '..', '्र': '|',
  };
  for (final MapEntry(:key, :value) in preferred.entries) {
    trie.add(key, value);
  }
  for (final MapEntry(:key, :value) in _sequences.entries) {
    trie.add(value, key);
  }
  final halfKeys = <String, String>{};
  for (final MapEntry(:key, :value) in _keys.entries) {
    if (key.codeUnitAt(0) > 0x7E) continue; // Prefer plain keys.
    trie.add(value, key);
    if (value.endsWith('्')) halfKeys[value] = key;
  }
  // A consonant with ्र, and a half form for consonants without its own
  // key: the full form followed by the halant key.
  for (final MapEntry(:key, :value) in _keys.entries) {
    if (value.length != 1 || !isConsonant(value.codeUnitAt(0))) continue;
    trie
      ..add('$value्र', '$key|')
      ..add('$value्', halfKeys['$value्'] ?? '$key\\');
  }
  for (final MapEntry(:key, :value) in _keys.entries) {
    trie.add(value, key);
  }
  trie.add(String.fromCharCode(_reph), '{');
  return trie;
}();

// Moves ि after its consonant cluster and the reph before its syllable,
// and joins vowels written in two parts.
String _toLogicalOrder(String text) {
  final units = <int>[];
  final source = text.codeUnits;
  for (var i = 0; i < source.length; i++) {
    final unit = source[i];
    final last = units.isEmpty ? -1 : units.last;
    // A half form followed by ा is the full letter: क्ष् + ा = क्ष.
    if (unit == _aaMatra && last == halant) {
      units.removeLast();
      continue;
    }
    final joined = _joinVowel(last, unit);
    if (joined != null) {
      units
        ..removeLast()
        ..add(joined);
      continue;
    }
    units.add(unit);
  }
  _moveIMatras(units);
  _moveRephs(units);
  return String.fromCharCodes(units);
}

// The vowel written as [first] then [second], if they form one.
int? _joinVowel(int first, int second) => switch ((first, second)) {
  (0x0905, 0x093E) => 0x0906, // अ ा → आ
  (0x0906, 0x0947) => 0x0913, // आ े → ओ
  (0x0906, 0x0948) => 0x0914, // आ ै → औ
  (0x090F, 0x0947) => 0x0910, // ए े → ऐ
  (0x093E, 0x0947) || (0x0947, 0x093E) => 0x094B, // ा े → ो
  (0x093E, 0x0948) || (0x0948, 0x093E) => 0x094C, // ा ै → ौ
  _ => null,
};

// The end of the consonant cluster at [start], or [start] if there is none.
int _clusterEnd(List<int> units, int start) {
  var i = start;
  while (i < units.length && isConsonant(units[i])) {
    i++;
    if (i < units.length && units[i] == nukta) i++;
    if (i + 1 < units.length &&
        units[i] == halant &&
        isConsonant(units[i + 1])) {
      i++;
      continue;
    }
    break;
  }
  return i;
}

void _moveIMatras(List<int> units) {
  var i = 0;
  while (i < units.length) {
    if (units[i] == _iMatra) {
      final end = _clusterEnd(units, i + 1);
      if (end > i + 1) {
        units
          ..removeAt(i)
          ..insert(end - 1, _iMatra);
        i = end;
        continue;
      }
    }
    i++;
  }
}

void _moveRephs(List<int> units) {
  for (var i = 0; i < units.length; i++) {
    if (units[i] != _reph) continue;
    // Walk back over the signs, the matra and the consonant cluster.
    var start = i;
    while (start > 0 &&
        (isMatra(units[start - 1]) || isSyllableSign(units[start - 1]))) {
      start--;
    }
    if (start > 0 && isConsonant(units[start - 1])) {
      start--;
      while (start >= 2 &&
          units[start - 1] == halant &&
          isConsonant(units[start - 2])) {
        start -= 2;
      }
    }
    units
      ..removeAt(i)
      ..insertAll(start, const [0x0930, halant]);
    i++;
  }
}

// Puts ि before its consonant cluster and the reph after its syllable.
String _toVisualOrder(String text) {
  final units = text.codeUnits;
  final out = <int>[];
  var i = 0;
  while (i < units.length) {
    final end = aksharaEnd(units, i);
    var start = i;
    var reph = false;
    if (end - start > 2 &&
        units[start] == 0x0930 &&
        units[start + 1] == halant &&
        isConsonant(units[start + 2])) {
      reph = true;
      start += 2;
    }
    final syllable = units.sublist(start, end);
    final iMatra = syllable.indexOf(_iMatra);
    if (iMatra > 0) {
      syllable
        ..removeAt(iMatra)
        ..insert(0, _iMatra);
    }
    if (reph) {
      var at = syllable.length;
      while (at > 0 && isSyllableSign(syllable[at - 1])) {
        at--;
      }
      syllable.insert(at, _reph);
    }
    out.addAll(syllable);
    i = end;
  }
  return String.fromCharCodes(out);
}
