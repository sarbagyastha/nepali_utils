# 4.0.0
**Breaking Changes**
* Requires Dart 3.13 or later. Rewritten with modern Dart: primary constructors, dot shorthands, records & patterns, extension types and class modifiers.
* `NepaliDateTime` is now instant based, exactly like `DateTime`:
  * It stores `microsecondsSinceEpoch` and presents fields in local time, UTC (`NepaliDateTime.utc`) or Nepal Time (`NepaliDateTime.nepal`, `toNepalTime()`).
  * `DateTime.toNepaliDateTime()` keeps the instant **and the time zone** (it no longer shifts to Nepal Time). Use `toNepaliDateTime().toNepalTime()` for Nepal Time.
  * `NepaliDateTime.now()` returns local time, like `DateTime.now()`. Use `NepaliDateTime.nepalNow()` for the current time in Nepal.
  * `toDateTime()` returns the same instant (UTC values give a UTC `DateTime`).
  * `toUtc()` now works, `toLocal()` converts to local time, and `timeZoneOffset`/`timeZoneName` report the real zone.
  * Components are normalised like `DateTime`, e.g. `NepaliDateTime(2080, 1, 35)` is `2080-02-04`, and dates outside 1969-2250 BS throw a `RangeError`.
  * `==` and `hashCode` compare the instant and the time zone (previously identity).
  * `difference`, `isBefore`, `isAfter`, `isAtSameMomentAs` and `compareTo` accept any `DateTime`.
  * `parse` follows `DateTime.parse`: values with `Z` or an offset are UTC, except `+05:45` which gives Nepal Time.
  * `NepaliDateTime` is now a `final class`, and its constructors are factories.
* `NepaliDateFormat` now follows `package:intl`'s `DateFormat` exactly:
  * Is now a `final class` and accepts any `DateTime` in `format`, keeping its time zone.
  * Named constructors use intl's skeletons: the `en` layouts for English and the `ne` layouts for Nepali. A skeleton name passed to the default constructor (`NepaliDateFormat('yMd')`) is resolved the same way.

    | Constructor | 3.x | 4.0 English | 4.0 Nepali |
    |---|---|---|---|
    | `yM` | `2076/08` | `8/2076` | `२०७६-०८` |
    | `yMd` | `2076/08/05` | `8/5/2076` | `२०७६-०८-०५` |
    | `yMEd` | `Thu, 2076/08/05` | `Thu, 8/5/2076` | `२०७६-०८-०५, बिहि` |
    | `yMMMd` (Nepali) | `मं ५, २०७६` | | `२०७६ मं ५` |
    | `j`, `jm`, `jms` (Nepali) | `बेलुकी ९:०४` | | `२१:०४` (24-hour) |
    | `H` | `9` | `09` | `०९` |

    Like intl, English time skeletons (`j`, `jm`, `jms`, ...) put a narrow no-break space (` `) before AM/PM.
  * Pattern letters follow intl:

    | Pattern | 3.x | 4.0 |
    |---|---|---|
    | `E` / `EE` / `EEE` | `T` / `Thu` / `Thursday` | `Thu` (all three) |
    | `EEEE` / `EEEEE` | `Thursday` | `Thursday` / `T` |
    | `G` / `GG` / `GGG` | `BS` / `B.S.` / `Bikram Sambat` | `BS` (all three); `GGGG` is `Bikram Sambat` |
    | `a` / `aa` (English) | `pm` / `PM` | `PM` |
    | `MMMMM` | `Marga` (colloquial) | `M` (narrow); the colloquial name is now `MMMMMM` |
    | `S` / `SS` | `1` / `12` | `123` (at least 3 digits) |
    | `QQQ` / `QQQQ` (Nepali) | `Q3` / `3rd quarter` | `तेस्रो त्रैमासिक`; `Q` digits are Devanagari |
  * Fixed `h` for midnight (`12` instead of `0`) and `hh` zero padding between 1 PM and 9 PM.
  * Fixed the patterns of `NepaliDateFormat.Hm` (`HH:mm`), `.m` (`m`) and `.ms` (`mm:ss`).
  * The skeletons honour the default language set through `NepaliUtils`.
* Removed the unreleased `toNepaliDateTimeFromInstant()`; use `toNepaliDateTime().toNepalTime()`.
* The default language API now works like intl's `Intl.defaultLocale` and `Intl.withLocale`. `NepaliUtils` only has static members and can't be instantiated:
  * `NepaliUtils(language)` → `NepaliUtils.defaultLanguage = language`.
  * `NepaliUtils().language` → `NepaliUtils.currentLanguage`.
  * Formatters read the language when they are created, so `withLanguage` applies to formatters created inside it.

* `NepaliNumberFormat` now follows `package:intl`'s `NumberFormat` and is an immutable `final class`:

  | 3.x | 4.0 |
  |---|---|
  | `NepaliNumberFormat()` | `NepaliNumberFormat.decimalPattern()` (up to 3 fraction digits), or `NepaliNumberFormat([pattern])` |
  | `NepaliNumberFormat(decimalDigits: 2)` | `NepaliNumberFormat.decimalPatternDigits(decimalDigits: 2)` |
  | `isMonetory: true, symbol: 'Rs.'` | `NepaliNumberFormat.simpleCurrency()` (`Rs. 1,234.00`) or `.currency(symbol: 'Rs.')` |
  | `symbolOnLeft`, `spaceBetweenAmountAndSymbol` | `currency(customPattern: '#,##,##0.00 ¤')` |
  | `inWords: true` | `NepaliNumberFormat.words()`, which now gives real words; `words(useDigits: true)` for the old `1 lakh 23 thousand` style |
  | `inWords: true, isMonetory: true` | `NepaliNumberFormat.words(currency: true)` |
  | `delimiter: ''` | `copyWith(groupSeparator: '')` |
  | `includeDecimalIfZero: false` | `copyWith(includeDecimalIfZero: false)` |
  | `format<T>(T? number)`; `null` gave `''` | `format(Object number)`; `null` is a compile error |

  * The currency patterns are those of intl's `ne` locale, with a no-break space after the symbol.
  * Numbers are rounded half away from zero instead of truncated: `2.999` with 2 digits is `3.00`, not `2.99`.
  * In Nepali, rupees is spelled `रुपैयाँ`.

* `NepaliMoment` is now an immutable formatter (`NepaliMoment(language:, style:, useWeeks:)`) in the style of moment.js. `fromBS` and `fromAD` remain as shorthands:
  * Fixed English phrases: `a few seconds ago`, `5 minutes ago`, `2 months ago` and `in 3 days` (was `few moment ago`, `5 minute ago`, `2 month ago` and `3 days from now`).
  * The thresholds are moment.js's: e.g. 22 hours is `a day`, 26 days is `a month`, and 320 days is `a year`. Previously 350 days could give `12 months`.
  * About an hour, a month or a year is now `an hour` / `एक घण्टा` (was `about an hour` / `लगभग एक घण्टा`).
  * Removed the `showToday` parameter, which had no effect; use `calendar` or `formatUnit(0, .day, numeric: false)`.
* `NepaliUnicode` is now an immutable `Converter<String, String>`:

  | 3.x | 4.0 |
  |---|---|
  | `NepaliUnicode.convert(text)` | `const NepaliUnicode().convert(text)` |
  | `NepaliUnicode.convert(text, live: true)` | `const NepaliUnicode().convertLive(text)`, or just `convert`: Devanagari followed by romanized text is joined either way |

  * The default `classic` style keeps the 3.x rules, with these fixes: zero width spaces no longer leak into the output (`sayau` gave `स​यौ`), `am` no longer gives य (`kamal` was `कयल्`), `chh` gives छ (`chhoraa` was `छ्ोरा`), `gy` gives ज्ञ (`gyaan` was `ज्ञ्ान्`), `ngh` gives ंह (`singha` was `सिहं`), any whitespace (not only a space) drops a halant, and `kchy` no longer gives क्ष.
  * Text inside `{}` is now kept as it is, so a literal `{` must be escaped as `{{}`.

**New**
* Conversions between Nepali units with `NepaliArea` (ropani-aana-paisa-daam, bigha-kattha-dhur, square feet/metres, acres, hectares), `NepaliWeight` (tola-lal, dharni-ser-pau-chhatak, grams) and `NepaliVolume` (muri-pathi-mana-muthi, litres). Each converts with `to(unit)`, splits into mixed units (`ropaniParts`), formats (`2-3-1-0` / `२ रोपनी ३ आना १ पैसा`), parses ASCII or Devanagari input and supports arithmetic and comparison.
* `NepaliPhoneNumber` validates and parses Nepali mobile and landline numbers (ASCII or Devanagari digits, with or without `+977`), reports the mobile operator (per NTA's National Numbering Allocation Plan, 2079) or the landline area code and district, formats them as national, international or E.164, and finds them in text with `findAll` and `replaceAll`.
* `NepaliUnicode` gains:
  * Styles: `NepaliUnicode(style: .google)` for Google Input Tools style romanization (`nepaal` → `नेपाल`, `~` for a halant), and Madan Puraskar Pustakalaya's keyboard layouts `.mppRomanized` and `.mppTraditional`.
  * `toRoman`, the reverse conversion (`नेपाली` → `nepaalii`), which round-trips through `convert`.
  * `{English}` escapes (`mero naam {Sarbagya} ho` → `मेरो नाम Sarbagya हो`) and `nepaliDigits: false`.
  * Stream support: `stream.transform(const NepaliUnicode())`.
* `Preeti.toUnicode` and `Preeti.fromUnicode` convert legacy Preeti-font text (`g]kfn` ↔ `नेपाल`), reordering ि and the reph.
* `Devanagari` helpers: `isDevanagari`, `containsDevanagari`, `toNepaliDigits`, `toEnglishDigits` and `aksharas` (`संस्कृति` → `[सं, स्कृ, ति]`).
* `NepaliMoment` gains:
  * `formatDuration` (`3 days`, or `in 3 days` with `withSuffix`).
  * `formatUnit`, like `Intl.RelativeTimeFormat`: `formatUnit(-1, .day)` is `1 day ago`, and with `numeric: false` it is `yesterday` / `हिजो`.
  * `calendar`: `Today at 9:04 PM`, `Yesterday at …`, `Last Sunday at …`, or the date / `आज २१:०४`, `गएको आइतबार, २१:०४`.
  * Short style (`3 hr. ago` / `३ घ. पहिले`) and optional weeks (`3 weeks ago`).
* `NepaliNumberFormat` gains what intl's `NumberFormat` has:
  * `percentPattern`, `decimalPercentPattern`, `currency`, `simpleCurrency`, `compact` (`12.3L`), `compactLong` (`12.3 lakh`), `compactCurrency` and `compactSimpleCurrency`. Compact formats use thousand, lakh, crore, arab and kharab.
  * Custom patterns: `NepaliNumberFormat('#,##0.00')` for international grouping, `%`, `‰`, `¤`, quoted text and negative subpatterns (`#,##0;(#,##0)`).
  * `parse` and `tryParse`, which accept ASCII and Devanagari digits.
  * `minimumIntegerDigits`, `minimumFractionDigits`, `maximumFractionDigits` and significant digits, set with `copyWith`.
* `NepaliNumberFormat` formats negative numbers, doubles such as `1e21` and `1.5e-7`, `BigInt`s and numeric strings without losing digits. Doubles are rounded as written, so `1.005` rounds to `1.01`.
* `NepaliNumberFormat.words` spells numbers out (`one lakh twenty-three thousand four hundred fifty-six` / `एक लाख तेइस हजार चार सय छपन्न`). It also handles negative numbers, fractions and values beyond a sankha, and no longer shows zero groups (`1 lakh 00 thousand 0 hundred 00`).
* `NepaliDateTime.utc`, `.nepal`, `.nepalNow`, `.fromMicrosecondsSinceEpoch`, `.fromMillisecondsSinceEpoch`, `copyWith`, `toNepalTime`, `isNepalTime` and weekday/month constants (`NepaliDateTime.sunday`, `NepaliDateTime.baishakh`, ...).
* `NepaliDateTime.fromDateTime` is no longer deprecated.
* `NepaliDateFormat` gains what intl's `DateFormat` has:
  * The pattern letters `L` (standalone month), `c` (standalone weekday), `D` (day of year), `K` (hour 0-11), `k` (hour 1-24), `z`/`v` (time zone: `NPT`, `UTC`, or the local name; `zzzz` is `Nepal Time`) and `Z` (`+0545`, `GMT+05:45`). intl leaves the time-zone letters empty.
  * The `EEEEE`, `jmv`, `jmz`, `jv` and `jz` constructors.
  * The skeleton constants (`NepaliDateFormat.YEAR_MONTH_DAY`, ...).
  * `addPattern` and `add_*()` (e.g. `NepaliDateFormat.yMd().add_jms()`). These return a new formatter, because `NepaliDateFormat` is immutable.
  * `NepaliDateFormat()` without a pattern uses `yMMMMd jms`.
* `Language` converts to and from locales: `languageCode`, `countryCode`, `localeName`, `toLanguageTag()`, `Language.parse`, `Language.tryParse` and `Language.fromLocale`.
* `NepaliUtils.withLanguage(language, () => ...)` overrides the language for the code run inside the callback, including async work. `NepaliUtils.currentLanguage` returns the language in effect.
* `NepaliMoment.fromBS` and `fromAD` accept a `language`.

**Performance**
* Conversion is constant time using a precomputed month index and pure integer Gregorian arithmetic (AD → BS ~16x faster, `weekday` ~500x faster than 3.x).
* Formatting compiles the pattern once and converts digits directly.
* `NepaliUnicode` converts in a single pass instead of ~170 `replaceAll` passes per character: linear instead of quadratic, e.g. 10,000 characters take 0.4 ms instead of 13.6 s.

# 3.0.8
* Fixed dates for year 2082 & 2093.

# 3.0.7
* Added `MMMMM` support for NepaliDateFormat; alt version of months.

# 3.0.6
* Added support for `NepaliDateTime` up to 2250 BS.

# 3.0.5
* Same as [3.0.6]

# 3.0.4
* Fixes date time conversion for timezone other than Nepal.

# 3.0.3
* Adds english support for moment conversion.

# 3.0.2
* Adds `delimiter` property to **NumberFormat**. [PR #6](https://github.com/sarbagyastha/nepali_utils/pull/6) Thanks to [@Ravikant](https://github.com/ravikant-paudel)

# 3.0.1
* Fixed incorrect date conversion for the year 1970.

# 3.0.0
**Breaking Changes**
* Migrated to Null Safety
* Added support for `NepalitDateTime` from 1970 BS to 2100 BS.

# 2.2.1
* Renamed `weekDay` to `weekday`.

# 2.2.0+2
* Improved Date Conversion Speed

# 2.2.0+1
* Added `weekDay` property to NepaliDateTime.

# 2.2.0
* Default language for all the utility classes can be set as `NepaliUtils(language);`.
**Breaking Changes**
* `language` property is now optional for utility classes.

# 2.1.0+5
* `fromDateTime()` is deprecated. Use `toNepaliDateTime()` exposed to `DateTime` instead.
* Added `add()`, `substract()`, `format()`, `millisecondSinceEpoch`, `microsecondSinceEpoch` to `NepaliDateTime`.

# 2.1.0+4
* Fixes in *NepaliNumberFormat*.
* Fixed lint warning.

# 2.1.0+1
* Added `totalDays` getter for *NepaliDateTime* class.

# 2.1.0
* **[Improvement]** Code refactor.
* Added dart docs.
* Methods in *NepaliNumberFormat* are now generic and supports types `String` and `num`.

# 2.0.0+4
* **FIXED** Issue with comma formatting in `NepaliNumberFormat`.

# 2.0.0+2
* **ADDED** `mergeTime` method to NepaliDateTime.

## 2.0.0+1
**BREAKING CHANGES** 
* DateConvertor is now integrated to NepaliDateTime class.
* NepaliNumber is renamed into NepaliNumberFormat.
* NepaliDateFormatter is renamed into NepaliDateFormat.
* **FEATURE** The package now supports from 2000 B.S. upto 2099 B.S. 
* Preconfigured constructors are added for quick formatting in NepaliDateFormat class.
  
See ReadMe section to know about using newer APIs.

## 1.1.0+2
* **ADDED** `NepaliMoment` class.

## 1.1.0
* **ADDED** `NepaliUnicode` class.
* Updated Dart Constraint to `>=2.2.2 <3.0.0`.

## 1.0.1
* **Fixed** Wrong current datetime retrieval.

## 1.0.0+3
* `formatWithComma` boolean argument added to `from` & `fromString` methods of **NepaliNumber**.

## 1.0.0+1
* Added Example

## 1.0.0
**Initial Version with**
* NepaliDateTime
* DateConverter
* NepaliDateFormatter
* NepaliNumber
