// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils/src/unicode_to_english.dart';

void main(List<String> arguments) {
  heading('Nepali Date Time');
  var gorkhaEarthQuake = NepaliDateTime.parse('2072-01-12T11:56:25');
  //print(
  //    'Gorkha Earquake Details\nYear = ${gorkhaEarthQuake.year}\nMonth = ${gorkhaEarthQuake.month}\nDay = ${gorkhaEarthQuake.day}\nHour = ${gorkhaEarthQuake.hour}\nMinute = ${gorkhaEarthQuake.minute}');
  //print('\nCurrent NepaliDateTime = ${NepaliDateTime.now()}');

  heading('Date Converter');
  var nt = DateTime(2019, 5, 14).toNepaliDateTime();
  print('In BS = $nt');
  var dt = nt.toDateTime();
  print('In AD = $dt');

  print(NepaliDateTime.now().toIso8601String());

  heading('Nepali Date Formatter');
  var date1 = NepaliDateFormat("yyyy.MM.dd G 'at' HH:mm:ss");
  var date2 = NepaliDateFormat("EEE, MMM d, ''yy");
  var date3 = NepaliDateFormat('h:mm a');
  var date4 = NepaliDateFormat("hh 'o''clock' aa");
  var date5 = NepaliDateFormat('yyyy.MMMM.dd GGG hh:mm a');
  print(date1.format(gorkhaEarthQuake));
  print(date2.format(gorkhaEarthQuake));
  print(date3.format(gorkhaEarthQuake));
  print(date4.format(gorkhaEarthQuake));
  print(date5.format(gorkhaEarthQuake));

  heading('Nepali Number Format');
  final numberFormat = NepaliNumberFormat(
    symbol: 'Rs.',
  );
  final commaSeparated = NepaliNumberFormat(
    decimalDigits: 2,
  );

  final numberFormatWithDefaultDelimiter = NepaliNumberFormat(
    symbol: 'Rs.',
    delimiter: ',',
  );
  final numberFormatWithEmptyDelimiter = NepaliNumberFormat(
    symbol: 'Rs.',
    delimiter: '',
  );

  // Sets default language for nepali utilities to be Nepali.
  NepaliUtils(Language.nepali);

  var inWords = NepaliNumberFormat(
    inWords: true,
    language: Language.nepali,
  );
  var currencyInWords = NepaliNumberFormat(
    inWords: true,
    language: Language.nepali,
    isMonetory: true,
  );
  print('123456 -> ${numberFormat.format(123456)}');
  print('123456789.6548 -> ${commaSeparated.format(123456789.6548)}');
  print('123456 -> ${inWords.format(123456)}');
  print('123456789.6548 -> ${currencyInWords.format(123456789.6548)}');

  heading('Number Format With Delimiter');
  print('12345 -> ${numberFormatWithDefaultDelimiter.format(12345)}');
  print('12345 -> ${numberFormatWithEmptyDelimiter.format(12345)}');

  heading('Nepali Unicode');
  print(NepaliUnicode.convert(
      "sayau' thu''gaa fUlakaa haamii, euTai maalaa nepaalii"));
  print(NepaliUnicode.convert(
      'saarwabhauma bhai failiekaa, mecii-mahaakaalii\n'));
  heading('Unicode to English');
  print(UnicodeToEnglish.convert('सयौं थुँगा फूलका हामी, एउटै माला नेपाली'));
  print(UnicodeToEnglish.convert('सार्वभौम भै फैलिएका, मेची-महाकाली\n'));
}

void heading(String text) {
  var starLine = '', padString = '';
  var padding = (40 - text.length) ~/ 2;
  for (var i = 0; i < 40; i++) {
    starLine += '*';
  }
  for (var i = 0; i < padding; i++) {
    padString += ' ';
  }
  print(starLine);
  print(padString + text + padString);
  print(starLine);
}
