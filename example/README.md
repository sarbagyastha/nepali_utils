# Nepali Utils web app

**[Open Nepali Utils →](https://nepali-utils.sarbagyastha.com.np/tool/)**

This example is a Flutter web app built on `nepali_utils`, made for everyday use. It uses every part of the package, and its UI is built with Material 3 Expressive from the [`material_ui`](https://pub.dev/packages/material_ui) package.

| Tool | What it does | APIs used |
| --- | --- | --- |
| Today | Today's date in BS, a live Nepal Time clock, a month calendar with AD dates, and countdowns | `NepaliDateTime.nepalNow`, `NepaliDateFormat`, `NepaliMoment.formatUnit` |
| Dates | BS ⇄ AD converter with a BS date picker, ready-made formats, a pattern playground, and an age / days-between calculator | `toNepaliDateTime`, `toDateTime`, a `CalendarDelegate` built on `NepaliDateTime`, `NepaliMoment` |
| Money | Lakh/crore formatting, amounts in words for cheques (English and Nepali), compact forms, and a 13% VAT calculator | `NepaliNumberFormat` (`decimalPattern`, `currency`, `simpleCurrency`, `compact*`, `words`, `percentPattern`, `parse`) |
| Type | Romanized and keyboard typing to Unicode (also live, in place), Preeti ⇄ Unicode, and Devanagari digits and syllables | `NepaliUnicode`, `Preeti`, `Devanagari` |
| Units | Land (ropani/bigha/metric), gold and weight with a price calculator, and grain volume | `NepaliArea`, `NepaliWeight`, `NepaliVolume` |
| Phone | Validates and formats a number, finds, tidies and hides numbers in pasted text, and lists operator prefixes | `NepaliPhoneNumber`, `MobileOperator`, `PhoneNumberMatch` |

The EN/ने button switches the whole app, including every formatter, between English and Nepali. Links can open a specific tool: `?tool=money&lang=ne&theme=dark`.

## Run it locally

```sh
cd example
flutter pub get
flutter run -d chrome
```

Run the tests with `flutter test`.

---

## Using the package

### Nepali Date Time
The class is similar to `dart:core`'s [DateTime]() class, except that, this works with Bikram Sambat.
```dart
NepaliDateTime constitutionDay = NepaliDateTime.parse('2072-06-03T17:00:00');
print(constitutionDay.year); // 2072

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

print(date1.format(constitutionDay)); // Sun, 6/3
print(date2.format(constitutionDay)); // Sunday, Ashwin 3
print(date3.format(constitutionDay)); // 5:00:00 PM
```

```dart
var date1 = NepaliDateFormat("yyyy.MM.dd G 'at' HH:mm:ss");
var date2 = NepaliDateFormat("EEE, MMM d, ''yy");
var date3 = NepaliDateFormat("h:mm a");
var date4 = NepaliDateFormat("hh 'o''clock' a");
var date5 = NepaliDateFormat("yyyy.MMMM.dd GGGG hh:mm a");

print(date1.format(constitutionDay)); // 2072.06.03 BS at 17:00:00
print(date2.format(constitutionDay)); // Sun, Ash 3, '72
print(date3.format(constitutionDay)); // 5:00 PM
print(date4.format(constitutionDay)); // 05 o'clock PM
print(date5.format(constitutionDay)); // 2072.Ashwin.03 Bikram Sambat 05:00 PM
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
