// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language_symbols.dart';

/// English, laid out like `package:intl`'s `en` locale.
const LanguageSymbols english = LanguageSymbols(
  zeroDigit: 0x30,
  months: [
    'Baishakh', 'Jestha', 'Ashadh', 'Shrawan', 'Bhadra', 'Ashwin', //
    'Kartik', 'Mangsir', 'Poush', 'Magh', 'Falgun', 'Chaitra',
  ],
  monthsAlt: [
    'Baisak', 'Jeth', 'Asar', 'Saun', 'Bhadau', 'Asoj', //
    'Kartik', 'Marga', 'Pus', 'Magh', 'Fagun', 'Chait',
  ],
  monthsShort: [
    'Bai', 'Jes', 'Asar', 'Shr', 'Bha', 'Ash', //
    'Kar', 'Marg', 'Pou', 'Mag', 'Fal', 'Cha',
  ],
  monthsNarrow: ['B', 'J', 'A', 'S', 'B', 'A', 'K', 'M', 'P', 'M', 'F', 'C'],
  weekdays: [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', //
    'Thursday', 'Friday', 'Saturday',
  ],
  weekdaysShort: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
  weekdaysNarrow: ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
  eras: (short: 'BS', long: 'Bikram Sambat'),
  quarters: ['1st quarter', '2nd quarter', '3rd quarter', '4th quarter'],
  quartersShort: ['Q1', 'Q2', 'Q3', 'Q4'],
  dayPeriod: _dayPeriod,
  nepalTime: 'Nepal Time',
  utc: 'Coordinated Universal Time',
  // Copied from intl's `dateTimePatterns` for `en`. `EEEEE` and `jv` are not
  // in intl's table; they follow `E`/`jz`. As in intl (CLDR), times put a
  // narrow no-break space (U+202F) before AM/PM, e.g. `9:04\u202fPM`.
  skeletons: {
    'd': 'd',
    'E': 'ccc',
    'EEEE': 'cccc',
    'EEEEE': 'ccccc',
    'LLL': 'LLL',
    'LLLL': 'LLLL',
    'M': 'L',
    'Md': 'M/d',
    'MEd': 'EEE, M/d',
    'MMM': 'LLL',
    'MMMd': 'MMM d',
    'MMMEd': 'EEE, MMM d',
    'MMMM': 'LLLL',
    'MMMMd': 'MMMM d',
    'MMMMEEEEd': 'EEEE, MMMM d',
    'QQQ': 'QQQ',
    'QQQQ': 'QQQQ',
    'y': 'y',
    'yM': 'M/y',
    'yMd': 'M/d/y',
    'yMEd': 'EEE, M/d/y',
    'yMMM': 'MMM y',
    'yMMMd': 'MMM d, y',
    'yMMMEd': 'EEE, MMM d, y',
    'yMMMM': 'MMMM y',
    'yMMMMd': 'MMMM d, y',
    'yMMMMEEEEd': 'EEEE, MMMM d, y',
    'yQQQ': 'QQQ y',
    'yQQQQ': 'QQQQ y',
    'H': 'HH',
    'Hm': 'HH:mm',
    'Hms': 'HH:mm:ss',
    'j': 'h\u202fa',
    'jm': 'h:mm\u202fa',
    'jms': 'h:mm:ss\u202fa',
    'jmv': 'h:mm\u202fa v',
    'jmz': 'h:mm\u202fa z',
    'jv': 'h\u202fa v',
    'jz': 'h\u202fa z',
    'm': 'm',
    'ms': 'mm:ss',
    's': 's',
    'v': 'v',
    'z': 'z',
    'zzzz': 'zzzz',
    'ZZZZ': 'ZZZZ',
  },
  numbers: NumberSymbols(
    belowHundred: [
      'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', //
      'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', //
      'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen', 'twenty', //
      'twenty-one', 'twenty-two', 'twenty-three', 'twenty-four', //
      'twenty-five', 'twenty-six', 'twenty-seven', 'twenty-eight', //
      'twenty-nine', 'thirty', 'thirty-one', 'thirty-two', 'thirty-three', //
      'thirty-four', 'thirty-five', 'thirty-six', 'thirty-seven', //
      'thirty-eight', 'thirty-nine', 'forty', 'forty-one', 'forty-two', //
      'forty-three', 'forty-four', 'forty-five', 'forty-six', 'forty-seven', //
      'forty-eight', 'forty-nine', 'fifty', 'fifty-one', 'fifty-two', //
      'fifty-three', 'fifty-four', 'fifty-five', 'fifty-six', 'fifty-seven', //
      'fifty-eight', 'fifty-nine', 'sixty', 'sixty-one', 'sixty-two', //
      'sixty-three', 'sixty-four', 'sixty-five', 'sixty-six', 'sixty-seven', //
      'sixty-eight', 'sixty-nine', 'seventy', 'seventy-one', 'seventy-two', //
      'seventy-three', 'seventy-four', 'seventy-five', 'seventy-six', //
      'seventy-seven', 'seventy-eight', 'seventy-nine', 'eighty', //
      'eighty-one', 'eighty-two', 'eighty-three', 'eighty-four', //
      'eighty-five', 'eighty-six', 'eighty-seven', 'eighty-eight', //
      'eighty-nine', 'ninety', 'ninety-one', 'ninety-two', 'ninety-three', //
      'ninety-four', 'ninety-five', 'ninety-six', 'ninety-seven', //
      'ninety-eight', 'ninety-nine',
    ],
    hundred: 'hundred',
    scales: [
      'thousand', 'lakh', 'crore', 'arab', //
      'kharab', 'nil', 'padam', 'sankha',
    ],
    compactShort: ['K', 'L', 'Cr', 'Arab', 'Kharab'],
    compactLong: [' thousand', ' lakh', ' crore', ' arab', ' kharab'],
    minus: 'minus',
    point: 'point',
    rupees: 'rupees',
    paisa: 'paisa',
    currencySymbol: 'Rs.',
  ),
  relativeTime: RelativeTimeSymbols(
    moments: 'few moment',
    minute: 'one minute',
    minutes: '# minute',
    hour: 'about an hour',
    hours: '# hours',
    day: 'one day',
    days: '# days',
    month: 'about a month',
    months: '# month',
    year: 'about one year',
    years: '# year',
    past: '# ago',
    future: '# from now',
  ),
);

String _dayPeriod(int hour) => hour < 12 ? 'AM' : 'PM';
