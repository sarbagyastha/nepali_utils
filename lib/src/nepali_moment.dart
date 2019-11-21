// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'nepali_date_time.dart';
import 'nepali_unicode.dart';

/// NepaliMoment describes the moment in Nepali locale.
///
/// Generates a fuzzy timestamp using dates provided.
class NepaliMoment {
  /// Converts the difference between [date] and [referenceDate] in [NepaliDateTime] into moment string.
  ///
  /// If [referenceDate] is null, the difference between [date] and the current date is
  /// converted into moment.
  static String fromBS(NepaliDateTime date, {NepaliDateTime referenceDate}) =>
      _calc(date, referenceDate ?? NepaliDateTime.now());

  /// Converts the difference between [date] and [referenceDate] in [DateTime] into moment string.
  ///
  /// If [referenceDate] is null, the difference between [date] and the current date is
  /// converted into moment.
  static String fromAD(DateTime date, {DateTime referenceDate}) =>
      _calc(date, referenceDate ?? DateTime.now());

  static String _calc(date, referenceDate) {
    Duration elapsedDuration = referenceDate.difference(date);
    var elapsed = elapsedDuration.inMilliseconds;
    var isFuture = elapsed.isNegative;
    final num seconds = elapsed.abs() / 1000;
    final num minutes = seconds / 60;
    final num hours = minutes / 60;
    final num days = hours / 24;
    final num months = days / 30;
    final num years = days / 365;

    if (seconds < 45) {
      return 'केही क्षण ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (seconds < 90) {
      return 'एक मिनेट ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (minutes < 45) {
      return '${NepaliUnicode.convert('${minutes.round()}')} मिनेट ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (minutes < 90) {
      return 'लगभग एक घण्टा ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (hours < 24) {
      return '${NepaliUnicode.convert('${hours.round()}')} घण्टा ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (hours < 48) {
      return 'एक दिन ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (days < 30) {
      return '${NepaliUnicode.convert('${days.round()}')} दिन ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (days < 60) {
      return 'लगभग एक महिना ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (days < 365) {
      return '${NepaliUnicode.convert('${months.round()}')} दिन ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (years < 2) {
      return 'लगभग एक वर्ष ${isFuture ? 'पछि' : 'पहिले'}';
    } else {
      return '${NepaliUnicode.convert('${years.round()}')} वर्ष ${isFuture ? 'पछि' : 'पहिले'}';
    }
  }
}
