// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/number/format/decimal.dart';

/// The text around a number, with the currency placeholder resolved.
typedef Affixes = ({String prefix, String suffix});

const int _devanagariZero = 0x0966;
const int _devanagariNine = 0x096F;
const int _zero = 0x30;

/// Whitespace, including the no-break spaces used by number patterns.
final RegExp _spaces = RegExp(r'[\s  ]+');

/// Parses [text] as formatted by a `NepaliNumberFormat`.
///
/// * Digits may be ASCII or Devanagari.
/// * Spaces are ignored, and [groupSeparator] may appear anywhere in the
///   integer part.
/// * The number is negative when it's wrapped in [negative], or when it
///   starts with `-` or `−`. A leading `+` is allowed.
/// * When [lenient] is true, [positive] and [negative] may be left out,
///   e.g. `1,234.50` for a currency format.
/// * [suffixExponents] maps compact suffixes (lower case, without spaces) to
///   their power of ten, e.g. `{'l': 5, 'lakh': 5}`.
///
/// The result is divided by `10^multiplierExponent`.
///
/// Returns `null` when [text] isn't a number in this format.
Decimal? parseNumber(
  String text, {
  required Affixes positive,
  required Affixes negative,
  required String groupSeparator,
  int multiplierExponent = 0,
  Map<String, int> suffixExponents = const {},
  bool lenient = false,
}) {
  final input = _normalize(text);
  if (input.isEmpty) return null;

  final pos = _strip(positive);
  final neg = _strip(negative);
  final candidates =
      [
          if (neg != pos) (affixes: neg, negative: true),
          (affixes: pos, negative: false),
          if (lenient) (affixes: (prefix: '', suffix: ''), negative: false),
        ]
        // Try the longest affixes first, so `-Rs.` wins over `Rs.`.
        ..sort(
          (a, b) => (b.affixes.prefix.length + b.affixes.suffix.length)
              .compareTo(a.affixes.prefix.length + a.affixes.suffix.length),
        );

  final separator = groupSeparator.replaceAll(_spaces, '');
  for (final (:affixes, :negative) in candidates) {
    final (:prefix, :suffix) = affixes;
    if (input.length < prefix.length + suffix.length ||
        !input.startsWith(prefix) ||
        !input.endsWith(suffix)) {
      continue;
    }
    final core = input.substring(prefix.length, input.length - suffix.length);
    final value = _parseCore(
      core,
      separator: separator,
      suffixExponents: suffixExponents,
      allowSign: !negative,
    );
    if (value != null) {
      return value.withSign(negate: negative).shift(-multiplierExponent);
    }
  }
  return null;
}

final RegExp _plain = RegExp(r'^(?:\d+\.?\d*|\.\d+)$');

Decimal? _parseCore(
  String text, {
  required String separator,
  required Map<String, int> suffixExponents,
  required bool allowSign,
}) {
  var core = text;
  // When the negative affixes matched, the number can't have its own sign.
  final negative = allowSign && core.startsWith('-');
  if (allowSign && (negative || core.startsWith('+'))) {
    core = core.substring(1);
  }

  var exponent = 0;
  if (suffixExponents.isNotEmpty) {
    final lower = core.toLowerCase();
    final suffixes = suffixExponents.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final suffix in suffixes) {
      if (suffix.isNotEmpty && lower.endsWith(suffix)) {
        exponent = suffixExponents[suffix]!;
        core = core.substring(0, core.length - suffix.length);
        break;
      }
    }
  }

  if (separator.isNotEmpty && separator != '.') {
    final dot = core.indexOf('.');
    final integer = dot < 0 ? core : core.substring(0, dot);
    final fraction = dot < 0 ? '' : core.substring(dot);
    if (integer.startsWith(separator) || integer.endsWith(separator)) {
      return null;
    }
    core = integer.replaceAll(separator, '') + fraction;
  }

  if (!_plain.hasMatch(core)) return null;
  return Decimal.tryParse(core)?.withSign(negate: negative).shift(exponent);
}

/// Removes spaces, converts Devanagari digits to ASCII and `−` to `-`.
String _normalize(String text) {
  final buffer = StringBuffer();
  for (final rune in text.replaceAll(_spaces, '').runes) {
    if (rune >= _devanagariZero && rune <= _devanagariNine) {
      buffer.writeCharCode(rune - _devanagariZero + _zero);
    } else if (rune == 0x2212) {
      buffer.write('-');
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

Affixes _strip(Affixes affixes) =>
    (prefix: _normalize(affixes.prefix), suffix: _normalize(affixes.suffix));
