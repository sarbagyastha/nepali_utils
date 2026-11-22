// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/number/format/decimal.dart';

/// Powers of ten of the compact place values: thousand, lakh, crore, arab
/// and kharab.
const List<int> compactExponents = [3, 5, 7, 9, 11];

// The significant digits shown by a compact format, like
// `package:intl`'s `NumberFormat.compact`.
const int _significantDigits = 3;

// Follows intl's NumberFormat.compact:
// * At most three significant digits are kept, but digits before the decimal
//   point are never dropped (1234567890000000 is 12345 kharab).
// * When rounding reaches the next place value, that one is used instead, so
//   99999 is 1 lakh rather than 100 thousand.

/// [value] scaled down to its compact place value.
///
/// Returns the rounded mantissa and the index into [compactExponents], or
/// -1 when [value] is below a thousand.
({Decimal mantissa, int scale}) compact(Decimal value) {
  var scale = -1;
  for (var i = compactExponents.length - 1; i >= 0; i--) {
    if (value.abs().compareMagnitude(_power(compactExponents[i])) >= 0) {
      scale = i;
      break;
    }
  }

  while (true) {
    final mantissa = _round(
      scale < 0 ? value : value.shift(-compactExponents[scale]),
    );
    final next = scale + 1;
    if (next < compactExponents.length) {
      final threshold = _power(
        compactExponents[next] - (scale < 0 ? 0 : compactExponents[scale]),
      );
      if (mantissa.compareMagnitude(threshold) >= 0) {
        scale = next;
        continue;
      }
    }
    return (mantissa: mantissa.normalize(), scale: scale);
  }
}

Decimal _round(Decimal value) {
  if (value.isZero) return value;
  final integerDigits = value.exponent + 1;
  return integerDigits >= _significantDigits
      ? value.round(0)
      : value.roundSignificant(_significantDigits);
}

Decimal _power(int exponent) => Decimal.fromBigInt(BigInt.one).shift(exponent);
