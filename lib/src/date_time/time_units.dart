// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Microseconds in one millisecond.
const int microsecondsPerMillisecond = 1000;

/// Microseconds in one second.
const int microsecondsPerSecond = 1_000_000;

/// Microseconds in one minute.
const int microsecondsPerMinute = 60_000_000;

/// Microseconds in one hour.
const int microsecondsPerHour = 3_600_000_000;

/// Microseconds in one day.
const int microsecondsPerDay = 86_400_000_000;

/// Nepal Time (NPT) offset from UTC: +05:45.
const int nepalOffsetMicroseconds = 20_700_000_000;

/// Nepal Time (NPT) offset from UTC as a [Duration].
const Duration nepalTimeZoneOffset = Duration(hours: 5, minutes: 45);

/// Integer division rounding towards negative infinity, for positive [b].
int floorDiv(int a, int b) => (a - a % b) ~/ b;
