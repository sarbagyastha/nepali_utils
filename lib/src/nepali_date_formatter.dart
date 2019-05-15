import 'nepali_date_time.dart';
import 'nepali_number.dart';

enum Language { ENGLISH, NEPALI }

class NepaliDateFormatter {
  final String pattern;
  final Language language;
  String _pattern;
  String _checkPattern;
  bool _firstRun = true;
  int _index = 0;

  NepaliDateFormatter(
    this.pattern, {
    this.language = Language.ENGLISH,
  });

  String format(NepaliDateTime dateTime) {
    //print(_checkPattern);
    if (_firstRun) {
      _checkPattern = _pattern = pattern;
      _firstRun = false;
    }
    for (int i = 0; i < _matchers.length; i++) {
      var regex = _matchers[i];
      Match match = regex.firstMatch(_checkPattern);
      if (_checkPattern.isEmpty) {
        return _pattern;
      }
      if (match != null) {
        _checkPattern = _checkPattern.substring(match.group(0).length);
        switch (i) {
          case 0:
            _trim(match.group(0));
            format(dateTime);
            break;
          case 1:
            _format(match.group(0), dateTime);
            format(dateTime);
            break;
          case 2:
            _index += match.group(0).length;
            format(dateTime);
            break;
        }
      }
    }
    return '';
  }

  void _trim(String match) {
    if (match == "\'\'") {
      _pattern = _pattern.replaceFirst("\'\'", "\'");
      --_index;
    } else {
      _pattern =
          _pattern.replaceFirst(match, match.substring(1, match.length - 1));
      _index -= 2;
      if (match.contains("\'\'")) {
        _pattern = _pattern.replaceFirst("\'\'", "\'");
        --_index;
      }
    }
    _index += match.length;
  }

  void _format(String match, NepaliDateTime dateTime) {
    switch (match) {
      case 'G':
        _replacer(match, language == Language.ENGLISH ? 'BS' : 'बि सं');
        break;
      case 'GG':
        _replacer(match, language == Language.ENGLISH ? 'B.S.' : 'बि.सं.');
        break;
      case 'GGG':
        _replacer(match,
            language == Language.ENGLISH ? 'Bikram Sambat' : 'बिक्रम संबत');
        break;
      case 'y':
        _replacer(
            match,
            language == Language.ENGLISH
                ? '${dateTime.year}'
                : '${NepaliNumber.from(dateTime.year)}');
        break;
      case 'yy':
        _replacer(
            match,
            language == Language.ENGLISH
                ? '${dateTime.year.toString().substring(2)}'
                : '${NepaliNumber.fromString(dateTime.year.toString().substring(2))}');
        break;
      case 'yyyy':
        _replacer(
            match,
            language == Language.ENGLISH
                ? '${dateTime.year}'
                : '${NepaliNumber.from(dateTime.year)}');
        break;
      case 'Q':
        _replacer(match, '${_getQuarter(dateTime.month)}');
        break;
      case 'QQ':
        _replacer(match, '0${_getQuarter(dateTime.month)}');
        break;
      case 'QQQ':
        _replacer(match, 'Q${_getQuarter(dateTime.month)}');
        break;
      case 'QQQQ':
        _replacer(
            match, '${_getPosition(_getQuarter(dateTime.month))} quarter');
        break;
      case 'M':
        _replacer(
            match,
            language == Language.ENGLISH
                ? '${dateTime.month}'
                : '${NepaliNumber.from(dateTime.month)}');
        break;
      case 'MM':
        _replacer(match, _prependZero(dateTime.month));
        break;
      case 'MMM':
        _replacer(match, _monthString(dateTime.month, short: true));
        break;
      case 'MMMM':
        _replacer(match, _monthString(dateTime.month));
        break;
      case 'd':
        _replacer(
            match,
            language == Language.ENGLISH
                ? '${dateTime.day}'
                : '${NepaliNumber.from(dateTime.day)}');
        break;
      case 'dd':
        _replacer(match, _prependZero(dateTime.day));
        break;
      case 'E':
        _replacer(match, _weekDayString(dateTime.weekDay, short: true));
        break;
      case 'EE':
        _replacer(
            match,
            language == Language.ENGLISH
                ? _weekDayString(dateTime.weekDay).substring(0, 3)
                : _weekDayString(dateTime.weekDay).replaceFirst('बार', ''));
        break;
      case 'EEE':
        _replacer(match, _weekDayString(dateTime.weekDay));
        break;
      case 'a':
        _replacer(
          match,
          language == Language.ENGLISH
              ? dateTime.hour >= 12 ? 'pm' : 'am'
              : dateTime.hour < 12
                  ? 'बिहान'
                  : dateTime.hour == 12
                      ? 'मध्यान्न'
                      : dateTime.hour < 16
                          ? 'दिउसो'
                          : dateTime.hour < 20 ? 'साँझ' : 'बेलुकी',
        );
        break;
      case 'aa':
        _replacer(
          match,
          language == Language.ENGLISH
              ? dateTime.hour >= 12 ? 'PM' : 'AM'
              : dateTime.hour < 12
                  ? 'बिहान'
                  : dateTime.hour == 12
                      ? 'मध्यान्न'
                      : dateTime.hour < 16
                          ? 'दिउसो'
                          : dateTime.hour < 20 ? 'साँझ' : 'बेलुकी',
        );
        break;
      case 'h':
        _replacer(match, _clockHour(dateTime.hour));
        break;
      case 'hh':
        _replacer(match, _clockHour(dateTime.hour, prependZero: true));
        break;
      case 'H':
        _replacer(
            match,
            language == Language.ENGLISH
                ? '${dateTime.hour}'
                : NepaliNumber.from(dateTime.hour));
        break;
      case 'HH':
        _replacer(match, _prependZero(dateTime.hour));
        break;
      case 'm':
        _replacer(
            match,
            language == Language.ENGLISH
                ? '${dateTime.minute}'
                : NepaliNumber.from(dateTime.minute));
        break;
      case 'mm':
        _replacer(match, _prependZero(dateTime.minute));
        break;
      case 's':
        _replacer(
            match,
            language == Language.ENGLISH
                ? '${dateTime.second}'
                : NepaliNumber.from(dateTime.second));
        break;
      case 'ss':
        _replacer(match, _prependZero(dateTime.second));
        break;
      case 'S':
        _replacer(
            match, _threeDigitMaker(dateTime.millisecond).substring(0, 1));
        break;
      case 'SS':
        _replacer(
            match, _threeDigitMaker(dateTime.millisecond).substring(0, 2));
        break;
      case 'SSS':
        _replacer(
            match, _threeDigitMaker(dateTime.millisecond).substring(0, 3));
        break;
      case 'SSSS':
        _replacer(
            match,
            '${_threeDigitMaker(dateTime.millisecond)}${_threeDigitMaker(dateTime.microsecond)}'
                .substring(0, 4));
        break;
      case 'SSSSS':
        _replacer(
            match,
            '${_threeDigitMaker(dateTime.millisecond)}${_threeDigitMaker(dateTime.microsecond)}'
                .substring(0, 5));
        break;
      case 'SSSSSS':
        _replacer(
            match,
            '${_threeDigitMaker(dateTime.millisecond)}${_threeDigitMaker(dateTime.microsecond)}'
                .substring(0, 6));
        break;
    }
  }

  String _threeDigitMaker(int number) {
    String numString = number.toString();
    if (numString.length == 1) {
      return language == Language.ENGLISH
          ? '00$numString'
          : '००${NepaliNumber.from(number)}';
    }
    if (numString.length == 2) {
      return language == Language.ENGLISH
          ? '0$numString'
          : '०${NepaliNumber.from(number)}';
    }
    return language == Language.ENGLISH
        ? numString.substring(0, 3)
        : NepaliNumber.fromString(numString.substring(0, 3));
  }

  String _clockHour(int hour, {bool prependZero = false}) {
    if (hour > 12) {
      return language == Language.ENGLISH
          ? '${hour - 12}'
          : '${NepaliNumber.from(hour - 12)}';
    } else if (hour == 12) {
      return language == Language.ENGLISH ? '12' : '१२';
    } else {
      return language == Language.ENGLISH
          ? prependZero ? _prependZero(hour) : '${hour}'
          : prependZero ? _prependZero(hour) : '${NepaliNumber.from(hour)}';
    }
  }

  String _prependZero(int number) => number < 10
      ? language == Language.ENGLISH
          ? '0$number'
          : '०${NepaliNumber.from(number)}'
      : language == Language.ENGLISH ? '$number' : NepaliNumber.from(number);

  void _replacer(String match, String replaceWith) {
    _pattern = _pattern.replaceFirst(match, replaceWith, _index);
    _index += replaceWith.length;
  }

  String _weekDayString(int day, {bool short = false}) {
    switch (day) {
      case 1:
        return language == Language.ENGLISH
            ? short ? 'S' : 'Sunday'
            : short ? 'आ' : 'आइतबार';
      case 2:
        return language == Language.ENGLISH
            ? short ? 'M' : 'Monday'
            : short ? 'सो' : 'सोमबार';
      case 3:
        return language == Language.ENGLISH
            ? short ? 'T' : 'Tuesday'
            : short ? 'मं' : 'मंगलबार';
      case 4:
        return language == Language.ENGLISH
            ? short ? 'W' : 'Wednesday'
            : short ? 'बु' : 'बुधबार';
      case 5:
        return language == Language.ENGLISH
            ? short ? 'T' : 'Thursday'
            : short ? 'बि' : 'बिहिबार';
      case 6:
        return language == Language.ENGLISH
            ? short ? 'F' : 'Friday'
            : short ? 'शु' : 'शुक्रबार';
      case 7:
        return language == Language.ENGLISH
            ? short ? 'S' : 'Saturday'
            : short ? 'श' : 'शनिबार';
      default:
        return '';
    }
  }

  String _monthString(int month, {short = false}) {
    switch (month) {
      case 1:
        return language == Language.ENGLISH
            ? short ? 'Bai' : 'Baishakh'
            : short ? 'बै' : 'बैशाख';
      case 2:
        return language == Language.ENGLISH
            ? short ? 'Jes' : 'Jestha'
            : short ? 'जे' : 'जेष्ठ';
      case 3:
        return language == Language.ENGLISH
            ? short ? 'Asa' : 'Ashadh'
            : short ? 'अ' : 'अषाढ';
      case 4:
        return language == Language.ENGLISH
            ? short ? 'Shr' : 'Shrawan'
            : short ? 'श्रा' : 'श्रावण';
      case 5:
        return language == Language.ENGLISH
            ? short ? 'Bha' : 'Bhadra'
            : short ? 'भा' : 'भाद्र';
      case 6:
        return language == Language.ENGLISH
            ? short ? 'Ash' : 'Ashwin'
            : short ? 'आ' : 'आश्विन';
      case 7:
        return language == Language.ENGLISH
            ? short ? 'Kar' : 'Kartik'
            : short ? 'का' : 'कार्तिक';
      case 8:
        return language == Language.ENGLISH
            ? short ? 'Marg' : 'Mangsir'
            : short ? 'मं' : 'मंसिर';
      case 9:
        return language == Language.ENGLISH
            ? short ? 'Pou' : 'Poush'
            : short ? 'पौ' : 'पौष';
      case 10:
        return language == Language.ENGLISH
            ? short ? 'Mag' : 'Magh'
            : short ? 'मा' : 'माघ';
      case 11:
        return language == Language.ENGLISH
            ? short ? 'Fal' : 'Falgun'
            : short ? 'फा' : 'फाल्गुन';
      case 12:
        return language == Language.ENGLISH
            ? short ? 'Cha' : 'Chaitra'
            : short ? 'चै' : 'चैत्र';
      default:
        return '';
    }
  }

  int _getQuarter(int month) => (month / 3).ceil();

  String _getPosition(int position) => position == 1
      ? '1st'
      : position == 2 ? '2nd' : position == 3 ? '3rd' : '${position}th';

  /// A series of regular expressions used to parse a format string into its
  /// component fields.
  List<RegExp> _matchers = [
    // Quoted String - anything between single quotes, with escaping
    //   of single quotes by doubling them.
    // e.g. in the pattern "hh 'o''clock'" will match 'o''clock'
    RegExp("^\'(?:[^\']|\'\')*\'"),
    // Fields - any sequence of 1 or more of the same field characters.
    // e.g. in "hh:mm:ss" will match hh, mm, and ss. But in "hms" would
    // match each letter individually.
    RegExp("^(?:G+|y+|M+|k+|S+|E+|a+|h+|K+|H+|c+|L+|Q+|d+|D+|m+|s+|v+|z+|Z+)"),
    // Everything else - A sequence that is not quotes or field characters.
    // e.g. in "hh:mm:ss" will match the colons.
    RegExp("^[^\'GyMkSEahKHcLQdDmsvzZ]+")
  ];
}
