// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'language.dart';
import 'nepali_date_time.dart';
import 'nepali_unicode.dart';
import 'nepali_utils.dart';

/// NepaliDateFormat is for formatting and parsing dates in Bikram Sambat.
class NepaliDateFormat {
  final Language _language;
  late String _pattern;
  String _checkPattern = '';
  bool _firstRun = true;
  int _index = 0;

  /// Creates a new NepaliDateFormat, with the [pattern] and [language] specified.
  NepaliDateFormat(
    String pattern, [
    Language? language,
  ]) : _language = language ?? NepaliUtils().language {
    _pattern = pattern;
  }

  /// Return a string representing [date] formatted according to assigned [pattern] and [language].
  String format(NepaliDateTime date) {
    if (_firstRun) {
      _checkPattern = _pattern;
      _firstRun = false;
    }
    for (var i = 0; i < _matchers.length; i++) {
      final regex = _matchers[i];
      final match = regex.firstMatch(_checkPattern);

      if (_checkPattern.isEmpty) return _pattern;

      if (match != null) {
        final matchedString = match.group(0);
        if (matchedString != null) {
          _checkPattern = _checkPattern.substring(matchedString.length);
          switch (i) {
            case 0:
              _trim(matchedString);
              format(date);
              break;
            case 1:
              _format(matchedString, date);
              format(date);
              break;
            case 2:
              _index += matchedString.length;
              format(date);
              break;
          }
        }
      }
    }
    return '';
  }

  /// Converts the formatted date string into a string representing [date] formatted
  /// according assigned [pattern] and [language].
  String parseAndFormat(String dateString) =>
      format(NepaliDateTime.parse(dateString));

  void _trim(String match) {
    if (match == "\'\'") {
      _pattern = _pattern.replaceFirst("\'\'", "\'");
      --_index;
    } else {
      _pattern =
          _pattern.replaceFirst(match, match.substring(1, match.length - 1));
      _index -= 2;
      if (match.contains("\'\'")) {
        _pattern = _pattern.replaceFirst("\'\'", "\'");
        --_index;
      }
    }
    _index += match.length;
  }

  void _format(String match, NepaliDateTime date) {
    switch (match) {
      case 'G':
        _replacer(match, _isEnglish ? 'BS' : 'बि सं');
        break;
      case 'GG':
        _replacer(match, _isEnglish ? 'B.S.' : 'बि.सं.');
        break;
      case 'GGG':
        _replacer(match, _isEnglish ? 'Bikram Sambat' : 'बिक्रम संबत');
        break;
      case 'y':
        _replacer(
            match,
            _isEnglish
                ? '${date.year}'
                : '${NepaliUnicode.convert('${date.year}')}');
        break;
      case 'yy':
        _replacer(
            match,
            _isEnglish
                ? '${date.year.toString().substring(2)}'
                : '${NepaliUnicode.convert(date.year.toString().substring(2))}');
        break;
      case 'yyyy':
        _replacer(
            match,
            _isEnglish
                ? '${date.year}'
                : '${NepaliUnicode.convert('${date.year}')}');
        break;
      case 'Q':
        _replacer(match, '${_getQuarter(date.month)}');
        break;
      case 'QQ':
        _replacer(match, '0${_getQuarter(date.month)}');
        break;
      case 'QQQ':
        _replacer(match, 'Q${_getQuarter(date.month)}');
        break;
      case 'QQQQ':
        _replacer(match, '${_getPosition(_getQuarter(date.month))} quarter');
        break;
      case 'M':
        _replacer(
            match,
            _isEnglish
                ? '${date.month}'
                : '${NepaliUnicode.convert('${date.month}')}');
        break;
      case 'MM':
        _replacer(match, _prependZero(date.month));
        break;
      case 'MMM':
        _replacer(match, _monthString(date.month, short: true));
        break;
      case 'MMMM':
        _replacer(match, _monthString(date.month));
        break;
      case 'd':
        _replacer(
            match,
            _isEnglish
                ? '${date.day}'
                : '${NepaliUnicode.convert('${date.day}')}');
        break;
      case 'dd':
        _replacer(match, _prependZero(date.day));
        break;
      case 'E':
        _replacer(match, _weekDayString(date.weekday, short: true));
        break;
      case 'EE':
        _replacer(
            match,
            _isEnglish
                ? _weekDayString(date.weekday).substring(0, 3)
                : _weekDayString(date.weekday).replaceFirst('बार', ''));
        break;
      case 'EEE':
        _replacer(match, _weekDayString(date.weekday));
        break;
      case 'a':
        _replacer(
          match,
          _isEnglish
              ? date.hour >= 12
                  ? 'pm'
                  : 'am'
              : date.hour < 12
                  ? 'बिहान'
                  : date.hour == 12
                      ? 'मध्यान्न'
                      : date.hour < 16
                          ? 'दिउसो'
                          : date.hour < 20
                              ? 'साँझ'
                              : 'बेलुकी',
        );
        break;
      case 'aa':
        _replacer(
          match,
          _isEnglish
              ? date.hour >= 12
                  ? 'PM'
                  : 'AM'
              : date.hour < 12
                  ? 'बिहान'
                  : date.hour == 12
                      ? 'मध्यान्न'
                      : date.hour < 16
                          ? 'दिउसो'
                          : date.hour < 20
                              ? 'साँझ'
                              : 'बेलुकी',
        );
        break;
      case 'h':
        _replacer(match, _clockHour(date.hour));
        break;
      case 'hh':
        _replacer(match, _clockHour(date.hour, prependZero: true));
        break;
      case 'H':
        _replacer(
            match,
            _isEnglish
                ? '${date.hour}'
                : NepaliUnicode.convert('${date.hour}'));
        break;
      case 'HH':
        _replacer(match, _prependZero(date.hour));
        break;
      case 'm':
        _replacer(
            match,
            _isEnglish
                ? '${date.minute}'
                : NepaliUnicode.convert('${date.minute}'));
        break;
      case 'mm':
        _replacer(match, _prependZero(date.minute));
        break;
      case 's':
        _replacer(
            match,
            _isEnglish
                ? '${date.second}'
                : NepaliUnicode.convert('${date.second}'));
        break;
      case 'ss':
        _replacer(match, _prependZero(date.second));
        break;
      case 'S':
        _replacer(match, _threeDigitMaker(date.millisecond).substring(0, 1));
        break;
      case 'SS':
        _replacer(match, _threeDigitMaker(date.millisecond).substring(0, 2));
        break;
      case 'SSS':
        _replacer(match, _threeDigitMaker(date.millisecond).substring(0, 3));
        break;
      case 'SSSS':
        _replacer(
            match,
            '${_threeDigitMaker(date.millisecond)}${_threeDigitMaker(date.microsecond)}'
                .substring(0, 4));
        break;
      case 'SSSSS':
        _replacer(
            match,
            '${_threeDigitMaker(date.millisecond)}${_threeDigitMaker(date.microsecond)}'
                .substring(0, 5));
        break;
      case 'SSSSSS':
        _replacer(
            match,
            '${_threeDigitMaker(date.millisecond)}${_threeDigitMaker(date.microsecond)}'
                .substring(0, 6));
        break;
    }
  }

  String _threeDigitMaker(int number) {
    final numString = number.toString();
    if (numString.length == 1) {
      return _isEnglish
          ? '00$numString'
          : '००${NepaliUnicode.convert(numString)}';
    }
    if (numString.length == 2) {
      return _isEnglish
          ? '0$numString'
          : '०${NepaliUnicode.convert(numString)}';
    }
    return _isEnglish
        ? numString.substring(0, 3)
        : NepaliUnicode.convert(numString.substring(0, 3));
  }

  String _clockHour(int hour, {bool prependZero = false}) {
    if (hour > 12) {
      return _isEnglish
          ? '${hour - 12}'
          : '${NepaliUnicode.convert('${hour - 12}')}';
    } else if (hour == 12) {
      return _isEnglish ? '12' : '१२';
    } else {
      return _isEnglish
          ? prependZero
              ? _prependZero(hour)
              : '$hour'
          : prependZero
              ? _prependZero(hour)
              : '${NepaliUnicode.convert('$hour')}';
    }
  }

  String _prependZero(int number) {
    if (number < 10) {
      return _isEnglish ? '0$number' : '०${NepaliUnicode.convert('$number')}';
    }
    return _isEnglish ? '$number' : NepaliUnicode.convert('$number');
  }

  void _replacer(String match, String replaceWith) {
    _pattern = _pattern.replaceFirst(match, replaceWith, _index);
    _index += replaceWith.length;
  }

  String _weekDayString(int day, {bool short = false}) {
    assert(day > 0 && day < 8);

    final weeksInEnglish = [
      _Week('Sunday', 'S'),
      _Week('Monday', 'M'),
      _Week('Tuesday', 'T'),
      _Week('Wednesday', 'W'),
      _Week('Thursday', 'T'),
      _Week('Friday', 'F'),
      _Week('Saturday', 'S'),
    ];
    final weeksInNepali = [
      _Week('आइतबार', 'आ'),
      _Week('सोमबार', 'सो'),
      _Week('मंगलबार', 'मं'),
      _Week('बुधबार', 'बु'),
      _Week('बिहिबार', 'बि'),
      _Week('शुक्रबार', 'शु'),
      _Week('शनिबार', 'श'),
    ];

    if (_isEnglish) return weeksInEnglish[day - 1].get(short: short);
    return weeksInNepali[day - 1].get(short: short);
  }

  String _monthString(int month, {bool short = false}) {
    assert(month > 0 && month < 13);
    final monthsInEnglish = [
      _Month('Baishakh', 'Bai'),
      _Month('Jestha', 'Jes'),
      _Month('Ashadh', 'Asar'),
      _Month('Shrawan', 'Shr'),
      _Month('Bhadra', 'Bha'),
      _Month('Ashwin', 'Ash'),
      _Month('Kartik', 'Kar'),
      _Month('Mangsir', 'Mang'),
      _Month('Poush', 'Pou'),
      _Month('Magh', 'Mag'),
      _Month('Falgun', 'Fal'),
      _Month('Chaitra', 'Cha'),
    ];
    final monthsInNepali = [
      _Month('बैशाख', 'बै'),
      _Month('जेष्ठ', 'जे'),
      _Month('अषाढ', 'अ'),
      _Month('श्रावण', 'श्रा'),
      _Month('भाद्र', 'भा'),
      _Month('आश्विन', 'आ'),
      _Month('कार्तिक', 'का'),
      _Month('मंसिर', 'मं'),
      _Month('पौष', 'पौ'),
      _Month('माघ', 'मा'),
      _Month('फाल्गुन', 'फा'),
      _Month('चैत्र', 'चै'),
    ];

    if (_isEnglish) return monthsInEnglish[month - 1].get(short: short);
    return monthsInNepali[month - 1].get(short: short);
  }

  bool get _isEnglish => _language == Language.english;

  int _getQuarter(int month) => (month / 3).ceil();

  String _getPosition(int position) {
    switch (position) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${position}th';
    }
  }

  /// A series of regular expressions used to parse a format string into its
  /// component fields.
  final List<RegExp> _matchers = [
    // Quoted String - anything between single quotes, with escaping
    //   of single quotes by doubling them.
    // e.g. in the pattern "hh 'o''clock'" will match 'o''clock'
    RegExp("^\'(?:[^\']|\'\')*\'"),
    // Fields - any sequence of 1 or more of the same field characters.
    // e.g. in "hh:mm:ss" will match hh, mm, and ss. But in "hms" would
    // match each letter individually.
    RegExp('^(?:G+|y+|M+|k+|S+|E+|a+|h+|K+|H+|c+|L+|Q+|d+|D+|m+|s+|v+|z+|Z+)'),
    // Everything else - A sequence that is not quotes or field characters.
    // e.g. in "hh:mm:ss" will match the colons.
    RegExp("^[^\'GyMkSEahKHcLQdDmsvzZ]+")
  ];

  /// 2076-08-05 => 5
  NepaliDateFormat.d([Language? language]) : this('d', language);

  /// 2076-08-05 => Thu
  NepaliDateFormat.E([Language? language]) : this('EE', language);

  /// 2076-08-05 => Thursday
  NepaliDateFormat.EEEE([Language? language]) : this('EEE', language);

  /// 2076-08-05 => Marga
  NepaliDateFormat.LLL([Language? language]) : this('MMM', language);

  /// 2076-08-05 => Mangsir
  NepaliDateFormat.LLLL([Language? language]) : this('MMMM', language);

  /// 2076-08-05 => 8
  NepaliDateFormat.M([Language? language]) : this('M', language);

  /// 2076-08-05 => 8/15
  NepaliDateFormat.Md([Language? language]) : this('M/d', language);

  /// 2076-08-05 => Thu, 8/15
  NepaliDateFormat.MEd([Language? language]) : this('EE, M/d', language);

  /// 2076-08-05 => Marga
  NepaliDateFormat.MMM([Language? language]) : this('MMM', language);

  /// 2076-08-05 => Marga 5
  NepaliDateFormat.MMMd([Language? language]) : this('MMM d', language);

  /// 2076-08-05 => Thursday, Marga 5
  NepaliDateFormat.MMMEd([Language? language]) : this('EEE, MMM d', language);

  /// 2076-08-05 => Mangsir
  NepaliDateFormat.MMMM([Language? language]) : this('MMMM', language);

  /// 2076-08-05 => Mangsir 5
  NepaliDateFormat.MMMMd([Language? language]) : this('MMMM d', language);

  /// 2076-08-05 => Thursday, Mangsir 5
  NepaliDateFormat.MMMMEEEEd([Language? language])
      : this('EEE, MMMM d', language);

  /// 2076-08-05 => Q3
  NepaliDateFormat.QQQ([Language? language]) : this('QQQ', language);

  /// 2076-08-05 => 3rd quarter
  NepaliDateFormat.QQQQ([Language? language]) : this('QQQQ', language);

  /// 2076-08-05 => 2076
  NepaliDateFormat.y([Language? language]) : this('y', language);

  /// 2076-08-05 => 2076/08
  NepaliDateFormat.yM([Language? language]) : this('y/MM', language);

  /// 2076-08-05 => 2076/08/05
  NepaliDateFormat.yMd([Language? language]) : this('y/MM/dd', language);

  /// 2076-08-05 => Thu, 2076/08/05
  NepaliDateFormat.yMEd([Language? language]) : this('EE, y/MM/dd', language);

  /// 2076-08-05 => Marga 2076
  NepaliDateFormat.yMMM([Language? language]) : this('MMM y', language);

  /// 2076-08-05 => Marga 5,2076
  NepaliDateFormat.yMMMd([Language? language]) : this('MMM d, y', language);

  /// 2076-08-05 => Thu, Marga 5,2076
  NepaliDateFormat.yMMMEd([Language? language])
      : this('EE, MMM d, y', language);

  /// 2076-08-05 => Mangsir 2076
  NepaliDateFormat.yMMMM([Language? language]) : this('MMMM y', language);

  /// 2076-08-05 => Mangsir 5,2076
  NepaliDateFormat.yMMMMd([Language? language]) : this('MMMM d, y', language);

  /// 2076-08-05 => Thursday, Mangsir 5, 2076
  NepaliDateFormat.yMMMMEEEEd([Language? language])
      : this('EEE, MMMM d, y', language);

  /// 2076-08-05 => Q3 2076
  NepaliDateFormat.yQQQ([Language? language]) : this('QQQ y', language);

  /// 2076-08-05 => 3rd quarter 2076
  NepaliDateFormat.yQQQQ([Language? language]) : this('QQQQ y', language);

  /// 2076-08-05T21:04:25 => 21
  NepaliDateFormat.H([Language? language]) : this('H', language);

  /// 2076-08-05T21:04:25 => 21:04
  NepaliDateFormat.Hm([Language? language]) : this('HH:MM', language);

  /// 2076-08-05T21:04:25 => 21:04:25
  NepaliDateFormat.Hms([Language? language]) : this('HH:mm:ss', language);

  /// 2076-08-05T21:04:25 => p PM
  NepaliDateFormat.j([Language? language])
      : this(
          language == Language.nepali ? 'aa h' : 'h aa',
          language,
        );

  /// 2076-08-05T21:04:25 => 9:04 PM
  NepaliDateFormat.jm([Language? language])
      : this(
          language == Language.nepali ? 'aa h:mm' : 'h:mm aa',
          language,
        );

  /// 2076-08-05T21:04:25 => 9:04:25 PM
  NepaliDateFormat.jms([Language? language])
      : this(
          language == Language.nepali ? 'aa h:mm:ss' : 'h:mm:ss aa',
          language,
        );

  /// 2076-08-05T21:04:25 => 9
  NepaliDateFormat.m([Language? language]) : this('h', language);

  /// 2076-08-05T21:04:25 => 9:04
  NepaliDateFormat.ms([Language? language]) : this('hh:mm', language);

  /// 2076-08-05T21:04:25 => 25
  NepaliDateFormat.s([Language? language]) : this('s', language);
}

class _Month {
  final String name;
  final String shortName;

  _Month(this.name, this.shortName);

  String get({bool short = false}) => short ? shortName : name;
}

class _Week {
  final String name;
  final String shortName;

  _Week(this.name, this.shortName);

  String get({bool short = false}) => short ? shortName : name;
}
