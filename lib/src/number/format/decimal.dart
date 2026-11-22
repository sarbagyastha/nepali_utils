// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// An exact, finite decimal number: `±unscaled × 10^-scale`.
///
/// Formatting works on this instead of `double` so that rounding is exact
/// and values beyond the range of `int` (e.g. a [BigInt]) keep every digit.
final class Decimal {
  const new _(this.negative, this.unscaled, this.scale);

  /// Creates the decimal for [number].
  ///
  /// [number] is an [int], a finite [double], a [BigInt] or a numeric
  /// [String] such as `-1,234.5`'s plain form `-1234.5` or `1.5e-7`.
  ///
  /// A [double] is read from its shortest round-trip representation, so
  /// `1.005` is exactly 1.005 and rounds to `1.01`.
  ///
  /// Throws an [ArgumentError] for any other value.
  factory from(Object number) => switch (number) {
    final int value => .fromBigInt(BigInt.from(value)),
    final BigInt value => .fromBigInt(value),
    final double value when value.isFinite =>
      tryParse(value.toString()) ??
          (throw ArgumentError.value(number, 'number')),
    final String value =>
      tryParse(value.trim()) ??
          (throw ArgumentError.value(number, 'number', 'Not a number')),
    _ => throw ArgumentError.value(
      number,
      'number',
      'Expected an int, a finite double, a BigInt or a numeric String',
    ),
  };

  /// Creates the decimal for an integer [value].
  factory fromBigInt(BigInt value) => ._(value.isNegative, value.abs(), 0);

  static final RegExp _grammar = RegExp(
    r'^([+\-])?(\d*)(?:\.(\d*))?(?:[eE]([+\-]?\d+))?$',
  );

  /// Parses a plain decimal literal such as `-12.50` or `1e21`.
  ///
  /// Returns `null` when [text] isn't one.
  static Decimal? tryParse(String text) {
    final match = _grammar.firstMatch(text);
    if (match == null) return null;
    final integer = match[2]!;
    final fraction = match[3] ?? '';
    if (integer.isEmpty && fraction.isEmpty) return null;
    final exponent = int.parse(match[4] ?? '0');
    final digits = BigInt.parse(
      '$integer$fraction'.isEmpty ? '0' : '$integer$fraction',
    );
    return Decimal._(
      match[1] == '-' && digits != BigInt.zero,
      digits,
      fraction.length,
    ).shift(exponent);
  }

  /// Whether the number is below zero. Zero is never negative.
  final bool negative;

  /// The digits of the number without its decimal point.
  final BigInt unscaled;

  /// How many of the digits of [unscaled] are after the decimal point.
  final int scale;

  /// Whether this is zero.
  bool get isZero => unscaled == BigInt.zero;

  /// This number multiplied by `10^places`.
  Decimal shift(int places) {
    final newScale = scale - places;
    if (newScale >= 0) return ._(negative, unscaled, newScale);
    return ._(negative, unscaled * BigInt.from(10).pow(-newScale), 0);
  }

  /// The absolute value of this number.
  Decimal abs() => ._(false, unscaled, scale);

  /// This number, negated when [negate] is true.
  Decimal withSign({required bool negate}) =>
      ._(negate != negative && !isZero, unscaled, scale);

  /// Rounds to [fractionDigits] places after the decimal point, half away
  /// from zero like [double.round].
  ///
  /// A negative [fractionDigits] rounds to tens, hundreds, ...
  Decimal round(int fractionDigits) {
    if (scale <= fractionDigits) return this;
    final divisor = BigInt.from(10).pow(scale - fractionDigits);
    var quotient = unscaled ~/ divisor;
    if (unscaled.remainder(divisor) * BigInt.two >= divisor) {
      quotient += BigInt.one;
    }
    final rounded = Decimal._(
      negative && quotient != BigInt.zero,
      quotient,
      fractionDigits,
    );
    return fractionDigits < 0 ? rounded.shift(0) : rounded;
  }

  /// Rounds to [digits] significant digits, see [round].
  Decimal roundSignificant(int digits) {
    if (isZero) return this;
    return round(digits - 1 - exponent);
  }

  /// The power of ten of the leading digit, e.g. 2 for 123.4 and -2 for
  /// 0.012. Zero gives 0.
  int get exponent => isZero ? 0 : unscaled.toString().length - scale - 1;

  /// Drops trailing zeros after the decimal point.
  Decimal normalize() {
    var digits = unscaled;
    var places = scale;
    final ten = BigInt.from(10);
    while (places > 0 && digits.remainder(ten) == BigInt.zero) {
      digits ~/= ten;
      places--;
    }
    return ._(negative, digits, places);
  }

  /// The digits before the decimal point, `''` when the number is below 1.
  String get integerDigits {
    final text = unscaled.toString();
    if (text.length <= scale) return '';
    final integer = text.substring(0, text.length - scale);
    return integer == '0' ? '' : integer;
  }

  /// The [scale] digits after the decimal point.
  String get fractionDigits {
    if (scale == 0) return '';
    final text = unscaled.toString().padLeft(scale, '0');
    return text.substring(text.length - scale);
  }

  /// The integer part, i.e. this number truncated towards zero.
  BigInt get integerPart => unscaled ~/ BigInt.from(10).pow(scale);

  /// Compares the magnitudes of this and [other].
  int compareMagnitude(Decimal other) {
    final places = scale > other.scale ? scale : other.scale;
    final a = unscaled * BigInt.from(10).pow(places - scale);
    final b = other.unscaled * BigInt.from(10).pow(places - other.scale);
    return a.compareTo(b);
  }

  /// This number as an [int] when it's integral and fits in 64 bits,
  /// otherwise as a [double].
  num toNum() {
    final value = normalize();
    if (value.scale == 0 && value.unscaled.bitLength < 64) {
      final integer = value.unscaled.toInt();
      return value.negative ? -integer : integer;
    }
    return double.parse(value.toString());
  }

  @override
  String toString() {
    final integer = integerDigits.isEmpty ? '0' : integerDigits;
    final fraction = fractionDigits;
    return '${negative ? '-' : ''}$integer'
        '${fraction.isEmpty ? '' : '.$fraction'}';
  }
}
