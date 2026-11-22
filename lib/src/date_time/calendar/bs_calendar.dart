// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:nepali_utils/src/date_time/calendar/bs_calendar_data.dart';
import 'package:nepali_utils/src/date_time/calendar/epoch_day.dart';
import 'package:nepali_utils/src/date_time/calendar/gregorian.dart';
import 'package:nepali_utils/src/date_time/time_units.dart';

// Holds the epoch day of the first day of every supported BS month, plus a
// trailing entry for the end of the range, so that BS date -> epoch day is
// one array read and epoch day -> BS date is an estimate plus a couple of
// correction steps.

/// Bikram Sambat (BS) calendar arithmetic.
abstract final class BsCalendar {
  /// The first supported Bikram Sambat year.
  static const int minYear = bsDataFirstYear;

  /// The last supported Bikram Sambat year.
  static const int maxYear = bsDataLastYear;

  // Average month length in thousandths of a day, to estimate indices.
  static const int _avgMonthMilliDays = 30437;

  // Built on first use (static fields are lazy).
  static final Int32List _monthStarts = _buildIndex();

  static Int32List _buildIndex() {
    const years = maxYear - minYear + 1;
    assert(bsMonthLengths.length == years, 'Calendar data is incomplete.');

    // Reference point: 1970-01-01 BS == 1913-04-13 AD.
    final reference = Gregorian.toEpochDay(1913, 4, 13).value;
    const referenceIndex = (1970 - minYear) * 12;

    final starts = Int32List(years * 12 + 1);
    var day = 0;
    for (var y = 0; y < years; y++) {
      final months = bsMonthLengths[y];
      assert(
        _isPlausibleYear(minYear + y, months),
        'Invalid month lengths for ${minYear + y} BS: $months',
      );
      for (var m = 0; m < 12; m++) {
        starts[y * 12 + m] = day;
        day += months[m];
      }
    }
    starts[years * 12] = day;

    final shift = reference - starts[referenceIndex];
    for (var i = 0; i < starts.length; i++) {
      starts[i] += shift;
    }
    return starts;
  }

  static bool _isPlausibleYear(int year, List<int> months) {
    if (months.length != 12) return false;
    if (months.any((d) => d < 29 || d > 32)) return false;
    final total = months.fold(0, (a, b) => a + b);
    // 2200 BS carries known placeholder data; see bs_calendar_data.dart.
    return total == 365 || total == 366 || year == 2200;
  }

  /// The first supported day.
  static EpochDay get firstDay => EpochDay(_monthStarts.first);

  /// The day after the last supported day.
  static EpochDay get endDay => EpochDay(_monthStarts.last);

  /// Whether [day] falls inside the supported range.
  static bool contains(EpochDay day) =>
      day.value >= _monthStarts.first && day.value < _monthStarts.last;

  /// Number of days in [month] of [year].
  static int daysInMonth(int year, int month) {
    _checkYear(year);
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    final i = (year - minYear) * 12 + month - 1;
    return _monthStarts[i + 1] - _monthStarts[i];
  }

  /// Number of days in [year].
  static int daysInYear(int year) {
    _checkYear(year);
    final i = (year - minYear) * 12;
    return _monthStarts[i + 12] - _monthStarts[i];
  }

  /// The [EpochDay] of the BS date [year]-[month]-[day].
  ///
  /// [month] and [day] may be outside their natural ranges; they are
  /// normalised the same way [DateTime] does (e.g. month 13 is Baishakh of
  /// the next year and day 0 is the last day of the previous month). The
  /// normalised year/month must be supported.
  static EpochDay toEpochDay(int year, [int month = 1, int day = 1]) {
    final monthIndex = month - 1;
    final y = year + floorDiv(monthIndex, 12);
    _checkYear(y);
    final i = (y - minYear) * 12 + monthIndex % 12;
    return EpochDay(_monthStarts[i] + day - 1);
  }

  /// The BS `(year, month, day)` of [epochDay].
  ///
  /// Throws a [RangeError] when [epochDay] is not [contains]ed.
  static (int year, int month, int day) fromEpochDay(EpochDay epochDay) {
    final starts = _monthStarts;
    final v = epochDay.value;
    final first = starts.first;
    if (v < first || v >= starts.last) {
      throw RangeError(
        'Date is outside the supported Bikram Sambat range '
        '($minYear-$maxYear BS).',
      );
    }
    final lastMonth = starts.length - 2;
    var i = (v - first) * 1000 ~/ _avgMonthMilliDays;
    if (i > lastMonth) i = lastMonth;
    while (starts[i] > v) {
      i--;
    }
    while (starts[i + 1] <= v) {
      i++;
    }
    return (minYear + i ~/ 12, i % 12 + 1, v - starts[i] + 1);
  }

  static void _checkYear(int year) {
    if (year < minYear || year > maxYear) {
      throw RangeError.range(year, minYear, maxYear, 'year');
    }
  }
}
