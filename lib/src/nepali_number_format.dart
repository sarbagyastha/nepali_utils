// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/language/language_symbols.dart';
import 'package:nepali_utils/src/core/nepali_utils.dart';

/// Provides the ability to format a number in a Nepali way.
class NepaliNumberFormat {
  ///Create a nepali number format.
  new({
    this.inWords = false,
    this.isMonetory = false,
    this.decimalDigits,
    this.symbol,
    this.symbolOnLeft = true,
    this.delimiter = ',',
    this.spaceBetweenAmountAndSymbol = true,
    this.includeDecimalIfZero = true,
    Language? language,
  }) : _symbols = symbolsOf(language ?? NepaliUtils.currentLanguage);

  /// If true, formats the number in words.
  ///
  /// Default is false.
  final bool inWords;

  final LanguageSymbols _symbols;

  /// If true, formats the number as if it is monetary value.
  /// Also, [symbol] can be added while true.
  ///
  /// Default is false.
  final bool isMonetory;

  /// Specifies the number of decimal places to include in formatted number.
  ///
  /// Default is 0 for integer input, 2 for other data types.
  final int? decimalDigits;

  /// Specifies the symbol to use in monetary value.
  /// [isMonetory] is required to be set as true.
  final String? symbol;

  /// The character used to separate place value in number.
  ///
  /// i.e. 2000(delimiter = ',') -> 2,000
  ///      2000(delimiter = '') -> 2000
  ///      2000(delimiter = '.') -> 2.000
  ///
  /// Default value is ','.
  final String delimiter;

  /// If true, place the symbol on left side of the formatted number.
  ///
  /// Default is true.
  final bool symbolOnLeft;

  /// If true, places a space between [symbol] and the number.
  ///
  /// Default is true.
  final bool spaceBetweenAmountAndSymbol;

  /// If true, decimal value will be included in the formatted string even if
  /// numbers after decimals are only 0s.
  ///
  /// Otherwise, decimal value will be excluded
  /// i.e. 2.00 -> 2
  ///      2.01 -> 2.01
  ///
  /// Default is true.
  final bool includeDecimalIfZero;

  /// Format number according to specified parameters
  /// and return the formatted string.
  String format<T extends Object>(T? number) {
    if (number == null) return '';
    if (inWords) {
      return isMonetory
          ? _placeSymbol(_formatInWords<T>(number))
          : _formatInWords<T>(number);
    } else {
      return isMonetory
          ? _placeSymbol(_formatWithComma<T>(number))
          : _formatWithComma<T>(number);
    }
  }

  String _placeSymbol(String? number) {
    if (number == null) {
      return '';
    }
    if (symbol == null) {
      return number;
    } else if (symbolOnLeft) {
      return symbol! + (spaceBetweenAmountAndSymbol ? ' ' : '') + number;
    } else {
      return number + (spaceBetweenAmountAndSymbol ? ' ' : '') + symbol!;
    }
  }

  String _formatInWords<T extends Object>(T number) {
    final numberInWordBuffer = StringBuffer();
    var decimal = '';
    final commaFormattedNumber = _formatWithComma<T>(number);
    final digitGroups = commaFormattedNumber.split(',');

    if (commaFormattedNumber.contains('.')) {
      decimal = digitGroups.last.split('.').last;
    }

    for (var i = 0; i < digitGroups.length - 1; i++) {
      numberInWordBuffer.write(
        _digitGroupToWord(digitGroups.length - i - 2, digitGroups[i]),
      );
    }

    var digit = digitGroups.last;
    if (digit.contains('.')) {
      digit = digitGroups.last.split('.').first;
    }

    if (digit.length == 3) {
      numberInWordBuffer.write(
        '${_symbols.digits(digit[0])} ${_symbols.hundred} '
        '${_symbols.digits(digit.substring(1))}',
      );
    } else {
      numberInWordBuffer.write(_symbols.digits(digit));
    }

    final numberInWord = numberInWordBuffer.toString();

    if (isMonetory) {
      return numberInWord.trimRight() +
          (decimal.isEmpty
              ? ' ${_symbols.rupees}'
              : ' ${_symbols.rupees} '
                    '${_symbols.digits(decimal)} '
                    '${_symbols.paisa}');
    }
    return numberInWord.trimRight();
  }

  String _digitGroupToWord(int index, String number) {
    final scales = _symbols.scales;
    if (index < 0 || index >= scales.length) return '';
    return '${_symbols.digits(number)} ${scales[index]} ';
  }

  String _formatWithComma<T extends Object>(T number) {
    var decimalDigits = this.decimalDigits;
    var number0 = '';
    var fractionalPart = '';
    if (number is String) {
      decimalDigits ??= 2;
      number0 = number;
    } else if (number is int) {
      decimalDigits ??= 0;
      number0 = '$number';
    } else if (number is double) {
      decimalDigits ??= 2;
      number0 = '$number';
    } else {
      throw ArgumentError('number should be either "String" or "num"');
    }

    final fractionMatches = RegExp(r'^(\d*)\.?(\d*)$').allMatches(number0);
    if (fractionMatches.isNotEmpty) {
      number0 = fractionMatches.first.group(1) ?? '';
      fractionalPart = fractionMatches.first.group(2) ?? '';
    } else {
      throw Exception('Unexpected input: $number');
    }

    fractionalPart = fractionalPart
        .padRight(decimalDigits, '0')
        .substring(0, decimalDigits);

    final hideDecimal =
        !includeDecimalIfZero && RegExp(r'^0+$').hasMatch(fractionalPart);

    fractionalPart = _symbols.digits(fractionalPart);
    if (decimalDigits > 0) {
      fractionalPart = '.$fractionalPart';
    }

    if (number0.length <= 3) {
      if (hideDecimal) {
        return _symbols.digits(number0);
      }
      return '${_symbols.digits(number0)}'
          '$fractionalPart';
    } else if (number0.length < 5) {
      final localizedNum = _symbols.digits(number0);
      if (hideDecimal) {
        return '${localizedNum[0]}$delimiter${localizedNum.substring(1)}';
      }
      return '${localizedNum[0]}$delimiter${localizedNum.substring(1)}'
          '$fractionalPart';
    } else {
      final paddedNumber = number0.length.isOdd ? number0 : '0$number0';
      var formattedString = '';
      final digitMatcher = RegExp(r'\d{1,2}');
      final matches = digitMatcher.allMatches(paddedNumber);
      for (var i = 0; i < matches.length; i++) {
        if (i < matches.length - 2) {
          formattedString += '${matches.elementAt(i).group(0)}$delimiter';
        } else {
          formattedString += number0.substring(
            number0.length - 3,
            number0.length,
          );
          break;
        }
      }
      formattedString = formattedString[0] == '0'
          ? formattedString.substring(1)
          : formattedString;
      formattedString = _symbols.digits(formattedString);

      if (hideDecimal) return formattedString;
      return '$formattedString$fractionalPart';
    }
  }
}
