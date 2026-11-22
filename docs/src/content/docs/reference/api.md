---
title: API reference
description: Every public symbol exported by package:nepali_utils, with links to the full dartdoc on pub.dev.
---

The full API reference is generated from the source code and hosted on pub.dev:

**[pub.dev/documentation/nepali_utils/latest](https://pub.dev/documentation/nepali_utils/latest/)**

Everything below is exported by one library:

```dart
import 'package:nepali_utils/nepali_utils.dart';
```

## Core

| Symbol | Kind | Description | Guide |
|---|---|---|---|
| [`Language`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/Language.html) | enum | `english` or `nepali`; converts to and from locale identifiers. | [Language](/getting-started/language/) |
| [`NepaliUtils`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliUtils-class.html) | class (static) | `defaultLanguage`, `currentLanguage` and `withLanguage`. | [Language](/getting-started/language/) |

## Date & time

| Symbol | Kind | Description | Guide |
|---|---|---|---|
| [`NepaliDateTime`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliDateTime-class.html) | class | A Bikram Sambat `DateTime` in local time, UTC or Nepal Time. | [Date & time](/guides/date-time/) |
| [`ENepaliDateTime`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/ENepaliDateTime.html) | extension on `DateTime` | `toNepaliDateTime()`. | [Date & time](/guides/date-time/#converting-between-ad-and-bs) |
| [`NepaliDateFormat`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliDateFormat-class.html) | class | intl-style date formatting with skeletons and pattern letters. | [Date formatting](/guides/date-format/) |

## Numbers

| Symbol | Kind | Description | Guide |
|---|---|---|---|
| [`NepaliNumberFormat`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliNumberFormat-class.html) | class | Lakh/crore grouping, currency, percent, compact, words and parsing. | [Number formatting](/guides/number-format/) |

## Relative time

| Symbol | Kind | Description | Guide |
|---|---|---|---|
| [`NepaliMoment`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliMoment-class.html) | class | `format`, `formatDuration`, `formatUnit` and `calendar`. | [Relative time](/guides/moment/) |
| [`MomentUnit`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/MomentUnit.html) | enum | `second` … `year`, for `formatUnit`. | [Relative time](/guides/moment/#formatunit-an-exact-amount-of-a-unit) |
| [`MomentStyle`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/MomentStyle.html) | enum | `long` (`3 hours ago`) or `short` (`3 hr. ago`). | [Relative time](/guides/moment/#creating-a-formatter) |

## Unicode

| Symbol | Kind | Description | Guide |
|---|---|---|---|
| [`NepaliUnicode`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliUnicode-class.html) | class (`Converter`) | Romanized ↔ Devanagari conversion, live typing and streams. | [Nepali Unicode](/guides/unicode/) |
| [`NepaliUnicodeStyle`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliUnicodeStyle.html) | enum | `classic`, `google`, `mppRomanized` and `mppTraditional`. | [Nepali Unicode](/guides/unicode/#styles) |
| [`Preeti`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/Preeti-class.html) | class (static) | Converts between the Preeti font encoding and Unicode. | [Preeti](/guides/preeti-devanagari/#preeti) |
| [`Devanagari`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/Devanagari-class.html) | class (static) | Detection, digit conversion and akshara splitting. | [Devanagari](/guides/preeti-devanagari/#devanagari-helpers) |

## Measurement

| Symbol | Kind | Description | Guide |
|---|---|---|---|
| [`NepaliArea`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliArea-class.html) | class | Land area: ropani-aana-paisa-daam, bigha-kattha-dhur and metric. | [Measurement](/guides/measurement/#land-area-nepaliarea) |
| [`AreaUnit`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/AreaUnit.html) | enum | Area units, from `ropani` to `hectare`. | [Measurement](/guides/measurement/#land-area-nepaliarea) |
| [`AreaSystem`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/AreaSystem.html) | enum | `ropani` or `bigha` mixed-unit system. | [Measurement](/guides/measurement/#formatting) |
| [`NepaliWeight`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliWeight-class.html) | class | Weight: tola-lal, dharni-ser-pau-chhatak and metric. | [Measurement](/guides/measurement/#weight-nepaliweight) |
| [`WeightUnit`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/WeightUnit.html) | enum | Weight units, from `tola` to `kilogram`. | [Measurement](/guides/measurement/#weight-nepaliweight) |
| [`WeightSystem`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/WeightSystem.html) | enum | `tola` or `dharni` mixed-unit system. | [Measurement](/guides/measurement/#weight-nepaliweight) |
| [`NepaliVolume`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliVolume-class.html) | class | Grain volume: muri-pathi-mana-muthi and litres. | [Measurement](/guides/measurement/#grain-volume-nepalivolume) |
| [`VolumeUnit`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/VolumeUnit.html) | enum | Volume units, from `muri` to `liter`. | [Measurement](/guides/measurement/#grain-volume-nepalivolume) |

## Phone numbers

| Symbol | Kind | Description | Guide |
|---|---|---|---|
| [`NepaliPhoneNumber`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliPhoneNumber-class.html) | class | Parses, validates, formats and finds mobile and landline numbers. | [Phone numbers](/guides/phone-number/) |
| [`PhoneNumberMatch`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/PhoneNumberMatch-class.html) | class | A number found by `findAll`: `start`, `end`, `text`, `number`. | [Phone numbers](/guides/phone-number/#finding-numbers-in-text) |
| [`PhoneType`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/PhoneType.html) | enum | `mobile` or `landline`. | [Phone numbers](/guides/phone-number/#number-types) |
| [`PhoneFormat`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/PhoneFormat.html) | enum | `national`, `international` or `e164`. | [Phone numbers](/guides/phone-number/#formatting) |
| [`MobileOperator`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/MobileOperator.html) | enum | `nepalTelecom`, `ncell`, `smart` and `utl`, with their prefixes. | [Phone numbers](/guides/phone-number/#mobile-operators) |

:::note
Classes in 4.0 are `final` (or `abstract final` for the static-only ones), so you can't extend or implement them. Use composition instead.
:::
