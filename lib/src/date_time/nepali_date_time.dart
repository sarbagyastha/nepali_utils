// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/date_time/calendar/bs_calendar.dart';
import 'package:nepali_utils/src/date_time/calendar/epoch_day.dart';
import 'package:nepali_utils/src/date_time/calendar/gregorian.dart';
import 'package:nepali_utils/src/date_time/format/nepali_date_format.dart';
import 'package:nepali_utils/src/date_time/parsing.dart';
import 'package:nepali_utils/src/date_time/time_units.dart';
import 'package:nepali_utils/src/date_time/time_zone.dart';
import 'package:nepali_utils/src/language.dart';

/// Wall-clock parts cached by every [NepaliDateTime].
typedef _Parts = ({int wallClock, int year, int month, int day});

_Parts _partsOf(int microsecondsSinceEpoch, NepaliZone zone, int? knownWall) {
  final wallClock = knownWall ?? zone.wallClockOf(microsecondsSinceEpoch);
  final (year, month, day) = BsCalendar.fromEpochDay(
    EpochDay.ofMicroseconds(wallClock),
  );
  return (wallClock: wallClock, year: year, month: month, day: day);
}

/// An instant in time, presented in the Bikram Sambat (BS) calendar,
/// such as Mangsir 05, 2076, 11:05am.
///
/// Behaves like [DateTime]: it represents an exact instant
/// ([microsecondsSinceEpoch]) and presents its fields in a time zone, which
/// is either the local time zone, UTC, or Nepal Time (UTC+05:45, see
/// [NepaliDateTime.nepal] and [toNepalTime]).
///
/// Since it implements [DateTime] it can be passed anywhere a [DateTime] is
/// expected for instant-based operations (comparison, difference, epoch
/// values). Note however that [year], [month], [day] and [weekday] are Bikram
/// Sambat values, and [weekday] runs from [sunday] (1) to [saturday] (7).
///
/// Out-of-range components are normalised like [DateTime] does:
///
/// ```dart
/// NepaliDateTime(2080, 1, 35); // 2080-02-04 (Baishakh 2080 has 31 days)
/// NepaliDateTime(2080, 13);    // 2081-01-01
/// NepaliDateTime(2080, 2, 0);  // 2080-01-31
/// ```
final class NepaliDateTime._(
  @override final int microsecondsSinceEpoch,
  final NepaliZone _zone, [
  // Wall-clock microseconds when already known by the caller, which saves a
  // time zone lookup for local values.
  int? wallClock,
]) implements DateTime {
  /// Constructs a [NepaliDateTime] in the local time zone.
  ///
  /// Out-of-range components are normalised, see [NepaliDateTime].
  /// Throws a [RangeError] if the result is outside the supported range
  /// ([minYear]-[maxYear]).
  factory(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) => ._fromFields(
    .local,
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
    microsecond,
  );

  /// Constructs a [NepaliDateTime] in UTC, like [DateTime.utc].
  factory utc(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) => ._fromFields(
    .utc,
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
    microsecond,
  );

  /// Constructs a [NepaliDateTime] in Nepal Time (UTC+05:45), regardless of
  /// the device's time zone.
  factory nepal(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) => ._fromFields(
    .nepal,
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
    microsecond,
  );

  /// The current date and time in the local time zone, like [DateTime.now].
  factory now() =>
      .fromMicrosecondsSinceEpoch(DateTime.now().microsecondsSinceEpoch);

  /// The current date and time in Nepal Time (UTC+05:45).
  factory nepalNow() =>
      NepaliDateTime._(DateTime.now().microsecondsSinceEpoch, .nepal);

  /// The instant [microsecondsSinceEpoch] after 1970-01-01T00:00:00Z.
  ///
  /// Presented in UTC when [isUtc] is true, otherwise in local time.
  factory fromMicrosecondsSinceEpoch(
    int microsecondsSinceEpoch, {
    bool isUtc = false,
  }) => NepaliDateTime._(microsecondsSinceEpoch, isUtc ? .utc : .local);

  /// The instant [millisecondsSinceEpoch] after 1970-01-01T00:00:00Z.
  ///
  /// Presented in UTC when [isUtc] is true, otherwise in local time.
  factory fromMillisecondsSinceEpoch(
    int millisecondsSinceEpoch, {
    bool isUtc = false,
  }) => .fromMicrosecondsSinceEpoch(
    millisecondsSinceEpoch * microsecondsPerMillisecond,
    isUtc: isUtc,
  );

  factory _fromFields(
    NepaliZone zone,
    int year,
    int month,
    int day,
    int hour,
    int minute,
    int second,
    int millisecond,
    int microsecond,
  ) {
    final epochDay = BsCalendar.toEpochDay(year, month, day);
    if (zone == .local) {
      // Let DateTime resolve DST gaps/overlaps and time overflow.
      final (y, m, d) = Gregorian.fromEpochDay(epochDay);
      return ._fromLocal(
        DateTime(y, m, d, hour, minute, second, millisecond, microsecond),
      );
    }
    final wallClock =
        epochDay.startMicroseconds +
        hour * microsecondsPerHour +
        minute * microsecondsPerMinute +
        second * microsecondsPerSecond +
        millisecond * microsecondsPerMillisecond +
        microsecond;
    final offset = zone == .nepal ? nepalOffsetMicroseconds : 0;
    return NepaliDateTime._(wallClock - offset, zone, wallClock);
  }

  /// The local [NepaliDateTime] at the same instant as the local [dateTime].
  factory _fromLocal(DateTime dateTime) {
    final instant = dateTime.microsecondsSinceEpoch;
    return NepaliDateTime._(
      instant,
      .local,
      instant + dateTime.timeZoneOffset.inMicroseconds,
    );
  }

  /// The [NepaliDateTime] at the same instant and in the same time zone
  /// (local or UTC) as [dateTime].
  ///
  /// Same as `dateTime.toNepaliDateTime()`. Returns [dateTime] unchanged if
  /// it already is a [NepaliDateTime].
  factory fromDateTime(DateTime dateTime) => switch (dateTime) {
    final NepaliDateTime nepaliDateTime => nepaliDateTime,
    DateTime(isUtc: true) => NepaliDateTime._(
      dateTime.microsecondsSinceEpoch,
      .utc,
    ),
    _ => ._fromLocal(dateTime),
  };

  /// Wall-clock parts, computed once from the primary constructor's
  /// parameters (this also validates the supported range).
  final _Parts _parts = _partsOf(microsecondsSinceEpoch, _zone, wallClock);

  /// The first supported Bikram Sambat year.
  static const int minYear = BsCalendar.minYear;

  /// The last supported Bikram Sambat year.
  static const int maxYear = BsCalendar.maxYear;

  // Weekday constants that are returned by [weekday] (Sunday first).

  /// Weekday value of Sunday (आइतबार).
  static const int sunday = 1;

  /// Weekday value of Monday (सोमबार).
  static const int monday = 2;

  /// Weekday value of Tuesday (मंगलबार).
  static const int tuesday = 3;

  /// Weekday value of Wednesday (बुधबार).
  static const int wednesday = 4;

  /// Weekday value of Thursday (बिहिबार).
  static const int thursday = 5;

  /// Weekday value of Friday (शुक्रबार).
  static const int friday = 6;

  /// Weekday value of Saturday (शनिबार).
  static const int saturday = 7;

  /// Number of days in a week.
  static const int daysPerWeek = 7;

  // Month constants that are returned by [month].

  /// Month value of Baishakh (बैशाख).
  static const int baishakh = 1;

  /// Month value of Jestha (जेष्ठ).
  static const int jestha = 2;

  /// Month value of Ashadh (आषाढ).
  static const int ashadh = 3;

  /// Month value of Shrawan (श्रावण).
  static const int shrawan = 4;

  /// Month value of Bhadra (भाद्र).
  static const int bhadra = 5;

  /// Month value of Ashwin (आश्विन).
  static const int ashwin = 6;

  /// Month value of Kartik (कार्तिक).
  static const int kartik = 7;

  /// Month value of Mangsir (मंसिर).
  static const int mangsir = 8;

  /// Month value of Poush (पौष).
  static const int poush = 9;

  /// Month value of Magh (माघ).
  static const int magh = 10;

  /// Month value of Falgun (फाल्गुण).
  static const int falgun = 11;

  /// Month value of Chaitra (चैत्र).
  static const int chaitra = 12;

  /// Number of months in a year.
  static const int monthsPerYear = 12;

  /// Constructs a new [NepaliDateTime] from [formattedString].
  ///
  /// Accepts the same formats as [DateTime.parse], with the date part in
  /// Bikram Sambat, e.g. `2080-01-15`, `2080-01-15 10:30:00` or
  /// `2080-01-15T10:30:00.123456Z`.
  ///
  /// * Without a time zone designator the result is in local time.
  /// * With `Z` or an offset the result is in UTC, like [DateTime.parse],
  ///   except that `+05:45` produces a value in Nepal Time.
  ///
  /// Throws a [FormatException] if the input cannot be parsed.
  static NepaliDateTime parse(String formattedString) {
    final parsed = parseDateTime(formattedString);
    if (parsed == null) {
      throw FormatException('Invalid NepaliDateTime format', formattedString);
    }
    final (
      :year,
      :month,
      :day,
      :hour,
      :minute,
      :second,
      :millisecond,
      :microsecond,
      :offsetMinutes,
    ) = parsed;

    NepaliDateTime build(NepaliZone zone, [int minuteAdjustment = 0]) =>
        ._fromFields(
          zone,
          year,
          month,
          day,
          hour,
          minute - minuteAdjustment,
          second,
          millisecond,
          microsecond,
        );

    try {
      return switch (offsetMinutes) {
        null => build(.local),
        345 => build(.nepal),
        final offset => build(.utc, offset),
      };
      // Mirrors DateTime.parse, which reports out-of-range values as
      // FormatException.
      // ignore: avoid_catching_errors
    } on RangeError catch (e) {
      throw FormatException('${e.message}', formattedString);
    }
  }

  /// Like [parse], but returns `null` instead of throwing on invalid input.
  static NepaliDateTime? tryParse(String formattedString) {
    try {
      return parse(formattedString);
    } on FormatException {
      return null;
    }
  }

  /// The Bikram Sambat year.
  @override
  int get year => _parts.year;

  /// The Bikram Sambat month, from [baishakh] (1) to [chaitra] (12).
  @override
  int get month => _parts.month;

  /// The day of the month, from 1 to 32.
  @override
  int get day => _parts.day;

  int get _microsecondOfDay => _parts.wallClock % microsecondsPerDay;

  @override
  int get hour => _microsecondOfDay ~/ microsecondsPerHour;

  @override
  int get minute => _microsecondOfDay ~/ microsecondsPerMinute % 60;

  @override
  int get second => _microsecondOfDay ~/ microsecondsPerSecond % 60;

  @override
  int get millisecond => _microsecondOfDay ~/ microsecondsPerMillisecond % 1000;

  @override
  int get microsecond => _microsecondOfDay % 1000;

  /// The day of the week, from [sunday] (1) to [saturday] (7).
  @override
  int get weekday => EpochDay.ofMicroseconds(_parts.wallClock).weekday;

  @override
  int get millisecondsSinceEpoch =>
      floorDiv(microsecondsSinceEpoch, microsecondsPerMillisecond);

  @override
  bool get isUtc => _zone == .utc;

  /// Whether this is presented in Nepal Time (UTC+05:45).
  bool get isNepalTime => _zone == .nepal;

  @override
  String get timeZoneName => switch (_zone) {
    .utc => 'UTC',
    .nepal => 'NPT',
    .local => toDateTime().timeZoneName,
  };

  @override
  Duration get timeZoneOffset => switch (_zone) {
    .utc => Duration.zero,
    .nepal => nepalTimeZoneOffset,
    .local => Duration(microseconds: _parts.wallClock - microsecondsSinceEpoch),
  };

  /// Number of days in this [month].
  int get totalDays => BsCalendar.daysInMonth(year, month);

  /// Number of days in this [year].
  int get totalDaysInYear => BsCalendar.daysInYear(year);

  /// This instant presented in UTC.
  @override
  NepaliDateTime toUtc() => _inZone(.utc);

  /// This instant presented in the local time zone.
  @override
  NepaliDateTime toLocal() => _inZone(.local);

  /// This instant presented in Nepal Time (UTC+05:45).
  NepaliDateTime toNepalTime() => _inZone(.nepal);

  NepaliDateTime _inZone(NepaliZone zone) =>
      zone == _zone ? this : NepaliDateTime._(microsecondsSinceEpoch, zone);

  /// Converts to a Gregorian [DateTime] representing the same instant.
  ///
  /// The result is in UTC if [isUtc], otherwise in local time (a [DateTime]
  /// cannot represent Nepal Time on a device that isn't in Nepal).
  DateTime toDateTime() =>
      .fromMicrosecondsSinceEpoch(microsecondsSinceEpoch, isUtc: isUtc);

  @override
  NepaliDateTime add(Duration duration) =>
      NepaliDateTime._(microsecondsSinceEpoch + duration.inMicroseconds, _zone);

  @override
  NepaliDateTime subtract(Duration duration) =>
      NepaliDateTime._(microsecondsSinceEpoch - duration.inMicroseconds, _zone);

  /// The difference between this and [other], which may be any [DateTime].
  @override
  Duration difference(DateTime other) => Duration(
    microseconds: microsecondsSinceEpoch - other.microsecondsSinceEpoch,
  );

  @override
  bool isBefore(DateTime other) =>
      microsecondsSinceEpoch < other.microsecondsSinceEpoch;

  @override
  bool isAfter(DateTime other) =>
      microsecondsSinceEpoch > other.microsecondsSinceEpoch;

  @override
  bool isAtSameMomentAs(DateTime other) =>
      microsecondsSinceEpoch == other.microsecondsSinceEpoch;

  @override
  int compareTo(DateTime other) =>
      microsecondsSinceEpoch.compareTo(other.microsecondsSinceEpoch);

  /// Creates a copy with the given fields replaced, in the same time zone.
  ///
  /// Out-of-range values are normalised, see [NepaliDateTime].
  NepaliDateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) => ._fromFields(
    _zone,
    year ?? this.year,
    month ?? this.month,
    day ?? this.day,
    hour ?? this.hour,
    minute ?? this.minute,
    second ?? this.second,
    millisecond ?? this.millisecond,
    microsecond ?? this.microsecond,
  );

  /// Same date with the time replaced by [hour]:[minute]:[second].
  NepaliDateTime mergeTime(int hour, int minute, int second) => copyWith(
    hour: hour,
    minute: minute,
    second: second,
    millisecond: 0,
    microsecond: 0,
  );

  /// Formats this as per [pattern].
  ///
  /// For a wider set of formatting, use [NepaliDateFormat].
  String format(String pattern, [Language? language]) =>
      NepaliDateFormat(pattern, language).format(this);

  /// Whether [other] is a [NepaliDateTime] at the same moment and in the same
  /// time zone, like [DateTime.==].
  @override
  bool operator ==(Object other) =>
      other is NepaliDateTime &&
      other.microsecondsSinceEpoch == microsecondsSinceEpoch &&
      other._zone == _zone;

  @override
  int get hashCode => Object.hash(microsecondsSinceEpoch, _zone);

  /// A human-readable string, like [DateTime.toString].
  ///
  /// For example `2080-01-15 10:30:00.000`, with a trailing `Z` in UTC.
  /// The result can be parsed back using [parse].
  @override
  String toString() =>
      _format(dateTimeSeparator: ' ', suffix: isUtc ? 'Z' : '');

  /// An ISO-8601 full-precision extended format representation.
  ///
  /// For example `2080-01-15T10:30:00.000`; UTC values end with `Z` and
  /// Nepal Time values with `+05:45`.
  @override
  String toIso8601String() => _format(
    dateTimeSeparator: 'T',
    suffix: switch (_zone) {
      .utc => 'Z',
      .nepal => '+05:45',
      .local => '',
    },
  );

  String _format({required String dateTimeSeparator, required String suffix}) {
    String pad(int value, int width) => '$value'.padLeft(width, '0');
    final us = microsecond == 0 ? '' : pad(microsecond, 3);
    return '${pad(year, 4)}-${pad(month, 2)}-${pad(day, 2)}'
        '$dateTimeSeparator'
        '${pad(hour, 2)}:${pad(minute, 2)}:${pad(second, 2)}'
        '.${pad(millisecond, 3)}$us$suffix';
  }
}
