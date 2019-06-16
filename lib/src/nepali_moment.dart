import 'nepali_date_time.dart';
import 'nepali_number.dart';

class NepaliMoment {
  static String fromBS(NepaliDateTime date, {NepaliDateTime referenceDate}) {
    return _calc(date, referenceDate ?? NepaliDateTime.now());
  }

  static String fromAD(DateTime date, {DateTime referenceDate}) =>
      _calc(date, referenceDate ?? DateTime.now());

  static String _calc(date, referenceDate) {
    Duration elapsedDuration = referenceDate.difference(date);
    int elapsed = elapsedDuration.inMilliseconds;
    bool isFuture = elapsed.isNegative;
    final num seconds = elapsed.abs() / 1000;
    final num minutes = seconds / 60;
    final num hours = minutes / 60;
    final num days = hours / 24;
    final num months = days / 30;
    final num years = days / 365;

    if (seconds < 45) {
      return 'केही क्षण ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (seconds < 90) {
      return 'एक मिनेट ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (minutes < 45) {
      return '${NepaliNumber.from(minutes.round())} मिनेट ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (minutes < 90) {
      return 'लगभग एक घण्टा ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (hours < 24) {
      return '${NepaliNumber.from(hours.round())} घण्टा ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (hours < 48) {
      return 'एक दिन ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (days < 30) {
      return '${NepaliNumber.from(days.round())} दिन ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (days < 60) {
      return 'लगभग एक महिना ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (days < 365) {
      return '${NepaliNumber.from(months.round())} दिन ${isFuture ? 'पछि' : 'पहिले'}';
    } else if (years < 2) {
      return 'लगभग एक वर्ष ${isFuture ? 'पछि' : 'पहिले'}';
    } else {
      return '${NepaliNumber.from(years.round())} वर्ष ${isFuture ? 'पछि' : 'पहिले'}';
    }
  }
}
