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
  hundred: 'hundred',
  scales: [
    'thousand', 'lakh', 'crore', 'arab', //
    'kharab', 'nil', 'padam', 'sankha',
  ],
  rupees: 'rupees',
  paisa: 'paisa',
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
