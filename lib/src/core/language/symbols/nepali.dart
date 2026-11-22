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
  numbers: NumberSymbols(
    belowHundred: [
      'शून्य', 'एक', 'दुई', 'तीन', 'चार', //
      'पाँच', 'छ', 'सात', 'आठ', 'नौ', //
      'दश', 'एघार', 'बाह्र', 'तेह्र', 'चौध', //
      'पन्ध्र', 'सोह्र', 'सत्र', 'अठार', 'उन्नाइस', //
      'बीस', 'एक्काइस', 'बाइस', 'तेइस', 'चौबीस', //
      'पच्चीस', 'छब्बीस', 'सत्ताइस', 'अट्ठाइस', 'उनन्तीस', //
      'तीस', 'एकतीस', 'बत्तीस', 'तेत्तीस', 'चौंतीस', //
      'पैंतीस', 'छत्तीस', 'सैंतीस', 'अठतीस', 'उनन्चालीस', //
      'चालीस', 'एकचालीस', 'बयालीस', 'त्रिचालीस', 'चवालीस', //
      'पैंतालीस', 'छयालीस', 'सतचालीस', 'अठचालीस', 'उनन्चास', //
      'पचास', 'एकाउन्न', 'बाउन्न', 'त्रिपन्न', 'चउन्न', //
      'पचपन्न', 'छपन्न', 'सन्ताउन्न', 'अन्ठाउन्न', 'उनन्साठी', //
      'साठी', 'एकसट्ठी', 'बयसट्ठी', 'त्रिसट्ठी', 'चौंसट्ठी', //
      'पैंसट्ठी', 'छयसट्ठी', 'सतसट्ठी', 'अठसट्ठी', 'उनन्सत्तरी', //
      'सत्तरी', 'एकहत्तर', 'बहत्तर', 'त्रिहत्तर', 'चौहत्तर', //
      'पचहत्तर', 'छयहत्तर', 'सतहत्तर', 'अठहत्तर', 'उनासी', //
      'असी', 'एकासी', 'बयासी', 'त्रियासी', 'चौरासी', //
      'पचासी', 'छयासी', 'सतासी', 'अठासी', 'उनान्नब्बे', //
      'नब्बे', 'एकान्नब्बे', 'बयान्नब्बे', 'त्रियान्नब्बे', 'चौरान्नब्बे', //
      'पन्चानब्बे', 'छयान्नब्बे', 'सन्तान्नब्बे', 'अन्ठान्नब्बे', 'उनान्सय', //
    ],
    hundred: 'सय',
    scales: ['हजार', 'लाख', 'करोड', 'अर्ब', 'खर्ब', 'नील', 'पद्म', 'शंख'],
    // As in intl's `ne` locale, short forms use a no-break space.
    compactShort: [
      '\u00A0हजार', '\u00A0लाख', '\u00A0करोड', '\u00A0अर्ब', //
      '\u00A0खर्ब',
    ],
    compactLong: [' हजार', ' लाख', ' करोड', ' अर्ब', ' खर्ब'],
    minus: 'ऋण',
    point: 'दशमलव',
    rupees: 'रुपैयाँ',
    paisa: 'पैसा',
    currencySymbol: 'रु.',
  ),
  relativeTime: RelativeTimeSymbols(
    fewSeconds: 'केही क्षण',
    past: '# पहिले',
    future: '# पछि',
    second: UnitSymbols(
      approximate: 'एक सेकेन्ड',
      one: '# सेकेन्ड',
      other: '# सेकेन्ड',
      shortOne: '# से.',
      shortOther: '# से.',
      current: 'अहिले',
    ),
    minute: UnitSymbols(
      approximate: 'एक मिनेट',
      one: '# मिनेट',
      other: '# मिनेट',
      shortOne: '# मि.',
      shortOther: '# मि.',
      current: 'यही मिनेट',
    ),
    hour: UnitSymbols(
      approximate: 'एक घण्टा',
      one: '# घण्टा',
      other: '# घण्टा',
      shortOne: '# घ.',
      shortOther: '# घ.',
      current: 'यही घण्टा',
    ),
    day: UnitSymbols(
      approximate: 'एक दिन',
      one: '# दिन',
      other: '# दिन',
      shortOne: '# दिन',
      shortOther: '# दिन',
      previous: 'हिजो',
      current: 'आज',
      next: 'भोलि',
    ),
    week: UnitSymbols(
      approximate: 'एक हप्ता',
      one: '# हप्ता',
      other: '# हप्ता',
      shortOne: '# हप्ता',
      shortOther: '# हप्ता',
      previous: 'गत हप्ता',
      current: 'यो हप्ता',
      next: 'आउँदो हप्ता',
    ),
    month: UnitSymbols(
      approximate: 'एक महिना',
      one: '# महिना',
      other: '# महिना',
      shortOne: '# महिना',
      shortOther: '# महिना',
      previous: 'गत महिना',
      current: 'यो महिना',
      next: 'आउँदो महिना',
    ),
    year: UnitSymbols(
      approximate: 'एक वर्ष',
      one: '# वर्ष',
      other: '# वर्ष',
      shortOne: '# व.',
      shortOther: '# व.',
      previous: 'गत वर्ष',
      current: 'यो वर्ष',
      next: 'आउँदो वर्ष',
    ),
    calendar: CalendarSymbols(
      sameDay: 'आज {time}',
      previousDay: 'हिजो {time}',
      nextDay: 'भोलि {time}',
      previousWeek: 'गएको {weekday}, {time}',
      nextWeek: 'आउँदो {weekday}, {time}',
    ),
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
