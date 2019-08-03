import 'nepali_date_time.dart';
import 'nepali_language.dart';
import 'nepali_unicode.dart';

class NepaliDateFormat {
  Language _language;
  String _pattern;
  String _checkPattern;
  bool _firstRun = true;
  int _index = 0;

  NepaliDateFormat(
    String pattern, {
    Language language,
  }) {
    _pattern = pattern;
    _language = language ?? Language.ENGLISH;
  }

  String format(NepaliDateTime dateTime) {
    if (_firstRun) {
      _checkPattern = _pattern;
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
        _replacer(match, _language == Language.ENGLISH ? 'BS' : 'बि सं');
        break;
      case 'GG':
        _replacer(match, _language == Language.ENGLISH ? 'B.S.' : 'बि.सं.');
        break;
      case 'GGG':
        _replacer(match,
            _language == Language.ENGLISH ? 'Bikram Sambat' : 'बिक्रम संबत');
        break;
      case 'y':
        _replacer(
            match,
            _language == Language.ENGLISH
                ? '${dateTime.year}'
                : '${NepaliUnicode.convert('${dateTime.year}')}');
        break;
      case 'yy':
        _replacer(
            match,
            _language == Language.ENGLISH
                ? '${dateTime.year.toString().substring(2)}'
                : '${NepaliUnicode.convert(dateTime.year.toString().substring(2))}');
        break;
      case 'yyyy':
        _replacer(
            match,
            _language == Language.ENGLISH
                ? '${dateTime.year}'
                : '${NepaliUnicode.convert('${dateTime.year}')}');
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
            _language == Language.ENGLISH
                ? '${dateTime.month}'
                : '${NepaliUnicode.convert('${dateTime.month}')}');
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
            _language == Language.ENGLISH
                ? '${dateTime.day}'
                : '${NepaliUnicode.convert('${dateTime.day}')}');
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
            _language == Language.ENGLISH
                ? _weekDayString(dateTime.weekDay).substring(0, 3)
                : _weekDayString(dateTime.weekDay).replaceFirst('बार', ''));
        break;
      case 'EEE':
        _replacer(match, _weekDayString(dateTime.weekDay));
        break;
      case 'a':
        _replacer(
          match,
          _language == Language.ENGLISH
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
          _language == Language.ENGLISH
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
            _language == Language.ENGLISH
                ? '${dateTime.hour}'
                : NepaliUnicode.convert('${dateTime.hour}'));
        break;
      case 'HH':
        _replacer(match, _prependZero(dateTime.hour));
        break;
      case 'm':
        _replacer(
            match,
            _language == Language.ENGLISH
                ? '${dateTime.minute}'
                : NepaliUnicode.convert('${dateTime.minute}'));
        break;
      case 'mm':
        _replacer(match, _prependZero(dateTime.minute));
        break;
      case 's':
        _replacer(
            match,
            _language == Language.ENGLISH
                ? '${dateTime.second}'
                : NepaliUnicode.convert('${dateTime.second}'));
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
      return _language == Language.ENGLISH
          ? '00$numString'
          : '००${NepaliUnicode.convert('$number')}';
    }
    if (numString.length == 2) {
      return _language == Language.ENGLISH
          ? '0$numString'
          : '०${NepaliUnicode.convert('$number')}';
    }
    return _language == Language.ENGLISH
        ? numString.substring(0, 3)
        : NepaliUnicode.convert(numString.substring(0, 3));
  }

  String _clockHour(int hour, {bool prependZero = false}) {
    if (hour > 12) {
      return _language == Language.ENGLISH
          ? '${hour - 12}'
          : '${NepaliUnicode.convert('${hour - 12}')}';
    } else if (hour == 12) {
      return _language == Language.ENGLISH ? '12' : '१२';
    } else {
      return _language == Language.ENGLISH
          ? prependZero ? _prependZero(hour) : '${hour}'
          : prependZero
              ? _prependZero(hour)
              : '${NepaliUnicode.convert('$hour')}';
    }
  }

  String _prependZero(int number) => number < 10
      ? _language == Language.ENGLISH
          ? '0$number'
          : '०${NepaliUnicode.convert('$number')}'
      : _language == Language.ENGLISH
          ? '$number'
          : NepaliUnicode.convert('$number');

  void _replacer(String match, String replaceWith) {
    _pattern = _pattern.replaceFirst(match, replaceWith, _index);
    _index += replaceWith.length;
  }

  String _weekDayString(int day, {bool short = false}) {
    switch (day) {
      case 1:
        return _language == Language.ENGLISH
            ? short ? 'S' : 'Sunday'
            : short ? 'आ' : 'आइतबार';
      case 2:
        return _language == Language.ENGLISH
            ? short ? 'M' : 'Monday'
            : short ? 'सो' : 'सोमबार';
      case 3:
        return _language == Language.ENGLISH
            ? short ? 'T' : 'Tuesday'
            : short ? 'मं' : 'मंगलबार';
      case 4:
        return _language == Language.ENGLISH
            ? short ? 'W' : 'Wednesday'
            : short ? 'बु' : 'बुधबार';
      case 5:
        return _language == Language.ENGLISH
            ? short ? 'T' : 'Thursday'
            : short ? 'बि' : 'बिहिबार';
      case 6:
        return _language == Language.ENGLISH
            ? short ? 'F' : 'Friday'
            : short ? 'शु' : 'शुक्रबार';
      case 7:
        return _language == Language.ENGLISH
            ? short ? 'S' : 'Saturday'
            : short ? 'श' : 'शनिबार';
      default:
        return '';
    }
  }

  String _monthString(int month, {short = false}) {
    switch (month) {
      case 1:
        return _language == Language.ENGLISH
            ? short ? 'Bai' : 'Baishakh'
            : short ? 'बै' : 'बैशाख';
      case 2:
        return _language == Language.ENGLISH
            ? short ? 'Jes' : 'Jestha'
            : short ? 'जे' : 'जेष्ठ';
      case 3:
        return _language == Language.ENGLISH
            ? short ? 'Asa' : 'Ashadh'
            : short ? 'अ' : 'अषाढ';
      case 4:
        return _language == Language.ENGLISH
            ? short ? 'Shr' : 'Shrawan'
            : short ? 'श्रा' : 'श्रावण';
      case 5:
        return _language == Language.ENGLISH
            ? short ? 'Bha' : 'Bhadra'
            : short ? 'भा' : 'भाद्र';
      case 6:
        return _language == Language.ENGLISH
            ? short ? 'Ash' : 'Ashwin'
            : short ? 'आ' : 'आश्विन';
      case 7:
        return _language == Language.ENGLISH
            ? short ? 'Kar' : 'Kartik'
            : short ? 'का' : 'कार्तिक';
      case 8:
        return _language == Language.ENGLISH
            ? short ? 'Marg' : 'Mangsir'
            : short ? 'मं' : 'मंसिर';
      case 9:
        return _language == Language.ENGLISH
            ? short ? 'Pou' : 'Poush'
            : short ? 'पौ' : 'पौष';
      case 10:
        return _language == Language.ENGLISH
            ? short ? 'Mag' : 'Magh'
            : short ? 'मा' : 'माघ';
      case 11:
        return _language == Language.ENGLISH
            ? short ? 'Fal' : 'Falgun'
            : short ? 'फा' : 'फाल्गुन';
      case 12:
        return _language == Language.ENGLISH
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

  NepaliDateFormat.d([Language language]) : this("d", language: language);
  NepaliDateFormat.E([Language language]) : this("EE", language: language);
  NepaliDateFormat.EEEE([Language language]) : this("EEE", language: language);
  NepaliDateFormat.LLL([Language language]) : this("MMM", language: language);
  NepaliDateFormat.LLLL([Language language]) : this("MMMM", language: language);
  NepaliDateFormat.M([Language language]) : this("M", language: language);
  NepaliDateFormat.Md([Language language]) : this("M/d", language: language);
  NepaliDateFormat.MEd([Language language])
      : this("EE, M/d", language: language);
  NepaliDateFormat.MMM([Language language]) : this("MMM", language: language);
  NepaliDateFormat.MMMd([Language language])
      : this("MMM d", language: language);
  NepaliDateFormat.MMMEd([Language language])
      : this("EEE, MMM d", language: language);
  NepaliDateFormat.MMMM([Language language]) : this("MMMM", language: language);
  NepaliDateFormat.MMMMd([Language language])
      : this("MMMM d", language: language);
  NepaliDateFormat.MMMMEEEEd([Language language])
      : this("EEE, MMMM d", language: language);
  NepaliDateFormat.QQQ([Language language]) : this("QQQ", language: language);
  NepaliDateFormat.QQQQ([Language language]) : this("QQQQ", language: language);
  NepaliDateFormat.y([Language language]) : this("y", language: language);
  NepaliDateFormat.yM([Language language]) : this("y/MM", language: language);
  NepaliDateFormat.yMd([Language language])
      : this("y/MM/dd", language: language);
  NepaliDateFormat.yMEd([Language language])
      : this("EE, y/MM/dd", language: language);
  NepaliDateFormat.yMMM([Language language])
      : this("MMM y", language: language);
  NepaliDateFormat.yMMMd([Language language])
      : this("MMM d, y", language: language);
  NepaliDateFormat.yMMMEd([Language language])
      : this("EE, MMM d, y", language: language);
  NepaliDateFormat.yMMMM([Language language])
      : this("MMMM y", language: language);
  NepaliDateFormat.yMMMMd([Language language])
      : this("MMMM d, y", language: language);
  NepaliDateFormat.yMMMMEEEEd([Language language])
      : this("EEE, MMMM d, y", language: language);
  NepaliDateFormat.yQQQ([Language language])
      : this("QQQ y", language: language);
  NepaliDateFormat.yQQQQ([Language language])
      : this("QQQQ y", language: language);
  NepaliDateFormat.H([Language language]) : this("H", language: language);
  NepaliDateFormat.Hm([Language language]) : this("HH:MM", language: language);
  NepaliDateFormat.Hms([Language language])
      : this("HH:mm:ss", language: language);
  NepaliDateFormat.j([Language language])
      : this(
          language == Language.NEPALI ? "aa h" : "h aa",
          language: language,
        );
  NepaliDateFormat.jm([Language language])
      : this(
          language == Language.NEPALI ? "aa h:mm" : "h:mm aa",
          language: language,
        );
  NepaliDateFormat.jms([Language language])
      : this(
          language == Language.NEPALI ? "aa h:mm:ss" : "h:mm:ss aa",
          language: language,
        );
  NepaliDateFormat.m([Language language]) : this("h", language: language);
  NepaliDateFormat.ms([Language language]) : this("hh:mm", language: language);
  NepaliDateFormat.s([Language language]) : this("s", language: language);
}
