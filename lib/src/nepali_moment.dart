// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'language.dart';
import 'nepali_date_time.dart';
import 'nepali_unicode.dart';
import 'nepali_utils.dart';

/// NepaliMoment describes the moment in Nepali locale.
///
/// Generates a fuzzy timestamp using dates provided.
class NepaliMoment {
  /// Converts the difference between [date] and [referenceDate] in [NepaliDateTime] into moment string.
  ///
  /// If [referenceDate] is null, the difference between [date] and the current date is
  /// converted into moment.
  static String fromBS(
    NepaliDateTime date, {
    NepaliDateTime? referenceDate,
    bool showToday = false,
  }) {
    return _calc(date, referenceDate ?? NepaliDateTime.now(), showToday);
  }

  /// Converts the difference between [date] and [referenceDate] in [DateTime] into moment string.
  ///
  /// If [referenceDate] is null, the difference between [date] and the current date is
  /// converted into moment.
  static String fromAD(
    DateTime date, {
    DateTime? referenceDate,
    bool showToday = false,
  }) {
    return _calc(date, referenceDate ?? DateTime.now(), showToday);
  }

  static String _calc(DateTime date, DateTime referenceDate, bool showToday) {
    final elapsedDuration = referenceDate.difference(date);
    final elapsed = elapsedDuration.inMilliseconds;
    final isFuture = elapsed.isNegative;
    final seconds = elapsed.abs() / 1000;
    final minutes = seconds / 60;
    final hours = minutes / 60;
    final days = hours / 24;
    final months = days / 30;
    final years = days / 365;

    final isEnglish = NepaliUtils().language == Language.english;

    String _momentString;
    if (seconds < 45) {
      _momentString = isEnglish ? 'few moment' : 'केही क्षण';
    } else if (seconds < 90) {
      _momentString = isEnglish ? 'one minute' : 'एक मिनेट';
    } else if (minutes < 45) {
      final min = minutes.round();
      _momentString = isEnglish ? '$min minute' : _nepaliMoment(min, 'मिनेट');
    } else if (minutes < 90) {
      _momentString = isEnglish ? 'about an hour' : 'लगभग एक घण्टा';
    } else if (hours < 24) {
      final hr = hours.round();
      _momentString = isEnglish ? '$hr hours' : _nepaliMoment(hr, 'घण्टा');
    } else if (hours < 48) {
      _momentString = isEnglish ? 'one day' : 'एक दिन';
    } else if (days < 30) {
      final day = days.round();
      _momentString = isEnglish ? '$day days' : _nepaliMoment(day, 'दिन');
    } else if (days < 60) {
      _momentString = isEnglish ? 'about a month' : 'लगभग एक महिना';
    } else if (days < 365) {
      final month = months.round();
      _momentString =
          isEnglish ? '$month month' : _nepaliMoment(month, 'महिना');
    } else if (years < 2) {
      _momentString = isEnglish ? 'about one year' : 'लगभग एक वर्ष';
    } else {
      final year = years.round();
      _momentString = isEnglish ? '$year year' : _nepaliMoment(year, 'वर्ष');
    }
    if (isFuture) return _momentString += isEnglish ? ' from now' : ' पछि';
    return _momentString += isEnglish ? ' ago' : ' पहिले';
  }
}

String _nepaliMoment(int number, String label) {
  return '${NepaliUnicode.convert(number.toString())} $label';
}
