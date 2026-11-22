---
title: Phone numbers
description: Validate, parse, format and find Nepali mobile and landline phone numbers with NepaliPhoneNumber, including the operator and the district.
---

`NepaliPhoneNumber` validates, parses, formats and finds Nepali **mobile** and **landline** numbers. It tells you the mobile operator (Nepal Telecom, Ncell, Smart Telecom, UTL), or the landline's area code and district.

```dart
final phone = NepaliPhoneNumber.parse('+977 ९८४१२३४५६७');

phone.type;                          // PhoneType.mobile
phone.operator;                      // MobileOperator.nepalTelecom
phone.operator?.label();             // Nepal Telecom
phone.format();                      // 984-1234567
phone.format(style: .international); // +977 984-1234567
phone.format(language: .nepali);     // ९८४-१२३४५६७
phone.e164;                          // +9779841234567
```

## What is accepted

- ASCII or Devanagari digits, or a mix of the two.
- An optional country code: `+977`, `00977` or `977`. After the country code, the leading `0` of a landline can be written or left out.
- Spaces, `-`, `.`, `(` and `)` anywhere between the digits.

```dart
NepaliPhoneNumber.parse('977 9801234567').format();      // 980-1234567
NepaliPhoneNumber.parse('(+977) 980.123.4567').format(); // 980-1234567
NepaliPhoneNumber.parse('+977 1 4412345').format();      // 01-4412345
NepaliPhoneNumber.parse('00977-1-4412345').format();     // 01-4412345
NepaliPhoneNumber.parse('+977-01-4412345').format();     // 01-4412345
```

## Number types

| Type | Shape | Example |
|---|---|---|
| `PhoneType.mobile` | 10 digits; the first three are a prefix allocated to an operator | `984-1234567` |
| `PhoneType.landline`, Kathmandu Valley | `01` + 7 digits | `01-4412345` |
| `PhoneType.landline`, elsewhere | `0` + 2-digit area code + 6 digits | `061-523456` |

For a landline, the digit right after the area code is the operator code, and must be `4`, `5` or `6`. So `01-2412345` and `061-123456` aren't valid.

### Mobile operators

The prefixes come from the Nepal Telecommunications Authority's National Numbering Allocation Plan, 2079:

| `MobileOperator` | Prefixes | `label()` / `label(.nepali)` |
|---|---|---|
| `nepalTelecom` | 974, 975, 976, 984, 985, 986 | Nepal Telecom / नेपाल टेलिकम |
| `ncell` | 970, 980, 981, 982 | Ncell / एनसेल |
| `smart` | 961, 962, 988 | Smart Telecom / स्मार्ट टेलिकम |
| `utl` | 972 | UTL / युटिएल |

```dart
NepaliPhoneNumber.parse('9801234567').operator?.label(); // Ncell
MobileOperator.forPrefix('984');                          // MobileOperator.nepalTelecom
MobileOperator.forPrefix('990');                          // null
MobileOperator.nepalTelecom.prefixes; // [974, 975, 976, 984, 985, 986]
```

A 10-digit number whose prefix isn't allocated to any operator, such as `990…`, isn't valid.

### Landline area codes

```dart
final office = NepaliPhoneNumber.parse('061-523456');

office.type;               // PhoneType.landline
office.areaCode;           // 061
office.areaName();         // Kaski
office.areaName(.nepali);  // कास्की
office.operator;           // null

NepaliPhoneNumber.parse('01-4412345').areaName(); // Kathmandu Valley
NepaliPhoneNumber.parse('021-523456').areaName(); // Morang
```

`areaCode` is `null` for mobile numbers. `areaName` returns `null` for mobile numbers and for area codes that aren't in its list. Some codes cover more than one district, for example `026`, which is Dhankuta and Terhathum.

## Validating

```dart
NepaliPhoneNumber.isValid('9801234567');           // true
NepaliPhoneNumber.isValid('9901234567');           // false
NepaliPhoneNumber.isMobile('01-4412345');          // false
NepaliPhoneNumber.isLandline('01-4412345');        // true
NepaliPhoneNumber.isValid('9801234567', type: .landline); // false

NepaliPhoneNumber.tryParse('9901234567'); // null
NepaliPhoneNumber.parse('12345');         // throws FormatException: Invalid phone number
```

In a Flutter form:

```dart
TextFormField(
  keyboardType: TextInputType.phone,
  validator: (value) => NepaliPhoneNumber.isMobile(value ?? '')
      ? null
      : 'Enter a valid mobile number',
);
```

## Formatting

`format({PhoneFormat style = .national, Language? language})`:

| `PhoneFormat` | Mobile | Kathmandu landline | Other landline |
|---|---|---|---|
| `.national` | `984-1234567` | `01-4412345` | `061-523456` |
| `.international` | `+977 984-1234567` | `+977 1-4412345` | `+977 61-523456` |
| `.e164` | `+9779841234567` | `+97714412345` | `+97761523456` |

With `language: .nepali`, digits are Devanagari:

```dart
phone.format(language: .nepali);                          // ९८४-१२३४५६७
phone.format(style: .international, language: .nepali);   // +९७७ ९८४-१२३४५६७
```

`language` defaults to [`NepaliUtils.currentLanguage`](/getting-started/language/). `toString()` always uses English national format.

Other getters:

```dart
phone.nationalNumber; // 9841234567 (as dialled in Nepal, no separators)
phone.e164;           // +9779841234567 (same as format(style: .e164))
```

## Equality

Two numbers are equal when their `nationalNumber` is the same, however they were written:

```dart
NepaliPhoneNumber.parse('+977-9841234567') == NepaliPhoneNumber.parse('९८४१२३४५६७'); // true
```

Store `e164` or `nationalNumber` in your database. Don't store the text as the user typed it.

## Finding numbers in text

`findAll` returns every number in a text, in order, as `PhoneNumberMatch` objects:

```dart
for (final match in NepaliPhoneNumber.findAll('Call 9841234567 or ०१-४४१२३४५.')) {
  print('${match.text} at ${match.start}-${match.end}: ${match.number.e164}');
}
// 9841234567 at 5-15: +9779841234567
// ०१-४४१२३४५ at 19-29: +97714412345
```

| `PhoneNumberMatch` | Meaning |
|---|---|
| `start`, `end` | position of the number in the text |
| `text` | the number exactly as written |
| `number` | the parsed `NepaliPhoneNumber` |

Pass `type` to find only mobile or only landline numbers:

```dart
NepaliPhoneNumber.findAll('Call 9841234567 or 01-4412345.', type: .mobile)
    .map((match) => match.number.format())
    .toList(); // [984-1234567]
```

A number isn't matched if it comes right after a digit, a Latin letter or `+`, or right before a digit. Devanagari text may follow it directly:

```dart
NepaliPhoneNumber.findAll('ID9841234567 and 98412345678').toList(); // []
NepaliPhoneNumber.findAll('९८४१२३४५६७मा फोन गर्नुहोस्')
    .map((match) => match.text)
    .toList(); // [९८४१२३४५६७]
```

### Replacing numbers

`replaceAll` replaces every match with the result of a callback. This is useful for masking numbers or making them consistent:

```dart
NepaliPhoneNumber.replaceAll(
  'Call 9841234567',
  (match) => '${match.text.substring(0, 3)}*******',
); // Call 984*******

NepaliPhoneNumber.replaceAll(
  'Call 9841234567 or 014412345',
  (match) => match.number.format(style: .international),
); // Call +977 984-1234567 or +977 1-4412345
```

## Gotchas

:::caution
- The list of operator prefixes follows the NTA's 2079 allocation plan. A prefix allocated after that isn't recognised until the package is updated, so numbers with it are rejected as invalid.
- Only Nepali numbers are accepted. A number with another country code, such as `+91 …`, isn't valid.
:::

## See also

- [`NepaliPhoneNumber` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliPhoneNumber-class.html)
- [`PhoneNumberMatch`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/PhoneNumberMatch-class.html), [`MobileOperator`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/MobileOperator.html), [`PhoneType`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/PhoneType.html), [`PhoneFormat`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/PhoneFormat.html)
