// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/language.dart';
import 'package:nepali_utils/src/nepali_date_format.dart';

///
extension ENepaliDateTime on DateTime {
  /// Converts the [DateTime] to [NepaliDateTime].
  NepaliDateTime toNepaliDateTime() {
    const nepalTzOffset = Duration(hours: 5, minutes: 45);
    final now = toUtc().add(nepalTzOffset);
    // Setting nepali reference to 1970/1/1 with english date 1913/4/13
    var nepaliYear = 1970;
    var nepaliMonth = 1;
    var nepaliDay = 1;

    // Time was causing error while differencing dates.
    final date = DateTime(now.year, now.month, now.day);
    var difference = date.difference(DateTime(1913, 4, 13)).inDays;

    // 1986-1-1's duration is only 23 hours 45 minutes in Dart for Nepal Time.
    // This can be tested using
    // `print(DateTime(1986,1,2).difference(DateTime(1986,1,1)))`;
    // So, in order to compensate it one extra day is added from this date.
    if (date.timeZoneOffset == nepalTzOffset && date.isAfter(DateTime(1986))) {
      difference += 1;
    }

    // Getting nepali year until the difference remains less than 365
    var daysInYear = _nepaliYears[nepaliYear]!.first;
    while (difference >= daysInYear) {
      nepaliYear += 1;
      difference -= daysInYear;
      daysInYear = _nepaliYears[nepaliYear]!.first;
    }

    // Getting nepali month until the difference remains less than 31
    var daysInMonth = _nepaliYears[nepaliYear]![nepaliMonth];
    while (difference >= daysInMonth) {
      difference -= daysInMonth;
      nepaliMonth += 1;
      daysInMonth = _nepaliYears[nepaliYear]![nepaliMonth];
    }

    // Remaining days is the actual day;
    nepaliDay += difference;

    return NepaliDateTime(
      nepaliYear,
      nepaliMonth,
      nepaliDay,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
  }
}

/// An instant in time, such as Mangsir 05, 2076, 11:05am
class NepaliDateTime implements DateTime {
  /// Constructs a NepaliDateTime instance specified.
  factory NepaliDateTime(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) {
    // Adjusting month
    if (month > 12) {
      year += (month - 1) ~/ 12;
      month = (month - 1) % 12 + 1;
    } else if (month < 1) {
      year -= month.abs() ~/ 12 + 1;
      month = 12 - month.abs() % 12;
    }
    // Adjusting day
    while (true) {
      final currentMonthDays = _getMonthList(year)[month];
      if (day > 0 && day <= currentMonthDays) {
        break;
      }
      if (day > currentMonthDays) {
        day -= currentMonthDays;
        if (++month > 12) {
          month = 1;
          year++;
        }
      } else if (day < 1) {
        if (--month < 1) {
          month = 12;
          year--;
        }
        day += _getMonthList(year)[month];
      }
    }

    return NepaliDateTime._internal(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  /// Constructs a NepaliDateTime instance specified.
  NepaliDateTime._internal(
    this.year, [
    this.month = 1,
    this.day = 1,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.millisecond = 0,
    this.microsecond = 0,
  ]) : assert(year >= 1969 && year <= 2250, 'Supported year is 1970-2250');

  /// Constructs a DateTime instance with current date and time
  factory NepaliDateTime.now() => DateTime.now().toNepaliDateTime();

  /// Converts the specified [DateTime] to [NepaliDateTime].
  ///
  /// Use [toNepaliDateTime()] exposed to [DateTime] object instead.
  @Deprecated('Use toNepaliDateTime() instead.')
  factory NepaliDateTime.fromDateTime(DateTime dateTime) {
    return dateTime.toNepaliDateTime();
  }
  @override
  final int year;

  @override
  final int month;

  @override
  final int day;

  @override
  final int hour;

  @override
  final int minute;

  @override
  final int second;

  @override
  final int millisecond;

  @override
  final int microsecond;

  List<int> get _englishMonths =>
      [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  List<int> get _englishLeapMonths =>
      [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  /// Returns total days in the [month] of the [year].
  int get totalDays => _nepaliYears[year]![month];

  /// Returns total days in the [year].
  int get totalDaysInYear => _nepaliYears[year]!.first;

  /// The day of the week Sunday..Saturday.
  @override
  int get weekday => toDateTime().weekday % 7 + 1;

  /// Returns true if this occurs after other
  @override
  bool isAfter(covariant NepaliDateTime nepaliDateTime) =>
      toDateTime().isAfter(nepaliDateTime.toDateTime());

  /// Returns true if this occurs before other.
  @override
  bool isBefore(covariant NepaliDateTime nepaliDateTime) =>
      toDateTime().isBefore(nepaliDateTime.toDateTime());

  /// Merges specified time to current date.
  NepaliDateTime mergeTime(int hour, int minute, int second) =>
      NepaliDateTime(year, month, day, hour, minute, second);

  ///Constructs a new [DateTime] instance based on [formattedString].
  ///
  ///Throws a [FormatException] if the input cannot be parsed.
  static NepaliDateTime parse(String formattedString) {
    final re = _parseFormat;
    final Match? match = re.firstMatch(formattedString);
    if (match != null) {
      int parseIntOrZero(String? matched) {
        if (matched == null) return 0;
        return int.parse(matched);
      }

      // Parses fractional second digits of '.(\d+)' into the combined
      // microseconds. We only use the first 6 digits because of DateTime
      // precision of 999 milliseconds and 999 microseconds.
      int parseMilliAndMicroseconds(String? matched) {
        if (matched == null) return 0;
        final length = matched.length;
        assert(length >= 1, 'matched string is empty');
        var result = 0;
        for (var i = 0; i < 6; i++) {
          result *= 10;
          if (i < matched.length) {
            result += matched.codeUnitAt(i) ^ 0x30;
          }
        }
        return result;
      }

      final years = int.parse(match[1]!);
      final month = int.parse(match[2]!);
      final day = int.parse(match[3]!);
      final hour = parseIntOrZero(match[4]);
      final minute = parseIntOrZero(match[5]);
      final second = parseIntOrZero(match[6]);
      final milliAndMicroseconds = parseMilliAndMicroseconds(match[7]);
      final millisecond =
          milliAndMicroseconds ~/ Duration.microsecondsPerMillisecond;
      final microsecond =
          milliAndMicroseconds.remainder(Duration.microsecondsPerMillisecond);

      return NepaliDateTime(
        years,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );
    } else {
      throw FormatException('Invalid NepaliDateTime format', formattedString);
    }
  }

  ///Constructs a new NepaliDateTime instance based on formattedString.
  static NepaliDateTime? tryParse(String formattedString) {
    try {
      return parse(formattedString);
    } on FormatException {
      return null;
    }
  }

  @override
  Duration difference(covariant NepaliDateTime other) =>
      toDateTime().difference(other.toDateTime());

  @override
  NepaliDateTime add(Duration duration) =>
      toDateTime().add(duration).toNepaliDateTime();

  @override
  NepaliDateTime subtract(Duration duration) =>
      toDateTime().subtract(duration).toNepaliDateTime();

  @override
  int get millisecondsSinceEpoch => toDateTime().millisecondsSinceEpoch;

  @override
  int get microsecondsSinceEpoch => toDateTime().microsecondsSinceEpoch;

  static String _fourDigits(int n) {
    final absN = n.abs();
    final sign = n < 0 ? '-' : '';
    if (absN >= 1000) return '$n';
    if (absN >= 100) return '${sign}0$absN';
    if (absN >= 10) return '${sign}00$absN';
    return '${sign}000$absN';
  }

  static String _sixDigits(int n) {
    assert(n < -9999 || n > 9999, "abs($n) can't be >= 10000");
    final absN = n.abs();
    final sign = n < 0 ? '-' : '+';
    if (absN >= 100000) return '$sign$absN';
    return '${sign}0$absN';
  }

  static String _threeDigits(int n) {
    if (n >= 100) return '$n';
    if (n >= 10) return '0$n';
    return '00$n';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  ///
  ///Returns a human-readable string for this instance.
  ///
  ///The returned string is constructed for the time zone of this instance.
  ///The `toString()` method provides a simply formatted string.
  ///
  ///The resulting string can be parsed back using [parse].
  ///
  @override
  String toString() {
    final y = _fourDigits(year);
    final m = _twoDigits(month);
    final d = _twoDigits(day);
    final h = _twoDigits(hour);
    final min = _twoDigits(minute);
    final sec = _twoDigits(second);
    final ms = _threeDigits(millisecond);
    final us = microsecond == 0 ? '' : _threeDigits(microsecond);
    return '$y-$m-$d $h:$min:$sec.$ms$us';
  }

  @override
  String toIso8601String() {
    final y =
        (year >= -9999 && year <= 9999) ? _fourDigits(year) : _sixDigits(year);
    final m = _twoDigits(month);
    final d = _twoDigits(day);
    final h = _twoDigits(hour);
    final min = _twoDigits(minute);
    final sec = _twoDigits(second);
    final ms = _threeDigits(millisecond);
    final us = microsecond == 0 ? '' : _threeDigits(microsecond);
    return '$y-$m-${d}T$h:$min:$sec.$ms$us';
  }

  static final RegExp _parseFormat = RegExp(
      r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)' // Day part.
      r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,](\d{1,6}))?)?)?' // Time part.
      r'( ?[zZ]| ?([-+])(\d\d)(?::?(\d\d))?)?)?$');

  /// Formats [NepaliDateTime] as per the pattern provided.
  ///
  /// For wider set of formatting, use [NepaliDateFormat].
  String format(String pattern, [Language? language]) =>
      NepaliDateFormat(pattern, language).format(this);

  /// Converts the [NepaliDateTime] to corresponding [DateTime].
  ///
  /// Can be used to convert BS to AD.
  DateTime toDateTime() {
    // Setting english reference to 1913/1/1, which converts to 1969/9/18
    var englishYear = 1913;
    var englishMonth = 1;
    var englishDay = 1;

    var difference = _nepaliDateDifference(
      NepaliDateTime(year, month, day),
      NepaliDateTime(1969, 9, 18),
    );

    // Getting english year until the difference remains less than 365
    while (difference >= (_isLeapYear(englishYear) ? 366 : 365)) {
      difference = difference - (_isLeapYear(englishYear) ? 366 : 365);
      englishYear++;
    }

    // Getting english month until the difference remains less than 31
    final monthDays =
        _isLeapYear(englishYear) ? _englishLeapMonths : _englishMonths;
    var i = 0;
    while (difference >= monthDays[i]) {
      englishMonth++;
      difference -= monthDays[i];
      i++;
    }

    // Remaining days is the nepaliDateTime;
    englishDay += difference;

    return DateTime(
      englishYear,
      englishMonth,
      englishDay,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  int _nepaliDateDifference(NepaliDateTime date, NepaliDateTime refDate) {
    // Getting difference from the current nepaliDateTime
    // with the nepaliDateTime provided
    // final difference = (refDate.year-nepaliDateTime.year)*12*()
    final difference = _countTotalNepaliDays(date.year, date.month, date.day) -
        _countTotalNepaliDays(refDate.year, refDate.month, refDate.day);
    return (difference < 0 ? -difference : difference);
  }

  int _countTotalNepaliDays(int year, int month, int day) {
    var total = 0;
    if (year < 1969) return 0;

    final yearData = _nepaliYears[year]!;

    total += day - 1;

    for (var i = 1; i < month; i++) {
      total += yearData[i];
    }

    for (var i = 1969; i < year; i++) {
      total += _nepaliYears[i]!.first;
    }

    return total;
  }

  bool _isLeapYear(int year) =>
      (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));

  @override
  int compareTo(covariant NepaliDateTime other) {
    if (isBefore(other)) {
      return -1;
    } else if (isAfter(other)) {
      return 1;
    }
    return 0;
  }

  @override
  bool isAtSameMomentAs(covariant NepaliDateTime other) {
    return millisecondsSinceEpoch == other.millisecondsSinceEpoch;
  }

  @override
  bool get isUtc => false;

  @override
  String get timeZoneName => 'Nepal Time';

  @override
  Duration get timeZoneOffset => const Duration(hours: 5, minutes: 45);

  @override
  NepaliDateTime toLocal() => this;

  @Deprecated('Non operational')
  @override
  DateTime toUtc() => throw UnimplementedError();
}

List<int> _getMonthList(int year) {
  final list = _nepaliYears[year];
  if (list == null) {
    throw RangeError.range(
      year,
      1969,
      2250,
      'Unsupported year',
      'Supported year is 1970-2250',
    );
  }
  return list;
}

const Map<int, List<int>> _nepaliYears = {
  1969: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  1970: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  1971: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  1972: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  1973: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  1974: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  1975: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  1976: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  1977: [365, 30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  1978: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  1979: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  1980: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  1981: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  1982: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  1983: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  1984: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  1985: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  1986: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  1987: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  1988: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  1989: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  1990: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  1991: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  1992: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  1993: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  1994: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  1995: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  1996: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  1997: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  1998: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  1999: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2000: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2001: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2002: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2003: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2004: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2005: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2006: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2007: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2008: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  2009: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2010: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2011: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2012: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2013: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2014: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2015: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2016: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2017: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2018: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2019: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2020: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2021: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2022: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2023: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2024: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2025: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2026: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2027: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2028: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2029: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  2030: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2031: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2032: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2033: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2034: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2035: [365, 30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  2036: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2037: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2038: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2039: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2040: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2041: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2042: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2043: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2044: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2045: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2046: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2047: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2048: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2049: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2050: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2051: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2052: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2053: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2054: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2055: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2056: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  2057: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2058: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2059: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2060: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2061: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2062: [365, 30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
  2063: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2064: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2065: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2066: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  2067: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2068: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2069: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2070: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2071: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2072: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2073: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2074: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2075: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2076: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2077: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2078: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2079: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2080: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2081: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2082: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2083: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2084: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2085: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2086: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2087: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2088: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2089: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2090: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2091: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2092: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2093: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  2094: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2095: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2096: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2097: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2098: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2099: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2100: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2101: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2102: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2103: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2104: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2105: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2106: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2107: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2108: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2109: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2110: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2111: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2112: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2113: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2114: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  2115: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2116: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2117: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2118: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2119: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2120: [365, 30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  2121: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2122: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2123: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2124: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2125: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2126: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2127: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2128: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2129: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2130: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2131: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2132: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2133: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2134: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2135: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2136: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2137: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2138: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2139: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2140: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2141: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  2142: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2143: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2144: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2145: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2146: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2147: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2148: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2149: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2150: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2151: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  2152: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2153: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2154: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2155: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2156: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2157: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2158: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2159: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2160: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2161: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2162: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2163: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2164: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2165: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2166: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2167: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2168: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2169: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2170: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2171: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2172: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  2173: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2174: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2175: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2176: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2177: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2178: [365, 30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  2179: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2180: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2181: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2182: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2183: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2184: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2185: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2186: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2187: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2188: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2189: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2190: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2191: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2192: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2193: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2194: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2195: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2196: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2197: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2198: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2199: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  2200: [372, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31],
  2201: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2202: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2203: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2204: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2205: [365, 31, 31, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
  2206: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2207: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2208: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2209: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2210: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2211: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2212: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2213: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2214: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2215: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2216: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2217: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2218: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2219: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2220: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2221: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2222: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2223: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2224: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2225: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2226: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  2227: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2228: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2229: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2230: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2231: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2232: [365, 30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
  2233: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2234: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2235: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2236: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  2237: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2238: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2239: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2240: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2241: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2242: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2243: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2244: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2245: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2246: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2247: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2248: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2249: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2250: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
};
