// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language_symbols.dart';

/// Nepali, laid out like `package:intl`'s `ne` locale.
const LanguageSymbols nepali = LanguageSymbols(
  zeroDigit: 0x0966, // ०
  months: [
    'बैशाख', 'जेष्ठ', 'आषाढ', 'श्रावण', 'भाद्र', 'आश्विन', //
    'कार्तिक', 'मंसिर', 'पौष', 'माघ', 'फाल्गुण', 'चैत्र',
  ],
  monthsAlt: [
    'बैशाख', 'जेठ', 'असार', 'साउन', 'भदौ', 'असोज', //
    'कात्तिक', 'मार्ग', 'पुस', 'माघ', 'फागुन', 'चैत',
  ],
  monthsShort: _monthsShort,
  monthsNarrow: _monthsShort,
  weekdays: [
    'आइतबार', 'सोमबार', 'मंगलबार', 'बुधबार', //
    'बिहिबार', 'शुक्रबार', 'शनिबार',
  ],
  weekdaysShort: ['आइत', 'सोम', 'मंगल', 'बुध', 'बिहि', 'शुक्र', 'शनि'],
  weekdaysNarrow: ['आ', 'सो', 'मं', 'बु', 'बि', 'शु', 'श'],
  eras: (short: 'बि सं', long: 'बिक्रम संबत'),
  // Like intl's `ne` locale, the short and long quarter names are the same.
  quarters: _quarters,
  quartersShort: _quarters,
  dayPeriod: _dayPeriod,
  nepalTime: 'नेपाल समय',
  utc: 'समन्वित विश्व समय',
  // Copied from intl's `dateTimePatterns` for `ne`. `EEEEE` and `jv` are not
  // in intl's table; they follow `E`/`jz`.
  skeletons: {
    'd': 'd',
    'E': 'ccc',
    'EEEE': 'cccc',
    'EEEEE': 'ccccc',
    'LLL': 'LLL',
    'LLLL': 'LLLL',
    'M': 'L',
    'Md': 'MM-dd',
    'MEd': 'MM-dd, EEE',
    'MMM': 'LLL',
    'MMMd': 'MMM d',
    'MMMEd': 'MMM d, EEE',
    'MMMM': 'LLLL',
    'MMMMd': 'MMMM d',
    'MMMMEEEEd': 'MMMM d, EEEE',
    'QQQ': 'QQQ',
    'QQQQ': 'QQQQ',
    'y': 'y',
    'yM': 'y-MM',
    'yMd': 'y-MM-dd',
    'yMEd': 'y-MM-dd, EEE',
    'yMMM': 'y MMM',
    'yMMMd': 'y MMM d',
    'yMMMEd': 'y MMM d, EEE',
    'yMMMM': 'y MMMM',
    'yMMMMd': 'y MMMM d',
    'yMMMMEEEEd': 'y MMMM d, EEEE',
    'yQQQ': 'y QQQ',
    'yQQQQ': 'y QQQQ',
    'H': 'HH',
    'Hm': 'HH:mm',
    'Hms': 'HH:mm:ss',
    'j': 'HH',
    'jm': 'HH:mm',
    'jms': 'HH:mm:ss',
    'jmv': 'HH:mm v',
    'jmz': 'HH:mm z',
    'jv': "HH'h' v",
    'jz': "HH'h' z",
    'm': 'm',
    'ms': 'mm:ss',
    's': 's',
    'v': 'v',
    'z': 'z',
    'zzzz': 'zzzz',
    'ZZZZ': 'ZZZZ',
  },
  hundred: 'सय',
  scales: ['हजार', 'लाख', 'करोड', 'अर्ब', 'खर्ब', 'नील', 'पद्म', 'शंख'],
  rupees: 'रुपैया',
  paisa: 'पैसा',
  relativeTime: RelativeTimeSymbols(
    moments: 'केही क्षण',
    minute: 'एक मिनेट',
    minutes: '# मिनेट',
    hour: 'लगभग एक घण्टा',
    hours: '# घण्टा',
    day: 'एक दिन',
    days: '# दिन',
    month: 'लगभग एक महिना',
    months: '# महिना',
    year: 'लगभग एक वर्ष',
    years: '# वर्ष',
    past: '# पहिले',
    future: '# पछि',
  ),
);

const _monthsShort = [
  'बै', 'जे', 'अ', 'श्रा', 'भा', 'आ', 'का', 'मं', 'पौ', 'मा', 'फा', 'चै', //
];

const _quarters = [
  'पहिलो त्रैमासिक',
  'दोस्रो त्रैमासिक',
  'तेस्रो त्रैमासिक',
  'चौथो त्रैमासिक', //
];

String _dayPeriod(int hour) => switch (hour) {
  < 12 => 'बिहान',
  12 => 'मध्यान्न',
  < 16 => 'दिउसो',
  < 20 => 'साँझ',
  _ => 'बेलुकी',
};
