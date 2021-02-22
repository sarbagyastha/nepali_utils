// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
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
  static String fromBS(NepaliDateTime date, {NepaliDateTime? referenceDate}) =>
      _calc(date, referenceDate ?? NepaliDateTime.now());

  /// Converts the difference between [date] and [referenceDate] in [DateTime] into moment string.
  ///
  /// If [referenceDate] is null, the difference between [date] and the current date is
  /// converted into moment.
  static String fromAD(DateTime date, {DateTime? referenceDate}) =>
      _calc(date, referenceDate ?? DateTime.now());

  static String _calc(date, referenceDate) {
    final elapsedDuration = referenceDate.difference(date);
    final elapsed = elapsedDuration.inMilliseconds;
    final isFuture = elapsed.isNegative;
    final seconds = elapsed.abs() / 1000;
    final minutes = seconds / 60;
    final hours = minutes / 60;
    final days = hours / 24;
    final months = days / 30;
    final years = days / 365;
    String _momentString;

    if (seconds < 45) {
      _momentString = 'केही क्षण';
    } else if (seconds < 90) {
      _momentString = 'एक मिनेट';
    } else if (minutes < 45) {
      _momentString = '${NepaliUnicode.convert('${minutes.round()}')} मिनेट';
    } else if (minutes < 90) {
      _momentString = 'लगभग एक घण्टा';
    } else if (hours < 24) {
      _momentString = '${NepaliUnicode.convert('${hours.round()}')} घण्टा';
    } else if (hours < 48) {
      _momentString = 'एक दिन';
    } else if (days < 30) {
      _momentString = '${NepaliUnicode.convert('${days.round()}')} दिन';
    } else if (days < 60) {
      _momentString = 'लगभग एक महिना';
    } else if (days < 365) {
      _momentString = '${NepaliUnicode.convert('${months.round()}')} दिन';
    } else if (years < 2) {
      _momentString = 'लगभग एक वर्ष';
    } else {
      _momentString = '${NepaliUnicode.convert('${years.round()}')} वर्ष';
    }
    return _momentString += isFuture ? ' पछि' : ' पहिले';
  }
}
