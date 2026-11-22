/// Utilities for Nepali dates, numbers, text, units and phone numbers.
///
/// Everything is available from a single import:
///
/// ```dart
/// import 'package:nepali_utils/nepali_utils.dart';
/// ```
///
/// ## Dates
///
/// [NepaliDateTime] is a date and time in the Bikram Sambat calendar. It
/// implements [DateTime], converts to and from Gregorian dates, and can be
/// presented in local time, UTC or Nepal Time (UTC+05:45).
///
/// ```dart
/// final date = NepaliDateTime(2080, 1, 15);
/// date.toDateTime(); // 2023-04-28 00:00:00.000
/// DateTime(2023, 4, 28).toNepaliDateTime(); // 2080-01-15 00:00:00.000
/// ```
///
/// ## Date formatting
///
/// [NepaliDateFormat] formats Bikram Sambat dates with the same pattern
/// syntax and skeletons as intl's `DateFormat`, in English or Nepali.
///
/// ```dart
/// NepaliDateFormat.yMMMMd().format(date); // Baishakh 15, 2080
/// NepaliDateFormat.yMMMMd(.nepali).format(date); // २०८० बैशाख १५
/// ```
///
/// ## Numbers
///
/// [NepaliNumberFormat] formats and parses numbers with lakh and crore
/// grouping, Devanagari digits, currency, compact forms and words.
///
/// ```dart
/// NepaliNumberFormat.decimalPattern().format(1234567.891); // 12,34,567.891
/// NepaliNumberFormat.compact().format(1234567); // 12.3L
/// ```
///
/// ## Relative time
///
/// [NepaliMoment] describes dates relative to now, such as `3 days ago` or
/// `Yesterday at 9:04 PM`.
///
/// ## Unicode, Preeti and Devanagari
///
/// [NepaliUnicode] converts romanized text such as `nepaal` to Devanagari,
/// [Preeti] converts text typed in the legacy Preeti font to Unicode and
/// back, and [Devanagari] has helpers for digits and syllables.
///
/// ```dart
/// const NepaliUnicode(style: .google).convert('nepaal'); // नेपाल
/// Preeti.toUnicode('g]kfn'); // नेपाल
/// ```
///
/// ## Measurement
///
/// [NepaliArea], [NepaliWeight] and [NepaliVolume] convert between Nepali
/// units such as ropani, bigha, tola and pathi and their metric equivalents.
///
/// ## Phone numbers
///
/// [NepaliPhoneNumber] validates, formats and finds Nepali mobile and
/// landline numbers.
///
/// ## Language
///
/// Formatters take an optional [Language]. When it is omitted they use
/// [NepaliUtils.currentLanguage], which you can set with
/// [NepaliUtils.defaultLanguage] or [NepaliUtils.withLanguage].
///
/// See the documentation site at https://nepali-utils.sarbagyastha.com.np
/// for guides, and the migration guide at
/// https://nepali-utils.sarbagyastha.com.np/migration/v4/ when upgrading from
/// version 3.
///
/// @docImport 'src/core/language/language.dart';
/// @docImport 'src/core/nepali_utils.dart';
/// @docImport 'src/date_time/date_time.dart';
/// @docImport 'src/measurement/measurement.dart';
/// @docImport 'src/moment/moment.dart';
/// @docImport 'src/number/number.dart';
/// @docImport 'src/phone/phone.dart';
/// @docImport 'src/unicode/unicode.dart';
library;

export 'src/core/language/language.dart';
export 'src/core/nepali_utils.dart';
export 'src/date_time/date_time.dart';
export 'src/measurement/measurement.dart';
export 'src/moment/moment.dart';
export 'src/number/number.dart';
export 'src/phone/phone.dart';
export 'src/unicode/unicode.dart';
