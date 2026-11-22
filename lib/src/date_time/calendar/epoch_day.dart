// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/date_time/time_units.dart';

/// A day number counted from 1970-01-01 (the Unix/[DateTime] epoch).
///
/// Shared currency between the Gregorian and Bikram Sambat calendars.
/// Being an extension type, it has zero runtime cost while preventing day
/// numbers from being mixed up with microseconds or other integers.
extension type const EpochDay(int value) {
  /// The epoch day containing the wall-clock instant [microseconds].
  new ofMicroseconds(int microseconds)
    : value = floorDiv(microseconds, microsecondsPerDay);

  /// Day of the week, from Sunday (1) to Saturday (7).
  ///
  /// 1970-01-01 was a Thursday (5).
  int get weekday => (value + 4) % 7 + 1;

  /// Microseconds from the epoch to the start of this day.
  int get startMicroseconds => value * microsecondsPerDay;

  /// The day [days] after this one.
  EpochDay operator +(int days) => EpochDay(value + days);
}
