import 'dart:core';

class NepaliDateTime {
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;
  final int millisecond;
  final int microsecond;

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

  static List<List<int>> _nepaliMonths;
  static List<int> _englishMonths, _englishLeapMonths;

  int get weekDay {
    //ReferencenepaliDateTime 2000/1/1 Wednesday
    int difference = NepaliDateTime(year, month, day)
        .difference(NepaliDateTime(2000, 1, 1))
        .inDays;
    if (NepaliDateTime(year, month, day).isAfter(NepaliDateTime(2026, 9, 17))) {
      difference++;
    }
    int weekday = (3 + (difference % 7)) % 7;
    return weekday == 0 ? 7 : weekday;
  }

  bool isAfter(NepaliDateTime nepaliDateTime) =>
      NepaliDateTime(year, month, day)
          .toDateTime()
          .isAfter(nepaliDateTime.toDateTime());

  bool isBefore(NepaliDateTime nepaliDateTime) =>
      NepaliDateTime(year, month, day)
          .toDateTime()
          .isBefore(nepaliDateTime.toDateTime());

  static NepaliDateTime now() => NepaliDateTime.fromDateTime(DateTime.now());

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
  static NepaliDateTime parse(String formattedString) {
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
        int length = matched.length;
        assert(length >= 1);
        assert(length <= 6);

        int result = 0;
        for (int i = 0; i < 6; i++) {
          result *= 10;
          if (i < matched.length) {
            result += matched.codeUnitAt(i) ^ 0x30;
          }
        }
        return result;
      }

      int years = int.parse(match[1]);
      int month = int.parse(match[2]);
      int day = int.parse(match[3]);
      int hour = parseIntOrZero(match[4]);
      int minute = parseIntOrZero(match[5]);
      int second = parseIntOrZero(match[6]);
      int milliAndMicroseconds = parseMilliAndMicroseconds(match[7]);
      int millisecond =
          milliAndMicroseconds ~/ Duration.microsecondsPerMillisecond;
      int microsecond =
          milliAndMicroseconds.remainder(Duration.microsecondsPerMillisecond);

      return NepaliDateTime(
          years, month, day, hour, minute, second, millisecond, microsecond);
    } else {
      throw FormatException("InvalidnepaliDateTime format", formattedString);
    }
  }

  static NepaliDateTime tryParse(String formattedString) {
    try {
      return parse(formattedString);
    } on FormatException {
      return null;
    }
  }

  Duration difference(NepaliDateTime other) {
    DateTime thisDate = NepaliDateTime(year, month, day).toDateTime();
    thisDate = DateTime(
      thisDate.year,
      thisDate.month,
      thisDate.day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );

    DateTime otherDate = other.toDateTime();
    otherDate = DateTime(
      otherDate.year,
      otherDate.month,
      otherDate.day,
      other.hour,
      other.minute,
      other.second,
      other.millisecond,
      other.microsecond,
    );
    return thisDate.difference(otherDate);
  }

  static String _fourDigits(int n) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String _sixDigits(int n) {
    assert(n < -9999 || n > 9999);
    int absN = n.abs();
    String sign = n < 0 ? "-" : "+";
    if (absN >= 100000) return "$sign$absN";
    return "${sign}0$absN";
  }

  static String _threeDigits(int n) {
    if (n >= 100) return "${n}";
    if (n >= 10) return "0${n}";
    return "00${n}";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "${n}";
    return "0${n}";
  }

  ///
  ///Returns a human-readable string for this instance.
  ///
  ///The returned string is constructed for the time zone of this instance.
  ///The `toString()` method provides a simply formatted string.
  ///
  ///The resulting string can be parsed back using [parse].
  ///
  String toString() {
    String y = _fourDigits(year);
    String m = _twoDigits(month);
    String d = _twoDigits(day);
    String h = _twoDigits(hour);
    String min = _twoDigits(minute);
    String sec = _twoDigits(second);
    String ms = _threeDigits(millisecond);
    String us = microsecond == 0 ? "" : _threeDigits(microsecond);
    return "$y-$m-$d $h:$min:$sec.$ms$us";
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
    String y =
        (year >= -9999 && year <= 9999) ? _fourDigits(year) : _sixDigits(year);
    String m = _twoDigits(month);
    String d = _twoDigits(day);
    String h = _twoDigits(hour);
    String min = _twoDigits(minute);
    String sec = _twoDigits(second);
    String ms = _threeDigits(millisecond);
    String us = microsecond == 0 ? "" : _threeDigits(microsecond);
    return "$y-$m-${d}T$h:$min:$sec.$ms$us";
  }

  static final RegExp _parseFormat = RegExp(
      r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)' // Day part.
      r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,](\d{1,6}))?)?)?' // Time part.
      r'( ?[zZ]| ?([-+])(\d\d)(?::?(\d\d))?)?)?$'); // Timezone part.

  factory NepaliDateTime.fromDateTime(DateTime dateTime) {
    _initializeLists();
    //Setting nepali reference to 2000/1/1 with englishnepaliDateTime 1943/4/14
    int nepaliYear = 2000;
    int nepaliMonth = 1;
    int nepaliDay = 1;

    // Time was causing error while differencing dates.
    DateTime _date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    int difference = _date.difference(DateTime(1943, 4, 14)).inDays;

    // 1970-1-1 is epoch and it's duration is only 18 hours 15 minutes in dart
    // You can test using `print(DateTime(1970,1,2).difference(DateTime(1970,1,1)))`;
    // So, in order to compensate it one extra day is added from thisnepaliDateTime.
    if (_date.isAfter(DateTime(1970, 1, 1))) difference++;

    //Getting nepali year until the difference remains less than 365
    int index = 0;
    while (difference >= _nepaliYearDays(index)) {
      nepaliYear++;
      difference = difference - _nepaliYearDays(index);
      index++;
    }

    //Getting nepali month until the difference remains less than 31
    int i = 0;
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

  DateTime toDateTime() {
    //Setting english reference to 1944/1/1 with nepali nepaliDateTime 2000/9/17
    int englishYear = 1944;
    int englishMonth = 1;
    int englishDay = 1;

    int difference = _nepaliDateDifference(
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
    int i = 0;
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

  static int _nepaliYearDays(int index) {
    int total = 0;
    for (int i = 0; i < 12; i++) {
      total += _nepaliMonths[index][i];
    }
    return total;
  }

  int _nepaliDateDifference(
      NepaliDateTime nepaliDateTime, NepaliDateTime refDate) {
    //Getting difference from the current nepaliDateTime with the nepaliDateTime provided
    int difference = _countTotalNepaliDays(
            nepaliDateTime.year, nepaliDateTime.month, nepaliDateTime.day) -
        _countTotalNepaliDays(refDate.year, refDate.month, refDate.day);
    return (difference < 0 ? -difference : difference);
  }

  int _countTotalNepaliDays(int year, int month, int nepaliDateTime) {
    int total = 0;
    if (year < 2000) {
      return 0;
    }

    total = total + (nepaliDateTime - 1);

    int yearIndex = year - 2000;
    for (int i = 0; i < month - 1; i++) {
      total = total + _nepaliMonths[yearIndex][i];
    }

    for (int i = 0; i < yearIndex; i++) {
      total = total + _nepaliYearDays(i);
    }

    return total;
  }

  bool _isLeapYear(int year) =>
      (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));

  static _initializeLists() {
    _englishMonths ??= [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    _englishLeapMonths ??= [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    _nepaliMonths ??= [
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
  }
}
