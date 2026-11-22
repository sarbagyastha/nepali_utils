import 'package:nepali_utils/nepali_utils.dart';

/// The first date the Bikram Sambat calendar data covers well.
final NepaliDateTime firstBsDate = NepaliDateTime(1970);

/// The last date the Bikram Sambat calendar data covers.
final NepaliDateTime lastBsDate = NepaliDateTime(
  2250,
  12,
  NepaliDateTime(2250, 12).totalDays,
);

const _adMonthsEnglish = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _adMonthsNepali = [
  'जनवरी',
  'फेब्रुअरी',
  'मार्च',
  'अप्रिल',
  'मे',
  'जुन',
  'जुलाई',
  'अगस्ट',
  'सेप्टेम्बर',
  'अक्टोबर',
  'नोभेम्बर',
  'डिसेम्बर',
];

const _weekdaysEnglish = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _weekdaysNepali = ['आइत', 'सोम', 'मंगल', 'बुध', 'बिहि', 'शुक्र', 'शनि'];

/// Short weekday names from Sunday to Saturday.
List<String> weekdayNames(Language language) =>
    language == Language.nepali ? _weekdaysNepali : _weekdaysEnglish;

/// The name of the Gregorian [month] (1-12).
String adMonthName(int month, Language language, {bool short = false}) {
  final name = (language == Language.nepali
      ? _adMonthsNepali
      : _adMonthsEnglish)[month - 1];
  return short && language == Language.english ? name.substring(0, 3) : name;
}

/// [text] with Devanagari digits in Nepali.
String localDigits(Object text, Language language) =>
    language == Language.nepali ? Devanagari.toNepaliDigits('$text') : '$text';

/// A Gregorian date such as `November 22, 2026` / `नोभेम्बर २२, २०२६`.
String formatAd(DateTime date, Language language, {bool weekday = false}) {
  final text = '${adMonthName(date.month, language)} ${date.day}, ${date.year}';
  final prefix = weekday
      ? '${NepaliDateFormat.EEEE(language).format(date.toNepaliDateTime())}, '
      : '';
  return localDigits('$prefix$text', language);
}

/// The Gregorian months a Bikram Sambat month spans, e.g. `Nov – Dec 2026`.
String adSpanOfMonth(int year, int month, Language language) {
  final first = NepaliDateTime(year, month).toDateTime();
  final last = NepaliDateTime(
    year,
    month,
    NepaliDateTime(year, month).totalDays,
  ).toDateTime();
  final start = adMonthName(first.month, language, short: true);
  final end = adMonthName(last.month, language, short: true);
  final text = first.year == last.year
      ? '$start – $end ${last.year}'
      : '$start ${first.year} – $end ${last.year}';
  return localDigits(text, language);
}

/// The difference between two dates in Bikram Sambat years, months and
/// days, the way ages are counted in Nepal.
(int, int, int) bsDifference(NepaliDateTime from, NepaliDateTime to) {
  var start = NepaliDateTime(from.year, from.month, from.day);
  var end = NepaliDateTime(to.year, to.month, to.day);
  if (end.isBefore(start)) (start, end) = (end, start);
  var years = end.year - start.year;
  var months = end.month - start.month;
  var days = end.day - start.day;
  if (days < 0) {
    months--;
    // Days in the month before [end].
    days += NepaliDateTime(end.year, end.month - 1).totalDays;
  }
  if (months < 0) {
    years--;
    months += 12;
  }
  return (years, months, days);
}
