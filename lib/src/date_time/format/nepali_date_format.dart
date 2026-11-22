// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// Constructor names mirror package:intl's DateFormat skeletons (e.g. yMMMd).
// ignore_for_file: non_constant_identifier_names

import 'package:nepali_utils/src/date_time/format/format_token.dart';
import 'package:nepali_utils/src/date_time/format/locale_names.dart';
import 'package:nepali_utils/src/date_time/nepali_date_time.dart';
import 'package:nepali_utils/src/date_time/nepali_date_time_extension.dart';
import 'package:nepali_utils/src/language.dart';
import 'package:nepali_utils/src/nepali_digits.dart';
import 'package:nepali_utils/src/nepali_utils.dart';

/// Formats dates in the Bikram Sambat calendar.
///
/// Patterns follow the same syntax as `package:intl`'s `DateFormat`:
///
/// | Symbol | Meaning              | Example                            |
/// |--------|----------------------|------------------------------------|
/// | G      | era                  | BS, B.S., Bikram Sambat            |
/// | y      | year                 | 2076, (yy) 76                      |
/// | Q      | quarter              | 3, 03, Q3, 3rd quarter             |
/// | M      | month                | 8, 08, Marg, Mangsir, (MMMMM) Marga|
/// | d      | day of month         | 5, 05                              |
/// | E      | day of week          | T, Thu, Thursday                   |
/// | a      | am/pm (time of day)  | pm, PM (बिहान, दिउसो, …)            |
/// | h      | hour 1-12            | 9, 09                              |
/// | H      | hour 0-23            | 21                                 |
/// | m      | minute               | 4, 04                              |
/// | s      | second               | 5, 05                              |
/// | S      | fractional seconds   | 1 to 6 digits                      |
/// | '      | quoted literal text  | 'at', '' for a single quote        |
///
/// Numbers use Devanagari digits when the language is [Language.nepali].
///
/// The pattern is compiled once, so an instance can be reused freely.
final class NepaliDateFormat(
  /// The pattern used for formatting, see [NepaliDateFormat].
  final String pattern, [
  Language? language,
]) {
  /// Creates a formatter for [pattern].
  ///
  /// Names and digits use [language], or the default language set through
  /// [NepaliUtils] when omitted.
  this;

  /// 2076-08-05 => 5
  new d([Language? language]) : this('d', language);

  /// 2076-08-05 => Thu
  new E([Language? language]) : this('EE', language);

  /// 2076-08-05 => Thursday
  new EEEE([Language? language]) : this('EEE', language);

  /// 2076-08-05 => Marg
  new LLL([Language? language]) : this('MMM', language);

  /// 2076-08-05 => Mangsir
  new LLLL([Language? language]) : this('MMMM', language);

  /// 2076-08-05 => 8
  new M([Language? language]) : this('M', language);

  /// 2076-08-05 => 8/5
  new Md([Language? language]) : this('M/d', language);

  /// 2076-08-05 => Thu, 8/5
  new MEd([Language? language]) : this('EE, M/d', language);

  /// 2076-08-05 => Marg
  new MMM([Language? language]) : this('MMM', language);

  /// 2076-08-05 => Marg 5
  new MMMd([Language? language]) : this('MMM d', language);

  /// 2076-08-05 => Thursday, Marg 5
  new MMMEd([Language? language]) : this('EEE, MMM d', language);

  /// 2076-08-05 => Mangsir
  new MMMM([Language? language]) : this('MMMM', language);

  /// 2076-08-05 => Mangsir 5
  new MMMMd([Language? language]) : this('MMMM d', language);

  /// 2076-08-05 => Thursday, Mangsir 5
  new MMMMEEEEd([Language? language]) : this('EEE, MMMM d', language);

  /// 2076-08-05 => Q3
  new QQQ([Language? language]) : this('QQQ', language);

  /// 2076-08-05 => 3rd quarter
  new QQQQ([Language? language]) : this('QQQQ', language);

  /// 2076-08-05 => 2076
  new y([Language? language]) : this('y', language);

  /// 2076-08-05 => 2076/08
  new yM([Language? language]) : this('y/MM', language);

  /// 2076-08-05 => 2076/08/05
  new yMd([Language? language]) : this('y/MM/dd', language);

  /// 2076-08-05 => Thu, 2076/08/05
  new yMEd([Language? language]) : this('EE, y/MM/dd', language);

  /// 2076-08-05 => Marg 2076
  new yMMM([Language? language]) : this('MMM y', language);

  /// 2076-08-05 => Marg 5, 2076
  new yMMMd([Language? language]) : this('MMM d, y', language);

  /// 2076-08-05 => Thu, Marg 5, 2076
  new yMMMEd([Language? language]) : this('EE, MMM d, y', language);

  /// 2076-08-05 => Mangsir 2076
  new yMMMM([Language? language]) : this('MMMM y', language);

  /// 2076-08-05 => Mangsir 5, 2076
  new yMMMMd([Language? language]) : this('MMMM d, y', language);

  /// 2076-08-05 => Thursday, Mangsir 5, 2076
  new yMMMMEEEEd([Language? language]) : this('EEE, MMMM d, y', language);

  /// 2076-08-05 => Q3 2076
  new yQQQ([Language? language]) : this('QQQ y', language);

  /// 2076-08-05 => 3rd quarter 2076
  new yQQQQ([Language? language]) : this('QQQQ y', language);

  /// 2076-08-05T21:04:25 => 21
  new H([Language? language]) : this('H', language);

  /// 2076-08-05T21:04:25 => 21:04
  new Hm([Language? language]) : this('HH:mm', language);

  /// 2076-08-05T21:04:25 => 21:04:25
  new Hms([Language? language]) : this('HH:mm:ss', language);

  /// 2076-08-05T21:04:25 => 9 PM
  new j([Language? language])
    : this(_isNepali(language) ? 'aa h' : 'h aa', language);

  /// 2076-08-05T21:04:25 => 9:04 PM
  new jm([Language? language])
    : this(_isNepali(language) ? 'aa h:mm' : 'h:mm aa', language);

  /// 2076-08-05T21:04:25 => 9:04:25 PM
  new jms([Language? language])
    : this(_isNepali(language) ? 'aa h:mm:ss' : 'h:mm:ss aa', language);

  /// 2076-08-05T21:04:25 => 4
  new m([Language? language]) : this('m', language);

  /// 2076-08-05T21:04:25 => 04:25
  new ms([Language? language]) : this('mm:ss', language);

  /// 2076-08-05T21:04:25 => 25
  new s([Language? language]) : this('s', language);

  /// The language used for names and digits.
  final Language language = language ?? NepaliUtils().language;

  final List<FormatToken> _tokens = tokenize(pattern);

  static bool _isNepali(Language? language) =>
      (language ?? NepaliUtils().language) == .nepali;

  /// Formats [date] according to [pattern] and [language].
  ///
  /// A plain [DateTime] is converted with [ENepaliDateTime.toNepaliDateTime]
  /// first.
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

  String _formatField(FieldToken field, NepaliDateTime date) {
    final isNepali = language == .nepali;
    String number(int value, [int width = 0]) =>
        localizedNumber(value, language, width);

    return switch ((field.letter, field.count)) {
      ('G', 1) => isNepali ? 'बि सं' : 'BS',
      ('G', 2) => isNepali ? 'बि.सं.' : 'B.S.',
      ('G', _) => isNepali ? 'बिक्रम संबत' : 'Bikram Sambat',
      ('y', 2) => number(date.year % 100, 2),
      ('y', final count) => number(date.year, count),
      ('Q', final count) => _quarter((date.month + 2) ~/ 3, count),
      ('M', 1) => number(date.month),
      ('M', 2) => number(date.month, 2),
      ('M', 3) => BsMonthName.of(date.month).short(language),
      ('M', 4) => BsMonthName.of(date.month).full(language),
      ('M', _) => BsMonthName.of(date.month).alt(language),
      ('d', final count) => number(date.day, count),
      ('E', 1) => WeekdayName.of(date.weekday).initial(language),
      ('E', 2) => WeekdayName.of(date.weekday).short(language),
      ('E', _) => WeekdayName.of(date.weekday).full(language),
      ('a', final count) => _period(date.hour, upperCase: count > 1),
      ('h', final count) => number((date.hour + 11) % 12 + 1, count),
      ('H', final count) => number(date.hour, count),
      ('m', final count) => number(date.minute, count),
      ('s', final count) => number(date.second, count),
      ('S', final count) => _fraction(date, count),
      _ => field.text,
    };
  }

  String _quarter(int quarter, int count) => switch (count) {
    1 => '$quarter',
    2 => '0$quarter',
    3 => 'Q$quarter',
    _ => '${_ordinal(quarter)} quarter',
  };

  static String _ordinal(int n) => switch (n) {
    1 => '1st',
    2 => '2nd',
    3 => '3rd',
    _ => '${n}th',
  };

  String _period(int hour, {required bool upperCase}) {
    if (language == .nepali) {
      return switch (hour) {
        < 12 => 'बिहान',
        12 => 'मध्यान्न',
        < 16 => 'दिउसो',
        < 20 => 'साँझ',
        _ => 'बेलुकी',
      };
    }
    final period = hour < 12 ? 'am' : 'pm';
    return upperCase ? period.toUpperCase() : period;
  }

  String _fraction(NepaliDateTime date, int count) {
    final micros = date.millisecond * 1000 + date.microsecond;
    final digits = '$micros'.padLeft(6, '0');
    final text = count <= 6
        ? digits.substring(0, count)
        : digits.padRight(count, '0');
    return language == .nepali ? toNepaliDigits(text) : text;
  }
}
