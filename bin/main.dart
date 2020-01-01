// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/nepali_utils.dart';

void main(List<String> arguments) {
  heading('Nepali Date Time');
  var gorkhaEarthQuake = NepaliDateTime.parse('2072-01-12T11:56:25');
  print(
      'Gorkha Earthquake Details\nYear = ${gorkhaEarthQuake.year}\nMonth = ${gorkhaEarthQuake.month}\nDay = ${gorkhaEarthQuake.day}\nHour = ${gorkhaEarthQuake.hour}\nMinute = ${gorkhaEarthQuake.minute}');
  print('\nCurrent NepaliDateTime = ${NepaliDateTime.now()}');
  print(gorkhaEarthQuake.mergeTime(10, 20, 30));

  heading('Date Conversion');
  var nt = NepaliDateTime.fromDateTime(DateTime(2019, 8, 03, 14, 30, 15));
  print('In BS = $nt');
  var dt = nt.toDateTime();
  print('In AD = $dt');

  print(NepaliDateTime.now().toIso8601String());

  heading('Nepali Date Formatter');
  var date1 = NepaliDateFormat.MEd();
  var date2 = NepaliDateFormat.MMMMEEEEd();
  var date3 = NepaliDateFormat.jms();
  var date4 = NepaliDateFormat("yyyy.MM.dd G 'at' HH:mm:ss");
  var date5 = NepaliDateFormat("EEE, MMM d, ''yy");
  var date6 = NepaliDateFormat('h:mm a');
  var date7 = NepaliDateFormat("hh 'o''clock' aa");
  var date8 = NepaliDateFormat('yyyy.MMMM.dd GGG hh:mm a');
  print(date1.format(gorkhaEarthQuake));
  print(date2.format(gorkhaEarthQuake));
  print(date3.format(gorkhaEarthQuake));
  print(date4.format(gorkhaEarthQuake));
  print(date5.format(gorkhaEarthQuake));
  print(date6.format(gorkhaEarthQuake));
  print(date7.format(gorkhaEarthQuake));
  print(date8.format(gorkhaEarthQuake));

  heading('Nepali Number Format');
  var currencyFormat = NepaliNumberFormat(
    symbol: 'Rs.',
  );
  var commaSeparated = NepaliNumberFormat(
    decimalDigits: 2,
    isMonetory: true,
    language: Language.nepali,
  );
  var inWords = NepaliNumberFormat(
    inWords: true,
    language: Language.english,
  );
  var currencyInWords = NepaliNumberFormat(
    inWords: true,
    language: Language.nepali,
    isMonetory: true,
    decimalDigits: 2,
  );
  print('123456 -> ${currencyFormat.format<int>(123456)}');
  print('123456789.6548 -> ${commaSeparated.format<double>(123456789.6548)}');
  print('123456 -> ${inWords.format<String>('123456')}');
  print('123456789.6548 -> ${currencyInWords.format<num>(123456789.6548)}');

  heading('Nepali Unicode');
  print(
    NepaliUnicode.convert(
        "sayau' thu''gaa fUlakaa haamii, euTai maalaa nepaalii"),
  );
  print(
    NepaliUnicode.convert('saarwabhauma bhai failiekaa, mecii-mahaakaalii\n'),
  );

  heading('Nepali Moment');
  print(
    NepaliMoment.fromBS(
      NepaliDateTime.parse('2076-03-22T08:41:14'),
    ),
  );

  print(
    NepaliMoment.fromBS(
      NepaliDateTime.parse('2076-02-32T18:25:14'),
      referenceDate: NepaliDateTime.parse('2076-02-32T18:34:14'),
    ),
  );
  print(
    NepaliMoment.fromAD(
      DateTime.parse('2019-06-02T18:22:14'),
      referenceDate: DateTime.parse('2019-06-15T18:34:14'),
    ),
  );
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
