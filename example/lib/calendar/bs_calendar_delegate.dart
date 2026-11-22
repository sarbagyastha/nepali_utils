import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';

/// Lets Material's date pickers show the Bikram Sambat calendar.
///
/// [NepaliDateTime] implements [DateTime], so this plugs straight into
/// `showDatePicker(calendarDelegate: ...)`.
class const BsCalendarDelegate({required final Language language})
    extends CalendarDelegate<NepaliDateTime> {
  @override
  NepaliDateTime now() => NepaliDateTime.now();

  @override
  NepaliDateTime dateOnly(NepaliDateTime date) =>
      NepaliDateTime(date.year, date.month, date.day);

  @override
  int monthDelta(NepaliDateTime startDate, NepaliDateTime endDate) =>
      (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;

  @override
  NepaliDateTime addMonthsToMonthDate(
    NepaliDateTime monthDate,
    int monthsToAdd,
  ) => NepaliDateTime(monthDate.year, monthDate.month + monthsToAdd);

  @override
  NepaliDateTime addDaysToDate(NepaliDateTime date, int days) =>
      NepaliDateTime(date.year, date.month, date.day + days);

  @override
  int firstDayOffset(int year, int month, MaterialLocalizations localizations) {
    // NepaliDateTime.weekday is 1 (Sunday) to 7 (Saturday); the grid counts
    // from Sunday = 0, shifted by the locale's first day of the week.
    final fromSunday = NepaliDateTime(year, month).weekday - 1;
    return (fromSunday - localizations.firstDayOfWeekIndex) % 7;
  }

  @override
  int getDaysInMonth(int year, int month) =>
      NepaliDateTime(year, month).totalDays;

  @override
  NepaliDateTime getMonth(int year, int month) => NepaliDateTime(year, month);

  @override
  NepaliDateTime getDay(int year, int month, int day) =>
      NepaliDateTime(year, month, day);

  @override
  String formatMonthYear(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) => NepaliDateFormat.yMMMM(language).format(date);

  @override
  String formatYear(int year, MaterialLocalizations localizations) =>
      NepaliDateFormat.y(language).format(NepaliDateTime(year));

  @override
  String formatMediumDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) => NepaliDateFormat.MMMEd(language).format(date);

  @override
  String formatShortMonthDay(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) => NepaliDateFormat.MMMd(language).format(date);

  @override
  String formatShortDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) => NepaliDateFormat.yMMMd(language).format(date);

  @override
  String formatFullDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) => NepaliDateFormat.yMMMMEEEEd(language).format(date);

  @override
  String formatCompactDate(
    NepaliDateTime date,
    MaterialLocalizations localizations,
  ) => NepaliDateFormat('yyyy-MM-dd').format(date);

  @override
  NepaliDateTime? parseCompactDate(
    String? inputString,
    MaterialLocalizations localizations,
  ) {
    if (inputString == null) return null;
    final text = Devanagari.toEnglishDigits(inputString.trim());
    final match = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$')
        .firstMatch(text);
    if (match == null) return null;
    final year = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final day = int.parse(match[3]!);
    if (month < 1 || month > 12 || day < 1) return null;
    try {
      if (day > getDaysInMonth(year, month)) return null;
      return NepaliDateTime(year, month, day);
    } on Object {
      // Outside the supported range of the calendar.
      return null;
    }
  }

  @override
  String dateHelpText(MaterialLocalizations localizations) => 'yyyy-mm-dd';

  @override
  List<TextInputFormatter>? keyboardInputFormatters(
    MaterialLocalizations localizations,
  ) => [FilteringTextInputFormatter.allow(RegExp(r'[0-9०-९\-/.]'))];
}
