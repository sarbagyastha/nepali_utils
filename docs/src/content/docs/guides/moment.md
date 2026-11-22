---
title: Relative time (Moment)
description: Show times relative to now, such as "3 days ago", "in 2 hours" or "Yesterday at 9:04 PM", in English or Nepali with NepaliMoment.
---

`NepaliMoment` turns dates and durations into text relative to now, in English or Nepali. It works like moment.js's `fromNow` / `calendar` and `Intl.RelativeTimeFormat`. It accepts both `DateTime` and `NepaliDateTime`.

```dart
final moment = NepaliMoment();
final now = DateTime(2024, 1, 10, 8);

moment.format(DateTime(2024, 1, 7), reference: now);       // 3 days ago
moment.format(DateTime(2024, 1, 10, 11), reference: now);  // in 3 hours
NepaliMoment(language: .nepali).format(DateTime(2024, 1, 7), reference: now);
// ३ दिन पहिले
```

In real code, leave out `reference` and it defaults to `DateTime.now()`. The examples on this page pass a fixed `reference` so that their output is reproducible.

## Creating a formatter

```dart
NepaliMoment({Language? language, MomentStyle style = .long, bool useWeeks = false})
```

| Option | Effect |
|---|---|
| `language` | `Language.english` or `Language.nepali`. The default is [`NepaliUtils.currentLanguage`](/getting-started/language/) when the formatter is created. |
| `style` | `MomentStyle.long` (`3 hours ago`) or `MomentStyle.short` (`3 hr. ago` / `३ घ. पहिले`) |
| `useWeeks` | describe 7 days up to a month in weeks (`3 weeks ago`) instead of days |

```dart
NepaliMoment(style: .short).format(DateTime(2024, 1, 10, 5), reference: now);   // 3 hr. ago
NepaliMoment(style: .short, language: .nepali)
    .format(DateTime(2024, 1, 10, 5), reference: now);                         // ३ घ. पहिले
NepaliMoment(useWeeks: true).format(DateTime(2023, 12, 20), reference: now);   // 3 weeks ago
NepaliMoment().format(DateTime(2023, 12, 20), reference: now);                 // 21 days ago
```

`NepaliMoment` objects are immutable. Create one and reuse it.

## `format`: time from now

`format(date, {reference})` describes the time from `reference` to `date`. Past dates get `… ago` / `… पहिले`, and future dates get `in …` / `… पछि`.

```dart
moment.format(DateTime(2024, 1, 10, 7, 59, 30), reference: now); // a few seconds ago
moment.format(DateTime(2024, 1, 10, 7, 59), reference: now);     // a minute ago
moment.format(DateTime(2024, 1, 10, 7), reference: now);         // an hour ago
moment.format(DateTime(2024, 1, 9, 10), reference: now);         // a day ago
moment.format(DateTime(2023, 12, 10), reference: now);           // a month ago
moment.format(DateTime(2023, 1, 10), reference: now);            // a year ago
NepaliMoment(language: .nepali).format(DateTime(2024, 1, 10, 10), reference: now);
// २ घण्टा पछि
```

It also works with BS dates:

```dart
moment.format(NepaliDateTime(2080, 9, 1), reference: NepaliDateTime(2080, 9, 6)); // 5 days ago
```

### Thresholds

The text is rounded the same way as in moment.js:

| Span | English | Nepali | Short style (example) |
|---|---|---|---|
| 0–44 seconds | a few seconds | केही क्षण | a few seconds |
| 45–89 seconds | a minute | एक मिनेट | 1 min. |
| 90 seconds – 44 minutes | 2–44 minutes | २–४४ मिनेट | 2 min. |
| 45–89 minutes | an hour | एक घण्टा | 1 hr. |
| 90 minutes – 21 hours | 2–21 hours | २–२१ घण्टा | 2 hr. |
| 22–35 hours | a day | एक दिन | 1 day |
| 36 hours – 25 days | 2–25 days | २–२५ दिन | 2 days |
| 26–45 days | a month | एक महिना | 1 mo. |
| over 45 days – 319 days | 2–10 months | २–१० महिना | 10 mo. |
| 320–547 days | a year | एक वर्ष | 1 yr. |
| 548 days and more | 2 years and more | २ वर्ष … | 2 yr. |

With `useWeeks: true`, spans from 7 days up to a month are given in weeks (`a week`, `२ हप्ता`).

## `formatDuration`: a span without a date

```dart
moment.formatDuration(const Duration(minutes: 5));                  // 5 minutes
moment.formatDuration(const Duration(hours: 22));                   // a day
moment.formatDuration(const Duration(days: 3), withSuffix: true);   // in 3 days
moment.formatDuration(const Duration(days: -3), withSuffix: true);  // 3 days ago
NepaliMoment(language: .nepali).formatDuration(const Duration(hours: 5)); // ५ घण्टा
```

With `withSuffix`, a positive duration is in the future and a negative one is in the past.

## `formatUnit`: an exact amount of a unit

`formatUnit(value, unit, {numeric = true})` works like `Intl.RelativeTimeFormat.format`. It doesn't round, so you choose the number and the unit:

```dart
moment.formatUnit(-3, .day);   // 3 days ago
moment.formatUnit(2, .hour);   // in 2 hours
moment.formatUnit(1.5, .hour); // in 1.5 hours
NepaliMoment(style: .short).formatUnit(-3, .minute); // 3 min. ago
NepaliMoment(language: .nepali).formatUnit(3, .week); // ३ हप्ता पछि
```

The units are `MomentUnit.second`, `minute`, `hour`, `day`, `week`, `month` and `year`.

With `numeric: false`, the values -1, 0 and 1 use words where the language has them:

| `formatUnit(v, unit, numeric: false)` | -1 | 0 | 1 |
|---|---|---|---|
| `.day` | yesterday / हिजो | today / आज | tomorrow / भोलि |
| `.week` | last week | this week | next week |
| `.month` | last month / गत महिना | this month | next month |
| `.year` | last year | this year | next year |
| `.second` | 1 second ago | now / अहिले | in 1 second |

A value that isn't finite (`double.nan`, `double.infinity`) throws an `ArgumentError`.

## `calendar`: Today, Yesterday, Last Sunday…

`calendar(date, {reference})` describes `date` by its calendar day relative to the day of `reference`, like moment.js's `calendar()`:

| Day | English | Nepali |
|---|---|---|
| same day | Today at 9:04 PM | आज २१:०४ |
| the day before | Yesterday at 9:04 PM | हिजो २१:०४ |
| the day after | Tomorrow at 9:30 AM | भोलि ०९:३० |
| 2–6 days before | Last Sunday at 9:04 PM | गएको आइतबार, २१:०४ |
| 2–6 days after | Saturday at 9:04 PM | आउँदो शनिबार, २१:०४ |
| otherwise | 11/8/2080 | २०८०-११-०८ |

```dart
final now = DateTime(2024, 1, 10, 8);

moment.calendar(DateTime(2024, 1, 9, 21, 4), reference: now);  // Yesterday at 9:04 PM
moment.calendar(DateTime(2024, 1, 7, 21, 4), reference: now);  // Last Sunday at 9:04 PM
moment.calendar(DateTime(2024, 2, 20, 21, 4), reference: now); // 11/8/2080
NepaliMoment(language: .nepali).calendar(DateTime(2024, 1, 7, 21, 4), reference: now);
// गएको आइतबार, २१:०४
```

Days are counted in the time zone of `date`. Dates more than six days away are formatted with [`NepaliDateFormat.yMd`](/guides/date-format/#skeletons), in BS.

:::note
As with the `j` skeletons, the English time part has a **narrow no-break space** (` `) before AM/PM.
:::

## Shorthands: `fromBS` and `fromAD`

These static methods are the same as `NepaliMoment(language: language).format(date, reference: referenceDate)`:

```dart
NepaliMoment.fromBS(
  NepaliDateTime.parse('2076-02-32T18:25:14'),
  referenceDate: NepaliDateTime.parse('2076-02-32T18:34:14'),
); // 9 minutes ago

NepaliMoment.fromAD(
  DateTime.parse('2019-06-02T18:22:14'),
  referenceDate: DateTime.parse('2019-06-15T18:34:14'),
  language: .nepali,
); // १३ दिन पहिले
```

## Gotchas

:::caution[Tests that compare strings]
Many phrases changed in 4.0. For example, `few moment ago` is now `a few seconds ago`, `3 days from now` is now `in 3 days`, and `about an hour` is now `an hour`. The thresholds changed too, so 22 hours is now `a day`. Update any test expectations, and always pass a fixed `reference` in tests.
:::

- `format` without `reference` reads the clock, so the result depends on when it runs.
- `showToday` from 3.x is gone. Use `calendar`, or `formatUnit(0, .day, numeric: false)` for `today`.

## See also

- [`NepaliMoment` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliMoment-class.html)
- [`MomentUnit`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/MomentUnit.html) and [`MomentStyle`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/MomentStyle.html)
- [Date formatting](/guides/date-format/)
