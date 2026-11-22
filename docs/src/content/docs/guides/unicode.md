---
title: Nepali Unicode
description: Convert romanized text to Nepali Unicode (Devanagari) and back with NepaliUnicode. Covers classic, Google Input Tools and MPP keyboard styles, live typing and streams.
---

`NepaliUnicode` converts Latin-script text into Nepali Unicode (Devanagari), and back. Use it to transliterate romanized Nepali, or to add Nepali typing to a text field without a Nepali keyboard.

```dart
const unicode = NepaliUnicode();

unicode.convert("sayau' thu''gaa fUlakaa haamii, euTai maalaa nepaalii");
// सयौं थुँगा फूलका हामी, एउटै माला नेपाली
unicode.convert('saarwabhauma bhai failiekaa, mecii-mahaakaalii');
// सार्वभौम भै फैलिएका, मेची-महाकाली
unicode.convert('mero naam {Sarbagya} ho'); // मेरो नाम Sarbagya हो
unicode.toRoman('नेपाली');                  // nepaalii
```

`NepaliUnicode` is a `const`, immutable `Converter<String, String>`:

```dart
const NepaliUnicode({NepaliUnicodeStyle style = .classic, bool nepaliDigits = true})
```

## Styles

Choose the romanization scheme your users already know:

| Style | Typing `नेपाल` | Kind |
|---|---|---|
| `.classic` (default) | `nepaala` | Phonetic. These are the rules of earlier versions of this package. |
| `.google` | `nepaal` | Phonetic, in the style of Google Input Tools and Easy Nepali typing. |
| `.mppRomanized` | `nepal` | Madan Puraskar Pustakalaya's *Nepali Unicode Romanized* keyboard. Each key types one character. |
| `.mppTraditional` | `g]kfn` | Madan Puraskar Pustakalaya's *Nepali Unicode Traditional* keyboard, with the same key positions as Preeti. |

```dart
const NepaliUnicode().convert('nepaala');                         // नेपाल
const NepaliUnicode(style: .google).convert('nepaal ko maayaa');  // नेपाल को माया
const NepaliUnicode(style: .mppRomanized).convert('nepal');       // नेपाल
const NepaliUnicode(style: .mppTraditional).convert('g]kfn');     // नेपाल
```

### Classic

A consonant keeps a halant (्) until a vowel follows it. Before whitespace, the halant is dropped.

```dart
const classic = NepaliUnicode();

classic.convert('nepal');   // नेपल्
classic.convert('nepaala'); // नेपाल
classic.convert('kamal');   // कमल्
classic.convert('kamal ');  // कमल   (a space drops the halant)
classic.convert('khasha');  // खश
classic.convert('Tha Da kaaraNa Sa'); // ठ ड कारण ष
classic.convert('ma ghara jaanchu.'); // म घर जान्छु।
```

| Type | Get |
|---|---|
| `aa` or `A` | ा |
| `ii` or `I` | ी |
| `uu` or `U` | ू |
| `ai` or `E` | ै |
| `au` | ौ |
| `T`, `D`, `N`, `S` | ट, ड, ण, ष |
| consonant + `h` | aspirated, e.g. `kh` ख, `sh` श |
| `'` | ं (anusvara) |
| `''` | ँ (chandrabindu) |
| `:` | ः (visarga) |
| `.`, `\|`, `/` or `\` | । |

### Google

A consonant at the end of a word keeps its inherent vowel, and `~` forces a halant:

```dart
const google = NepaliUnicode(style: .google);

google.convert('nepaal ko maayaa, bhagawaan~ ko dayaa');
// नेपाल को माया, भगवान् को दया
google.convert('chhoraa chiyaa shaanti Shatkon kshetra gyaan');
// छोरा चिया शान्ति षत्कोन क्षेत्र ज्ञान
google.convert('saMsaar haa^s duHkha kRshi');
// संसार हाँस दुःख कृशि
```

| Type | Get |
|---|---|
| `ch` / `chh` | च / छ |
| `sh` / `Sh` | श / ष |
| `ksh` / `gy` | क्ष / ज्ञ |
| `ee` or `ii` / `oo` or `uu` | ी / ू |
| `M` / `^` / `H` | ं / ँ / ः |
| `R` | ृ |
| `~` | ् (halant) |
| `.` | । |

### MPP keyboards

The keyboard styles map each key to one character, or to a fixed conjunct. Nothing is combined. They suit users who learned these layouts.

```dart
const NepaliUnicode(style: .mppRomanized).convert('nmste'); // नमसते
const NepaliUnicode(style: .mppRomanized).toRoman('नमस्ते'); // nms/te
```

To read documents that were typed in the Preeti **font**, use [`Preeti.toUnicode`](/guides/preeti-devanagari/) instead of `.mppTraditional`.

## Keeping text as it is: `{…}`

In the phonetic styles (`classic` and `google`), text inside braces isn't converted, and the braces are removed:

```dart
const NepaliUnicode().convert('mero naam {Sarbagya} ho'); // मेरो नाम Sarbagya हो
```

To write a literal `{`, escape it as `{{}`:

```dart
const NepaliUnicode().convert('{{}a}'); // {अ}
```

## Digits

ASCII digits become Devanagari digits by default. Pass `nepaliDigits: false` to keep them:

```dart
const NepaliUnicode().convert('2081 saala');                     // २०८१ साल
const NepaliUnicode(nepaliDigits: false).convert('2081 saala');  // 2081 साल
```

## Mixing Devanagari and Latin

Devanagari that is already in the input is kept. Latin letters typed right after it join its last syllable:

```dart
const NepaliUnicode().convert('कमलa');   // कमला
const NepaliUnicode().convert('नेपालi'); // नेपालै
```

A Devanagari consonant counts as a consonant plus its inherent `a`. So adding `a` gives ा, and adding `i` gives ै (`a` + `i` = `ai`).

## Typing in a text field: `convertLive`

To convert while the user types, call `convertLive` on the field's whole text after every change, and put the result back:

```dart
const unicode = NepaliUnicode(style: .google);

unicode.convertLive('k');    // क्
unicode.convertLive('क्a');  // क
unicode.convertLive('कm');   // कम्
unicode.convertLive('कम् '); // कम   (followed by a space)
```

`convertLive` is different from `convert` in three ways:

- The word being typed keeps its halant until it's finished, so the next letter can still join it.
- A halant just before whitespace is dropped.
- `{…}` escapes **keep their braces**, so text typed later still knows it is inside an escape. Call `convert` on the final text to remove them.

A minimal Flutter version:

```dart
final controller = TextEditingController();
const unicode = NepaliUnicode(style: .google);

TextField(
  controller: controller,
  onChanged: (text) {
    final converted = unicode.convertLive(text);
    if (converted != text) {
      controller.value = TextEditingValue(
        text: converted,
        selection: TextSelection.collapsed(offset: converted.length),
      );
    }
  },
);
```

For the keyboard styles, `convertLive` is the same as `convert`.

## Back to Latin: `toRoman`

`toRoman` romanizes Devanagari so that `convert` gives the same text back:

```dart
const NepaliUnicode().toRoman('नेपाल');               // nepaala
const NepaliUnicode(style: .google).toRoman('नेपाल'); // nepaal
const NepaliUnicode(style: .google).toRoman('क्षत्रिय'); // kshatriy
const NepaliUnicode().toRoman('मेरो नाम Sarbagya हो'); // mero naam {Sarbagya} ho
const NepaliUnicode(style: .mppTraditional).toRoman('नेपाल'); // g]kfn
```

- Latin text is escaped in `{}`.
- In the phonetic styles, a separator is added between letters that would otherwise be read as a different letter: `{}` in classic, `~` in google.
- The keyboard styles return the keys to press.
- Characters the style can't write, such as ळ in the phonetic styles, are left as they are.

## Streams and chunked input

`NepaliUnicode` is a `Converter`, so it can transform a stream:

```dart
final text = await Stream.fromIterable(['mero naa', 'm nepaal', 'ii ho'])
    .transform(const NepaliUnicode())
    .join();
print(text); // मेरो नाम नेपाली हो
```

Each chunk is converted up to its last whitespace. The rest is held back until the next chunk arrives, so a word split across chunks still converts correctly.

## Gotchas

:::caution
- In 3.x this was a static call: `NepaliUnicode.convert(text)`. It is now `const NepaliUnicode().convert(text)`, and `live: true` became `convertLive`. See [Upgrading to 4.0](/migration/v4/).
- `{` now starts an escape. Existing text with literal braces needs `{{}`.
- In classic, a word ending in a consonant keeps its halant until a vowel or whitespace follows: `kamal` gives कमल्. Write `kamala`, or end with a space. The google style doesn't need this.
:::

## See also

- [`NepaliUnicode` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliUnicode-class.html)
- [`NepaliUnicodeStyle`](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliUnicodeStyle.html)
- [Preeti & Devanagari](/guides/preeti-devanagari/)
