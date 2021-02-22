// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'language.dart';
import 'nepali_date_format.dart';

///
extension ENepaliDateTime on DateTime {
  /// Converts the [DateTime] to [NepaliDateTime].
  NepaliDateTime toNepaliDateTime() {
    //Setting nepali reference to 2000/1/1 with english NepaliDateTime 1943/4/14
    var nepaliYear = 2000;
    var nepaliMonth = 1;
    var nepaliDay = 1;

    // Time was causing error while differencing dates.
    var _date = DateTime(year, month, day);
    var difference = _date.difference(DateTime(1943, 4, 14)).inDays;

    // 1970-1-1 is epoch and it's duration is only 18 hours 15 minutes in dart
    // You can test using `print(DateTime(1970,1,2).difference(DateTime(1970,1,1)))`;
    // So, in order to compensate it one extra day is added from this NepaliDateTime.
    if (_date.isAfter(DateTime(1970, 1, 1))) difference++;

    //Getting nepali year until the difference remains less than 365
    var index = 0;
    while (difference >= _yearDays[index]) {
      nepaliYear++;
      difference = difference - _yearDays[index];
      index++;
    }

    //Getting nepali month until the difference remains less than 31
    var i = 0;
    while (difference >= _nepaliMonths[index][i]) {
      difference = difference - _nepaliMonths[index][i];
      nepaliMonth++;
      i++;
    }

    //Remaining days is the actual day;
    nepaliDay += difference;

    return NepaliDateTime(
      nepaliYear,
      nepaliMonth,
      nepaliDay,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }
}

/// An instant in time, such as Mangsir 05, 2076, 11:05am
class NepaliDateTime implements DateTime {
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

  /// Constructs a NepaliDateTime instance specified.
  NepaliDateTime(
    this.year, [
    this.month = 1,
    this.day = 1,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.millisecond = 0,
    this.microsecond = 0,
  ]);

  List<int> get _englishMonths =>
      [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  List<int> get _englishLeapMonths =>
      [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  /// Returns total days in a month.
  int get totalDays => _nepaliMonths[year % 2000][month - 1];

  /// The day of the week [Sunday]..[Saturday].
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

  /// Constructs a DateTime instance with current date and time
  factory NepaliDateTime.now() => DateTime.now().toNepaliDateTime();

  ///Constructs a new [DateTime] instance based on [formattedString].
  ///
  ///Throws a [FormatException] if the input cannot be parsed.
  static NepaliDateTime parse(String formattedString) {
    var re = _parseFormat;
    Match? match = re.firstMatch(formattedString);
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
        var length = matched.length;
        assert(length >= 1);
        var result = 0;
        for (var i = 0; i < 6; i++) {
          result *= 10;
          if (i < matched.length) {
            result += matched.codeUnitAt(i) ^ 0x30;
          }
        }
        return result;
      }

      var years = int.parse(match[1]!);
      var month = int.parse(match[2]!);
      var day = int.parse(match[3]!);
      var hour = parseIntOrZero(match[4]);
      var minute = parseIntOrZero(match[5]);
      var second = parseIntOrZero(match[6]);
      var milliAndMicroseconds = parseMilliAndMicroseconds(match[7]);
      var millisecond =
          milliAndMicroseconds ~/ Duration.microsecondsPerMillisecond;
      var microsecond =
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
    var absN = n.abs();
    var sign = n < 0 ? '-' : '';
    if (absN >= 1000) return '$n';
    if (absN >= 100) return '${sign}0$absN';
    if (absN >= 10) return '${sign}00$absN';
    return '${sign}000$absN';
  }

  static String _sixDigits(int n) {
    assert(n < -9999 || n > 9999);
    var absN = n.abs();
    var sign = n < 0 ? '-' : '+';
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
    var y = _fourDigits(year);
    var m = _twoDigits(month);
    var d = _twoDigits(day);
    var h = _twoDigits(hour);
    var min = _twoDigits(minute);
    var sec = _twoDigits(second);
    var ms = _threeDigits(millisecond);
    var us = microsecond == 0 ? '' : _threeDigits(microsecond);
    return '$y-$m-$d $h:$min:$sec.$ms$us';
  }

  @override
  String toIso8601String() {
    var y =
        (year >= -9999 && year <= 9999) ? _fourDigits(year) : _sixDigits(year);
    var m = _twoDigits(month);
    var d = _twoDigits(day);
    var h = _twoDigits(hour);
    var min = _twoDigits(minute);
    var sec = _twoDigits(second);
    var ms = _threeDigits(millisecond);
    var us = microsecond == 0 ? '' : _threeDigits(microsecond);
    return '$y-$m-${d}T$h:$min:$sec.$ms$us';
  }

  static final RegExp _parseFormat = RegExp(
      r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)' // Day part.
      r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,](\d{1,6}))?)?)?' // Time part.
      r'( ?[zZ]| ?([-+])(\d\d)(?::?(\d\d))?)?)?$'); // Timezone part.

  /// Converts the specified [DateTime] to [NepaliDateTime].
  ///
  /// Use [toNepaliDateTime()] exposed to [DateTime] object instead.
  @deprecated
  factory NepaliDateTime.fromDateTime(DateTime dateTime) =>
      dateTime.toNepaliDateTime();

  /// Formats [NepaliDateTime] as per the pattern provided.
  ///
  /// For wider set of formatting, use [NepaliDateFormat].
  String format(String pattern, [Language? language]) =>
      NepaliDateFormat(pattern, language).format(this);

  /// Converts the [NepaliDateTime] to corresponding [DateTime].
  ///
  /// Can be used to convert BS to AD.
  DateTime toDateTime() {
    //Setting english reference to 1944/1/1 with nepali nepaliDateTime 2000/9/17
    var englishYear = 1944;
    var englishMonth = 1;
    var englishDay = 1;

    var difference = _nepaliDateDifference(
      NepaliDateTime(year, month, day),
      NepaliDateTime(2000, 9, 17),
    );

    //Getting english year until the difference remains less than 365
    while (difference >= (_isLeapYear(englishYear) ? 366 : 365)) {
      difference = difference - (_isLeapYear(englishYear) ? 366 : 365);
      englishYear++;
    }

    //Getting english month until the difference remains less than 31
    var monthDays =
        _isLeapYear(englishYear) ? _englishLeapMonths : _englishMonths;
    var i = 0;
    while (difference >= monthDays[i]) {
      englishMonth++;
      difference = difference - monthDays[i];
      i++;
    }

    //Remaining days is the nepaliDateTime;
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

  int _nepaliDateDifference(
      NepaliDateTime nepaliDateTime, NepaliDateTime refDate) {
    //Getting difference from the current nepaliDateTime with the nepaliDateTime provided
    //final difference = (refDate.year-nepaliDateTime.year)*12*()
    var difference = _countTotalNepaliDays(
            nepaliDateTime.year, nepaliDateTime.month, nepaliDateTime.day) -
        _countTotalNepaliDays(refDate.year, refDate.month, refDate.day);
    return (difference < 0 ? -difference : difference);
  }

  int _countTotalNepaliDays(int year, int month, int day) {
    var total = 0;
    if (year < 2000) {
      return 0;
    }

    total += day - 1;

    final yearIndex = year - 2000;
    final monthsInLatestYear = _nepaliMonths[yearIndex];

    for (var i = 0; i < month - 1; i++) {
      total += monthsInLatestYear[i];
    }

    for (var i = 0; i < yearIndex; i++) {
      total += _yearDays[i];
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
  Duration get timeZoneOffset => Duration(hours: 5, minutes: 45);

  @override
  NepaliDateTime toLocal() => this;

  @Deprecated('Non operational')
  @override
  DateTime toUtc() => throw UnimplementedError();
}

const List<int> _yearDays = [
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  366,
  365,
  365,
  365,
  366,
  365,
  365,
  365,
  366,
  364,
  366,
  365,
  365,
];

const List<List<int>> _nepaliMonths = [
  [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31], //2000
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30], //2010
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30], //2020
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31], //2030
  [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30], //2040
  [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31], //2050
  [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30], //2060
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30], //2070
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30], //2080
  [31, 31, 32, 32, 31, 30, 30, 30, 29, 30, 30, 30],
  [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
  [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30],
  [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30],
  [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 30, 30],
  [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30],
  [30, 31, 32, 32, 30, 31, 30, 30, 29, 30, 30, 30],
  [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
  [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30], //2090
  [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30],
  [30, 31, 32, 32, 31, 30, 30, 30, 29, 30, 30, 30],
  [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
  [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30],
  [31, 31, 32, 31, 31, 31, 30, 29, 30, 30, 30, 30],
  [30, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
  [31, 31, 32, 31, 31, 31, 29, 30, 29, 30, 29, 31],
  [31, 31, 32, 31, 31, 31, 30, 29, 29, 30, 30, 30], //2099
];
