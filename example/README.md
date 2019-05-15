# Nepali Utilities Example

### Nepali Date Time
The class is similar to `dart:core`'s [DateTime]() class, except that, this works with Bikram Sambat.
```dart
NepaliDateTime gorkhaEarthQuake = NepaliDateTime.parse('2072-01-12T11:56:25');
print(gorkhaEarthQuake.year); // 2072

NepaliDateTime currentTime = NepaliDateTime.now();
print(currentTime.toIso8601String()); // 2076-02-01T11:25:46.490980
```

### Date Converter
Converts dates from AD to BS and vice versa.
```dart
NepaliDateTime nepaliDate = DateConverter.toBS(DateTime(2019, 5, 14));
print(nepaliDate); // 2076-01-31 00:00:00.000

DateTime englishDate = DateConverter.toAD(nepaliDate);
print(englishDate); // 2019-05-14 00:00:00.000
```

### Nepali Date Formatter
Formats NepaliDateTime into desired format.
```dart
var date1 = NepaliDateFormatter("yyyy.MM.dd G 'at' HH:mm:ss");
var date2 = NepaliDateFormatter("EEE, MMM d, ''yy");
var date3 = NepaliDateFormatter("h:mm a");
var date4 = NepaliDateFormatter("hh 'o''clock' aa");
var date5 = NepaliDateFormatter("yyyy.MMMM.dd GGG hh:mm a");

print(date1.format(gorkhaEarthQuake)); // 2072.01.12 BS at 11:56:25
print(date2.format(gorkhaEarthQuake)); // Saturday, Bai 12, '72
print(date3.format(gorkhaEarthQuake)); // 11:56 am
print(date4.format(gorkhaEarthQuake)); // 11 o'clock AM
print(date5.format(gorkhaEarthQuake)); // 2072.Baishakh.12 Bikram Sambat 11:56 am
```

### Nepali Number
Converts English numbers into Nepali  number literals.
```dart
print(NepaliNumber.from(123456)); // १२३४५६
print(NepaliNumber.fromString('1,23,456')); // १,२३,४५६
```

Also includes a method to format number with Nepali style place value `commas`.
```dart
print(NepaliNumber.formatWithComma('123456')); // 1,23,456
print(NepaliNumber.formatWithComma('१२३४५६')); // १,२३,४५६
```