// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/nepali_digits.dart';

/// Digits kept in the smallest unit by the `…Parts` getters, enough to hide
/// floating point noise from metric conversions.
const int partsFractionDigits = 9;

final RegExp _separator = RegExp(r'\s*-\s*');
final RegExp _number = RegExp(r'^\d+(\.\d+)?$');

/// Splits [value], given in a base unit, into mixed units such as
/// ropani-aana-paisa-daam.
///
/// [factors] are the sizes of the units in the base unit, largest first; each
/// must be a whole multiple of the last. Every unit but the last gets a whole
/// count, the last keeps the fraction rounded to [fractionDigits] digits, with
/// any carry going to the bigger units (so 15.999 aana at 2 digits is 1
/// ropani, not 15 aana and 3.999 paisa).
///
/// The parts are of the magnitude of [value]; the caller applies the sign.
({List<int> whole, double last}) splitParts(
  double value,
  List<double> factors, {
  int fractionDigits = partsFractionDigits,
}) {
  final smallest = factors.last;
  final scale = math.pow(10, fractionDigits).toDouble();
  double round(double x) => (x * scale).roundToDouble() / scale;

  var rest = round(value.abs() / smallest);
  final whole = <int>[];
  for (final factor in factors.take(factors.length - 1)) {
    final ratio = (factor / smallest).roundToDouble();
    final count = (rest / ratio).floorToDouble();
    whole.add(count.toInt());
    rest -= count * ratio;
  }
  return (whole: whole, last: round(rest));
}

/// The parts of [value] in the units with [factors], as [splitParts] gives
/// them at [partsFractionDigits], with the sign of [value] on every part.
List<num> signedParts(double value, List<double> factors) {
  final (:whole, :last) = splitParts(value, factors);
  final sign = value < 0 ? -1 : 1;
  // `+ 0.0` turns -0.0 into 0.0.
  return [for (final count in whole) sign * count, sign * last + 0.0];
}

/// [value], in a base unit, written in the mixed units with [factors] and
/// [labels], e.g. `2-3-1-0` or, when [long], `2 ropani 3 aana 1 paisa`.
///
/// The long form leaves out zero parts. Digits are Devanagari for
/// [Language.nepali].
String formatParts(
  double value,
  List<double> factors,
  List<String> labels, {
  required bool long,
  required Language language,
  required int fractionDigits,
}) {
  RangeError.checkValueInInterval(fractionDigits, 0, 20, 'fractionDigits');
  final (:whole, :last) = splitParts(
    value,
    factors,
    fractionDigits: fractionDigits,
  );
  final numbers = [
    for (final count in whole) '$count',
    _decimal(last, fractionDigits),
  ];
  final isZero = last == 0 && whole.every((count) => count == 0);

  final String text;
  if (!long) {
    text = numbers.join('-');
  } else if (isZero) {
    text = '0 ${labels.last}';
  } else {
    text = [
      for (var i = 0; i < numbers.length; i++)
        if (i < whole.length ? whole[i] != 0 : last != 0)
          '${numbers[i]} ${labels[i]}',
    ].join(' ');
  }
  final signed = value < 0 && !isZero ? '-$text' : text;
  return language == .nepali ? toNepaliDigits(signed) : signed;
}

/// The value, in a base unit, of [text] written as dash separated mixed
/// units such as `2-3-1-0`, or `null` if it isn't valid.
///
/// Accepts ASCII and Devanagari digits and up to `factors.length` parts;
/// missing trailing parts are zero, so `2-3` is 2 ropani 3 aana. Each part
/// must be a non-negative decimal number.
double? parseParts(String text, List<double> factors) {
  final parts = toEnglishDigits(text).trim().split(_separator);
  if (parts.length > factors.length) return null;
  var value = 0.0;
  for (var i = 0; i < parts.length; i++) {
    if (!_number.hasMatch(parts[i])) return null;
    value += double.parse(parts[i]) * factors[i];
  }
  return value;
}

// [value] with up to [fractionDigits] digits and no trailing zeros, e.g.
// `19.10` → `19.1`, `3.00` → `3`.
String _decimal(double value, int fractionDigits) {
  final text = value.toStringAsFixed(fractionDigits);
  return text.contains('.') ? text.replaceFirst(_trailingZeros, '') : text;
}

final RegExp _trailingZeros = RegExp(r'\.?0+$');
