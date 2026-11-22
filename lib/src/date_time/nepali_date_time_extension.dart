// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/date_time/nepali_date_time.dart';

/// Bikram Sambat conversions for [DateTime].
extension ENepaliDateTime on DateTime {
  /// Converts this to a [NepaliDateTime] representing the same instant.
  ///
  /// The time zone is kept: a local [DateTime] gives a local
  /// [NepaliDateTime] and a UTC one gives a UTC [NepaliDateTime]. Use
  /// [NepaliDateTime.toNepalTime] to present it in Nepal Time.
  ///
  /// Returns this unchanged if it already is a [NepaliDateTime].
  NepaliDateTime toNepaliDateTime() => .fromDateTime(this);
}
