# Nepali Utilities for Dart

[![Pub](https://img.shields.io/pub/v/nepali_utils)](https://pub.dev/packages/nepali_utils) 
[![licence](https://img.shields.io/badge/Licence-MIT-orange.svg)](https://github.com/sarbagyastha/nepali_utils/blob/master/LICENSE) 
[![Top Language](https://img.shields.io/github/languages/top/sarbagyastha/nepali_utils?color=9cf)](https://github.com/sarbagyastha/nepali_utils)
[![effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://dart.dev/guides/language/effective-dart)

A pure dart package with collection of Nepali Utilities like Date converter, Date formatter, DateTime, Nepali Number, Nepali Unicode, Nepali Moments, land, weight & volume conversion and many more.

## Utility Classes
* **NepaliDateTime**
* **DateConversion**
* **NepaliDateFormat**
* **NepaliNumberFormat**
* **NepaliUnicode**, **Preeti** & **Devanagari**
* **NepaliMoment**
* **NepaliArea**, **NepaliWeight** & **NepaliVolume**
* many yet to come

Requires Dart 3.13 or later.

## Language Setup
Default language for Nepali Utility classes can be set as:
```dart
void main() {
  NepaliUtils.defaultLanguage = Language.nepali;
}
```

This is completely optional. Default language will be English if not set.
Every formatter also accepts a language directly, which takes precedence.

Use `withLanguage` to change the language only for some code, like intl's
`Intl.withLocale`. It also covers async work started inside the callback:

```dart
final text = NepaliUtils.withLanguage(Language.nepali, () {
  return NepaliDateFormat.yMMMd().format(date);
});

NepaliUtils.currentLanguage; // the override in effect, else defaultLanguage
```

`Language` converts to and from locale identifiers, which makes it easy to bridge
with `package:intl` or Flutter's `Locale`:

```dart
Language.parse('ne_NP');               // Language.nepali
Language.tryParse('fr');               // null
Language.fromLocale('fr');             // Language.english (fallback)
Language.nepali.localeName;            // 'ne_NP'
Language.nepali.toLanguageTag();       // 'ne-NP'

// Flutter
NepaliUtils.defaultLanguage =
    Language.fromLocale(Localizations.localeOf(context).toLanguageTag());
final locale = Locale(language.languageCode, language.countryCode);
```

### Nepali Date Time
`NepaliDateTime` works just like `dart:core`'s `DateTime`, except that its
fields are in Bikram Sambat. It implements `DateTime`, stores the exact instant,
and is presented either in local time, in UTC, or in Nepal Time (UTC+05:45).

```dart
final gorkhaEarthQuake = NepaliDateTime.parse('2072-01-12T11:56:25');
print(gorkhaEarthQuake.year); // 2072

final now = NepaliDateTime.now();          // local time, like DateTime.now()
final nowInNepal = NepaliDateTime.nepalNow(); // Nepal Time, on any device
final utc = NepaliDateTime.utc(2080, 1, 1);
final npt = NepaliDateTime.nepal(2080, 1, 1);

print(now.toIso8601String());        // 2083-08-06T11:25:46.490980
print(npt.toIso8601String());        // 2080-01-01T00:00:00.000+05:45
print(npt.toUtc());                  // 2079-12-30 18:15:00.000Z
print(gorkhaEarthQuake.mergeTime(10, 20, 30)); // 2072-01-12 10:20:30.000
print(gorkhaEarthQuake.copyWith(month: 2));    // 2072-02-12 11:56:25.000
```

Out-of-range values are normalised exactly like `DateTime`:

```dart
NepaliDateTime(2080, 1, 35); // 2080-02-04 (Baishakh 2080 has 31 days)
NepaliDateTime(2080, 13);    // 2081-01-01
NepaliDateTime(2080, 2, 0);  // 2080-01-31
```

Instant based operations accept any `DateTime`:

```dart
final bs = NepaliDateTime.utc(2080, 1, 1);
bs.isBefore(DateTime.now());
bs.difference(DateTime.utc(2023, 1, 1));
[DateTime.now(), bs].sort();
```

> `weekday` runs from `NepaliDateTime.sunday` (1) to `NepaliDateTime.saturday` (7).

Supported range: 1969 BS to 2250 BS.

### Date Conversion
Converts dates from AD to BS and vice versa. The instant and the time zone
are preserved.

```dart
final nt = DateTime(2019, 8, 3, 14, 30, 15).toNepaliDateTime();
print('In BS = $nt'); // 2076-04-18 14:30:15.000
final dt = nt.toDateTime();
print('In AD = $dt'); // 2019-08-03 14:30:15.000

// The Nepali date & time of an instant, regardless of the device time zone.
final inNepal = DateTime.now().toNepaliDateTime().toNepalTime();
```

### Nepali Date Formatter
Formats `NepaliDateTime` (or `DateTime`) into the desired format. `NepaliDateFormat` mirrors
`package:intl`'s `DateFormat`: the same pattern letters, the same skeleton constructors, constants
(`NepaliDateFormat.YEAR_MONTH_DAY`, ...) and `addPattern` / `add_*` composition.

Skeletons are laid out like intl's `en` locale for English and its `ne` locale for Nepali.
As in intl, English times use a narrow no-break space (`\u202f`) before AM/PM.

Constructor table for quick formatting (2076-04-18 21:17:56 NPT):

Constructor|English|Nepali
:----------|:------|:-----
d|18|१८
E|Sat|शनि
EEEE|Saturday|शनिबार
EEEEE|S|श
LLL|Shr|श्रा
LLLL|Shrawan|श्रावण
M|4|४
Md|4/18|०४-१८
MEd|Sat, 4/18|०४-१८, शनि
MMM|Shr|श्रा
MMMd|Shr 18|श्रा १८
MMMEd|Sat, Shr 18|श्रा १८, शनि
MMMM|Shrawan|श्रावण
MMMMd|Shrawan 18|श्रावण १८
MMMMEEEEd|Saturday, Shrawan 18|श्रावण १८, शनिबार
QQQ|Q2|दोस्रो त्रैमासिक
QQQQ|2nd quarter|दोस्रो त्रैमासिक
y|2076|२०७६
yM|4/2076|२०७६-०४
yMd|4/18/2076|२०७६-०४-१८
yMEd|Sat, 4/18/2076|२०७६-०४-१८, शनि
yMMM|Shr 2076|२०७६ श्रा
yMMMd|Shr 18, 2076|२०७६ श्रा १८
yMMMEd|Sat, Shr 18, 2076|२०७६ श्रा १८, शनि
yMMMM|Shrawan 2076|२०७६ श्रावण
yMMMMd|Shrawan 18, 2076|२०७६ श्रावण १८
yMMMMEEEEd|Saturday, Shrawan 18, 2076|२०७६ श्रावण १८, शनिबार
yQQQ|Q2 2076|२०७६ दोस्रो त्रैमासिक
yQQQQ|2nd quarter 2076|२०७६ दोस्रो त्रैमासिक
H|21|२१
Hm|21:17|२१:१७
Hms|21:17:56|२१:१७:५६
j|9 PM|२१
jm|9:17 PM|२१:१७
jms|9:17:56 PM|२१:१७:५६
jmv|9:17 PM NPT|२१:१७ NPT
jmz|9:17 PM NPT|२१:१७ NPT
jv|9 PM NPT|२१h NPT
jz|9 PM NPT|२१h NPT
m|17|१७
ms|17:56|१७:५६
s|56|५६

#### Example:
```dart
var date1 = NepaliDateFormat.MEd();
var date2 = NepaliDateFormat.MMMMEEEEd();
var date3 = NepaliDateFormat.jms();
var date4 = NepaliDateFormat.yMd().add_jm();

print(date1.format(gorkhaEarthQuake)); // Sat, 1/12
print(date2.format(gorkhaEarthQuake)); // Saturday, Baishakh 12
print(date3.format(gorkhaEarthQuake)); // 11:56:25 AM
print(date4.format(gorkhaEarthQuake)); // 1/12/2072 11:56 AM
```

Formats can also be specified with a pattern string.

Symbol|Meaning|Presentation|Example (en / np)
:-----|:------|:-----------|:------
G|era designator|(Text)|BS / बि सं
GGGG|era designator|(Text)|Bikram Sambat / बिक्रम संबत
y|year|(Number)|1996 / १९९६
yy|year|(Number)|96 / ९६
yyyy|year|(Number)|1996 / १९९६
Q|quarter|(Number)|3 / ३
QQ|quarter|(Number)|03 / ०३
QQQ|quarter|(Text)|Q3 / तेस्रो त्रैमासिक
QQQQ|quarter|(Text)|3rd quarter / तेस्रो त्रैमासिक
M|month in year|(Text & Number)|8 / ८
MM|month in year|(Text & Number)|08 / ०८
MMM|month in year|(Text & Number)|Marg / मं
MMMM|month in year|(Text & Number)|Mangsir / मंसिर
MMMMM|month in year|(Text & Number)|M / मं
MMMMMM|colloquial month name|(Text)|Marga / मार्ग
L|standalone month|(Text & Number)|same as M
d|day in month|(Number)|9 / ९
dd|day in month|(Number)|09 / ०९
D|day in year|(Number)|189 / १८९
E|day of week|(Text)|Mon / सोम
EEEE|day of week|(Text)|Monday / सोमबार
EEEEE|day of week|(Text)|M / सो
c|standalone day of week|(Text)|(ccc) Mon, (cccc) Monday
a|am/pm marker|(Text)|PM / बेलुकी
h|hour in am/pm (1~12)|(Number)|2 / २
hh|hour in am/pm (1~12)|(Number)|02 / ०२
H|hour in day (0~23)|(Number)|14 / १४
K|hour in am/pm (0~11)|(Number)|0 / ०
k|hour in day (1~24)|(Number)|24 / २४
m|minute in hour|(Number)|3 / ३
mm|minute in hour|(Number)|03 / ०३
s|second in minute|(Number)|5 / ५
ss|second in minute|(Number)|05 / ०५
S|fractional second|(Number)|978 / ९७८
z, v|time zone|(Text)|NPT, (zzzz) Nepal Time / नेपाल समय
Z|time zone offset|(Text)|+0545, (ZZZZ) GMT+05:45
'|escape for text|(Delimiter)|'Date='
''|single quote|(Literal)|'o''clock'

In Nepali, `a` is the time of day (बिहान, मध्यान्न, दिउसो, साँझ, बेलुकी) instead of AM/PM.

#### Example:
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

**Note:** Always wrap pattern string in double quote (`"`).

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

### Nepali Unicode
`NepaliUnicode` converts romanized text into Nepali Unicode (Devanagari), and back.
```dart
const unicode = NepaliUnicode();
unicode.convert("sayau' thu''gaa fUlakaa haamii, euTai maalaa nepaalii");
unicode.convert('saarwabhauma bhai failiekaa, mecii-mahaakaalii');
// सयौं थुँगा फूलका हामी, एउटै माला नेपाली
// सार्वभौम भै फैलिएका, मेची-महाकाली

unicode.convert('mero naam {Sarbagya} ho'); // मेरो नाम Sarbagya हो
unicode.toRoman('नेपाली');                  // nepaalii
```

Pick the mapping you are used to with `style`:

| Style | Example | |
|---|---|---|
| `.classic` (default) | `nepaala` → नेपाल | The rules of earlier versions: a consonant keeps its halant until a vowel or a space follows. `'` ं, `''` ँ, `:` ः, `.` । |
| `.google` | `nepaal` → नेपाल | Google Input Tools style: words end with their inherent vowel, `~` forces a halant (`bhagawaan~` → भगवान्). `M` ं, `^` ँ, `H` ः, `.` । |
| `.mppRomanized` | `nepal` → नेपाल | Madan Puraskar Pustakalaya's *Romanized* keyboard: one key, one character. |
| `.mppTraditional` | `g]kfn` → नेपाल | Madan Puraskar Pustakalaya's *Traditional* keyboard (Preeti key positions). |

```dart
const google = NepaliUnicode(style: .google);
google.convert('nepaal ko maayaa'); // नेपाल को माया
google.toRoman('क्षत्रिय');          // kshatriy
```

For the phonetic styles, text inside `{}` is kept as it is, and Devanagari already in the text is kept and joined with romanized letters typed after it. To convert a text field as the user types, call `convertLive` on each change and put the result back:
```dart
google.convertLive('k');    // क्
google.convertLive('क्a');  // क
google.convertLive('कm');   // कम्
google.convertLive('कम् '); // कम
```

`NepaliUnicode` is a `Converter`, so it also works on streams: `stream.transform(const NepaliUnicode())`. Pass `nepaliDigits: false` to keep ASCII digits.

#### Preeti
Converts text written in the legacy Preeti font to Unicode, and back:
```dart
Preeti.toUnicode('g]kfn');      // नेपाल
Preeti.toUnicode('sfof{no');    // कार्यालय
Preeti.fromUnicode('हिमाल');    // lxdfn
```

#### Devanagari helpers
```dart
Devanagari.isDevanagari('नमस्ते, संसार!'); // true
Devanagari.containsDevanagari('Hi नेपाल'); // true
Devanagari.toNepaliDigits('2081');        // २०८१
Devanagari.toEnglishDigits('२०८१');       // 2081
Devanagari.aksharas('संस्कृति');           // [सं, स्कृ, ति]
```

### Nepali Moment
`NepaliMoment` describes dates relative to now, like moment.js and `Intl.RelativeTimeFormat`. It accepts both `DateTime` and `NepaliDateTime`.
```dart
final moment = NepaliMoment(); // or NepaliMoment(language: .nepali)
final now = DateTime(2024, 1, 10, 8);

print(moment.format(DateTime(2024, 1, 7), reference: now)); // 3 days ago
print(moment.format(DateTime(2024, 1, 10, 11), reference: now)); // in 3 hours
print(NepaliMoment(language: .nepali).format(DateTime(2024, 1, 7), reference: now));
// ३ दिन पहिले

// Abbreviated units, and weeks instead of days.
print(NepaliMoment(style: .short).format(DateTime(2024, 1, 10, 5), reference: now)); // 3 hr. ago
print(NepaliMoment(useWeeks: true).format(DateTime(2023, 12, 20), reference: now)); // 3 weeks ago

// Durations and units.
print(moment.formatDuration(const Duration(minutes: 5))); // 5 minutes
print(moment.formatUnit(-1, .day)); // 1 day ago
print(moment.formatUnit(-1, .day, numeric: false)); // yesterday

// Calendar time.
print(moment.calendar(DateTime(2024, 1, 9, 21, 4), reference: now)); // Yesterday at 9:04 PM
print(NepaliMoment(language: .nepali).calendar(DateTime(2024, 1, 7, 21, 4), reference: now));
// गएको आइतबार, २१:०४

// Shorthands; the reference defaults to now.
print(NepaliMoment.fromBS(NepaliDateTime.parse('2076-02-32T18:25:14'),
    referenceDate: NepaliDateTime.parse('2076-02-32T18:34:14'))); // 9 minutes ago
print(NepaliMoment.fromAD(DateTime.parse('2019-06-02T18:22:14'),
    referenceDate: DateTime.parse('2019-06-15T18:34:14'))); // 13 days ago
```

### Nepali Measurement
`NepaliArea`, `NepaliWeight` and `NepaliVolume` convert between traditional Nepali units and metric units.

| Quantity | Units |
|---|---|
| Land (hills) | 1 ropani = 16 aana = 64 paisa = 256 daam = 5476 sq. ft |
| Land (Terai) | 1 bigha = 20 kattha = 400 dhur = 72900 sq. ft |
| Gold | 1 tola = 100 lal = 11.6638038 g |
| Market weight | 1 dharni = 3 ser = 12 pau = 48 chhatak = 2.3934096 kg |
| Grain | 1 muri = 20 pathi = 160 mana = 1600 muthi; 1 pathi = 4.54596 L |

```dart
final plot = NepaliArea.ropani(2, aana: 3, paisa: 1);
print(plot.to(.squareFoot)); // 12064.3125
print(plot.ropaniParts); // (aana: 3, daam: 0.0, paisa: 1, ropani: 2)
print(plot.format(.ropani)); // 2-3-1-0
print(plot.format(.ropani, long: true, language: .nepali)); // २ रोपनी ३ आना १ पैसा
print(plot.format(.bigha)); // 0-3-6.2

print(NepaliArea(1000, .squareMeter).format(.ropani)); // 1-15-1-3.21
print(NepaliArea.bigha(1, kattha: 5).to(.ropani)); // 16.64...
print(NepaliArea.parse('२-३-१-०', .ropani) == plot); // true

final gold = NepaliWeight.tola(2, lal: 50);
print(gold.to(.gram)); // 29.1595095
print(NepaliWeight(5, .kilogram).format(.dharni, long: true)); // 2 dharni 1 pau 0.28 chhatak

final rice = NepaliVolume.muri(1, pathi: 5, mana: 4);
print(rice.to(.liter)); // 115.92198
print(rice.format(long: true)); // 1 muri 5 pathi 4 mana
```

## Example
Find more detailed example [here](https://github.com/sarbagyastha/nepali_utils/tree/master/example/main.dart).

## Contribute
If you want to contribute to the package, please feel free to submit issues or PR at [Github Repo](https://github.com/sarbagyastha/nepali_utils).

Also show some love by staring the repo :star:, if you like the package.

## License
```
Copyright (c) 2020 Sarbagya Dhaubanjar

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