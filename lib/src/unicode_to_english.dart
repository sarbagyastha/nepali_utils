// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Converts Nepali Unicode (Devnagari Literals) into English(Roman) literals.
class UnicodeToEnglish {
  /// Converts specifies [text] into english literals.
  ///
  /// if live is true, texts will convert in live manner.
  /// i.e. as you go on typing
  /// Default for live is false.
  static String convert(String text, {bool live = false}) {
    final characters = text.split('');
    final convertedString = <String>[];
    for (var i = 0; i < characters.length; i++) {
      if (i < characters.length - 1 && characters[i + 1] == '\u094D') {
        var character = _unicodeMap[characters[i]].toString();
        character = character.substring(0, character.length - 1);
        convertedString.add(character);
      } else if (characters[i] != '\u094D') {
        convertedString.add(
          _unicodeMap[characters[i]] ?? characters[i],
        );
      }
    }
    for (var i = 0; i < convertedString.length; i++) {
      // if the converted string contains symbols
      if (_symbolMap[convertedString[i]] != null) {
        var preecedingCharacter = convertedString[i - 1].toString();
        print('$preecedingCharacter ${preecedingCharacter.endsWith('a')}');
        //  eg. tha + ु (u) = thu
        if (preecedingCharacter.endsWith('a')) {
          preecedingCharacter =
              preecedingCharacter.substring(0, preecedingCharacter.length - 1);
          convertedString[i - 1] = preecedingCharacter;
        }

        convertedString[i] = _symbolMap[convertedString[i]] ?? '';
      }
    }
    return convertedString.join('');
  }
}

const Map<String, String> _unicodeMap = {
  //ka - gya
  '\u0915': 'ka',
  '\u0916': 'kha',
  '\u0917': 'ga',
  '\u0918': 'gha',
  '\u0919': 'ng',
  '\u091A': 'ca',
  '\u091B': 'cha',
  '\u091C': 'ja',
  '\u091D': 'jha',
  '\u091E': 'ya',
  '\u091F': 'Ta',
  '\u0920': 'Tha',
  '\u0921': 'Da',
  '\u0922': 'Dha',
  '\u0923': 'na',
  '\u0924': 'ta',
  '\u0925': 'tha',
  '\u0926': 'da',
  '\u0927': 'dha',
  '\u0928': 'na',
  '\u092A': 'pa',
  '\u092B': 'fa',
  '\u092C': 'ba',
  '\u092D': 'bha',
  '\u092E': 'ma',
  '\u092F': 'ya',
  '\u0930': 'ra',
  '\u0932': 'la',
  '\u0935': 'wa',
  '\u0936': 'sha',
  '\u0937': 'sha',
  '\u0938': 'sa',
  '\u0939': 'ha',
  '\u0915\u094D\u0937': 'xa',
  '\u0924\u094D\u0930': 'tra',
  '\u091C\u094D\u091E': 'gya',
  // a - ahm
  '\u0905': 'a',
  '\u0906': 'aa',
  '\u0907': 'i',
  '\u0908': 'ii',
  '\u0909': 'u',
  '\u090A': 'oo',
  '\u090F': 'e',
  '\u0910': 'ai',
  '\u0913': 'o',
  '\u0914': 'au',
  '\u0935\u0902': 'am',
  '\u0935\u0903': 'ah',

  //numbers
  '\u0966': '0',
  '\u0967': '1',
  '\u0968': '2',
  '\u0969': '3',
  '\u096a': '4',
  '\u096b': '5',
  '\u096c': '6',
  '\u096d': '7',
  '\u096e': '8',
  '\u096f': '9',
  //symbols
  '%2c': ',',
};
const Map<String, String> _symbolMap = {
  '\u093E': 'aa',
  '\u093F': 'i',
  '\u0940': 'ii',
  '\u0941': 'u',
  '\u0942': 'U',
  '\u0947': 'e',
  '\u0948': 'ai',
  '\u094B': 'o',
  '\u094C': 'au',

  '\u0901': "''", //chandrabindu
  '\u0902': "'", //shreebindu
};
