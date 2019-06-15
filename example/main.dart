import 'package:nepali_utils/nepali_utils.dart';

main(List<String> arguments) {
  heading('Nepali Date Time');
  NepaliDateTime gorkhaEarthQuake = NepaliDateTime.parse('2072-01-12T11:56:25');
  //print(
  //    'Gorkha Earquake Details\nYear = ${gorkhaEarthQuake.year}\nMonth = ${gorkhaEarthQuake.month}\nDay = ${gorkhaEarthQuake.day}\nHour = ${gorkhaEarthQuake.hour}\nMinute = ${gorkhaEarthQuake.minute}');
  //print('\nCurrent NepaliDateTime = ${NepaliDateTime.now()}');

  heading('Date Converter');
  NepaliDateTime nt = DateConverter.toBS(DateTime(2019, 5, 14));
  print('In BS = $nt');
  DateTime dt = DateConverter.toAD(nt);
  print('In AD = $dt');

  print(NepaliDateTime.now().toIso8601String());

  heading('Nepali Date Formatter');
  var date1 = NepaliDateFormatter("yyyy.MM.dd G 'at' HH:mm:ss");
  var date2 = NepaliDateFormatter("EEE, MMM d, ''yy");
  var date3 = NepaliDateFormatter("h:mm a");
  var date4 = NepaliDateFormatter("hh 'o''clock' aa");
  var date5 = NepaliDateFormatter("yyyy.MMMM.dd GGG hh:mm a");
  print(date1.format(gorkhaEarthQuake));
  print(date2.format(gorkhaEarthQuake));
  print(date3.format(gorkhaEarthQuake));
  print(date4.format(gorkhaEarthQuake));
  print(date5.format(gorkhaEarthQuake));

  heading('Nepali Number');
  print('123456 -> ${NepaliNumber.from(123456)}');
  print('1,23,456 -> ${NepaliNumber.fromString('1,23,456')}');

  heading('Nepali Unicode');
  print(NepaliUnicode.convert(
      "sayau' thu''gaa fUlakaa haamii, euTai maalaa nepaalii"));
  print(NepaliUnicode.convert(
      "saarwabhauma bhai failiekaa, mecii-mahaakaalii\n"));
}

void heading(String text) {
  String starLine = '', padString = '';
  int padding = (40 - text.length) ~/ 2;
  for (int i = 0; i < 40; i++) starLine += '*';
  for (int i = 0; i < padding; i++) padString += ' ';
  print(starLine);
  print(padString + text + padString);
  print(starLine);
}
