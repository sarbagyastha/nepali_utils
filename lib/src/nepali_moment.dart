// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/language/language_symbols.dart';
import 'package:nepali_utils/src/core/nepali_utils.dart';
import 'package:nepali_utils/src/date_time/nepali_date_time.dart';

/// NepaliMoment describes the moment in Nepali locale.
///
/// Generates a fuzzy timestamp using dates provided.
class NepaliMoment {
  /// Converts the difference between [date] and [referenceDate]
  /// in [NepaliDateTime] into moment string.
  ///
  /// If [referenceDate] is null, the difference between [date]
  /// and the current date is converted into moment.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  static String fromBS(
    NepaliDateTime date, {
    NepaliDateTime? referenceDate,
    bool showToday = false,
    Language? language,
  }) {
    return _calc(
      date,
      referenceDate ?? NepaliDateTime.now(),
      showToday,
      language ?? NepaliUtils.currentLanguage,
    );
  }

  /// Converts the difference between [date] and [referenceDate]
  /// in [DateTime] into moment string.
  ///
  /// If [referenceDate] is null, the difference between [date]
  /// and the current date is converted into moment.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  static String fromAD(
    DateTime date, {
    DateTime? referenceDate,
    bool showToday = false,
    Language? language,
  }) {
    return _calc(
      date,
      referenceDate ?? DateTime.now(),
      showToday,
      language ?? NepaliUtils.currentLanguage,
    );
  }

  static String _calc(
    DateTime date,
    DateTime referenceDate,
    bool showToday,
    Language language,
  ) {
    final elapsedDuration = referenceDate.difference(date);
    final elapsed = elapsedDuration.inMilliseconds;
    final isFuture = elapsed.isNegative;
    final seconds = elapsed.abs() / 1000;
    final minutes = seconds / 60;
    final hours = minutes / 60;
    final days = hours / 24;
    final months = days / 30;
    final years = days / 365;

    final symbols = symbolsOf(language);
    final phrases = symbols.relativeTime;
    String count(String template, double value) =>
        template.replaceFirst('#', symbols.number(value.round()));

    String span() {
      if (seconds < 45) return phrases.moments;
      if (seconds < 90) return phrases.minute;
      if (minutes < 45) return count(phrases.minutes, minutes);
      if (minutes < 90) return phrases.hour;
      if (hours < 24) return count(phrases.hours, hours);
      if (hours < 48) return phrases.day;
      if (days < 30) return count(phrases.days, days);
      if (days < 60) return phrases.month;
      if (days < 365) return count(phrases.months, months);
      if (years < 2) return phrases.year;
      return count(phrases.years, years);
    }

    return (isFuture ? phrases.future : phrases.past).replaceFirst('#', span());
  }
}
