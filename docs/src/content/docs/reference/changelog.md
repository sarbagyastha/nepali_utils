---
title: Changelog
description: Release notes for nepali_utils, with the highlights of version 4.0.
---

The full release history is in the changelog:

- **[CHANGELOG.md on GitHub](https://github.com/sarbagyastha/nepali_utils/blob/develop/CHANGELOG.md)**
- **[Changelog on pub.dev](https://pub.dev/packages/nepali_utils/changelog)**

## 4.0.0 highlights

4.0 is a near-total rewrite for modern Dart (3.13+). Almost every class has breaking changes. **Read [Upgrading to 4.0](/migration/v4/) before you upgrade.**

### Breaking

- **Dart 3.13 or later is required.** Classes are now `final`, so you can't extend or implement them.
- **`NepaliDateTime` is instant-based**, like `DateTime`. It can be local, UTC or Nepal Time.
  - `NepaliDateTime.now()` now returns **local** time. Use `nepalNow()` for Nepal time.
  - `DateTime.toNepaliDateTime()` keeps the time zone. Add `.toNepalTime()` to get the old behaviour.
  - Out-of-range components are normalised, `==` compares values, and `parse` follows `DateTime.parse`.
- **`NepaliDateFormat`** follows intl's `DateFormat`: intl's skeleton layouts and pattern letters, and it's immutable.
- **`NepaliNumberFormat`** follows intl's `NumberFormat`. Named constructors and `copyWith` replace the old constructor flags. Numbers are rounded instead of truncated.
- **`NepaliUtils`** is static: `NepaliUtils.defaultLanguage = …` and `withLanguage`.
- **`NepaliMoment`** is an immutable formatter. Its English phrases and thresholds now match moment.js.
- **`NepaliUnicode`** is a `const` instance with styles: `const NepaliUnicode().convert(…)`. `live: true` became `convertLive`. `{…}` now escapes text.

### New

- [Measurement units](/guides/measurement/): `NepaliArea`, `NepaliWeight` and `NepaliVolume`.
- [Phone numbers](/guides/phone-number/): `NepaliPhoneNumber`, with the operator, the district, formatting and `findAll`.
- [Preeti & Devanagari](/guides/preeti-devanagari/): `Preeti.toUnicode` / `fromUnicode` and the `Devanagari` helpers.
- [Unicode](/guides/unicode/) styles: `google`, `mppRomanized` and `mppTraditional`, plus `toRoman` and stream support.
- [Moment](/guides/moment/): `formatDuration`, `formatUnit`, `calendar`, a short style, and weeks.
- [Number formatting](/guides/number-format/): percent, currency, compact (`12.3L`), real number words, custom patterns and parsing.
- [Date formatting](/guides/date-format/): the `L`, `c`, `D`, `K`, `k`, `z`/`v` and `Z` letters, skeleton constants and `addPattern`.
- [`Language`](/getting-started/language/) converts to and from locales.

### Performance

- AD → BS conversion is about 16× faster, and `weekday` is about 500× faster.
- `NepaliUnicode` converts in a single pass. 10,000 characters take about 0.4 ms instead of 13.6 s.
