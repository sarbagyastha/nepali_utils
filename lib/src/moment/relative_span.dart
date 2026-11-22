// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/date_time/time_units.dart';
import 'package:nepali_utils/src/moment/moment_unit.dart';

/// A fuzzy span of time: `count` `unit`s, where a count of 1 means "about
/// one", e.g. "a day".
typedef RelativeSpan = ({MomentUnit unit, int count});

/// The fuzzy span describing [duration], or `null` for "a few seconds".
///
/// Uses the thresholds of moment.js's `fromNow`:
///
/// | Range                 | Result              |
/// |-----------------------|---------------------|
/// | 0 to 44 seconds       | a few seconds       |
/// | 45 to 89 seconds      | a minute            |
/// | 90 seconds to 44 min  | 2 to 44 minutes     |
/// | 45 to 89 minutes      | an hour             |
/// | 90 minutes to 21 h    | 2 to 21 hours       |
/// | 22 to 35 hours        | a day               |
/// | 36 hours to 25 days   | 2 to 25 days        |
/// | 26 to 45 days         | a month             |
/// | 45 days to 319 days   | 2 to 10 months      |
/// | 320 to 547 days       | a year              |
/// | 548 days and more     | 2 years and more    |
///
/// When [useWeeks] is true, spans from 7 days to a month are given in weeks
/// ("a week", "2 weeks", "3 weeks").
///
/// Months and years are of average length (30.44 and 365.2425 days).
RelativeSpan? relativeSpan(Duration duration, {bool useWeeks = false}) {
  final microseconds = duration.inMicroseconds.abs();
  int round(int unit) => (microseconds / unit).round();

  final seconds = round(Duration.microsecondsPerSecond);
  final minutes = round(Duration.microsecondsPerMinute);
  final hours = round(Duration.microsecondsPerHour);
  final exactDays = microseconds / microsecondsPerDay;
  final days = exactDays.round();
  final weeks = (exactDays / 7).round();
  final months = (exactDays * 4800 / 146097).round();
  final years = (exactDays / 365.2425).round();

  if (seconds < 45) return null;
  if (minutes <= 1) return (unit: .minute, count: 1);
  if (minutes < 45) return (unit: .minute, count: minutes);
  if (hours <= 1) return (unit: .hour, count: 1);
  if (hours < 22) return (unit: .hour, count: hours);
  if (days <= 1) return (unit: .day, count: 1);
  if (days < (useWeeks ? 7 : 26)) return (unit: .day, count: days);
  if (useWeeks) {
    if (weeks <= 1) return (unit: .week, count: 1);
    if (weeks < 4) return (unit: .week, count: weeks);
  }
  if (months <= 1) return (unit: .month, count: 1);
  if (months < 11) return (unit: .month, count: months);
  if (years <= 1) return (unit: .year, count: 1);
  return (unit: .year, count: years);
}
