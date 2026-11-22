// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

const int _zero = 0x30; // '0'
const int _nine = 0x39; // '9'
const int _devanagariZero = 0x0966; // '०'

/// Replaces ASCII digits in [text] with Devanagari digits.
///
/// Every other character is left untouched.
String toNepaliDigits(String text) {
  final units = text.codeUnits;
  var i = 0;
  while (i < units.length && (units[i] < _zero || units[i] > _nine)) {
    i++;
  }
  if (i == units.length) return text;
  return String.fromCharCodes([
    for (final unit in units)
      if (unit >= _zero && unit <= _nine)
        unit - _zero + _devanagariZero
      else
        unit,
  ]);
}
