// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/date_time/calendar/epoch_day.dart';

/// Constant-time conversions for the proleptic Gregorian calendar.
///
/// Based on Howard Hinnant's `days_from_civil` / `civil_from_days`
/// algorithms (http://howardhinnant.github.io/date_algorithms.html).
/// Pure integer arithmetic: no loops, no [DateTime] allocations.
abstract final class Gregorian {
  /// The [EpochDay] of the Gregorian date [year]-[month]-[day].
  ///
  /// [month] must be in 1..12 and [day] in 1..31.
  static EpochDay toEpochDay(int year, int month, int day) {
    final y = month <= 2 ? year - 1 : year;
    final era = (y >= 0 ? y : y - 399) ~/ 400;
    final yearOfEra = y - era * 400;
    final shiftedMonth = (month + 9) % 12; // March = 0 ... February = 11
    final dayOfYear = (153 * shiftedMonth + 2) ~/ 5 + day - 1;
    final dayOfEra =
        yearOfEra * 365 + yearOfEra ~/ 4 - yearOfEra ~/ 100 + dayOfYear;
    return EpochDay(era * 146097 + dayOfEra - 719468);
  }

  /// The Gregorian `(year, month, day)` of [epochDay].
  static (int year, int month, int day) fromEpochDay(EpochDay epochDay) {
    final z = epochDay.value + 719468;
    final era = (z >= 0 ? z : z - 146096) ~/ 146097;
    final dayOfEra = z - era * 146097;
    final yearOfEra =
        (dayOfEra -
            dayOfEra ~/ 1460 +
            dayOfEra ~/ 36524 -
            dayOfEra ~/ 146096) ~/
        365;
    final dayOfYear =
        dayOfEra - (365 * yearOfEra + yearOfEra ~/ 4 - yearOfEra ~/ 100);
    final shiftedMonth = (5 * dayOfYear + 2) ~/ 153;
    final day = dayOfYear - (153 * shiftedMonth + 2) ~/ 5 + 1;
    final month = shiftedMonth < 10 ? shiftedMonth + 3 : shiftedMonth - 9;
    final year = yearOfEra + era * 400 + (month <= 2 ? 1 : 0);
    return (year, month, day);
  }
}
