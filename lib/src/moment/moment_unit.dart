// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// A unit of time used by `NepaliMoment`.
enum MomentUnit {
  /// Seconds.
  second,

  /// Minutes.
  minute,

  /// Hours.
  hour,

  /// Days.
  day,

  /// Weeks.
  week,

  /// Months.
  month,

  /// Years.
  year,
}

/// How long the phrases of `NepaliMoment` are.
enum MomentStyle {
  /// Full words, e.g. `3 hours ago` / `३ घण्टा पहिले`.
  long,

  /// Abbreviated units, e.g. `3 hr. ago` / `३ घ. पहिले`.
  short,
}
