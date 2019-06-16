# Nepali Utilities for Dart

[![Pub](https://img.shields.io/badge/pub-v1.1.0+2-green.svg)](https://pub.dev/packages/nepali_utils) [![licence](https://img.shields.io/badge/Licence-MIT-orange.svg)](https://github.com/sarbagyastha/nepali_utils/blob/master/LICENSE) 

A pure dart package with collection of Nepali Utilities like Date converter, Date formatter, DateTime, Nepali Numbers, Nepali Unicode, Nepali Moments and many more.

## Package Includes
* **NepaliDateTime**
* **DateConverter**
* **NepaliDateFormatter**
* **NepaliNumber**
* **NepaliUnicode** *since v1.1.0*
* **NepaliMoment** *since v1.1.0*
* many yet to come

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

**Note:** Always wrap pattern string in double quote (`"`).

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