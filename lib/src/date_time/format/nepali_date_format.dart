// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// Constructor and constant names mirror package:intl's DateFormat.
// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/language/language_symbols.dart';
import 'package:nepali_utils/src/core/nepali_utils.dart';
import 'package:nepali_utils/src/date_time/calendar/bs_calendar.dart';
import 'package:nepali_utils/src/date_time/format/format_token.dart';
import 'package:nepali_utils/src/date_time/nepali_date_time.dart';
import 'package:nepali_utils/src/date_time/nepali_date_time_extension.dart';

/// Formats dates in the Bikram Sambat calendar.
///
/// It works like `package:intl`'s `DateFormat`: the same pattern syntax,
/// the same skeletons (named constructors such as [NepaliDateFormat.yMMMd])
/// and the same [addPattern] / `add_*` composition. Skeletons are laid out
/// like intl's `en` locale for [Language.english] and its `ne` locale for
/// [Language.nepali], e.g. [NepaliDateFormat.yMd] gives `8/5/2076` or
/// `२०७६-०८-०५`.
///
/// | Symbol | Meaning                | Example (english / nepali)          |
/// |--------|------------------------|-------------------------------------|
/// | G      | era                    | BS / बि सं, (GGGG) Bikram Sambat    |
/// | y      | year                   | 2076, (yy) 76                       |
/// | Q      | quarter                | 3, 03, Q3, 3rd quarter              |
/// | M      | month                  | 8, 08, Marg, Mangsir, (MMMMM) M     |
/// | L      | standalone month       | same as M                           |
/// | d      | day of month           | 5, 05                               |
/// | D      | day of year            | 215                                 |
/// | E      | day of week            | Thu, (EEEE) Thursday, (EEEEE) T     |
/// | c      | standalone day of week | (ccc) Thu, (cccc) Thursday          |
/// | a      | AM/PM marker           | PM / बेलुकी                          |
/// | h      | hour 1-12              | 9, 09                               |
/// | H      | hour 0-23              | 21                                  |
/// | K      | hour 0-11              | 9                                   |
/// | k      | hour 1-24              | 21                                  |
/// | m      | minute                 | 4, 04                               |
/// | s      | second                 | 5, 05                               |
/// | S      | fractional seconds     | 123, (SSSSSS) 123456                |
/// | z, v   | time zone              | NPT, (zzzz) Nepal Time              |
/// | Z      | time zone offset       | +0545, (ZZZZ) GMT+05:45             |
/// | '      | quoted literal text    | 'at', '' for a single quote         |
///
/// Beyond intl:
/// * `MMMMMM` (and `LLLLLL`) is the colloquial month name, e.g. Marga / मार्ग.
/// * In Nepali, `a` is the time of day: बिहान, मध्यान्न, दिउसो, साँझ or बेलुकी.
/// * `S` beyond 3 letters shows microseconds instead of zeros.
/// * `z`, `v` and `Z` show the time zone of the date, which intl leaves
///   empty.
///
/// Numbers use Devanagari digits when the language is [Language.nepali].
///
/// Like intl, the English time skeletons ([NepaliDateFormat.j],
/// [NepaliDateFormat.jm], ...) put a narrow no-break space (U+202F) before
/// AM/PM, e.g. `9:04 PM`.
///
/// Instances are immutable: [addPattern] and the `add_*` methods return a
/// new formatter instead of modifying this one.
final class NepaliDateFormat._(
  final String? _pattern,

  /// The language used for names and digits.
  final Language language,
) {
  /// Creates a formatter for [newPattern] in [language].
  ///
  /// [newPattern] is either a skeleton such as `yMMMd` (laid out for
  /// [language]) or an explicit pattern such as `'MMMM d, y'`. Without one,
  /// the format is `yMMMMd jms`.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage] at the time the
  /// formatter is created.
  factory([String? newPattern, Language? language]) {
    final lang = language ?? NepaliUtils.currentLanguage;
    return ._(newPattern == null ? null : _resolve(newPattern, lang), lang);
  }

  /// 2076-08-05 => 5
  factory d([Language? language]) => .new(DAY, language);

  /// 2076-08-05 => Thu / बिहि
  factory E([Language? language]) => .new(ABBR_WEEKDAY, language);

  /// 2076-08-05 => Thursday / बिहिबार
  factory EEEE([Language? language]) => .new(WEEKDAY, language);

  /// 2076-08-05 => T / बि
  factory EEEEE([Language? language]) => .new('EEEEE', language);

  /// 2076-08-05 => Marg / मं
  factory LLL([Language? language]) => .new(ABBR_STANDALONE_MONTH, language);

  /// 2076-08-05 => Mangsir / मंसिर
  factory LLLL([Language? language]) => .new(STANDALONE_MONTH, language);

  /// 2076-08-05 => 8
  factory M([Language? language]) => .new(NUM_MONTH, language);

  /// 2076-08-05 => 8/5 / ०८-०५
  factory Md([Language? language]) => .new(NUM_MONTH_DAY, language);

  /// 2076-08-05 => Thu, 8/5 / ०८-०५, बिहि
  factory MEd([Language? language]) => .new(NUM_MONTH_WEEKDAY_DAY, language);

  /// 2076-08-05 => Marg / मं
  factory MMM([Language? language]) => .new(ABBR_MONTH, language);

  /// 2076-08-05 => Marg 5 / मं ५
  factory MMMd([Language? language]) => .new(ABBR_MONTH_DAY, language);

  /// 2076-08-05 => Thu, Marg 5 / मं ५, बिहि
  factory MMMEd([Language? language]) => .new(ABBR_MONTH_WEEKDAY_DAY, language);

  /// 2076-08-05 => Mangsir / मंसिर
  factory MMMM([Language? language]) => .new(MONTH, language);

  /// 2076-08-05 => Mangsir 5 / मंसिर ५
  factory MMMMd([Language? language]) => .new(MONTH_DAY, language);

  /// 2076-08-05 => Thursday, Mangsir 5 / मंसिर ५, बिहिबार
  factory MMMMEEEEd([Language? language]) => .new(MONTH_WEEKDAY_DAY, language);

  /// 2076-08-05 => Q3 / तेस्रो त्रैमासिक
  factory QQQ([Language? language]) => .new(ABBR_QUARTER, language);

  /// 2076-08-05 => 3rd quarter / तेस्रो त्रैमासिक
  factory QQQQ([Language? language]) => .new(QUARTER, language);

  /// 2076-08-05 => 2076
  factory y([Language? language]) => .new(YEAR, language);

  /// 2076-08-05 => 8/2076 / २०७६-०८
  factory yM([Language? language]) => .new(YEAR_NUM_MONTH, language);

  /// 2076-08-05 => 8/5/2076 / २०७६-०८-०५
  factory yMd([Language? language]) => .new(YEAR_NUM_MONTH_DAY, language);

  /// 2076-08-05 => Thu, 8/5/2076 / २०७६-०८-०५, बिहि
  factory yMEd([Language? language]) =>
      .new(YEAR_NUM_MONTH_WEEKDAY_DAY, language);

  /// 2076-08-05 => Marg 2076 / २०७६ मं
  factory yMMM([Language? language]) => .new(YEAR_ABBR_MONTH, language);

  /// 2076-08-05 => Marg 5, 2076 / २०७६ मं ५
  factory yMMMd([Language? language]) => .new(YEAR_ABBR_MONTH_DAY, language);

  /// 2076-08-05 => Thu, Marg 5, 2076 / २०७६ मं ५, बिहि
  factory yMMMEd([Language? language]) =>
      .new(YEAR_ABBR_MONTH_WEEKDAY_DAY, language);

  /// 2076-08-05 => Mangsir 2076 / २०७६ मंसिर
  factory yMMMM([Language? language]) => .new(YEAR_MONTH, language);

  /// 2076-08-05 => Mangsir 5, 2076 / २०७६ मंसिर ५
  factory yMMMMd([Language? language]) => .new(YEAR_MONTH_DAY, language);

  /// 2076-08-05 => Thursday, Mangsir 5, 2076 / २०७६ मंसिर ५, बिहिबार
  factory yMMMMEEEEd([Language? language]) =>
      .new(YEAR_MONTH_WEEKDAY_DAY, language);

  /// 2076-08-05 => Q3 2076 / २०७६ तेस्रो त्रैमासिक
  factory yQQQ([Language? language]) => .new(YEAR_ABBR_QUARTER, language);

  /// 2076-08-05 => 3rd quarter 2076 / २०७६ तेस्रो त्रैमासिक
  factory yQQQQ([Language? language]) => .new(YEAR_QUARTER, language);

  /// 2076-08-05T21:04:25 => 21
  factory H([Language? language]) => .new(HOUR24, language);

  /// 2076-08-05T21:04:25 => 21:04
  factory Hm([Language? language]) => .new(HOUR24_MINUTE, language);

  /// 2076-08-05T21:04:25 => 21:04:25
  factory Hms([Language? language]) => .new(HOUR24_MINUTE_SECOND, language);

  /// 2076-08-05T21:04:25 => 9 PM / २१
  factory j([Language? language]) => .new(HOUR, language);

  /// 2076-08-05T21:04:25 => 9:04 PM / २१:०४
  factory jm([Language? language]) => .new(HOUR_MINUTE, language);

  /// 2076-08-05T21:04:25 => 9:04:25 PM / २१:०४:२५
  factory jms([Language? language]) => .new(HOUR_MINUTE_SECOND, language);

  /// 2076-08-05T21:04:25+05:45 => 9:04 PM NPT / २१:०४ NPT
  factory jmv([Language? language]) => .new(HOUR_MINUTE_GENERIC_TZ, language);

  /// 2076-08-05T21:04:25+05:45 => 9:04 PM NPT / २१:०४ NPT
  factory jmz([Language? language]) => .new(HOUR_MINUTE_TZ, language);

  /// 2076-08-05T21:04:25+05:45 => 9 PM NPT / २१h NPT
  factory jv([Language? language]) => .new(HOUR_GENERIC_TZ, language);

  /// 2076-08-05T21:04:25+05:45 => 9 PM NPT / २१h NPT
  factory jz([Language? language]) => .new(HOUR_TZ, language);

  /// 2076-08-05T21:04:25 => 4
  factory m([Language? language]) => .new(MINUTE, language);

  /// 2076-08-05T21:04:25 => 04:25
  factory ms([Language? language]) => .new(MINUTE_SECOND, language);

  /// 2076-08-05T21:04:25 => 25
  factory s([Language? language]) => .new(SECOND, language);

  // Skeleton names, the same as `package:intl`'s `DateFormat` constants.

  /// Skeleton for an abbreviated month, e.g. Marg.
  static const String ABBR_MONTH = 'MMM';

  /// Skeleton for the day of month.
  static const String DAY = 'd';

  /// Skeleton for an abbreviated weekday, e.g. Thu.
  static const String ABBR_WEEKDAY = 'E';

  /// Skeleton for a weekday, e.g. Thursday.
  static const String WEEKDAY = 'EEEE';

  /// Skeleton for an abbreviated standalone month.
  static const String ABBR_STANDALONE_MONTH = 'LLL';

  /// Skeleton for a standalone month.
  static const String STANDALONE_MONTH = 'LLLL';

  /// Skeleton for the month number.
  static const String NUM_MONTH = 'M';

  /// Skeleton for month and day numbers.
  static const String NUM_MONTH_DAY = 'Md';

  /// Skeleton for weekday, month and day numbers.
  static const String NUM_MONTH_WEEKDAY_DAY = 'MEd';

  /// Skeleton for abbreviated month and day.
  static const String ABBR_MONTH_DAY = 'MMMd';

  /// Skeleton for weekday, abbreviated month and day.
  static const String ABBR_MONTH_WEEKDAY_DAY = 'MMMEd';

  /// Skeleton for a month, e.g. Mangsir.
  static const String MONTH = 'MMMM';

  /// Skeleton for month and day.
  static const String MONTH_DAY = 'MMMMd';

  /// Skeleton for weekday, month and day.
  static const String MONTH_WEEKDAY_DAY = 'MMMMEEEEd';

  /// Skeleton for an abbreviated quarter.
  static const String ABBR_QUARTER = 'QQQ';

  /// Skeleton for a quarter.
  static const String QUARTER = 'QQQQ';

  /// Skeleton for the year.
  static const String YEAR = 'y';

  /// Skeleton for year and month numbers.
  static const String YEAR_NUM_MONTH = 'yM';

  /// Skeleton for year, month and day numbers.
  static const String YEAR_NUM_MONTH_DAY = 'yMd';

  /// Skeleton for weekday with year, month and day numbers.
  static const String YEAR_NUM_MONTH_WEEKDAY_DAY = 'yMEd';

  /// Skeleton for year and abbreviated month.
  static const String YEAR_ABBR_MONTH = 'yMMM';

  /// Skeleton for year, abbreviated month and day.
  static const String YEAR_ABBR_MONTH_DAY = 'yMMMd';

  /// Skeleton for weekday, year, abbreviated month and day.
  static const String YEAR_ABBR_MONTH_WEEKDAY_DAY = 'yMMMEd';

  /// Skeleton for year and month.
  static const String YEAR_MONTH = 'yMMMM';

  /// Skeleton for year, month and day.
  static const String YEAR_MONTH_DAY = 'yMMMMd';

  /// Skeleton for weekday, year, month and day.
  static const String YEAR_MONTH_WEEKDAY_DAY = 'yMMMMEEEEd';

  /// Skeleton for year and abbreviated quarter.
  static const String YEAR_ABBR_QUARTER = 'yQQQ';

  /// Skeleton for year and quarter.
  static const String YEAR_QUARTER = 'yQQQQ';

  /// Skeleton for the 24-hour hour.
  static const String HOUR24 = 'H';

  /// Skeleton for the 24-hour hour and minute.
  static const String HOUR24_MINUTE = 'Hm';

  /// Skeleton for the 24-hour hour, minute and second.
  static const String HOUR24_MINUTE_SECOND = 'Hms';

  /// Skeleton for the hour in the language's preferred clock.
  static const String HOUR = 'j';

  /// Skeleton for hour and minute in the language's preferred clock.
  static const String HOUR_MINUTE = 'jm';

  /// Skeleton for hour, minute and second in the language's preferred clock.
  static const String HOUR_MINUTE_SECOND = 'jms';

  /// Skeleton for hour, minute and generic time zone.
  static const String HOUR_MINUTE_GENERIC_TZ = 'jmv';

  /// Skeleton for hour, minute and time zone.
  static const String HOUR_MINUTE_TZ = 'jmz';

  /// Skeleton for hour and generic time zone.
  static const String HOUR_GENERIC_TZ = 'jv';

  /// Skeleton for hour and time zone.
  static const String HOUR_TZ = 'jz';

  /// Skeleton for the minute.
  static const String MINUTE = 'm';

  /// Skeleton for minute and second.
  static const String MINUTE_SECOND = 'ms';

  /// Skeleton for the second.
  static const String SECOND = 's';

  /// The pattern used for formatting, with skeletons already resolved.
  String get pattern =>
      _pattern ??
      '${_resolve(YEAR_MONTH_DAY, language)} '
          '${_resolve(HOUR_MINUTE_SECOND, language)}';

  late final List<FormatToken> _tokens = tokenize(pattern);

  /// Returns a formatter whose pattern is this one's followed by
  /// [separator] and [inputPattern].
  ///
  /// [inputPattern] is resolved as a skeleton when it is one, like in the
  /// default constructor. If this formatter was created without a pattern,
  /// the result uses only [inputPattern]. A `null` [inputPattern] returns
  /// this formatter.
  ///
  /// Unlike `package:intl`, this does not modify this formatter.
  NepaliDateFormat addPattern(String? inputPattern, [String separator = ' ']) {
    if (inputPattern == null) return this;
    final added = _resolve(inputPattern, language);
    final current = _pattern;
    return ._(current == null ? added : '$current$separator$added', language);
  }

  /// Appends the [DAY] skeleton, see [addPattern].
  NepaliDateFormat add_d() => addPattern(DAY);

  /// Appends the [ABBR_WEEKDAY] skeleton, see [addPattern].
  NepaliDateFormat add_E() => addPattern(ABBR_WEEKDAY);

  /// Appends the [WEEKDAY] skeleton, see [addPattern].
  NepaliDateFormat add_EEEE() => addPattern(WEEKDAY);

  /// Appends the narrow weekday skeleton, see [addPattern].
  NepaliDateFormat add_EEEEE() => addPattern('EEEEE');

  /// Appends the [ABBR_STANDALONE_MONTH] skeleton, see [addPattern].
  NepaliDateFormat add_LLL() => addPattern(ABBR_STANDALONE_MONTH);

  /// Appends the [STANDALONE_MONTH] skeleton, see [addPattern].
  NepaliDateFormat add_LLLL() => addPattern(STANDALONE_MONTH);

  /// Appends the [NUM_MONTH] skeleton, see [addPattern].
  NepaliDateFormat add_M() => addPattern(NUM_MONTH);

  /// Appends the [NUM_MONTH_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_Md() => addPattern(NUM_MONTH_DAY);

  /// Appends the [NUM_MONTH_WEEKDAY_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_MEd() => addPattern(NUM_MONTH_WEEKDAY_DAY);

  /// Appends the [ABBR_MONTH] skeleton, see [addPattern].
  NepaliDateFormat add_MMM() => addPattern(ABBR_MONTH);

  /// Appends the [ABBR_MONTH_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_MMMd() => addPattern(ABBR_MONTH_DAY);

  /// Appends the [ABBR_MONTH_WEEKDAY_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_MMMEd() => addPattern(ABBR_MONTH_WEEKDAY_DAY);

  /// Appends the [MONTH] skeleton, see [addPattern].
  NepaliDateFormat add_MMMM() => addPattern(MONTH);

  /// Appends the [MONTH_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_MMMMd() => addPattern(MONTH_DAY);

  /// Appends the [MONTH_WEEKDAY_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_MMMMEEEEd() => addPattern(MONTH_WEEKDAY_DAY);

  /// Appends the [ABBR_QUARTER] skeleton, see [addPattern].
  NepaliDateFormat add_QQQ() => addPattern(ABBR_QUARTER);

  /// Appends the [QUARTER] skeleton, see [addPattern].
  NepaliDateFormat add_QQQQ() => addPattern(QUARTER);

  /// Appends the [YEAR] skeleton, see [addPattern].
  NepaliDateFormat add_y() => addPattern(YEAR);

  /// Appends the [YEAR_NUM_MONTH] skeleton, see [addPattern].
  NepaliDateFormat add_yM() => addPattern(YEAR_NUM_MONTH);

  /// Appends the [YEAR_NUM_MONTH_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_yMd() => addPattern(YEAR_NUM_MONTH_DAY);

  /// Appends the [YEAR_NUM_MONTH_WEEKDAY_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_yMEd() => addPattern(YEAR_NUM_MONTH_WEEKDAY_DAY);

  /// Appends the [YEAR_ABBR_MONTH] skeleton, see [addPattern].
  NepaliDateFormat add_yMMM() => addPattern(YEAR_ABBR_MONTH);

  /// Appends the [YEAR_ABBR_MONTH_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_yMMMd() => addPattern(YEAR_ABBR_MONTH_DAY);

  /// Appends the [YEAR_ABBR_MONTH_WEEKDAY_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_yMMMEd() => addPattern(YEAR_ABBR_MONTH_WEEKDAY_DAY);

  /// Appends the [YEAR_MONTH] skeleton, see [addPattern].
  NepaliDateFormat add_yMMMM() => addPattern(YEAR_MONTH);

  /// Appends the [YEAR_MONTH_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_yMMMMd() => addPattern(YEAR_MONTH_DAY);

  /// Appends the [YEAR_MONTH_WEEKDAY_DAY] skeleton, see [addPattern].
  NepaliDateFormat add_yMMMMEEEEd() => addPattern(YEAR_MONTH_WEEKDAY_DAY);

  /// Appends the [YEAR_ABBR_QUARTER] skeleton, see [addPattern].
  NepaliDateFormat add_yQQQ() => addPattern(YEAR_ABBR_QUARTER);

  /// Appends the [YEAR_QUARTER] skeleton, see [addPattern].
  NepaliDateFormat add_yQQQQ() => addPattern(YEAR_QUARTER);

  /// Appends the [HOUR24] skeleton, see [addPattern].
  NepaliDateFormat add_H() => addPattern(HOUR24);

  /// Appends the [HOUR24_MINUTE] skeleton, see [addPattern].
  NepaliDateFormat add_Hm() => addPattern(HOUR24_MINUTE);

  /// Appends the [HOUR24_MINUTE_SECOND] skeleton, see [addPattern].
  NepaliDateFormat add_Hms() => addPattern(HOUR24_MINUTE_SECOND);

  /// Appends the [HOUR] skeleton, see [addPattern].
  NepaliDateFormat add_j() => addPattern(HOUR);

  /// Appends the [HOUR_MINUTE] skeleton, see [addPattern].
  NepaliDateFormat add_jm() => addPattern(HOUR_MINUTE);

  /// Appends the [HOUR_MINUTE_SECOND] skeleton, see [addPattern].
  NepaliDateFormat add_jms() => addPattern(HOUR_MINUTE_SECOND);

  /// Appends the [HOUR_MINUTE_GENERIC_TZ] skeleton, see [addPattern].
  NepaliDateFormat add_jmv() => addPattern(HOUR_MINUTE_GENERIC_TZ);

  /// Appends the [HOUR_MINUTE_TZ] skeleton, see [addPattern].
  NepaliDateFormat add_jmz() => addPattern(HOUR_MINUTE_TZ);

  /// Appends the [HOUR_GENERIC_TZ] skeleton, see [addPattern].
  NepaliDateFormat add_jv() => addPattern(HOUR_GENERIC_TZ);

  /// Appends the [HOUR_TZ] skeleton, see [addPattern].
  NepaliDateFormat add_jz() => addPattern(HOUR_TZ);

  /// Appends the [MINUTE] skeleton, see [addPattern].
  NepaliDateFormat add_m() => addPattern(MINUTE);

  /// Appends the [MINUTE_SECOND] skeleton, see [addPattern].
  NepaliDateFormat add_ms() => addPattern(MINUTE_SECOND);

  /// Appends the [SECOND] skeleton, see [addPattern].
  NepaliDateFormat add_s() => addPattern(SECOND);

  static String _resolve(String pattern, Language language) =>
      symbolsOf(language).skeletons[pattern] ?? pattern;

  /// Formats [date] according to [pattern] and [language].
  ///
  /// A plain [DateTime] is converted with [ENepaliDateTime.toNepaliDateTime]
  /// first, which keeps its time zone.
  String format(DateTime date) {
    final nepaliDate = date.toNepaliDateTime();
    final buffer = StringBuffer();
    for (final token in _tokens) {
      buffer.write(switch (token) {
        LiteralToken(:final text) => text,
        final FieldToken field => _formatField(field, nepaliDate),
      });
    }
    return buffer.toString();
  }

  /// Parses [dateString] with [NepaliDateTime.parse] and formats the result.
  String parseAndFormat(String dateString) =>
      format(NepaliDateTime.parse(dateString));

  LanguageSymbols get _symbols => symbolsOf(language);

  String _formatField(FieldToken field, NepaliDateTime date) {
    final count = field.count;
    final symbols = _symbols;
    String number(int value, [int width = 0]) => symbols.number(value, width);

    return switch (field.letter) {
      'G' => count >= 4 ? symbols.eras.long : symbols.eras.short,
      'y' => count == 2 ? number(date.year % 100, 2) : number(date.year, count),
      'Q' => _quarter((date.month + 2) ~/ 3, count),
      'M' || 'L' => _month(date.month, count),
      'd' => number(date.day, count),
      'D' => number(_dayOfYear(date), count),
      'E' => _weekday(date.weekday, count),
      'c' =>
        count >= 3 && count <= 5
            ? _weekday(date.weekday, count)
            : number(date.day),
      'a' => symbols.dayPeriod(date.hour),
      'h' => number((date.hour + 11) % 12 + 1, count),
      'H' => number(date.hour, count),
      'K' => number(date.hour % 12, count),
      'k' => number(date.hour == 0 ? 24 : date.hour, count),
      'm' => number(date.minute, count),
      's' => number(date.second, count),
      'S' => _fraction(date, count),
      'z' || 'v' => _zoneName(date, count),
      'Z' => _zoneOffset(date.timeZoneOffset, count),
      _ => field.text,
    };
  }

  String _quarter(int quarter, int count) => switch (count) {
    3 => _symbols.quartersShort[quarter - 1],
    4 => _symbols.quarters[quarter - 1],
    _ => _symbols.number(quarter, count),
  };

  String _month(int month, int count) => switch (count) {
    1 || 2 => _symbols.number(month, count),
    3 => _symbols.monthsShort[month - 1],
    4 => _symbols.months[month - 1],
    5 => _symbols.monthsNarrow[month - 1],
    _ => _symbols.monthsAlt[month - 1],
  };

  String _weekday(int weekday, int count) => switch (count) {
    <= 3 => _symbols.weekdaysShort[weekday - 1],
    4 => _symbols.weekdays[weekday - 1],
    5 => _symbols.weekdaysNarrow[weekday - 1],
    _ => throw UnsupportedError(
      '"Short" weekdays are currently not supported.',
    ),
  };

  static int _dayOfYear(NepaliDateTime date) =>
      BsCalendar.toEpochDay(date.year, date.month, date.day).value -
      BsCalendar.toEpochDay(date.year).value +
      1;

  String _fraction(NepaliDateTime date, int count) {
    final String text;
    if (count <= 3) {
      // Like intl: always at least the 3 millisecond digits.
      text = '${date.millisecond}'.padLeft(3, '0');
    } else {
      final micros = '${date.millisecond * 1000 + date.microsecond}'.padLeft(
        6,
        '0',
      );
      text = count <= 6
          ? micros.substring(0, count)
          : micros.padRight(count, '0');
    }
    return _symbols.digits(text);
  }

  String _zoneName(NepaliDateTime date, int count) {
    // A local zone has no long name of its own, even if it is UTC.
    if (count < 4 || !(date.isNepalTime || date.isUtc)) {
      return date.timeZoneName;
    }
    return date.isNepalTime ? _symbols.nepalTime : _symbols.utc;
  }

  String _zoneOffset(Duration offset, int count) {
    final minutes = offset.inMinutes;
    final sign = minutes < 0 ? '-' : '+';
    final hh = '${minutes.abs() ~/ 60}'.padLeft(2, '0');
    final mm = '${minutes.abs() % 60}'.padLeft(2, '0');
    final text = switch (count) {
      4 when minutes == 0 => 'GMT',
      4 => 'GMT$sign$hh:$mm',
      5 when minutes == 0 => 'Z',
      5 => '$sign$hh:$mm',
      _ => '$sign$hh$mm',
    };
    return _symbols.digits(text);
  }
}
