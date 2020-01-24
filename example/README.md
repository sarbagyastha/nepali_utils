# Nepali Utilities Example

### Nepali Date Time
The class is similar to `dart:core`'s [DateTime]() class, except that, this works with Bikram Sambat.
```dart
NepaliDateTime gorkhaEarthQuake = NepaliDateTime.parse('2072-01-12T11:56:25');
print(gorkhaEarthQuake.year); // 2072

NepaliDateTime currentTime = NepaliDateTime.now();
print(currentTime.toIso8601String()); // 2076-02-01T11:25:46.490980
```

### Date Conversion
Converts dates from AD to BS and vice versa.

```dart
NepaliDateTime nt = DateTime(2019, 8, 03, 14, 30, 15).toNepaliDateTime();
print('In BS = $nt'); //2076-04-18 14:30:15.000
DateTime dt = nt.toDateTime(); //2019-08-03 14:30:15.000
print('In AD = $dt');
```

### Nepali Date Formatter
Formats NepaliDateTime into desired format.

```dart
var date1 = NepaliDateFormat.MEd();
var date2 = NepaliDateFormat.MMMMEEEEd();
var date3 = NepaliDateFormat.jms();

print(date1.format(gorkhaEarthQuake)); // Sat, 1/12 
print(date2.format(gorkhaEarthQuake)); // Saturday, Baisakh 18
print(date3.format(gorkhaEarthQuake)); // 11:56:00 AM
```

```dart
var date1 = NepaliDateFormat("yyyy.MM.dd G 'at' HH:mm:ss");
var date2 = NepaliDateFormat("EEE, MMM d, ''yy");
var date3 = NepaliDateFormat("h:mm a");
var date4 = NepaliDateFormat("hh 'o''clock' aa");
var date5 = NepaliDateFormat("yyyy.MMMM.dd GGG hh:mm a");

print(date1.format(gorkhaEarthQuake)); // 2072.01.12 BS at 11:56:25
print(date2.format(gorkhaEarthQuake)); // Saturday, Bai 12, '72
print(date3.format(gorkhaEarthQuake)); // 11:56 am
print(date4.format(gorkhaEarthQuake)); // 11 o'clock AM
print(date5.format(gorkhaEarthQuake)); // 2072.Baishakh.12 Bikram Sambat 11:56 am
```

### Nepali Number
Converts English numbers into Nepali  number literals.
```dart
var currencyFormat = NepaliNumberFormat(
    symbol: 'Rs.',
);
var commaSeparated = NepaliNumberFormat(
    decimalDigits: 2,
);
var inWords = NepaliNumberFormat(
    inWords: true,
    language: Language.NEPALI,
);
var currencyInWords = NepaliNumberFormat(
    inWords: true,
    language: Language.NEPALI,
    isMonetory: true,
);

print('123456 -> ${currencyFormat.format(123456)}');
print('123456789.6548 -> ${commaSeparated.format(123456789.6548)}');
print('123456 -> ${inWords.format(123456)}');
print('123456789.6548 -> ${currencyInWords.format(123456789.6548)}');
```