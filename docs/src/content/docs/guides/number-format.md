---
title: Number formatting
description: Format and parse numbers the Nepali way with NepaliNumberFormat. Covers lakh/crore grouping, currency, percent, compact forms, numbers in words and Devanagari digits.
---

`NepaliNumberFormat` formats and parses numbers the Nepali way. Its API matches `NumberFormat` from `package:intl`.

- Digits are grouped in thousands, lakhs and crores: `12,34,56,789`.
- In Nepali, digits are Devanagari: `१२,३४,५६,७८९`.
- It can also spell numbers out in words, and compact formats use lakh, crore, arab and kharab.

```dart
final decimal = NepaliNumberFormat.decimalPattern();

decimal.format(123456789.6548); // 12,34,56,789.655
decimal.format(-1234.5);        // -1,234.5
NepaliNumberFormat.decimalPattern(.nepali).format(1234567.891); // १२,३४,५६७.८९१
```

## Ready-made formats

| Constructor | `1234567.891` / example | Notes |
|---|---|---|
| `decimalPattern()` | `12,34,567.891` | up to 3 fraction digits |
| `decimalPatternDigits(decimalDigits: 2)` | `1234.5` → `1,234.50` | exactly *n* fraction digits |
| `percentPattern()` | `0.1234` → `12%` | |
| `decimalPercentPattern(decimalDigits: 2)` | `0.12345` → `12.35%` | |
| `currency()` | `123456` → `NPR 1,23,456.00` | ISO code |
| `simpleCurrency()` | `123456` → `Rs. 1,23,456.00` | `रु.` in Nepali |
| `compact()` | `1234567` → `12.3L` | |
| `compactLong()` | `1234567` → `12.3 lakh` | |
| `compactCurrency()` | `1234567` → `NPR 12.3L` | |
| `compactSimpleCurrency()` | `1234567` → `Rs. 12.3L` | |
| `words()` | `123456` → `one lakh twenty-three thousand four hundred fifty-six` | can't parse |
| `NepaliNumberFormat('#,##0.00')` | `1,234,567.89` | any intl pattern |

Every constructor takes an optional `language`. Without one, it uses [`NepaliUtils.currentLanguage`](/getting-started/language/) at the time the formatter is created.

## Decimal and percent

```dart
NepaliNumberFormat.decimalPatternDigits(decimalDigits: 2).format(123456789.6548);
// 12,34,56,789.65
NepaliNumberFormat.percentPattern().format(0.1234);                      // 12%
NepaliNumberFormat.decimalPercentPattern(decimalDigits: 2).format(0.12345); // 12.35%
```

Numbers are rounded **half away from zero**, using the decimal value as written:

```dart
final twoDigits = NepaliNumberFormat.decimalPatternDigits(decimalDigits: 2);
twoDigits.format(2.999); // 3.00
twoDigits.format(1.005); // 1.01
```

## Currency

```dart
NepaliNumberFormat.currency().format(123456);                         // NPR 1,23,456.00
NepaliNumberFormat.simpleCurrency().format(123456);                   // Rs. 1,23,456.00
NepaliNumberFormat.simpleCurrency(language: .nepali).format(123456);  // रु. १,२३,४५६.००
NepaliNumberFormat.simpleCurrency(decimalDigits: 0).format(123456);   // Rs. 1,23,456
```

Use `currency` to choose the code or symbol and the layout:

```dart
NepaliNumberFormat.currency(symbol: 'Rs').format(1234.5);   // Rs 1,234.50
NepaliNumberFormat.simpleCurrency(name: 'USD').format(1234.5); // USD 1,234.50

// Put the symbol after the amount.
NepaliNumberFormat.currency(symbol: 'Rs.', customPattern: '#,##,##0.00 ¤').format(1234.5);
// 1,234.50 Rs.
```

| Parameter | Meaning |
|---|---|
| `name` | ISO currency code. The default is `NPR`. |
| `symbol` | Text shown for `¤`. `currency()` defaults to `name`. `simpleCurrency()` uses `Rs.` / `रु.` for NPR. |
| `decimalDigits` | Overrides the pattern's fraction digits. |
| `customPattern` | Replaces the default pattern, `¤ #,##,##0.00`. |

:::note[No-break space]
The built-in currency patterns put a **no-break space** (` `) between the symbol and the amount, so the two stay on the same line. Remember this when you compare strings in tests.
:::

## Compact numbers

Compact formats show at most three significant digits. They never drop digits before the decimal point.

```dart
final compact = NepaliNumberFormat.compact();
for (final n in [999, 1234, 123456, 1234567, 123456789, 12345678901, 1234567890123]) {
  compact.format(n);
}
// 999, 1.23K, 1.23L, 12.3L, 12.3Cr, 12.3Arab, 12.3Kharab

NepaliNumberFormat.compact(language: .nepali).format(1234567);     // १२.३ लाख
NepaliNumberFormat.compactLong().format(123456789);                // 12.3 crore
NepaliNumberFormat.compact(explicitSign: true).format(1234567);    // +12.3L
NepaliNumberFormat.compactSimpleCurrency(language: .nepali).format(1234567); // रु. १२.३ लाख
```

| Place value | Short | Long | Nepali |
|---|---|---|---|
| 1,000 | `K` | thousand | हजार |
| 1,00,000 | `L` | lakh | लाख |
| 1,00,00,000 | `Cr` | crore | करोड |
| 1,00,00,00,000 | `Arab` | arab | अर्ब |
| 1,00,00,00,00,000 | `Kharab` | kharab | खर्ब |

## Numbers in words

```dart
NepaliNumberFormat.words().format(123456);
// one lakh twenty-three thousand four hundred fifty-six
NepaliNumberFormat.words(language: .nepali).format(123456);
// एक लाख तेइस हजार चार सय छपन्न
NepaliNumberFormat.words().format(-12.05);
// minus twelve point zero five
```

**Amounts of money.** With `currency: true`, the number is read as rupees and rounded to the paisa:

```dart
NepaliNumberFormat.words(currency: true).format(123.45);
// one hundred twenty-three rupees forty-five paisa
NepaliNumberFormat.words(language: .nepali, currency: true).format(123456789.6548);
// बाह्र करोड चौंतीस लाख छपन्न हजार सात सय उनान्नब्बे रुपैयाँ पैंसट्ठी पैसा
```

**Digits with place names.** With `useDigits: true`, each group is written in digits:

```dart
NepaliNumberFormat.words(useDigits: true).format(123456);  // 1 lakh 23 thousand 4 hundred 56
NepaliNumberFormat.words(useDigits: true, language: .nepali).format(123456);
// १ लाख २३ हजार ४ सय ५६
NepaliNumberFormat.words(useDigits: true).format(100000);  // 1 lakh
```

`words()` can't parse. Calling `parse` on it throws an `UnsupportedError`.

## Custom patterns

Patterns use intl's syntax:

| Symbol | Meaning |
|---|---|
| `0` | a digit, always shown |
| `#` | a digit, hidden when it's a leading or trailing zero |
| `,` | grouping separator |
| `.` | decimal separator |
| `;` | separates the positive and negative subpatterns |
| `%` | multiply by 100 and show as a percentage |
| `‰` | multiply by 1000 and show as per mille |
| `¤` | the currency symbol (`NPR` by default) |
| `'` | quotes literal text; `''` for a single quote |

The size of the **last** group sets how digits are grouped. `#,##,##0` groups in lakhs and crores (3-2-2), and `#,##0` groups in thousands and millions (3-3-3):

```dart
NepaliNumberFormat('#,##0.00').format(1234567);                  // 1,234,567.00
NepaliNumberFormat('#,##,##0.00', .nepali).format(1234567.891);  // १२,३४,५६७.८९
NepaliNumberFormat('0000').format(42);                           // 0042
NepaliNumberFormat('#,##,##0;(#,##,##0)').format(-1234567);      // (12,34,567)
NepaliNumberFormat('#,##0‰').format(0.0125);                     // 13‰
NepaliNumberFormat("#,##,##0 'pcs'").format(12345);              // 12,345 pcs
```

A malformed pattern throws a `FormatException`.

## Adjusting a formatter with `copyWith`

Formatters are **immutable**. Instead of intl's setters, use `copyWith` to get a changed copy:

```dart
final decimal = NepaliNumberFormat.decimalPattern();

decimal.copyWith(groupSeparator: '', maximumFractionDigits: 2).format(12345.678); // 12345.68
decimal.copyWith(minimumIntegerDigits: 3).format(7);           // 007
decimal.copyWith(minimumFractionDigits: 2).format(5);          // 5.00
decimal.copyWith(maximumSignificantDigits: 3).format(1234567); // 12,30,000

final money = NepaliNumberFormat.decimalPatternDigits(decimalDigits: 2)
    .copyWith(includeDecimalIfZero: false);
money.format(2);    // 2
money.format(2.01); // 2.01
```

| Field | Meaning |
|---|---|
| `minimumIntegerDigits` | pads the integer part with zeros |
| `minimumFractionDigits` / `maximumFractionDigits` | fraction digits; if you pass a value that conflicts with the other, the one you pass wins |
| `minimumSignificantDigits` / `maximumSignificantDigits` | round to significant digits instead |
| `groupSeparator` | default `,`; `''` turns grouping off |
| `includeDecimalIfZero` | `false` drops an all-zero fraction (`2.00` → `2`) |

## What `format` accepts

`format(Object number)` accepts an `int`, a `double`, a `BigInt` or a **numeric `String`**. Strings and `BigInt`s keep every digit, which is useful for money:

```dart
decimal.format('12345678901234567890.12'); // 1,23,45,67,89,01,23,45,67,890.12
decimal.format(BigInt.parse('123456789012345678901234'));
// 1,23,45,67,89,01,23,45,67,89,01,234
decimal.format(double.nan);      // NaN
decimal.format(double.infinity); // ∞
```

Any other type, or a string that isn't a number, throws an `ArgumentError`. `null` is a compile-time error.

## Parsing

`parse` and `tryParse` accept ASCII or Devanagari digits. They return an `int` when the value is a whole number that fits, and a `double` otherwise:

```dart
decimal.parse('१२,३४,५६७.८९');                     // 1234567.89
decimal.parse('1,23,456');                         // 123456 (an int)
NepaliNumberFormat.percentPattern().parse('12%');  // 0.12
NepaliNumberFormat.compact().parse('1.23L');       // 123000
NepaliNumberFormat.compactLong(language: .nepali).parse('१२.३ लाख'); // 1230000
NepaliNumberFormat.simpleCurrency().parse('Rs. 1,234.50'); // 1234.5
NepaliNumberFormat.simpleCurrency().parse('1,234.50');     // 1234.5 (symbol optional)
decimal.tryParse('abc');                           // null
```

Group separators may appear anywhere in the integer part, and spaces are ignored. `parse` throws a `FormatException` for invalid input.

## Gotchas

:::caution
- `decimalPattern()` shows up to **three** fraction digits (`123456789.6548` → `…789.655`). For a fixed number of digits, use `decimalPatternDigits(decimalDigits: 2)`.
- The language is fixed when the formatter is **created**. A formatter stored in a field doesn't change when you later change `NepaliUtils.defaultLanguage`.
- The 3.x constructor parameters (`isMonetory`, `inWords`, `delimiter`, …) are gone. `NepaliNumberFormat()` is now the same as `decimalPattern()`. See [Upgrading to 4.0](/migration/v4/) for the full mapping.
:::

## See also

- [`NepaliNumberFormat` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliNumberFormat-class.html)
- [Devanagari helpers](/guides/preeti-devanagari/#devanagari-helpers) to convert only the digits of a string
