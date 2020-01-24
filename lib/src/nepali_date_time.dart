// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'nepali_date_format.dart';
import 'nepali_language.dart';

///
extension ENepaliDateTime on DateTime {
  /// Converts the [DateTime] to [NepaliDateTime].
  NepaliDateTime toNepaliDateTime() {
    //Setting nepali reference to 2000/1/1 with englishnepaliDateTime 1943/4/14
    var nepaliYear = 2000;
    var nepaliMonth = 1;
    var nepaliDay = 1;

    // Time was causing error while differencing dates.
    var _date = DateTime(year, month, day);
    var difference = _date.difference(DateTime(1943, 4, 14)).inDays;

    // 1970-1-1 is epoch and it's duration is only 18 hours 15 minutes in dart
    // You can test using `print(DateTime(1970,1,2).difference(DateTime(1970,1,1)))`;
    // So, in order to compensate it one extra day is added from thisnepaliDateTime.
    if (_date.isAfter(DateTime(1970, 1, 1))) difference++;

    //Getting nepali year until the difference remains less than 365
    var index = 0;
    while (difference >= _nepaliYearDays(index)) {
      nepaliYear++;
      difference = difference - _nepaliYearDays(index);
      index++;
    }

    //Getting nepali month until the difference remains less than 31
    var i = 0;
    while (difference >= _nepaliMonths[index][i]) {
      difference = difference - _nepaliMonths[index][i];
      nepaliMonth++;
      i++;
    }

    //Remaning days is the actual day;
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
class NepaliDateTime {
  /// The year.
  final int year;

  /// The month 1..12.
  final int month;

  /// The day of the month.
  final int day;

  /// The hour of the day, expressed as in a 24-hour clock 0..23.
  final int hour;

  /// The minute 0...59.
  final int minute;

  /// The second 0...59.
  final int second;

  /// The millisecond 0...999.
  final int millisecond;

  /// The microsecond 0...999.
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

  /// Returns true if this occurs after other
  bool isAfter(NepaliDateTime nepaliDateTime) =>
      toDateTime().isAfter(nepaliDateTime.toDateTime());

  /// Returns true if this occurs before other.
  bool isBefore(NepaliDateTime nepaliDateTime) =>
      toDateTime().isBefore(nepaliDateTime.toDateTime());

  /// Merges specified time to current date.
  NepaliDateTime mergeTime(int hour, int minute, int second) =>
      NepaliDateTime(year, month, day, hour, minute, second);

  /// Constructs a DateTime instance with current date and time
  factory NepaliDateTime.now() => DateTime.now().toNepaliDateTime();

  ///
  ///Constructs a new [DateTime] instance based on [formattedString].
  ///
  ///Throws a [FormatException] if the input cannot be parsed.
  ///
  ///The function parses a subset of ISO 8601
  ///which includes the subset accepted by RFC 3339.
  ///
  ///The accepted inputs are currently:
  ///
  /// AnepaliDateTime: A signed four-to-six digit year, two digit month and
  ///  two digit day, optionally separated by `-` characters.
  ///  Examples: "19700101", "-0004-12-24", "81030-04-01".
  /// An optional time part, separated from thenepaliDateTime by either `T` or a space.
  ///  The time part is a two digit hour,
  ///  then optionally a two digit minutes value,
  ///  then optionally a two digit seconds value, and
  ///  then optionally a '.' or ',' followed by a one-to-six digit second fraction.
  ///  The minutes and seconds may be separated from the previous parts by a
  ///  ':'.
  ///  Examples: "12", "12:30:24.124", "12:30:24,124", "123010.50".
  ///
  ///  The minutes may be separated from the hours by a ':'.
  ///  Examples: "-10", "01:30", "1130".
  ///
  ///This includes the output of both [toString] and [toIso8601String], which
  ///will be parsed back into a `NepaliDateTime` object with the same time as the
  ///original.
  ///
  ///
  ///Examples of accepted strings:
  ///
  /// `"2012-02-27 13:27:00"`
  /// `"2012-02-27 13:27:00.123456"`
  /// `"2012-02-27 13:27:00,123456"`
  /// `"20120227 13:27:00"`
  /// `"20120227T132700"`
  /// `"20120227"`
  /// `"+20120227"`
  /// `"2012-02-27T14+00:00"`
  /// `"2002-02-27T14:00:00-0500"`
  ///
  factory NepaliDateTime.parse(String formattedString) {
    var re = _parseFormat;
    Match match = re.firstMatch(formattedString);
    if (match != null) {
      int parseIntOrZero(String matched) {
        if (matched == null) return 0;
        return int.parse(matched);
      }

      // Parses fractional second digits of '.(\d{1,6})' into the combined
      // microseconds.
      int parseMilliAndMicroseconds(String matched) {
        if (matched == null) return 0;
        var length = matched.length;
        assert(length >= 1);
        assert(length <= 6);

        var result = 0;
        for (var i = 0; i < 6; i++) {
          result *= 10;
          if (i < matched.length) {
            result += matched.codeUnitAt(i) ^ 0x30;
          }
        }
        return result;
      }

      var years = int.parse(match[1]);
      var month = int.parse(match[2]);
      var day = int.parse(match[3]);
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
      throw FormatException('InvalidnepaliDateTime format', formattedString);
    }
  }

  ///Constructs a new NepaliDateTime instance based on formattedString.
  factory NepaliDateTime.tryParse(String formattedString) {
    try {
      return NepaliDateTime.parse(formattedString);
    } on FormatException {
      return null;
    }
  }

  /// Returns a [Duration] with the difference between [this] and [other].
  Duration difference(NepaliDateTime other) =>
      toDateTime().difference(other.toDateTime());

  /// Returns a new [NepaliDateTime] instance with [Duration] added to [this].
  NepaliDateTime add(Duration duration) =>
      toDateTime().add(duration).toNepaliDateTime();

  /// Returns a new [NepaliDateTime] instance with [Duration] substracted to [this].
  NepaliDateTime subtract(Duration duration) =>
      toDateTime().subtract(duration).toNepaliDateTime();

  /// The number of milliseconds since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  int get millisecondsSinceEpoch => toDateTime().millisecondsSinceEpoch;

  /// The number of microseconds since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  int get microsecondsSinceEpoch => toDateTime().microsecondsSinceEpoch;

  /// The day of the week sunday..saturday.
  int get weekDay {
    //ReferencenepaliDateTime 2000/1/1 Wednesday
    var difference = this.difference(NepaliDateTime(2000, 1, 1)).inDays;
    if (isAfter(NepaliDateTime(2026, 9, 17))) {
      difference++;
    }
    var weekday = (3 + (difference % 7)) % 7;
    return weekday == 0 ? 7 : weekday;
  }

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

  ///
  ///Returns an ISO-8601 full-precision extended format representation.
  ///
  ///The format is `yyyy-MM-ddTHH:mm:ss.mmmuuu`,
  ///where:
  ///
  /// `yyyy` is a, possibly negative, four digit representation of the year,
  /// if the year is in the range -9999 to 9999,
  /// otherwise it is a signed six digit representation of the year.
  /// `MM` is the month in the range 01 to 12,
  /// `dd` is the day of the month in the range 01 to 31,
  /// `HH` are hours in the range 00 to 23,
  /// `mm` are minutes in the range 00 to 59,
  /// `ss` are seconds in the range 00 to 59 (no leap seconds),
  /// `mmm` are milliseconds in the range 000 to 999, and
  /// `uuu` are microseconds in the range 001 to 999. If [microsecond] equals
  /// 0, then this part is omitted.
  ///
  /// The resulting string can be parsed back using [parse].
  ///
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
  factory NepaliDateTime.fromDateTime(DateTime dateTime) {
    //Setting nepali reference to 2000/1/1 with englishnepaliDateTime 1943/4/14
    var nepaliYear = 2000;
    var nepaliMonth = 1;
    var nepaliDay = 1;

    // Time was causing error while differencing dates.
    var _date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    var difference = _date.difference(DateTime(1943, 4, 14)).inDays;

    // 1970-1-1 is epoch and it's duration is only 18 hours 15 minutes in dart
    // You can test using `print(DateTime(1970,1,2).difference(DateTime(1970,1,1)))`;
    // So, in order to compensate it one extra day is added from thisnepaliDateTime.
    if (_date.isAfter(DateTime(1970, 1, 1))) difference++;

    //Getting nepali year until the difference remains less than 365
    var index = 0;
    while (difference >= _nepaliYearDays(index)) {
      nepaliYear++;
      difference = difference - _nepaliYearDays(index);
      index++;
    }

    //Getting nepali month until the difference remains less than 31
    var i = 0;
    while (difference >= _nepaliMonths[index][i]) {
      difference = difference - _nepaliMonths[index][i];
      nepaliMonth++;
      i++;
    }

    //Remaning days is the actual day;
    nepaliDay += difference;

    return NepaliDateTime(
      nepaliYear,
      nepaliMonth,
      nepaliDay,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
      dateTime.microsecond,
    );
  }

  /// Formats [NepaliDateTime] as per the pattern provided.
  ///
  /// For wider set of formatting, use [NepaliDateFormat].
  String format(String pattern, [Language language]) =>
      NepaliDateFormat(pattern, language: language).format(this);

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
    var difference = _countTotalNepaliDays(
            nepaliDateTime.year, nepaliDateTime.month, nepaliDateTime.day) -
        _countTotalNepaliDays(refDate.year, refDate.month, refDate.day);
    return (difference < 0 ? -difference : difference);
  }

  int _countTotalNepaliDays(int year, int month, int nepaliDateTime) {
    var total = 0;
    if (year < 2000) {
      return 0;
    }

    total = total + (nepaliDateTime - 1);

    var yearIndex = year - 2000;
    for (var i = 0; i < month - 1; i++) {
      total = total + _nepaliMonths[yearIndex][i];
    }

    for (var i = 0; i < yearIndex; i++) {
      total = total + _nepaliYearDays(i);
    }

    return total;
  }

  bool _isLeapYear(int year) =>
      (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
}

List<List<int>> get _nepaliMonths => [
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

int _nepaliYearDays(int index) {
  var total = 0;
  for (var i = 0; i < 12; i++) {
    total += _nepaliMonths[index][i];
  }
  return total;
}
