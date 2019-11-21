# Nepali Utilities for Dart

[![Pub](https://img.shields.io/pub/v/nepali_utils)](https://pub.dev/packages/nepali_utils) 
[![licence](https://img.shields.io/badge/Licence-MIT-orange.svg)](https://github.com/sarbagyastha/nepali_utils/blob/master/LICENSE) 
[![Top Language](https://img.shields.io/github/languages/top/sarbagyastha/nepali_utils?color=9cf)](https://github.com/sarbagyastha/nepali_utils)
[![effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://dart.dev/guides/language/effective-dart)

A pure dart package with collection of Nepali Utilities like Date converter, Date formatter, DateTime, Nepali Number, Nepali Unicode, Nepali Moments and many more.

## Package Includes
* **NepaliDateTime**
* **DateConversion**
* **NepaliDateFormat**
* **NepaliNumberFormat**
* **NepaliUnicode**
* **NepaliMoment**
* many yet to come

### Nepali Date Time
The class is similar to `dart:core`'s [DateTime]() class, except that, this works with Bikram Sambat.
```dart
NepaliDateTime gorkhaEarthQuake = NepaliDateTime.parse('2072-01-12T11:56:25');
print(gorkhaEarthQuake.year); // 2072

NepaliDateTime currentTime = NepaliDateTime.now();
print(currentTime.toIso8601String()); //2076-02-01T11:25:46.490980
print(gorkhaEarthQuake.mergeTime(10, 20, 30));
// 2072-01-12 10:20:30.000
```

### Date Conversion
Converts dates from AD to BS and vice versa.
**Note** Since v2.x.x DateConverter has been integrated into NepaliDateTime class.

```dart
NepaliDateTime nt =
      NepaliDateTime.fromDateTime(DateTime(2019, 8, 03, 14, 30, 15));
print('In BS = $nt'); //2076-04-18 14:30:15.000
DateTime dt = nt.toDateTime(); //2019-08-03 14:30:15.000
print('In AD = $dt');
```

### Nepali Date Formatter
Formats NepaliDateTime into desired format.
Formats NepaliDateTime into desired format.

Constructor table for quick formatting:

Constructor|Result
:----------|:----:
d|18
E|Sat
EEEE|Saturday
LLL|Shr
LLLL|Shrawan
M|4
Md|4/18
MEd|Sat, 4/18
MMM|Shr
MMMd|Shr 18
MMMEd|Saturday, Shr 18
MMMM|Shrawan
MMMMd|Shrawan 18
MMMMEEEEd|Saturday, Shrawan 18
QQQ|Q2
QQQQ|2nd quarter
y|2076
yM|2076/04
yMd|2076/04/18
yMEd|Sat, 2076/04/18
yMMM|Shr 2076
yMMMd|Shr 18, 2076
yMMMEd|Sat, Shr 18, 2076
yMMMMM|Shrawan 2076
yMMMMd|Shrawan 18, 2076
yMMMMEEEEd|Saturday, Shrawan 18, 2076
yQQQ|Q2 2076
yQQQQ|2nd quarter 2076
H|21
Hm|21:04
Hms|21:17:56
j|9 PM
jm|9:17 PM
jms|9:17:56 PM
m|9
ms|9:17
s|56

#### Example:
```dart
var date1 = NepaliDateFormat.MEd();
var date2 = NepaliDateFormat.MMMMEEEEd();
var date3 = NepaliDateFormat.jms();

print(date1.format(gorkhaEarthQuake)); // Sat, 1/12 
print(date2.format(gorkhaEarthQuake)); // Saturday, Baisakh 18
print(date3.format(gorkhaEarthQuake)); // 11:56:00 AM
```

Formats can also be specified with a pattern string.

Symbol|Meaning|Presentation|Example (en / np)
:-----|:------|:-----------|:------
G|era designator|(Text)|BS / बि सं
GG|era designator|(Text)|B.S.  / बि.सं.
GGG|era designator|(Text)|Bikram Sambat  / बिक्रम संबत
y|year|(Number)|1996 / १९९६
yy|year|(Number)|96 / ९६
yyyy|year|(Number)|1996 / १९९६
Q|quarter|(Text)|3
QQ|quarter|(Text)|03
QQQ|quarter|(Text)|Q3
QQQQ|quarter|(Text)|3rd quarter
M|month in year|(Text & Number)|1 / १
MM|month in year|(Text & Number)|01 / ०१
MMM|month in year|(Text & Number)|Bai / बै
MMMM|month in year|(Text & Number)|Baishakh / बैशाख
d|day in month|(Number)|9 / ९
dd|day in month|(Number)|09 / ०९
E|day of week|(Text)|M / सो
EE|day of week|(Text)|Mon / सोम
EEE|day of week|(Text)|Monday / सोमबार
a|am/pm marker|(Text)|pm / बेलुकी
aa|am/pm marker|(Text)|PM / बेलुकी
h|hour in am/pm(1~12)|(Number)|2 / २
hh|hour in am/pm(1~12)|(Number)|02 / ०२
H|hour in day (0~23)|(Number)|14 / १४
HH|hour in day (0~23)|(Number)|14 / १४
m|minute in hour|(Number)|3 / ३
mm|minute in hour|(Number)|03 / ०३  
s|second in minute|(Number)|55 / ५५
s|second in minute|(Number)|55 / ५५
S|fractional second|(Number)|978 / ९७८
'|escape for text|(Delimiter)|'Date='
''|single quote|(Literal)|'o''clock'

#### Example:
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

**Note:** Always wrap pattern string in double quote (`"`).

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
    decimalDigits: 2,
);
print('123456 -> ${currencyFormat.format(123456)}');
// 123456 -> 1,23,456

print('123456789.6548 -> ${commaSeparated.format(123456789.6548)}');
// 123456789.6548 -> 12,34,56,789.65

print('123456 -> ${inWords.format(123456)}');
// 123456 -> 1 lakh 23 thousand 4 hundred 56

print('123456789.6548 -> ${currencyInWords.format(123456789.6548)}');
// 123456789.6548 -> १२ करोड ३४ लाख ५६ हजार ७ सय ८९ रुपैया ६५ पैसा
```

### Nepali Unicode
Converts English literal (Roman Literals) into Nepali Unicode.
```dart
print(NepaliUnicode.convert("sayau' thu''gaa fUlakaa haamii, euTai maalaa nepaalii"));
print(NepaliUnicode.convert("saarwabhauma bhai failiekaa, mecii-mahaakaalii\n"));

// स​यौं थुँगा फूलका हामी, एउटै माला नेपाली
// सार्वभौम भै फैलिएका, मेची-महाकाली
```

If live conversion is required *i.e. conversion as you type*, then set `live: true`.
```dart
NepaliUnicode.convert(textFromTextField, live: true);
```

### Nepali Moment
Generates a fuzzy timestamp using dates provided.
```dart
print(NepaliMoment.fromBS(NepaliDateTime.parse('2076-03-22T08:41:14')));
// २२ दिन पछि
```
Here, the current DateTime is 2076-02-32 19:09:25 *i.e. reference date*

```dart
print(NepaliMoment.fromBS(NepaliDateTime.parse('2076-02-32T18:25:14'),
      referenceDate: NepaliDateTime.parse('2076-02-32T18:34:14')));
// ९ मिनेट पहिले

print(NepaliMoment.fromAD(DateTime.parse('2019-06-02T18:22:14'),
      referenceDate: DateTime.parse('2019-06-15T18:34:14')));
// १३ दिन पहिले
```


## Example
Find more detailed example [here](https://github.com/sarbagyastha/nepali_utils/tree/master/example/main.dart).

## Contribute
If you want to contribute to the package, please feel free to submit issues or PR at [Github Repo](https://github.com/sarbagyastha/nepali_utils).

Also show some love by staring the repo :star:, if you like the package.

## License
```
Copyright (c) 2019 Sarbagya Dhaubanjar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```