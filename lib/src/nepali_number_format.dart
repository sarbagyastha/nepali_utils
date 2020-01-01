// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'nepali_language.dart';
import 'nepali_unicode.dart';

/// Provides the ability to format a number in a Nepali way.
class NepaliNumberFormat {
  /// If true, formats the number in words.
  ///
  /// Default is false.
  final bool inWords;

  /// Specifies the lanaguage the use in the conversion.
  ///
  /// Default is [Language.ENGLISH].
  final Language language;

  /// If true, formats the number as if it is monetary value.
  /// Also, [symbol] can be added while true.
  ///
  /// Default is false.
  final bool isMonetory;

  /// Specifies the number of decimal places to include in formatted number.
  ///
  /// Default is 0 for integer input, 2 for other data types.
  final int decimalDigits;

  /// Specifies the symbol to use in monetary value.
  /// [isMonetory] is required to be set as true.
  final String symbol;

  /// If true, place the symbol on left side of the formatted number.
  ///
  /// Default is true.
  final bool symbolOnLeft;

  /// If true, places a space between [symbol] and the number.
  ///
  /// Default is true.
  final bool spaceBetweenAmountandSymbol;

  ///Create a nepali number format.
  NepaliNumberFormat({
    this.inWords = false,
    this.language = Language.english,
    this.isMonetory = false,
    this.decimalDigits,
    this.symbol,
    this.symbolOnLeft = true,
    this.spaceBetweenAmountandSymbol = true,
  });

  /// Format number according to specified parameters and return the formatted string.
  String format<T>(T number) {
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

  String _placeSymbol(String number) {
    if (number == null) {
      return '';
    }
    if (symbol == null) {
      return number;
    } else if (symbolOnLeft) {
      return symbol + (spaceBetweenAmountandSymbol ? ' ' : '') + number;
    } else {
      return number + (spaceBetweenAmountandSymbol ? ' ' : '') + symbol;
    }
  }

  String _formatInWords<T>(T number) {
    var numberInWord = '';
    var decimal = '';
    var commaFormattedNumber = _formatWithComma<T>(number);
    var digitGroups = commaFormattedNumber.split(',');

    if (commaFormattedNumber.contains('.')) {
      decimal = digitGroups.last.split('.').last;
    }

    for (var i = 0; i < digitGroups.length - 1; i++) {
      numberInWord +=
          _digitGroupToWord(digitGroups.length - i - 2, digitGroups[i]);
    }

    var digit = digitGroups.last;
    if (digit.contains('.')) {
      digit = digitGroups.last.split('.').first;
    }

    if (digit.length == 3) {
      numberInWord +=
          '${_languageNumber(digit[0])} ${_language('hundred')} ${_languageNumber(digit.substring(1))}';
    } else {
      numberInWord += '${_languageNumber(digit)}';
    }

    if (isMonetory) {
      return numberInWord.trimRight() +
          (decimal.isEmpty
              ? ' ${_language('rupees')}'
              : ' ${_language('rupees')} ${_isEnglish ? decimal : NepaliUnicode.convert(decimal)} ${_language('paisa')}');
    }
    return numberInWord.trimRight();
  }

  String _digitGroupToWord(int index, String number) {
    switch (index) {
      case 0:
        return '${_languageNumber(number)} ${_language('thousand')} ';
      case 1:
        return '${_languageNumber(number)} ${_language('lakh')} ';
      case 2:
        return '${_languageNumber(number)} ${_language('crore')} ';
      case 3:
        return '${_languageNumber(number)} ${_language('arab')} ';
      case 4:
        return '${_languageNumber(number)} ${_language('kharab')} ';
      case 5:
        return '${_languageNumber(number)} ${_language('nil')} ';
      case 6:
        return '${_languageNumber(number)} ${_language('padam')} ';
      case 7:
        return '${_languageNumber(number)} ${_language('sankha')} ';
      default:
        return '';
    }
  }

  String _languageNumber(String number) =>
      _isEnglish ? number : NepaliUnicode.convert('$number');

  bool get _isEnglish => language == Language.english;

  String _language(String word) {
    switch (word) {
      case 'rupees':
        return _isEnglish ? word : 'रुपैया';
      case 'paisa':
        return _isEnglish ? word : 'पैसा';
      case 'hundred':
        return _isEnglish ? word : 'सय';
      case 'thousand':
        return _isEnglish ? word : 'हजार';
      case 'lakh':
        return _isEnglish ? word : 'लाख';
      case 'crore':
        return _isEnglish ? word : 'करोड';
      case 'arab':
        return _isEnglish ? word : 'अर्ब';
      case 'kharab':
        return _isEnglish ? word : 'खर्ब';
      case 'nil':
        return _isEnglish ? word : 'नील';
      case 'padam':
        return _isEnglish ? word : 'पद्म';
      case 'sankha':
        return _isEnglish ? word : 'शंख';
      default:
        return '';
    }
  }

  String _formatWithComma<T extends Object>(T number) {
    var _decimalDigits = decimalDigits;
    var _number = '', _fractionalPart = '';
    if (number is String) {
      _decimalDigits ??= 2;
      _number = number;
    } else if (number is int) {
      _decimalDigits ??= 0;
      _number = '$number';
    } else if (number is double) {
      _decimalDigits ??= 2;
      _number = '$number';
    } else {
      throw ArgumentError('number should be either "String" or "num"');
    }

    var fractionMatches = RegExp(r'^(\d*)\.?(\d*)$').allMatches(_number);
    if (fractionMatches.isNotEmpty) {
      _number = fractionMatches.first.group(1);
      _fractionalPart = fractionMatches.first.group(2);
    } else {
      throw Exception('Inexpected input: $number');
    }

    _fractionalPart = _fractionalPart
        .padRight(_decimalDigits, '0')
        .substring(0, _decimalDigits);
    _fractionalPart =
        _isEnglish ? _fractionalPart : NepaliUnicode.convert(_fractionalPart);
    if (_decimalDigits > 0) {
      _fractionalPart = '.$_fractionalPart';
    }

    if (_number.length <= 3) {
      return '${_isEnglish ? _number : NepaliUnicode.convert(_number)}$_fractionalPart';
    } else if (_number.length < 5) {
      var localizedNum = _isEnglish ? _number : NepaliUnicode.convert(_number);
      return '${localizedNum[0]},${localizedNum.substring(1)}$_fractionalPart';
    } else {
      var paddedNumber = _number.length.isOdd ? _number : '0$_number';
      var formattedString = '';
      var digitMatcher = RegExp(r'\d{1,2}');
      var matches = digitMatcher.allMatches(paddedNumber);
      for (var i = 0; i < matches.length; i++) {
        if (i < matches.length - 2) {
          formattedString += '${matches.elementAt(i).group(0)},';
        } else {
          formattedString +=
              _number.substring(_number.length - 3, _number.length);
          break;
        }
      }
      formattedString = formattedString[0] == '0'
          ? formattedString.substring(1)
          : formattedString;
      formattedString =
          _isEnglish ? formattedString : NepaliUnicode.convert(formattedString);

      return '$formattedString$_fractionalPart';
    }
  }
}
