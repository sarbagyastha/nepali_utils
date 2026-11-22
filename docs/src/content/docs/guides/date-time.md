---
title: Nepali date & time
description: Create, convert, compare and do arithmetic with Bikram Sambat dates using NepaliDateTime, with local, UTC and Nepal Time.
---

`NepaliDateTime` is a `DateTime` whose fields are in the **Bikram Sambat (BS)** calendar. It implements `DateTime`, so it works like the one you know:

- It stores an exact instant (`microsecondsSinceEpoch`).
- It shows its fields in a time zone: **local**, **UTC**, or **Nepal Time** (UTC+05:45).
- You can pass it anywhere a `DateTime` is expected for instant-based operations, such as comparing, sorting, `difference` and epoch values.

The difference is that `year`, `month` and `day` are BS values, and `weekday` starts on Sunday.

```dart
final gorkhaEarthquake = NepaliDateTime.parse('2072-01-12T11:56:25');

print(gorkhaEarthquake);              // 2072-01-12 11:56:25.000
print(gorkhaEarthquake.year);         // 2072
print(gorkhaEarthquake.month);        // 1 (Baishakh)
print(gorkhaEarthquake.weekday);      // 7 (Saturday)
print(gorkhaEarthquake.toDateTime()); // 2015-04-25 11:56:25.000
```

## Creating dates

| Constructor | Time zone | Like |
|---|---|---|
| `NepaliDateTime(year, [month, day, hour, minute, second, millisecond, microsecond])` | local | `DateTime(...)` |
| `NepaliDateTime.utc(...)` | UTC | `DateTime.utc(...)` |
| `NepaliDateTime.nepal(...)` | Nepal Time | — |
| `NepaliDateTime.now()` | local | `DateTime.now()` |
| `NepaliDateTime.nepalNow()` | Nepal Time | — |
| `NepaliDateTime.fromDateTime(dateTime)` | same as `dateTime` | — |
| `NepaliDateTime.fromMicrosecondsSinceEpoch(us, {isUtc})` | local or UTC | `DateTime.fromMicrosecondsSinceEpoch` |
| `NepaliDateTime.fromMillisecondsSinceEpoch(ms, {isUtc})` | local or UTC | `DateTime.fromMillisecondsSinceEpoch` |
| `NepaliDateTime.parse(string)` / `tryParse(string)` | depends on the string | `DateTime.parse` |

```dart
final local = NepaliDateTime(2080, 1, 1);
final utc = NepaliDateTime.utc(2080, 1, 1);
final npt = NepaliDateTime.nepal(2080, 1, 1);

print(utc.toIso8601String()); // 2080-01-01T00:00:00.000Z
print(npt.toIso8601String()); // 2080-01-01T00:00:00.000+05:45
print(npt.toUtc());           // 2079-12-30 18:15:00.000Z
```

Months and weekdays have named constants:

```dart
NepaliDateTime(2081, NepaliDateTime.shrawan, 1);
date.weekday == NepaliDateTime.saturday;
```

| Months | Value |
|---|---|
| `baishakh`, `jestha`, `ashadh`, `shrawan`, `bhadra`, `ashwin` | 1–6 |
| `kartik`, `mangsir`, `poush`, `magh`, `falgun`, `chaitra` | 7–12 |

| Weekdays | Value |
|---|---|
| `sunday`, `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `saturday` | 1–7 |

:::caution[Weekdays start on Sunday]
`DateTime.weekday` runs from Monday (1) to Sunday (7). `NepaliDateTime.weekday` runs from **Sunday (1) to Saturday (7)**, as in the Nepali week. Compare with the `NepaliDateTime` constants, not the `DateTime` ones.
:::

### Supported range

`NepaliDateTime.minYear` is **1969** and `NepaliDateTime.maxYear` is **2250**. Creating a date outside that range throws a `RangeError`. `parse` throws a `FormatException` instead.

### Out-of-range values are normalised

Like `DateTime`, components that are too large or too small roll over into the next or previous unit, using the real length of each BS month:

```dart
NepaliDateTime(2080, 1, 35);    // 2080-02-04 (Baishakh 2080 has 31 days)
NepaliDateTime(2080, 13);       // 2081-01-01
NepaliDateTime(2080, 2, 0);     // 2080-01-31
NepaliDateTime(2080, 1, 1, 25); // 2080-01-02 01:00:00.000
```

## Time zones

A `NepaliDateTime` is always one of three kinds:

| Kind | Created by | `isUtc` | `isNepalTime` | `timeZoneName` |
|---|---|---|---|---|
| Local | `NepaliDateTime(...)`, `now()`, `toLocal()` | `false` | `false` | the device's zone |
| UTC | `.utc(...)`, `toUtc()` | `true` | `false` | `UTC` |
| Nepal Time | `.nepal(...)`, `nepalNow()`, `toNepalTime()` | `false` | `true` | `NPT` |

`toLocal()`, `toUtc()` and `toNepalTime()` keep the instant and change only how it's shown:

```dart
final npt = NepaliDateTime.nepal(2081, 1, 1, 10, 30);

print(npt.toUtc().toIso8601String());               // 2081-01-01T04:45:00.000Z
print(npt.toUtc().toNepalTime().toIso8601String()); // 2081-01-01T10:30:00.000+05:45
print(npt.timeZoneName);   // NPT
print(npt.timeZoneOffset); // 5:45:00.000000
```

### "Now": local time or Nepal time?

```dart
final now = NepaliDateTime.now();          // local time, like DateTime.now()
final nowInNepal = NepaliDateTime.nepalNow(); // Nepal Time, on any device
```

On a device in Nepal the two are the same. On a device elsewhere, such as a user abroad, a CI server in UTC or a cloud function, `now()` gives the BS date **at the device's location**, and `nepalNow()` gives the date **in Nepal**. Use `nepalNow()` when you need "today in Nepal", for example for business days or Nepali holidays.

:::caution[Changed in 4.0]
In 3.x, `NepaliDateTime.now()` always returned Nepal time. In 4.0 it returns local time. If your code needs Nepal's date, switch to `nepalNow()`. See [Upgrading to 4.0](/migration/v4/).
:::

## Converting between AD and BS

`toNepaliDateTime()` on any `DateTime`, and `toDateTime()` on a `NepaliDateTime`, convert between the calendars. Both keep **the instant and the time zone**:

```dart
final bs = DateTime(2019, 8, 3, 14, 30, 15).toNepaliDateTime();
print(bs); // 2076-04-18 14:30:15.000

final ad = bs.toDateTime();
print(ad); // 2019-08-03 14:30:15.000
```

A UTC `DateTime` gives a UTC `NepaliDateTime`. Add `.toNepalTime()` to show it in Nepal Time:

```dart
final instant = DateTime.utc(2024, 1, 1);

print(instant.toNepaliDateTime());               // 2080-09-16 00:00:00.000Z
print(instant.toNepaliDateTime().toNepalTime()); // 2080-09-16 05:45:00.000
```

`NepaliDateTime.fromDateTime(dateTime)` does the same as `dateTime.toNepaliDateTime()`. If its argument already is a `NepaliDateTime`, both return it unchanged.

`toDateTime()` returns a UTC `DateTime` for a UTC value and a local `DateTime` otherwise, because a `DateTime` can't hold Nepal Time on a device outside Nepal. The instant is always the same:

```dart
NepaliDateTime.utc(2080, 1, 1).toDateTime(); // 2023-04-14 00:00:00.000Z
```

:::tip[The Nepali date of an instant]
To get the BS date of an instant, such as a server timestamp, the same way on every device, use `toNepaliDateTime().toNepalTime()`.
:::

## Parsing

`NepaliDateTime.parse` accepts the same formats as `DateTime.parse`, but the date is in BS:

```dart
NepaliDateTime.parse('2080-01-15');                // 2080-01-15 00:00:00.000 (local)
NepaliDateTime.parse('2080-01-15 10:30:00');       // 2080-01-15 10:30:00.000 (local)
NepaliDateTime.parse('20800115');                  // 2080-01-15 00:00:00.000 (local)
NepaliDateTime.parse('2080-01-15T10:30:00Z');      // 2080-01-15 10:30:00.000Z
NepaliDateTime.parse('2080-01-15T10:30:00.123456Z'); // 2080-01-15 10:30:00.123456Z
NepaliDateTime.parse('2080-01-15T10:30:00+01:00'); // 2080-01-15 09:30:00.000Z
NepaliDateTime.parse('2080-01-15T10:30:00+05:45'); // Nepal Time, 10:30
```

- With no time zone, the result is **local**.
- With `Z` or any offset, the result is **UTC**. The one exception is `+05:45`, which gives a **Nepal Time** value.
- Invalid input, including years outside 1969–2250, throws a `FormatException`. `tryParse` returns `null` instead.

```dart
NepaliDateTime.tryParse('2080/01/01'); // null
```

To parse text in a custom layout such as `Baishakh 15, 2080`, extract the numbers yourself, then call the constructor.

## Reading fields

| Getter | Meaning |
|---|---|
| `year`, `month`, `day` | BS date (month 1 = Baishakh, day 1–32) |
| `hour`, `minute`, `second`, `millisecond`, `microsecond` | wall-clock time in the value's time zone |
| `weekday` | 1 (Sunday) – 7 (Saturday) |
| `totalDays` | number of days in this BS month |
| `totalDaysInYear` | number of days in this BS year |
| `isUtc`, `isNepalTime`, `timeZoneName`, `timeZoneOffset` | the time zone |

BS months have 29 to 32 days, and the lengths change from year to year:

```dart
NepaliDateTime(2081, 2).totalDays;  // 32 (Jestha 2081)
NepaliDateTime(2081, 9).totalDays;  // 29 (Poush 2081)
NepaliDateTime(2072).totalDaysInYear; // 365
```

## Changing dates

`copyWith` replaces fields and keeps the time zone. The result is normalised like the constructor's:

```dart
final date = NepaliDateTime.parse('2072-01-12T11:56:25');

date.copyWith(month: 2);         // 2072-02-12 11:56:25.000
date.copyWith(day: 40);          // 2072-02-09 11:56:25.000
date.mergeTime(10, 20, 30);      // 2072-01-12 10:20:30.000
```

`mergeTime(hour, minute, second)` keeps the date, sets the time, and clears milliseconds and microseconds.

Two common tasks:

```dart
// Last day of the month: day 0 of the next month.
final first = NepaliDateTime(2081, 5, 1);
first.copyWith(month: first.month + 1, day: 0); // 2081-05-31

// "Same day next month" can overflow. Jestha 2081 has 32 days, Ashadh 31.
NepaliDateTime(2081, 2, 32).copyWith(month: 3); // 2081-04-01
```

## Arithmetic and comparison

`add`, `subtract`, `difference`, `isBefore`, `isAfter`, `isAtSameMomentAs` and `compareTo` work on the instant. They accept any `DateTime`, so you can mix AD and BS values:

```dart
NepaliDateTime(2080, 12, 25).add(const Duration(days: 10)); // 2081-01-05
NepaliDateTime(2080, 1, 1).subtract(const Duration(days: 1)); // 2079-12-30

NepaliDateTime.utc(2081, 1, 1).difference(NepaliDateTime.utc(2080, 1, 1)).inDays; // 365

final bs = NepaliDateTime.utc(2080, 1, 1);
bs.isBefore(DateTime.utc(2023, 4, 15));   // true
bs.difference(DateTime.utc(2023, 1, 1));  // 2472:00:00.000000

final dates = <DateTime>[
  NepaliDateTime.utc(2081, 1, 1),
  DateTime.utc(2020, 1, 1),
  NepaliDateTime.utc(2070, 1, 1),
]..sort();
// [2070-01-01 00:00:00.000Z, 2020-01-01 00:00:00.000Z, 2081-01-01 00:00:00.000Z]
```

:::note
`add(Duration(days: 1))` adds exactly 24 hours, as with `DateTime`. In a local zone with daylight saving time, that isn't always the same time on the next calendar day. To move by calendar days, use `copyWith(day: date.day + 1)`.
:::

### Equality

Like `DateTime`, `==` is true only when the **instant and the time zone** both match. To compare only the instant, use `isAtSameMomentAs`:

```dart
final npt = NepaliDateTime.nepal(2080, 1, 1);

npt == NepaliDateTime.nepal(2080, 1, 1); // true
npt == npt.toUtc();                      // false: different zone
npt.isAtSameMomentAs(npt.toUtc());       // true
```

## Formatting

`toString()` and `toIso8601String()` match `DateTime`'s format. Nepal Time values end in `+05:45` in ISO form:

```dart
NepaliDateTime.utc(2080, 1, 1).toString();          // 2080-01-01 00:00:00.000Z
NepaliDateTime.nepal(2080, 1, 1).toIso8601String(); // 2080-01-01T00:00:00.000+05:45
```

For anything else, use `format` or [`NepaliDateFormat`](/guides/date-format/):

```dart
final date = NepaliDateTime.parse('2072-01-12T11:56:25');

date.format('yyyy-MM-dd');                   // 2072-01-12
date.format('yyyy MMMM d, EEEE', .nepali);   // २०७२ बैशाख १२, शनिबार
NepaliDateFormat.yMMMMEEEEd().format(date);  // Saturday, Baishakh 12, 2072
```

## Gotchas

:::caution[Local dates and the device's time zone]
`NepaliDateTime(2080, 1, 1)` is midnight **local time**. Converting it to UTC, or to AD with `toDateTime()` and then to UTC, gives a different result on each device. If a date means "a day in Nepal", for example from an API or a database, create it with `NepaliDateTime.nepal(...)`, or parse it with `+05:45`.
:::

- `toNepaliDateTime()` **keeps the zone** in 4.0. To get the 3.x behaviour, add `.toNepalTime()`.
- `DateTime` methods that take a `DateTime` treat a `NepaliDateTime` as an instant. `DateTime(2023).isBefore(nepaliDate)` works, but `DateTime`'s own `year` and `month` are still AD values.

## See also

- [`NepaliDateTime` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliDateTime-class.html)
- [`ENepaliDateTime` extension](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/ENepaliDateTime.html) (`toNepaliDateTime()`)
- [Date formatting](/guides/date-format/)
- [Relative time](/guides/moment/)
