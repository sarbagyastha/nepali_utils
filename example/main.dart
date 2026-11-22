// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
// ignore_for_file: avoid_print

import 'package:nepali_utils/nepali_utils.dart';

void main(List<String> arguments) {
  heading('Nepali Date Time');
  final gorkhaEarthQuake = NepaliDateTime.parse('2072-01-12T11:56:25');
  print('Gorkha Earthquake: $gorkhaEarthQuake');
  print('Now (local): ${NepaliDateTime.now()}');
  print('Now (Nepal): ${NepaliDateTime.nepalNow().toIso8601String()}');
  print('Normalised:  ${NepaliDateTime(2080, 1, 35)}');

  heading('Date Converter');
  final nt = DateTime(2019, 5, 14).toNepaliDateTime();
  print('In BS = $nt');
  final dt = nt.toDateTime();
  print('In AD = $dt');

  heading('Nepali Date Formatter');
  final date1 = NepaliDateFormat("yyyy.MM.dd G 'at' HH:mm:ss");
  final date2 = NepaliDateFormat("EEE, MMM d, ''yy");
  final date3 = NepaliDateFormat('h:mm a');
  final date4 = NepaliDateFormat("hh 'o''clock' a");
  final date5 = NepaliDateFormat('yyyy.MMMM.dd GGGG hh:mm a', Language.nepali);
  final date6 = NepaliDateFormat.yMd().add_jm();
  print(date1.format(gorkhaEarthQuake));
  print(date2.format(gorkhaEarthQuake));
  print(date3.format(gorkhaEarthQuake));
  print(date4.format(gorkhaEarthQuake));
  print(date5.format(gorkhaEarthQuake));
  print(date6.format(gorkhaEarthQuake));

  heading('Nepali Number Format');
  final numberFormat = NepaliNumberFormat.simpleCurrency(decimalDigits: 0);
  final commaSeparated = NepaliNumberFormat.decimalPatternDigits(
    decimalDigits: 2,
  );

  final numberFormatWithDefaultDelimiter = numberFormat;
  final numberFormatWithEmptyDelimiter = numberFormat.copyWith(
    groupSeparator: '',
  );

  // Sets default language for nepali utilities to be Nepali.
  NepaliUtils.defaultLanguage = Language.fromLocale('ne_NP');

  final inWords = NepaliNumberFormat.words(language: Language.nepali);
  final currencyInWords = NepaliNumberFormat.words(
    language: Language.nepali,
    currency: true,
  );
  final compact = NepaliNumberFormat.compact(language: Language.nepali);
  print('123456 -> ${numberFormat.format(123456)}');
  print('123456789.6548 -> ${commaSeparated.format(123456789.6548)}');
  print('123456 -> ${inWords.format(123456)}');
  print('123456789.6548 -> ${currencyInWords.format(123456789.6548)}');
  print('1234567 -> ${compact.format(1234567)}');
  print('१२,३४,५६७.८९ -> ${commaSeparated.parse('१२,३४,५६७.८९')}');

  heading('Number Format With Delimiter');
  print('12345 -> ${numberFormatWithDefaultDelimiter.format(12345)}');
  print('12345 -> ${numberFormatWithEmptyDelimiter.format(12345)}');

  heading('Nepali Unicode');
  const unicode = NepaliUnicode();
  print(
    unicode.convert("sayau' thu''gaa fUlakaa haamii, euTai maalaa nepaalii"),
  );
  print(unicode.convert('saarwabhauma bhai failiekaa, mecii-mahaakaalii'));
  print(unicode.convert('mero naam {Sarbagya} ho'));
  print(unicode.toRoman('नेपाली'));

  const google = NepaliUnicode(style: .google);
  print(google.convert('nepaal ko maayaa, bhagawaan~ ko dayaa'));
  print(google.toRoman('क्षत्रिय'));
  print(const NepaliUnicode(style: .mppRomanized).convert('nepal'));

  heading('Preeti & Devanagari');
  print(Preeti.toUnicode('sfof{no / lxdfn'));
  print(Preeti.fromUnicode('काठमाडौं'));
  print(Devanagari.aksharas('संस्कृति'));
  print(Devanagari.toEnglishDigits('२०८१'));

  heading('Nepali Measurement');
  final plot = NepaliArea.ropani(2, aana: 3, paisa: 1);
  print('${plot.format(.ropani)} = ${plot.to(.squareFoot)} sq. ft');
  print(plot.format(.ropani, long: true, language: .nepali));
  print(plot.format(.bigha, long: true));
  print(NepaliArea(1000, .squareMeter).format(.ropani));
  print('${NepaliWeight.tola(2, lal: 50).to(.gram)} g');
  print(NepaliWeight(5, .kilogram).format(.dharni, long: true));
  print(NepaliVolume.muri(1, pathi: 5, mana: 4).format(long: true));
}

void heading(String text) {
  final padding = ' ' * ((40 - text.length) ~/ 2);
  final stars = '*' * 40;
  print(stars);
  print('$padding$text$padding');
  print(stars);
}
