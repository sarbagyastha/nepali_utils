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
print(date2.format(gorkhaEarthQuake)); // Saturday, Baishakh 12
print(date3.format(gorkhaEarthQuake)); // 11:56:25 AM
```

```dart
var date1 = NepaliDateFormat("yyyy.MM.dd G 'at' HH:mm:ss");
var date2 = NepaliDateFormat("EEE, MMM d, ''yy");
var date3 = NepaliDateFormat("h:mm a");
var date4 = NepaliDateFormat("hh 'o''clock' a");
var date5 = NepaliDateFormat("yyyy.MMMM.dd GGGG hh:mm a");

print(date1.format(gorkhaEarthQuake)); // 2072.01.12 BS at 11:56:25
print(date2.format(gorkhaEarthQuake)); // Sat, Bai 12, '72
print(date3.format(gorkhaEarthQuake)); // 11:56 AM
print(date4.format(gorkhaEarthQuake)); // 11 o'clock AM
print(date5.format(gorkhaEarthQuake)); // 2072.Baishakh.12 Bikram Sambat 11:56 AM
```

### Nepali Number
`NepaliNumberFormat` has the same API as `package:intl`'s `NumberFormat`. It groups numbers in lakhs and crores and uses Devanagari digits in Nepali.
```dart
final decimal = NepaliNumberFormat.decimalPattern();
print(decimal.format(123456789.6548)); // 12,34,56,789.655
print(decimal.format(-1234.5)); // -1,234.5

final currency = NepaliNumberFormat.simpleCurrency(language: .nepali);
print(currency.format(123456)); // रु. १,२३,४५६.००
print(NepaliNumberFormat.currency().format(123456)); // NPR 1,23,456.00

print(NepaliNumberFormat.percentPattern().format(0.1234)); // 12%
print(NepaliNumberFormat.compact().format(1234567)); // 12.3L
print(NepaliNumberFormat.compactLong(language: .nepali).format(1234567)); // १२.३ लाख

// International grouping, or any other intl pattern.
print(NepaliNumberFormat('#,##0.00').format(1234567)); // 1,234,567.00

// Spell numbers out.
print(NepaliNumberFormat.words().format(123456));
// one lakh twenty-three thousand four hundred fifty-six
print(NepaliNumberFormat.words(language: .nepali, currency: true).format(123456789.6548));
// बाह्र करोड चौंतीस लाख छपन्न हजार सात सय उनान्नब्बे रुपैयाँ पैंसट्ठी पैसा
print(NepaliNumberFormat.words(useDigits: true).format(123456));
// 1 lakh 23 thousand 4 hundred 56

// Parse ASCII or Devanagari digits.
print(decimal.parse('१२,३४,५६७.८९')); // 1234567.89
print(NepaliNumberFormat.compact().parse('1.23L')); // 123000

// Formatters are immutable; copyWith replaces intl's setters.
final noGrouping = decimal.copyWith(groupSeparator: '', maximumFractionDigits: 2);
print(noGrouping.format(12345.678)); // 12345.68
```
