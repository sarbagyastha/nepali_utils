---
title: Measurement units
description: Convert traditional Nepali units of land area, weight and grain volume (ropani, bigha, tola, dharni, pathi…) to and from metric with NepaliArea, NepaliWeight and NepaliVolume.
---

`NepaliArea`, `NepaliWeight` and `NepaliVolume` convert between traditional Nepali units and metric units. All three work the same way:

- Create a value from one unit, or from mixed units: `NepaliArea.ropani(2, aana: 3)`.
- Convert it with `to(unit)`.
- Split it into mixed units with the `…Parts` getters.
- Write it as `2-3-1-0` or `2 ropani 3 aana 1 paisa` with `format`, in English or Nepali.
- Read `2-3-1-0` or `२-३-१-०` back with `parse` / `tryParse`.
- Add, subtract, multiply, divide and compare values.

Values are immutable and compare by quantity.

## Land area: `NepaliArea`

Land in the hills is measured in **ropani-aana-paisa-daam**, and land in the Terai in **bigha-kattha-dhur**.

| Unit | Equals | Square feet | Square metres |
|---|---|---|---|
| ropani (रोपनी) | 16 aana | 5476 (74 × 74) | ≈ 508.737 |
| aana (आना) | 4 paisa | 342.25 | ≈ 31.796 |
| paisa (पैसा) | 4 daam | 85.5625 | ≈ 7.949 |
| daam (दाम) | | 21.390625 | ≈ 1.987 |
| bigha (बिघा) | 20 kattha | 72900 (270 × 270) | ≈ 6772.632 |
| kattha (कट्ठा) | 20 dhur | 3645 | ≈ 338.632 |
| dhur (धुर) | | 182.25 | ≈ 16.932 |

`AreaUnit` also has `squareFoot`, `squareMeter`, `acre` and `hectare`.

```dart
final plot = NepaliArea.ropani(2, aana: 3, paisa: 1);

plot.to(.squareFoot);  // 12064.3125
plot.to(.squareMeter); // 1120.81130676
plot.to(.aana);        // 35.25
plot.ropaniParts;      // (aana: 3, daam: 0.0, paisa: 1, ropani: 2)
plot.bighaParts;       // (bigha: 0, dhur: 6.196502058, kattha: 3)

plot.format(.ropani);                               // 2-3-1-0
plot.format(.ropani, long: true);                   // 2 ropani 3 aana 1 paisa
plot.format(.ropani, long: true, language: .nepali); // २ रोपनी ३ आना १ पैसा
plot.format(.bigha);                                // 0-3-6.2
plot.format(.bigha, long: true);                    // 3 kattha 6.2 dhur
```

Any unit can be converted to any other:

```dart
NepaliArea(1000, .squareMeter).format(.ropani); // 1-15-1-3.21
NepaliArea.bigha(1, kattha: 5).to(.ropani);     // 16.640796201607014
NepaliArea(1, .acre).format(.bigha, long: true); // 11 kattha 19.01 dhur
```

`format` takes an `AreaSystem`: `.ropani` (ropani-aana-paisa-daam) or `.bigha` (bigha-kattha-dhur).

## Weight: `NepaliWeight`

Gold and silver are weighed in **tola-lal**, and goods in the market in **dharni-ser-pau-chhatak**.

| Unit | Equals | Grams |
|---|---|---|
| tola (तोला) | 100 lal | 11.6638038 |
| lal (लाल) | | 0.116638038 |
| dharni (धार्नी) | 3 ser | 2393.4096 |
| ser (सेर) | 4 pau | 797.8032 |
| pau (पाउ) | 4 chhatak | 199.4508 |
| chhatak (छटाक) | | 49.8627 |

`WeightUnit` also has `gram` and `kilogram`. `WeightSystem` is `.tola` or `.dharni`.

```dart
final gold = NepaliWeight.tola(2, lal: 50);

gold.to(.gram);                     // 29.1595095
gold.tolaParts;                     // (lal: 50.0, tola: 2)
gold.format(.tola);                 // 2-50
gold.format(.tola, long: true);     // 2 tola 50 lal
gold.format(.tola, long: true, language: .nepali); // २ तोला ५० लाल

NepaliWeight(10, .gram).format(.tola);                  // 0-85.74
NepaliWeight(5, .kilogram).format(.dharni);             // 2-0-1-0.28
NepaliWeight(5, .kilogram).format(.dharni, long: true); // 2 dharni 1 pau 0.28 chhatak
```

:::note[Which tola and dharni?]
The tola is the 180-grain tola. The dharni is the one defined by Nepal's Standard Measurement and Weight Act, 2025 BS (1968). Local usage varies, so check the figures before you use them for trade.
:::

## Grain volume: `NepaliVolume`

Grain is measured in **muri-pathi-mana-muthi**.

| Unit | Equals | Litres |
|---|---|---|
| muri (मुरी) | 20 pathi | 90.9192 |
| pathi (पाथी) | 8 mana | 4.54596 |
| mana (माना) | 10 muthi | 0.568245 |
| muthi (मुठी) | | 0.0568245 |

`VolumeUnit` also has `liter`. There is only one system, so `format` and `parse` don't take one.

```dart
final rice = NepaliVolume.muri(1, pathi: 5, mana: 4);

rice.to(.pathi);                 // 25.5
rice.to(.liter);                 // 115.92198
rice.muriParts;                  // (mana: 4, muri: 1, muthi: 0.0, pathi: 5)
rice.format();                   // 1-5-4-0
rice.format(long: true);         // 1 muri 5 pathi 4 mana
rice.format(language: .nepali);  // १-५-४-०

NepaliVolume(10, .liter).format(); // 0-2-1-5.98
```

## Formatting

All three `format` methods take the same options:

| Option | Default | Effect |
|---|---|---|
| `long` | `false` | `false` gives dash-separated parts (`2-3-1-0`). `true` names the units and leaves out zero parts (`2 ropani 3 aana 1 paisa`). |
| `language` | `NepaliUtils.currentLanguage` | Nepali uses Devanagari digits and unit names. |
| `fractionDigits` | `2` | Decimal places for the smallest unit. Rounding carries into the larger units. |

```dart
plot.format(.bigha);                    // 0-3-6.2
plot.format(.bigha, fractionDigits: 0); // 0-3-6
NepaliArea.zero.format(.ropani, long: true); // 0 daam
```

Because rounding carries, 15 ropani 15 aana 3 paisa 3.999 daam becomes `16-0-0-0` with 2 digits, not `15-15-3-4`:

```dart
NepaliArea.ropani(15, aana: 15, paisa: 3, daam: 3.999).format(.ropani); // 16-0-0-0
```

Unit names are available on their own through `label`:

```dart
AreaUnit.ropani.label();          // ropani
AreaUnit.ropani.label(.nepali);   // रोपनी
AreaUnit.squareMeter.label();     // sq. m
WeightUnit.tola.label(.nepali);   // तोला
```

## Parsing

`parse` reads dash-separated parts in ASCII or Devanagari digits. Missing parts at the end count as zero:

```dart
NepaliArea.parse('२-३-१-०', .ropani) == plot;  // true
NepaliArea.parse('2-3', .ropani).format(.ropani); // 2-3-0-0
NepaliArea.parse('1-5-2.5', .bigha).format(.bigha, long: true); // 1 bigha 5 kattha 2.5 dhur
NepaliWeight.parse('२-५०', .tola) == gold;     // true
NepaliVolume.parse('१-५-४') == rice;           // true

NepaliArea.tryParse('2-x', .ropani);           // null
```

Each part must be a non-negative decimal number, and there can't be more parts than the system has units. Otherwise `parse` throws a `FormatException` and `tryParse` returns `null`.

## Arithmetic and comparison

```dart
(plot + NepaliArea.ropani(0, aana: 13)).format(.ropani); // 3-0-1-0
(plot / 2).format(.ropani);                             // 1-1-2-2
(rice * 2).format(long: true);                          // 2 muri 11 pathi
plot > NepaliArea.ropani(2);                            // true
(-plot).ropaniParts; // (aana: -3, daam: 0.0, paisa: -1, ropani: -2)
```

The operators `+`, `-`, `*` (by a number), `/` (by a number), unary `-`, `<`, `<=`, `>` and `>=` are supported, and `compareTo` too. Values implement `Comparable`, so lists of them can be sorted.

## Precision

Every value is stored in one base unit: square feet for area, grams for weight and litres for volume. Every ropani and bigha unit is a whole multiple of 1/64 square foot. So conversions between those units, square feet and acres are exact. Conversions through square metres, hectares or other metric units are rounded like any `double`:

```dart
NepaliWeight.dharni(1, ser: 2).to(.kilogram); // 3.9890159999999995
```

Round the result for display, or use `format`, which rounds the smallest unit for you.

## See also

- [`NepaliArea` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliArea-class.html), [`AreaUnit`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/AreaUnit.html), [`AreaSystem`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/AreaSystem.html)
- [`NepaliWeight` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliWeight-class.html), [`WeightUnit`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/WeightUnit.html), [`WeightSystem`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/WeightSystem.html)
- [`NepaliVolume` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliVolume-class.html), [`VolumeUnit`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/VolumeUnit.html)
