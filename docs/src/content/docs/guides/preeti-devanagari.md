---
title: Preeti & Devanagari
description: Convert legacy Preeti-font text to Unicode and back, and work with Devanagari text. Detect it, convert digits and split it into aksharas.
---

## Preeti

Preeti is a legacy Nepali **font**. It draws Devanagari glyphs on top of ASCII character codes. Many older documents, government forms and databases were typed in Preeti. Without the font installed, that text looks like nonsense: `g]kfn` instead of नेपाल.

The `Preeti` class converts between that encoding and real Unicode:

```dart
Preeti.toUnicode('g]kfn');            // नेपाल
Preeti.toUnicode('sfof{no');          // कार्यालय
Preeti.toUnicode('sfof{no / lxdfn');  // कार्यालय र हिमाल
Preeti.toUnicode('cfh d]/f] hGdlbg xf] .'); // आज मेरो जन्मदिन हो ।

Preeti.fromUnicode('हिमाल');    // lxdfn
Preeti.fromUnicode('काठमाडौं'); // sf&df*f}+
```

Text converted with `fromUnicode` and then back with `toUnicode` comes back unchanged:

```dart
Preeti.toUnicode(Preeti.fromUnicode('नेपाली भाषा')); // नेपाली भाषा
```

Some details of the conversion:

- **Visual order.** Preeti stores text in the order it's drawn. The short-i sign ि is typed *before* its consonant, and the reph (र् above a letter, typed `{`) is typed *after* its syllable. `toUnicode` moves both to their Unicode positions, and `fromUnicode` moves them back.
- **Vowels drawn in two parts**, such as ो written as ा + े, are combined into one character.
- Characters that the font doesn't draw are kept as they are.

:::tip[Preeti or the MPP Traditional keyboard?]
`Preeti.toUnicode` decodes text that was **stored** in the Preeti font. To let users **type** with Preeti key positions and get Unicode, use [`NepaliUnicode(style: .mppTraditional)`](/guides/unicode/#mpp-keyboards). That layout has the same keys, but each key maps directly to a Unicode character, and no reordering happens.
:::

## Devanagari helpers

`Devanagari` has static helpers for text in the Devanagari script.

### Detecting Devanagari

```dart
Devanagari.isDevanagari('नमस्ते, संसार!');   // true
Devanagari.isDevanagari('Hi नेपाल');         // false
Devanagari.containsDevanagari('Hi नेपाल');   // true
Devanagari.containsDevanagari('Hello');      // false
```

- `isDevanagari` is `true` when the text contains at least one Devanagari character and everything else is whitespace, punctuation, or a zero-width joiner or non-joiner.
- `containsDevanagari` is `true` when there is at least one Devanagari character.

One use is choosing a font, or deciding whether to run `NepaliUnicode.convert` on user input.

### Converting digits

```dart
Devanagari.toNepaliDigits('2081');        // २०८१
Devanagari.toNepaliDigits('2081/01/15');  // २०८१/०१/१५
Devanagari.toEnglishDigits('२०८१');       // 2081
```

Only the digits change. Everything else is kept. Convert with `toEnglishDigits` before calling `int.parse` on user input.

### Splitting into aksharas

An *akshara* is the unit that Devanagari is written in: a consonant cluster together with its vowel sign and marks. `aksharas` splits text into them:

```dart
Devanagari.aksharas('संस्कृति'); // [सं, स्कृ, ति]
Devanagari.aksharas('क्षमा');    // [क्ष, मा]
Devanagari.aksharas('नेपाल देश'); // [ने, पा, ल,  , दे, श]
```

Every other character, including a space, is its own item.

Use aksharas, not `String.length` or code units, when you count, truncate or reverse Devanagari text. Cutting in the middle of an akshara breaks how it's drawn:

```dart
'नमस्ते'.length;                       // 6
Devanagari.aksharas('नमस्ते').length;  // 3
```

## See also

- [`Preeti` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/Preeti-class.html)
- [`Devanagari` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/Devanagari-class.html)
- [Nepali Unicode](/guides/unicode/) for romanized ↔ Devanagari conversion
