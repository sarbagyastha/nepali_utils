// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language_symbols.dart';
import 'package:nepali_utils/src/number/format/decimal.dart';

/// Spells numbers out with the Nepali place values: hundred, thousand,
/// lakh, crore, arab, kharab, nil, padam and sankha.
///
/// ```text
/// 123456 => one lakh twenty-three thousand four hundred fifty-six
///        => एक लाख तेइस हजार चार सय छपन्न
/// ```
final class NumberWords {
  /// Creates a speller for [symbols].
  ///
  /// When [useDigits] is true, each group is written in digits instead of
  /// words, e.g. `1 lakh 23 thousand 4 hundred 56`.
  const new(this.symbols, {this.useDigits = false});

  /// The language's words and digits.
  final LanguageSymbols symbols;

  /// Whether groups are written in digits instead of words.
  final bool useDigits;

  NumberSymbols get _words => symbols.numbers;

  /// [value] in words. Its fraction is read digit by digit after "point".
  String format(Decimal value) {
    final number = value.normalize();
    final parts = [
      if (number.negative) _words.minus,
      integer(number.integerPart),
    ];
    final fraction = number.fractionDigits;
    if (fraction.isNotEmpty) {
      parts.add(_words.point);
      if (useDigits) {
        parts.add(symbols.digits(fraction));
      } else {
        for (final digit in fraction.codeUnits) {
          parts.add(_words.belowHundred[digit - 0x30]);
        }
      }
    }
    return parts.join(' ');
  }

  /// [value] as an amount of rupees and paisa, rounded to the paisa.
  String currency(Decimal value) {
    final amount = value.round(2);
    final rupees = amount.integerPart;
    final paisa = int.parse(amount.fractionDigits.padRight(2, '0'));
    final parts = [
      if (amount.negative) _words.minus,
      if (rupees > BigInt.zero || paisa == 0) ...[
        integer(rupees),
        _words.rupees,
      ],
      if (paisa > 0) ...[_group(paisa), _words.paisa],
    ];
    return parts.join(' ');
  }

  /// The non-negative integer [value] in words.
  String integer(BigInt value) {
    if (value == BigInt.zero) return _group(0);
    final parts = <String>[];
    final scales = _words.scales;

    // Sankha is the largest place value; anything above it is a count of
    // sankha, spelled out recursively.
    final sankha = BigInt.from(10).pow(17);
    final sankhas = value ~/ sankha;
    var rest = value.remainder(sankha);
    if (sankhas > BigInt.zero) {
      parts
        ..add(integer(sankhas))
        ..add(scales[7]);
    }

    // Padam (10^15) down to thousand (10^3): two digits each.
    for (var scale = 6; scale >= 0; scale--) {
      final unit = BigInt.from(10).pow(3 + 2 * scale);
      final count = (rest ~/ unit).toInt();
      rest = rest.remainder(unit);
      if (count > 0) {
        parts
          ..add(_group(count))
          ..add(scales[scale]);
      }
    }

    final below = rest.toInt();
    if (below >= 100) {
      parts
        ..add(_group(below ~/ 100))
        ..add(_words.hundred);
    }
    if (below % 100 > 0) parts.add(_group(below % 100));
    return parts.join(' ');
  }

  /// A number from 0 to 99.
  String _group(int value) =>
      useDigits ? symbols.number(value) : _words.belowHundred[value];
}
