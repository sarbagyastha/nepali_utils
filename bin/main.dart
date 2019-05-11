import 'dart:async';

import 'package:nepali_utils/nepali_utils.dart';

main(List<String> arguments) {
  NepaliDateTime dt = DateConverter.toBS(DateTime.now());
  //print('Date in BS: ${dt.year}-${dt.month}-${dt.day} ${dt.weekDay}');
  DateTime at = DateConverter.toAD(NepaliDateTime(2016, 11, 15));
  //print('Date in AD: ${at.year}-${at.month}-${at.day}');
  NepaliDateTime sarbagya = NepaliDateTime.parse("2052-01-05T07:04:04");

  var date1 = NepaliDateFormatter("yyyy.MM.dd G 'at' HH:mm:ss");
  var date2 = NepaliDateFormatter("EEE, MMM d, ''yy");
  var date3 = NepaliDateFormatter("h:mm a");
  var date4 = NepaliDateFormatter("hh 'o''clock' aa");
  var date5 = NepaliDateFormatter("yyyy.MMMM.dd GGG hh:mm a");
  print(date1.format(dt));
  print(date2.format(dt));
  print(date3.format(dt));
  print(date4.format(dt));
  print(date5.format(dt));
}
