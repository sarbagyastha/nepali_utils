// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Code unit classes of the Devanagari block (U+0900–U+097F).
library;

/// ् (virama).
const int halant = 0x094D;

/// ़ (nukta).
const int nukta = 0x093C;

/// Zero width non-joiner.
const int zwnj = 0x200C;

/// Zero width joiner.
const int zwj = 0x200D;

/// Whether [unit] is in the Devanagari or Devanagari Extended block.
bool isDevanagariUnit(int unit) =>
    (unit >= 0x0900 && unit <= 0x097F) || (unit >= 0xA8E0 && unit <= 0xA8FF);

/// Whether [unit] is a consonant, e.g. क or क़.
bool isConsonant(int unit) =>
    (unit >= 0x0915 && unit <= 0x0939) ||
    (unit >= 0x0958 && unit <= 0x095F) ||
    (unit >= 0x0978 && unit <= 0x097F);

/// Whether [unit] is an independent vowel, e.g. अ or ऋ.
bool isIndependentVowel(int unit) =>
    (unit >= 0x0904 && unit <= 0x0914) ||
    unit == 0x0960 ||
    unit == 0x0961 ||
    (unit >= 0x0972 && unit <= 0x0977);

/// Whether [unit] is a dependent vowel sign (matra), e.g. ा or ि.
bool isMatra(int unit) =>
    unit == 0x093A ||
    unit == 0x093B ||
    (unit >= 0x093E && unit <= 0x094C) ||
    unit == 0x094E ||
    unit == 0x094F ||
    (unit >= 0x0955 && unit <= 0x0957) ||
    unit == 0x0962 ||
    unit == 0x0963;

/// Whether [unit] is a sign that follows a syllable: ँ ं ः, or a stress mark.
bool isSyllableSign(int unit) =>
    (unit >= 0x0900 && unit <= 0x0903) || (unit >= 0x0951 && unit <= 0x0954);

/// Whether [unit] begins a syllable: a consonant or an independent vowel.
bool isLetter(int unit) => isConsonant(unit) || isIndependentVowel(unit);

/// The end of the akshara (orthographic syllable) that starts at [start] in
/// [units].
///
/// An akshara is a consonant cluster (consonants joined by halants, each
/// optionally with a nukta, a joiner after a halant allowed) followed by a
/// final halant or a matra, then any syllable signs; or an independent vowel
/// followed by signs. Any other character is an akshara of its own, a
/// surrogate pair counting as one character.
int aksharaEnd(List<int> units, int start) {
  final length = units.length;
  final first = units[start];
  var i = start + 1;
  if (isConsonant(first)) {
    if (i < length && units[i] == nukta) i++;
    while (i < length && units[i] == halant) {
      var next = i + 1;
      if (next < length && (units[next] == zwj || units[next] == zwnj)) {
        next++;
      }
      if (next < length && isConsonant(units[next])) {
        i = next + 1;
        if (i < length && units[i] == nukta) i++;
      } else {
        // A final halant, with its joiner if any.
        i = next;
        break;
      }
    }
    if (units[i - 1] != halant &&
        units[i - 1] != zwj &&
        units[i - 1] != zwnj &&
        i < length &&
        isMatra(units[i])) {
      i++;
    }
  } else if (isIndependentVowel(first)) {
    if (i < length && units[i] == nukta) i++;
  } else {
    if (first >= 0xD800 &&
        first <= 0xDBFF &&
        i < length &&
        units[i] >= 0xDC00 &&
        units[i] <= 0xDFFF) {
      i++;
    }
    return i;
  }
  while (i < length && isSyllableSign(units[i])) {
    i++;
  }
  return i;
}
