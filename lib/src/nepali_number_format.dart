import 'dart:math';

import '../nepali_utils.dart';
import 'nepali_language.dart';

class NepaliNumberFormat {
  final bool inWords;
  final Language language;
  final bool isMonetory;
  final int decimalDigits;
  final String symbol;
  final bool symbolOnLeft;
  final bool spaceBetweenAmountandSymbol;

  NepaliNumberFormat({
    this.inWords = false,
    this.language = Language.ENGLISH,
    this.isMonetory = false,
    this.decimalDigits = 0,
    this.symbol,
    this.symbolOnLeft = true,
    this.spaceBetweenAmountandSymbol = true,
  });

  String format(double number) {
    assert(number != null, 'Number cannot be null');
    assert(number < 999999999999999999, 'Number is too large for formatting');
    if (inWords) {
      return isMonetory ? _placeSymbol(_formatInWords(number.abs())) : _formatInWords(number.abs());
    } else {
      return isMonetory
          ? _placeSymbol(_formatWithComma(number.abs()))
          : _formatWithComma(number.abs());
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

  String _formatInWords(double number) {
    int _num = number.truncate();
    int _decimal = ((number - _num) * pow(10, decimalDigits)).truncate();
    List<int> digitGroups = List.filled(9, 0);
    String numberInWord = '';
    for (int i = 0; i < 9; i++) {
      if (i == 0) {
        digitGroups[i] = _num % 1000;
        _num = (_num / 1000).truncate();
      } else {
        digitGroups[i] = _num % 100;
        _num = (_num / 100).truncate();
      }
    }
    for (int i = 8; i >= 0; i--) {
      numberInWord += _digitGroupToWord(i, digitGroups[i]);
    }
    if (isMonetory) {
      return numberInWord.trimRight() +
          (_decimal == 0
              ? ' ${_language('rupees')}'
              : ' ${_language('rupees')} ${language == Language.ENGLISH ? _decimal : NepaliUnicode.convert('$_decimal')} ${_language('paisa')}');
    }
    return numberInWord.trimRight();
  }

  String _digitGroupToWord(int index, int number) {
    if (number == 0) {
      return '';
    }
    if (index == 0) {
      String hundreds = '${_languageNumber((number / 100).truncate())} ${_language('hundred')} ';
      String tens = '${_languageNumber(number % 100)}';
      return '$hundreds$tens';
    }
    switch (index) {
      case 1:
        return '${_languageNumber(number)} ${_language('thousand')} ';
      case 2:
        return '${_languageNumber(number)} ${_language('lakh')} ';
      case 3:
        return '${_languageNumber(number)} ${_language('crore')} ';
      case 4:
        return '${_languageNumber(number)} ${_language('arab')} ';
      case 5:
        return '${_languageNumber(number)} ${_language('kharab')} ';
      case 6:
        return '${_languageNumber(number)} ${_language('nil')} ';
      case 7:
        return '${_languageNumber(number)} ${_language('padam')} ';
      case 8:
        return '${_languageNumber(number)} ${_language('sankha')} ';
      default:
        return '';
    }
  }

  String _languageNumber(int number) {
    if (language == Language.ENGLISH)
      return '$number';
    else
      return NepaliUnicode.convert('$number');
  }

  String _language(String word) {
    switch (word) {
      case 'rupees':
        return language == Language.ENGLISH ? word : 'रुपैया';
      case 'paisa':
        return language == Language.ENGLISH ? word : 'पैसा';
      case 'hundred':
        return language == Language.ENGLISH ? word : 'सय';
      case 'thousand':
        return language == Language.ENGLISH ? word : 'हजार';
      case 'lakh':
        return language == Language.ENGLISH ? word : 'लाख';
      case 'crore':
        return language == Language.ENGLISH ? word : 'करोड';
      case 'arab':
        return language == Language.ENGLISH ? word : 'अर्ब';
      case 'kharab':
        return language == Language.ENGLISH ? word : 'खर्ब';
      case 'nil':
        return language == Language.ENGLISH ? word : 'नील';
      case 'padam':
        return language == Language.ENGLISH ? word : 'पद्म';
      case 'sankha':
        return language == Language.ENGLISH ? word : 'शंख';
      default:
        return '';
    }
  }

  String _formatWithComma(double number) {
    int _num = number.truncate();
    String _decimal = number.toStringAsFixed(decimalDigits).split('.').last;
    List<int> digitGroups = List.filled(9, 0);
    String _formattedNumber = '';
    for (int i = 0; i < 9; i++) {
      if (i == 0) {
        digitGroups[i] = _num % 1000;
        _num = (_num / 1000).truncate();
      } else {
        digitGroups[i] = _num % 100;
        _num = (_num / 100).truncate();
      }
    }
    for (int i = 8; i >= 0; i--) {
      _formattedNumber += _formatDigits(i, digitGroups[i]);
    }
    String formattedNumber = _formattedNumber.trimRight();
    if (number != 0) {
      formattedNumber +=
          '${decimalDigits == 0 ? "" : ".${language == Language.ENGLISH ? _decimal : NepaliUnicode.convert(_decimal)}"}';
    }
    for (int i = 0; i < formattedNumber.length; i++) {
      if (language == Language.ENGLISH) {
        if (formattedNumber[i] != '0' && formattedNumber[i] != ',') {
          return formattedNumber.substring(i);
        }
      } else {
        if (formattedNumber[i] != '०' && formattedNumber[i] != ',') {
          return formattedNumber.substring(i);
        }
      }
    }
    return '';
  }

  String _formatDigits(int index, int number) {
    if (index == 0) {
      if (number == 0) {
        return language == Language.ENGLISH ? '000' : NepaliUnicode.convert('000');
      }
      return language == Language.ENGLISH ? '$number' : NepaliUnicode.convert('$number');
    } else {
      if (number == 0) {
        return language == Language.ENGLISH ? '00,' : '${NepaliUnicode.convert('00')},';
      }
      return language == Language.ENGLISH ? '$number,' : '${NepaliUnicode.convert('$number')},';
    }
  }
}
