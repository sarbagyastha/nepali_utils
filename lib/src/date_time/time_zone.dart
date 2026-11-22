// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/date_time/time_units.dart';

/// Time zone in which a `NepaliDateTime` presents its wall-clock fields.
enum NepaliZone {
  /// The device's local time zone, like a local [DateTime].
  local,

  /// UTC, like a [DateTime] with `isUtc` set.
  utc,

  /// Nepal Time (NPT), a fixed UTC+05:45 offset.
  nepal;

  /// The wall-clock microseconds (fields interpreted as if UTC) for the
  /// instant [microsecondsSinceEpoch] in this zone.
  int wallClockOf(int microsecondsSinceEpoch) => switch (this) {
    .utc => microsecondsSinceEpoch,
    .nepal => microsecondsSinceEpoch + nepalOffsetMicroseconds,
    .local =>
      microsecondsSinceEpoch +
          DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch)
              .timeZoneOffset
              .inMicroseconds,
  };
}
