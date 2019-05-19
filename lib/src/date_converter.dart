import 'nepali_date_time.dart';

class DateConverter {
  List<List<int>> _nepaliMonths;
  List<int> _englishMonths, _englishLeapMonths;

  DateConverter._() {
    _englishMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    _englishLeapMonths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    _nepaliMonths = [
      [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31], //2000
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30], //2010
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
      [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30], //2020
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
      [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31], //2030
      [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30], //2040
      [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31], //2050
      [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30], //2060
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30], //2070
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
      [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
      [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30], //2080
      [31, 31, 32, 32, 31, 30, 30, 30, 29, 30, 30, 30],
      [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
      [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30],
      [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30],
      [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 30, 30],
      [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30],
      [30, 31, 32, 32, 30, 31, 30, 30, 29, 30, 30, 30],
      [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
      [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30], //2090
      [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30],
      [30, 31, 32, 32, 31, 30, 30, 30, 29, 30, 30, 30],
      [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
      [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30],
      [31, 31, 32, 31, 31, 31, 30, 29, 30, 30, 30, 30],
      [30, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
      [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
      [31, 31, 32, 31, 31, 31, 29, 30, 29, 30, 29, 31],
      [31, 31, 32, 31, 31, 31, 30, 29, 29, 30, 30, 30], //2099
    ];
  }

  static DateTime toAD(NepaliDateTime date) {
    var dc = DateConverter._();
    //Setting english reference to 1944/1/1 with nepali date 2000/9/17
    int englishYear = 1944;
    int englishMonth = 1;
    int englishDay = 1;

    int difference =
        dc._nepaliDateDifference(date, NepaliDateTime(2000, 9, 17), dc);

    //Getting english year until the difference remains less than 365
    while (difference >= (dc._isLeapYear(englishYear) ? 366 : 365)) {
      difference = difference - (dc._isLeapYear(englishYear) ? 366 : 365);
      englishYear++;
    }

    //Getting english month until the difference remains less than 31
    var monthDays =
        dc._isLeapYear(englishYear) ? dc._englishLeapMonths : dc._englishMonths;
    int i = 0;
    while (difference >= monthDays[i]) {
      englishMonth++;
      difference = difference - monthDays[i];
      i++;
    }

    //Remaning days is the date;
    englishDay += difference;

    return DateTime(englishYear, englishMonth, englishDay, date.hour,
        date.minute, date.second, date.millisecond, date.microsecond);
  }

  static NepaliDateTime toBS(DateTime date) {
    var dc = DateConverter._();
    //Setting nepali reference to 2000/1/1 with english date 1943/4/14
    int nepaliYear = 2000;
    int nepaliMonth = 1;
    int nepaliDay = 1;

    // Time was causing error while differencing dates. 
    
    DateTime _date = DateTime(date.year, date.month, date.day);

    int difference = _date.difference(DateTime(1943, 4, 14)).inDays;

    // 1970-1-1 is epoch and it's duration is only 18 hours 15 minutes in dart
    // You can test using `print(DateTime(1970,1,2).difference(DateTime(1970,1,1)))`;
    // So, in order to compensate it one extra day is added from this date.
    if (_date.isAfter(DateTime(1970, 1, 1))) difference++;

    //Getting nepali year until the difference remains less than 365
    int index = 0;
    while (difference >= dc._nepaliYearDays(index, dc)) {
      nepaliYear++;
      difference = difference - dc._nepaliYearDays(index, dc);
      index++;
    }

    //Getting nepali month until the difference remains less than 31
    int i = 0;
    while (difference >= dc._nepaliMonths[index][i]) {
      difference = difference - dc._nepaliMonths[index][i];
      nepaliMonth++;
      i++;
    }

    //Remaning days is the actual day;
    nepaliDay += difference;

    return NepaliDateTime(nepaliYear, nepaliMonth, nepaliDay, date.hour,
        date.minute, date.second, date.millisecond, date.microsecond);
  }

  int _nepaliYearDays(int index, dc) {
    int total = 0;
    for (int i = 0; i < 12; i++) {
      total += dc._nepaliMonths[index][i];
    }
    return total;
  }

  int _nepaliDateDifference(NepaliDateTime date, NepaliDateTime refDate, dc) {
    //Getting difference from the current date with the date provided
    int difference =
        _countTotalNepaliDays(date.year, date.month, date.day, dc) -
            _countTotalNepaliDays(refDate.year, refDate.month, refDate.day, dc);
    return (difference < 0 ? -difference : difference);
  }

  int _countTotalNepaliDays(int year, int month, int date, dc) {
    int total = 0;
    if (year < 2000) {
      return 0;
    }

    total = total + (date - 1);

    int yearIndex = year - 2000;
    for (int i = 0; i < month - 1; i++) {
      total = total + dc._nepaliMonths[yearIndex][i];
    }

    for (int i = 0; i < yearIndex; i++) {
      total = total + _nepaliYearDays(i, dc);
    }

    return total;
  }

  bool _isLeapYear(int year) =>
      (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
}
