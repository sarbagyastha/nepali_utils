// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/unicode/devanagari_chars.dart';
import 'package:nepali_utils/src/unicode/schemes/phonetic_scheme.dart';

const int _braceOpen = 0x7B; // {
const int _braceClose = 0x7D; // }
const int _zero = 0x30;
const int _nine = 0x39;
const int _devanagariZero = 0x0966;
const String _halant = '्';

bool _isWhitespace(int unit) =>
    unit == 0x20 || (unit >= 0x09 && unit <= 0x0D) || unit == 0xA0;

/// Converts romanized text with a [PhoneticScheme].
final class PhoneticEngine {
  /// Creates an engine for [scheme].
  const new(this.scheme, {required this.digits});

  /// The romanization rules.
  final PhoneticScheme scheme;

  /// Whether ASCII digits become Devanagari digits.
  final bool digits;

  /// Whether [unit] starts a token, i.e. would be converted.
  bool startsToken(int unit) =>
      scheme.trie.startsWith(unit) ||
      (digits && unit >= _zero && unit <= _nine);

  /// Converts the romanized parts of [input].
  ///
  /// Devanagari directly followed by romanized text is joined with it, so
  /// `क` + `h` gives ख. With [live], the last word keeps its halant (its
  /// next letter is still being typed), a halant before whitespace in the
  /// Devanagari is dropped and escapes keep their braces, so converting the
  /// text again after each keystroke gives the same result as converting
  /// what was typed at once.
  String convert(String input, {bool live = false}) {
    final text = _joinDevanagari(input, live: live);
    final out = StringBuffer();
    var pending = false;

    void settle(int boundary) {
      if (!pending) return;
      pending = false;
      final keep = boundary < 0
          ? live || scheme.halantAtEnd
          : _isWhitespace(boundary)
          ? scheme.halantBeforeSpace
          : scheme.halantAtEnd;
      if (keep) out.write(_halant);
    }

    bool accept(PhoneticToken token) => !token.independentOnly || !pending;

    var i = 0;
    while (i < text.length) {
      final unit = text.codeUnitAt(i);
      if (unit == _braceOpen) {
        settle(unit);
        final close = text.indexOf('}', i + 1);
        final end = close < 0 ? text.length : close;
        if (live) {
          out.write(text.substring(i, close < 0 ? end : end + 1));
        } else {
          out.write(text.substring(i + 1, end));
        }
        i = close < 0 ? end : end + 1;
        continue;
      }
      if (digits && unit >= _zero && unit <= _nine) {
        settle(unit);
        out.writeCharCode(unit - _zero + _devanagariZero);
        i++;
        continue;
      }
      final match = scheme.trie.match(text, i, accept);
      if (match == null) {
        settle(unit);
        out.writeCharCode(unit);
        i++;
        continue;
      }
      final (length, token) = match;
      switch (token.kind) {
        case .consonant:
          if (pending) out.write(_halant);
          out.write(token.text);
          pending = true;
        case .vowel:
          out.write(pending ? token.matra : token.text);
          pending = false;
        case .sign:
          out.write(token.text);
          pending = false;
        case .symbol:
          settle(unit);
          out.write(token.text);
        case .halant:
          if (pending) out.write(_halant);
          pending = false;
      }
      i += length;
    }
    settle(-1);
    return out.toString();
  }

  /// Romanizes the Devanagari in [input] with the canonical spellings.
  ///
  /// Text that would be converted, like Latin words, is wrapped in `{}`
  /// escapes so that converting the result gives [input] back.
  String toRoman(String input) {
    final units = input.codeUnits;
    final out = _RomanBuilder(this);
    var i = 0;
    while (i < units.length) {
      final unit = units[i];
      if (isDevanagariUnit(unit)) {
        final end = aksharaEnd(units, i);
        final next = end < units.length ? units[end] : -1;
        if (!out.addAkshara(units, i, end, explicit: false, next: next)) {
          out.addRaw(input.substring(i, end));
        }
        i = end;
      } else if (unit > 0x20 && unit < 0x7F && unit != _braceOpen) {
        var end = i;
        var convertible = false;
        while (end < units.length &&
            units[end] > 0x20 &&
            units[end] < 0x7F &&
            units[end] != _braceOpen &&
            units[end] != _braceClose) {
          convertible = convertible || startsToken(units[end]);
          end++;
        }
        if (end == i) end++; // A lone `}`.
        final run = input.substring(i, end);
        out.addRaw(convertible ? '{$run}' : run);
        i = end;
      } else {
        out.addRaw(String.fromCharCode(unit));
        i++;
      }
    }
    return out.toString();
  }

  /// Replaces the last akshara of each Devanagari run that is directly
  /// followed by romanized text with its spelling, so the two convert
  /// together.
  String _joinDevanagari(String input, {required bool live}) {
    final units = input.codeUnits;
    if (!units.any(isDevanagariUnit)) return input;
    final out = StringBuffer();
    var i = 0;
    while (i < units.length) {
      final unit = units[i];
      if (unit == _braceOpen) {
        final close = input.indexOf('}', i + 1);
        final end = close < 0 ? units.length : close + 1;
        out.write(input.substring(i, end));
        i = end;
        continue;
      }
      if (!isDevanagariUnit(unit)) {
        out.writeCharCode(unit);
        i++;
        continue;
      }
      var end = i;
      while (end < units.length &&
          (isDevanagariUnit(units[end]) ||
              units[end] == zwj ||
              units[end] == zwnj)) {
        end++;
      }
      final next = end < units.length ? units[end] : -1;
      var runEnd = end;
      if (live &&
          next >= 0 &&
          _isWhitespace(next) &&
          runEnd - i >= 2 &&
          units[runEnd - 1] == halant &&
          isConsonant(units[runEnd - 2])) {
        runEnd--;
      }
      if (next >= 0 && startsToken(next)) {
        // Find the last akshara of the run.
        var start = i;
        var last = i;
        while (start < runEnd) {
          last = start;
          start = aksharaEnd(units, start);
        }
        final roman = _RomanBuilder(this);
        if (roman.addAkshara(units, last, runEnd, explicit: true, next: -1)) {
          out
            ..write(input.substring(i, last))
            ..write(roman);
        } else {
          out.write(input.substring(i, runEnd));
        }
      } else {
        out.write(input.substring(i, runEnd));
      }
      i = end;
    }
    return out.toString();
  }
}

/// Builds romanized text token by token, writing the scheme's separator
/// between tokens that would otherwise be read as a different token.
final class _RomanBuilder {
  new(this.engine);

  final PhoneticEngine engine;
  final StringBuffer _out = StringBuffer();
  final List<String> _recent = [];

  PhoneticScheme get _scheme => engine.scheme;

  void addRaw(String text) {
    _out.write(text);
    _recent.clear();
  }

  void _addToken(String token) {
    final first = token.codeUnitAt(0);
    if (first >= _zero && first <= _nine) return addRaw(token); // No merging.
    if (_recent.isNotEmpty && _merges(token)) {
      _out.write(_scheme.separator);
      _recent.clear();
    }
    _out.write(token);
    _recent.add(token);
    if (_recent.length > _scheme.trie.maxLength) _recent.removeAt(0);
  }

  /// Whether [token] would change how the recent tokens are read.
  bool _merges(String token) {
    final joined = '${_recent.join()}$token';
    var offset = 0;
    for (final recent in _recent) {
      final match = _scheme.trie.match(joined, offset);
      if (match == null || match.$1 != recent.length) return true;
      offset += recent.length;
    }
    return false;
  }

  /// Adds the akshara `units[start, end)`, followed by [next] (`-1` at the
  /// end). With [explicit], a bare consonant is always spelt with its
  /// inherent `a` and a final halant isn't spelt at all, so that letters
  /// typed after it join it.
  ///
  /// Returns false, adding nothing, if the akshara can't be romanized.
  bool addAkshara(
    List<int> units,
    int start,
    int end, {
    required bool explicit,
    required int next,
  }) {
    final tokens = <String>[];
    final first = units[start];
    var i = start;
    if (isConsonant(first)) {
      var halantEnd = false;
      final akshara = String.fromCharCodes(units, start, end);
      while (true) {
        final match = _scheme.consonantRoman.match(akshara, i - start);
        if (match == null) return false;
        tokens.add(match.$2);
        i += match.$1;
        if (i < end && units[i] == halant) {
          if (i + 1 < end && isConsonant(units[i + 1])) {
            i++;
            continue;
          }
          if (i + 1 < end) return false; // A joiner or nukta.
          halantEnd = true;
          i++;
        }
        break;
      }
      final hasSign = i < end && isSyllableSign(units[i]);
      if (halantEnd) {
        if (!explicit && _scheme.halantKey != null) {
          tokens.add(_scheme.halantKey!);
        }
      } else if (i < end && isMatra(units[i])) {
        final roman = _scheme.matraRoman[units[i]];
        if (roman == null) return false;
        tokens.add(roman);
        i++;
      } else if (!hasSign && (explicit || !_omitsInherent(next))) {
        tokens.add(_scheme.independentRoman[0x0905]!); // a
      }
    } else if (isIndependentVowel(first)) {
      final roman = _scheme.independentRoman[first];
      if (roman == null) return false;
      tokens.add(roman);
      i++;
    } else if (first >= _devanagariZero &&
        first <= _devanagariZero + 9 &&
        engine.digits) {
      tokens.add(String.fromCharCode(first - _devanagariZero + _zero));
      i++;
    } else {
      final roman = _scheme.symbolRoman[String.fromCharCodes(units, i, end)];
      if (roman == null) return false;
      tokens.add(roman);
      i = end;
    }
    while (i < end) {
      final roman = _scheme.signRoman[units[i]];
      if (roman == null) return false;
      tokens.add(roman);
      i++;
    }
    tokens.forEach(_addToken);
    return true;
  }

  /// Whether a bare consonant followed by [next] converts back without its
  /// `a`, i.e. ends a word.
  bool _omitsInherent(int next) {
    if (next < 0) return !_scheme.halantAtEnd;
    if (isLetter(next) || isMatra(next) || next == halant) return false;
    if (_isWhitespace(next)) return !_scheme.halantBeforeSpace;
    return !_scheme.halantAtEnd;
  }

  @override
  String toString() => _out.toString();
}
