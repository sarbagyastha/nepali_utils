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
    required this.numbers,
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

  /// Words and symbols used by `NepaliNumberFormat`.
  final NumberSymbols numbers;

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

/// Words and symbols used to format numbers.
final class NumberSymbols {
  /// Creates the number symbols of a language.
  const new({
    required this.belowHundred,
    required this.hundred,
    required this.scales,
    required this.compactShort,
    required this.compactLong,
    required this.minus,
    required this.point,
    required this.rupees,
    required this.paisa,
    required this.currencySymbol,
  });

  /// The words for 0 to 99, e.g. fifty-six / छपन्न.
  final List<String> belowHundred;

  /// The word for hundred.
  final String hundred;

  /// Words for thousand, lakh, crore, arab, kharab, nil, padam and sankha.
  final List<String> scales;

  /// Short compact suffixes for thousand, lakh, crore, arab and kharab,
  /// including any leading space, e.g. `K` or ` लाख`.
  final List<String> compactShort;

  /// Long compact suffixes for thousand, lakh, crore, arab and kharab,
  /// including any leading space, e.g. ` lakh`.
  final List<String> compactLong;

  /// The word for a negative number, e.g. minus / ऋण.
  final String minus;

  /// The word for the decimal point, e.g. point / दशमलव.
  final String point;

  /// The word for rupees.
  final String rupees;

  /// The word for paisa.
  final String paisa;

  /// The symbol of the Nepalese rupee, e.g. Rs. / रु.
  final String currencySymbol;
}

/// Phrases used by `NepaliMoment`.
///
/// In the templates, `#` is replaced by the localized number or phrase.
final class RelativeTimeSymbols {
  /// Creates the relative time phrases of a language.
  const new({
    required this.fewSeconds,
    required this.past,
    required this.future,
    required this.second,
    required this.minute,
    required this.hour,
    required this.day,
    required this.week,
    required this.month,
    required this.year,
    required this.calendar,
  });

  /// A span under 45 seconds, e.g. a few seconds / केही क्षण.
  final String fewSeconds;

  /// A span in the past, e.g. `# ago`.
  final String past;

  /// A span in the future, e.g. `in #`.
  final String future;

  /// Phrases for seconds.
  final UnitSymbols second;

  /// Phrases for minutes.
  final UnitSymbols minute;

  /// Phrases for hours.
  final UnitSymbols hour;

  /// Phrases for days.
  final UnitSymbols day;

  /// Phrases for weeks.
  final UnitSymbols week;

  /// Phrases for months.
  final UnitSymbols month;

  /// Phrases for years.
  final UnitSymbols year;

  /// Phrases for calendar times such as "Yesterday at 9:04 PM".
  final CalendarSymbols calendar;
}

/// Phrases for one unit of time, e.g. days.
///
/// In the templates, `#` is replaced by the localized count.
final class UnitSymbols {
  /// Creates the phrases of a unit.
  const new({
    required this.approximate,
    required this.one,
    required this.other,
    required this.shortOne,
    required this.shortOther,
    this.previous,
    this.current,
    this.next,
  });

  /// About one unit, e.g. a day / एक दिन.
  final String approximate;

  /// Exactly one unit, e.g. `# day`.
  final String one;

  /// Any other count, e.g. `# days`.
  final String other;

  /// Exactly one unit, abbreviated, e.g. `# hr.`.
  final String shortOne;

  /// Any other count, abbreviated, e.g. `# hr.`.
  final String shortOther;

  /// The previous unit, e.g. yesterday / हिजो.
  final String? previous;

  /// The current unit, e.g. today / आज.
  final String? current;

  /// The next unit, e.g. tomorrow / भोलि.
  final String? next;
}

/// Phrases for a date relative to today.
///
/// In the templates, `{time}` is replaced by the time and `{weekday}` by
/// the name of the day.
final class CalendarSymbols {
  /// Creates the calendar phrases of a language.
  const new({
    required this.sameDay,
    required this.previousDay,
    required this.nextDay,
    required this.previousWeek,
    required this.nextWeek,
  });

  /// Today, e.g. `Today at {time}`.
  final String sameDay;

  /// Yesterday, e.g. `Yesterday at {time}`.
  final String previousDay;

  /// Tomorrow, e.g. `Tomorrow at {time}`.
  final String nextDay;

  /// Within the past week, e.g. `Last {weekday} at {time}`.
  final String previousWeek;

  /// Within the coming week, e.g. `{weekday} at {time}`.
  final String nextWeek;
}
