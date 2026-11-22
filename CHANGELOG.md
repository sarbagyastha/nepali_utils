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
* `NepaliDateFormat`:
  * Is now a `final class` and accepts any `DateTime` in `format`.
  * Fixed `h` for midnight (`12` instead of `0`) and `hh` zero padding between 1 PM and 9 PM.
  * Fixed the patterns of `NepaliDateFormat.Hm` (`HH:mm`), `.m` (`m`) and `.ms` (`mm:ss`).
  * `j`, `jm` and `jms` honour the default language set through `NepaliUtils`.
* Removed the unreleased `toNepaliDateTimeFromInstant()`; use `toNepaliDateTime().toNepalTime()`.
* `NepaliUtils` is now a `final class`.

**New**
* `NepaliDateTime.utc`, `.nepal`, `.nepalNow`, `.fromMicrosecondsSinceEpoch`, `.fromMillisecondsSinceEpoch`, `copyWith`, `toNepalTime`, `isNepalTime` and weekday/month constants (`NepaliDateTime.sunday`, `NepaliDateTime.baishakh`, ...).
* `NepaliDateTime.fromDateTime` is no longer deprecated.
* `Language` converts to and from locales: `languageCode`, `countryCode`, `localeName`, `toLanguageTag()`, `Language.parse`, `Language.tryParse`, `Language.fromLocale` and `NepaliUtils.fromLocale`.

**Performance**
* Conversion is constant time using a precomputed month index and pure integer Gregorian arithmetic (AD → BS ~16x faster, `weekday` ~500x faster than 3.x).
* Formatting compiles the pattern once and converts digits directly.

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
