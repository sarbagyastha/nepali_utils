import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils_example/calendar/bs_calendar_delegate.dart';
import 'package:nepali_utils_example/state/settings.dart';
import 'package:nepali_utils_example/util/dates.dart';

/// Opens Material's date picker in Bikram Sambat ([bs]) or Gregorian, and
/// returns the picked day as a Gregorian date.
Future<DateTime?> pickDate(
  BuildContext context, {
  required DateTime initial,
  required bool bs,
}) async {
  final language = context.language;
  final first = firstBsDate.toDateTime();
  final last = lastBsDate.toDateTime();
  final clamped = initial.isBefore(first)
      ? first
      : initial.isAfter(last)
      ? last
      : initial;

  if (!bs) {
    final ad = await showDatePicker(
      context: context,
      initialDate: clamped,
      firstDate: first,
      lastDate: last,
      helpText: context.tr('Pick a date (AD)', 'मिति छान्नुहोस् (ई.सं.)'),
      // Hovering a day shows its Bikram Sambat date.
      dayBuilder: (context, details) => Tooltip(
        message: NepaliDateFormat.yMMMMd(language)
            .format(details.day.toNepaliDateTime()),
        child: details.child,
      ),
    );
    return ad;
  }

  final picked = await showDatePicker(
    context: context,
    initialDate: clamped.toNepaliDateTime(),
    firstDate: firstBsDate,
    lastDate: lastBsDate,
    currentDate: NepaliDateTime.now(),
    helpText: context.tr('Pick a date (BS)', 'मिति छान्नुहोस् (वि.सं.)'),
    fieldHintText: 'yyyy-mm-dd',
    calendarDelegate: BsCalendarDelegate(language: language),
    // Hovering a day shows its Gregorian date.
    dayBuilder: (context, details) => Tooltip(
      message: formatAd((details.day as NepaliDateTime).toDateTime(), language),
      child: details.child,
    ),
  );
  if (picked == null) return null;
  final ad = (picked as NepaliDateTime).toDateTime();
  return DateTime(ad.year, ad.month, ad.day);
}
