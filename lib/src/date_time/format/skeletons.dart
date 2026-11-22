// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/language.dart';

/// The pattern for each `package:intl` skeleton, per language.
///
/// Copied from intl's `dateTimePatterns` for the `en` and `ne` locales, so a
/// skeleton lays out exactly like `DateFormat.<skeleton>('en' | 'ne')`.
/// `EEEEE` and `jv` are not in intl's tables; they are added following
/// `E`/`jz`, since intl falls back to treating them as raw patterns.
///
/// As in intl (CLDR), English times put a narrow no-break space (U+202F)
/// before the AM/PM marker, e.g. `9:04\u202fPM`.
Map<String, String> skeletonsFor(Language language) =>
    language == .nepali ? _nepali : _english;

const Map<String, String> _english = {
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
};

const Map<String, String> _nepali = {
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
};
