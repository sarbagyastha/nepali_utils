// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/language/language_symbols.dart';
import 'package:nepali_utils/src/core/nepali_utils.dart';
import 'package:nepali_utils/src/date_time/calendar/epoch_day.dart';
import 'package:nepali_utils/src/date_time/format/nepali_date_format.dart';
import 'package:nepali_utils/src/date_time/nepali_date_time.dart';
import 'package:nepali_utils/src/moment/moment_unit.dart';
import 'package:nepali_utils/src/moment/relative_span.dart';
import 'package:nepali_utils/src/number/format/nepali_number_format.dart';

/// Describes dates relative to now, like moment.js and
/// `Intl.RelativeTimeFormat`:
///
/// ```dart
/// final moment = NepaliMoment();
/// moment.format(date);                      // 3 days ago / in 2 hours
/// moment.formatDuration(Duration(days: 3)); // 3 days
/// moment.formatUnit(-1, .day);              // 1 day ago
/// moment.formatUnit(-1, .day, numeric: false); // yesterday
/// moment.calendar(date);                    // Yesterday at 9:04 PM
///
/// NepaliMoment(language: .nepali).format(date); // ३ दिन पहिले
/// ```
///
/// Accepts both [DateTime] and [NepaliDateTime].
///
/// Instances are immutable.
final class NepaliMoment {
  /// Creates a moment formatter.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage] at the time the
  /// formatter is created. [style] chooses between full and abbreviated
  /// units. When [useWeeks] is true, [format] and [formatDuration] describe
  /// spans from 7 days to a month in weeks.
  factory({
    Language? language,
    MomentStyle style = .long,
    bool useWeeks = false,
  }) => ._(language ?? NepaliUtils.currentLanguage, style, useWeeks);

  new _(this.language, this.style, this.useWeeks);

  /// The fuzzy time between [date] and [referenceDate], e.g. `3 days ago`.
  ///
  /// [referenceDate] defaults to now.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  static String fromBS(
    NepaliDateTime date, {
    NepaliDateTime? referenceDate,
    Language? language,
  }) => NepaliMoment(language: language).format(date, reference: referenceDate);

  /// The fuzzy time between [date] and [referenceDate], e.g. `3 days ago`.
  ///
  /// [referenceDate] defaults to now.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  static String fromAD(
    DateTime date, {
    DateTime? referenceDate,
    Language? language,
  }) => NepaliMoment(language: language).format(date, reference: referenceDate);

  /// The language of the phrases and digits.
  final Language language;

  /// Whether units are written in full or abbreviated.
  final MomentStyle style;

  /// Whether spans from 7 days to a month are given in weeks.
  final bool useWeeks;

  RelativeTimeSymbols get _phrases => symbolsOf(language).relativeTime;

  /// The fuzzy time from [reference] to [date], e.g. `3 days ago`,
  /// `in 2 hours` / `३ दिन पहिले`, `२ घण्टा पछि`.
  ///
  /// [reference] defaults to now. See [formatDuration] for the thresholds.
  String format(DateTime date, {DateTime? reference}) {
    final difference = date.difference(reference ?? DateTime.now());
    return _withSuffix(_span(difference), future: difference > Duration.zero);
  }

  /// [duration] as a fuzzy span, e.g. `3 days` / `३ दिन`.
  ///
  /// With [withSuffix], a positive duration is in the future (`in 3 days`)
  /// and a negative one in the past (`3 days ago`).
  ///
  /// The thresholds are those of moment.js:
  ///
  /// | Range                 | Result              |
  /// |-----------------------|---------------------|
  /// | 0 to 44 seconds       | a few seconds       |
  /// | 45 to 89 seconds      | a minute            |
  /// | 90 seconds to 44 min  | 2 to 44 minutes     |
  /// | 45 to 89 minutes      | an hour             |
  /// | 90 minutes to 21 h    | 2 to 21 hours       |
  /// | 22 to 35 hours        | a day               |
  /// | 36 hours to 25 days   | 2 to 25 days        |
  /// | 26 to 45 days         | a month             |
  /// | 45 days to 319 days   | 2 to 10 months      |
  /// | 320 to 547 days       | a year              |
  /// | 548 days and more     | 2 years and more    |
  String formatDuration(Duration duration, {bool withSuffix = false}) {
    final span = _span(duration);
    return withSuffix ? _withSuffix(span, future: !duration.isNegative) : span;
  }

  /// [value] [unit]s from now, like `Intl.RelativeTimeFormat.format`:
  /// `formatUnit(-3, .day)` is `3 days ago` and `formatUnit(2, .hour)` is
  /// `in 2 hours`.
  ///
  /// When [numeric] is false, -1, 0 and 1 use words where the language has
  /// them: `yesterday`, `today`, `tomorrow`, `last month`, `now` /
  /// `हिजो`, `आज`, `भोलि`, `गत महिना`, `अहिले`.
  ///
  /// Throws an [ArgumentError] when [value] isn't finite.
  String formatUnit(num value, MomentUnit unit, {bool numeric = true}) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'Must be finite');
    }
    final phrases = _unit(unit);
    if (!numeric) {
      final word = switch (value) {
        -1 => phrases.previous,
        0 => phrases.current,
        1 => phrases.next,
        _ => null,
      };
      if (word != null) return word;
    }
    final count = value.abs();
    final template = switch ((style, count == 1)) {
      (.long, true) => phrases.one,
      (.long, false) => phrases.other,
      (.short, true) => phrases.shortOne,
      (.short, false) => phrases.shortOther,
    };
    return _withSuffix(
      template.replaceFirst('#', _number(count)),
      future: !value.isNegative,
    );
  }

  /// [date] relative to the day of [reference], like moment.js's
  /// `calendar`:
  ///
  /// | Day             | English                  | Nepali               |
  /// |-----------------|--------------------------|----------------------|
  /// | same day        | Today at 9:04 PM         | आज २१:०४             |
  /// | the day before  | Yesterday at 9:04 PM     | हिजो २१:०४           |
  /// | the day after   | Tomorrow at 9:04 PM      | भोलि २१:०४           |
  /// | 2-6 days before | Last Thursday at 9:04 PM | गएको बिहिबार, २१:०४  |
  /// | 2-6 days after  | Thursday at 9:04 PM      | आउँदो बिहिबार, २१:०४ |
  /// | otherwise       | 8/5/2076                 | २०७६-०८-०५           |
  ///
  /// Days are counted in the time zone of [date]. [reference] defaults to
  /// now.
  String calendar(DateTime date, {DateTime? reference}) {
    final offset = date.timeZoneOffset.inMicroseconds;
    EpochDay day(DateTime value) =>
        EpochDay.ofMicroseconds(value.microsecondsSinceEpoch + offset);
    final days = day(date).value - day(reference ?? DateTime.now()).value;

    final phrases = _phrases.calendar;
    final template = switch (days) {
      0 => phrases.sameDay,
      -1 => phrases.previousDay,
      1 => phrases.nextDay,
      >= -6 && < -1 => phrases.previousWeek,
      > 1 && <= 6 => phrases.nextWeek,
      _ => null,
    };
    if (template == null) return NepaliDateFormat.yMd(language).format(date);
    return template
        .replaceFirst('{weekday}', NepaliDateFormat.EEEE(language).format(date))
        .replaceFirst('{time}', NepaliDateFormat.jm(language).format(date));
  }

  String _span(Duration duration) {
    final span = relativeSpan(duration, useWeeks: useWeeks);
    if (span == null) return _phrases.fewSeconds;
    final (:unit, :count) = span;
    final phrases = _unit(unit);
    if (count == 1 && style == .long) return phrases.approximate;
    final template = switch ((style, count == 1)) {
      (.long, _) => phrases.other,
      (.short, true) => phrases.shortOne,
      (.short, false) => phrases.shortOther,
    };
    return template.replaceFirst('#', _number(count));
  }

  String _withSuffix(String span, {required bool future}) =>
      (future ? _phrases.future : _phrases.past).replaceFirst('#', span);

  String _number(num value) =>
      NepaliNumberFormat.decimalPattern(language).format(value);

  UnitSymbols _unit(MomentUnit unit) {
    final phrases = _phrases;
    return switch (unit) {
      .second => phrases.second,
      .minute => phrases.minute,
      .hour => phrases.hour,
      .day => phrases.day,
      .week => phrases.week,
      .month => phrases.month,
      .year => phrases.year,
    };
  }

  @override
  String toString() => 'NepaliMoment(${language.name}, ${style.name})';
}
