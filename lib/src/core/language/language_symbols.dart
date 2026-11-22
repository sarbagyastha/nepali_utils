// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/language/symbols/english.dart';
import 'package:nepali_utils/src/core/language/symbols/nepali.dart';

/// The localized text and digits for [language].
///
/// Supporting a new [Language] means adding its [LanguageSymbols] here; the
/// exhaustive switch makes a missing one a compile-time error.
LanguageSymbols symbolsOf(Language language) => switch (language) {
  .english => english,
  .nepali => nepali,
};

/// Everything that differs between languages: digits, names, date layouts and
/// the words used by the number and moment formatters.
final class LanguageSymbols {
  /// Creates the symbols of a language.
  const new({
    required this.zeroDigit,
    required this.months,
    required this.monthsAlt,
    required this.monthsShort,
    required this.monthsNarrow,
    required this.weekdays,
    required this.weekdaysShort,
    required this.weekdaysNarrow,
    required this.eras,
    required this.quarters,
    required this.quartersShort,
    required this.dayPeriod,
    required this.nepalTime,
    required this.utc,
    required this.skeletons,
    required this.hundred,
    required this.scales,
    required this.rupees,
    required this.paisa,
    required this.relativeTime,
  });

  /// Code point of the digit zero; the other digits follow it consecutively.
  final int zeroDigit;

  /// Bikram Sambat month names, Baishakh first, e.g. Mangsir / मंसिर.
  final List<String> months;

  /// Colloquial month names, e.g. Marga / मार्ग.
  final List<String> monthsAlt;

  /// Abbreviated month names, e.g. Marg / मं.
  final List<String> monthsShort;

  /// Narrow month names, e.g. M / मं.
  final List<String> monthsNarrow;

  /// Weekday names, Sunday first, e.g. Thursday / बिहिबार.
  final List<String> weekdays;

  /// Abbreviated weekday names, e.g. Thu / बिहि.
  final List<String> weekdaysShort;

  /// Weekday initials, e.g. T / बि.
  final List<String> weekdaysNarrow;

  /// The era, abbreviated then in full, e.g. (BS, Bikram Sambat).
  final ({String short, String long}) eras;

  /// Quarter names, e.g. 3rd quarter.
  final List<String> quarters;

  /// Abbreviated quarter names, e.g. Q3.
  final List<String> quartersShort;

  /// The AM/PM marker (or time of day) for an hour from 0 to 23.
  final String Function(int hour) dayPeriod;

  /// Long name of Nepal Time.
  final String nepalTime;

  /// Long name of UTC.
  final String utc;

  /// The pattern for each `package:intl` skeleton.
  final Map<String, String> skeletons;

  /// The word for hundred.
  final String hundred;

  /// Words for thousand, lakh, crore, arab, kharab, nil, padam and sankha.
  final List<String> scales;

  /// The word for rupees.
  final String rupees;

  /// The word for paisa.
  final String paisa;

  /// Phrases used by `NepaliMoment`.
  final RelativeTimeSymbols relativeTime;

  /// [text] with its ASCII digits written in this language's digits.
  String digits(String text) {
    const zero = 0x30;
    const nine = 0x39;
    if (zeroDigit == zero) return text;
    final units = text.codeUnits;
    if (!units.any((u) => u >= zero && u <= nine)) return text;
    return String.fromCharCodes([
      for (final unit in units)
        if (unit >= zero && unit <= nine) unit - zero + zeroDigit else unit,
    ]);
  }

  /// [value] zero-padded to [width], in this language's digits.
  String number(int value, [int width = 0]) =>
      digits(width > 0 ? '$value'.padLeft(width, '0') : '$value');
}

/// Phrases for a fuzzy time span such as "3 days ago".
///
/// In the templates, `#` is replaced by the localized number.
final class RelativeTimeSymbols {
  /// Creates the relative time phrases of a language.
  const new({
    required this.moments,
    required this.minute,
    required this.minutes,
    required this.hour,
    required this.hours,
    required this.day,
    required this.days,
    required this.month,
    required this.months,
    required this.year,
    required this.years,
    required this.past,
    required this.future,
  });

  /// Under 45 seconds.
  final String moments;

  /// About one minute.
  final String minute;

  /// Some minutes.
  final String minutes;

  /// About one hour.
  final String hour;

  /// Some hours.
  final String hours;

  /// About one day.
  final String day;

  /// Some days.
  final String days;

  /// About one month.
  final String month;

  /// Some months.
  final String months;

  /// About one year.
  final String year;

  /// Some years.
  final String years;

  /// A span in the past, e.g. `# ago`.
  final String past;

  /// A span in the future, e.g. `# from now`.
  final String future;
}
