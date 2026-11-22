---
title: Language
description: Choose English or Nepali output with the Language enum, NepaliUtils.defaultLanguage, withLanguage and Flutter locales.
---

Every formatter in `nepali_utils` can write English or Nepali. The language controls month and weekday names, digits (`2081` or `२०८१`), number words, and the phrases used for relative time and units.

## The `Language` enum

```dart
enum Language { english, nepali }
```

| Value | `languageCode` | `countryCode` | `localeName` | `toLanguageTag()` |
|---|---|---|---|---|
| `Language.english` | `en` | `US` | `en_US` | `en-US` |
| `Language.nepali` | `ne` | `NP` | `ne_NP` | `ne-NP` |

## Where the language comes from

Each formatter picks its language in this order:

1. The `language` argument passed to it.
2. The language set by the innermost [`NepaliUtils.withLanguage`](#for-part-of-your-code-withlanguage) call that is running.
3. [`NepaliUtils.defaultLanguage`](#the-default-language), which is `Language.english` unless you change it.

`NepaliUtils.currentLanguage` returns the result of steps 2 and 3: the language a formatter gets when you don't pass one.

```dart
final date = NepaliDateTime(2081, 1, 15);

NepaliDateFormat.yMMMd().format(date);          // Bai 15, 2081
NepaliDateFormat.yMMMd(.nepali).format(date);   // २०८१ बै १५
```

:::note
Formatters read the language **when they are created**, not when they format. A formatter created inside `withLanguage(.nepali, ...)` keeps writing Nepali after the callback returns. Changing `defaultLanguage` later doesn't change formatters you have already created.
:::

## The default language

Set `NepaliUtils.defaultLanguage` once, usually at the start of `main`:

```dart
void main() {
  NepaliUtils.defaultLanguage = Language.nepali;

  print(NepaliNumberFormat.decimalPattern().format(1234567)); // १२,३४,५६७
}
```

This is optional. If you don't set it, the default is English.

## For part of your code: `withLanguage`

`NepaliUtils.withLanguage` runs a callback with a different language and returns what the callback returns. It works like `Intl.withLocale` in `package:intl`:

```dart
final date = NepaliDateTime(2081, 1, 15);

final text = NepaliUtils.withLanguage(.nepali, () {
  return NepaliDateFormat.yMMMd().format(date);
});
print(text); // २०८१ बै १५

// Outside the callback, the default applies again.
print(NepaliDateFormat.yMMMd().format(date)); // Bai 15, 2081
```

- `defaultLanguage` doesn't change.
- The override also applies to async work started inside the callback, because it is stored in a `Zone`:

  ```dart
  final language = await NepaliUtils.withLanguage(.nepali, () async {
    await Future<void>.delayed(Duration.zero);
    return NepaliUtils.currentLanguage;
  });
  print(language); // Language.nepali
  ```

- An explicit `language` argument still wins inside the callback:

  ```dart
  NepaliUtils.withLanguage(.nepali, () {
    return NepaliDateFormat.yMMMd(.english).format(date); // Bai 15, 2081
  });
  ```

## Converting to and from locales

`Language` converts to and from locale identifiers, so you can connect it to `package:intl` or Flutter's `Locale`.

```dart
Language.parse('ne_NP');        // Language.nepali
Language.tryParse('NE-np');     // Language.nepali
Language.tryParse('ne_Deva_NP'); // Language.nepali
Language.tryParse('fr');        // null
Language.fromLocale('fr');      // Language.english (the fallback)
Language.fromLocale('fr', orElse: .nepali); // Language.nepali

Language.nepali.localeName;      // ne_NP
Language.nepali.toLanguageTag(); // ne-NP
```

- `tryParse` looks only at the language subtag. It ignores case and accepts `_` or `-` as the separator. It returns `null` for languages it doesn't support.
- `parse` throws an `ArgumentError` for languages it doesn't support.
- `fromLocale` never throws. It falls back to `orElse`, which defaults to `Language.english`.

### Flutter

Follow the app's locale:

```dart
@override
Widget build(BuildContext context) {
  final locale = Localizations.localeOf(context);
  NepaliUtils.defaultLanguage = Language.fromLocale(locale.toLanguageTag());
  // ...
}
```

To pass formatters into a widget subtree without changing the global default, create them inside `withLanguage`, or pass the language to each one:

```dart
final language = Language.fromLocale(Localizations.localeOf(context).toLanguageTag());
final dateFormat = NepaliDateFormat.yMMMMd(language);
```

And going the other way, from a `Language` to a `Locale`:

```dart
final locale = Locale(language.languageCode, language.countryCode);
```

## See also

- [`Language` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/Language.html)
- [`NepaliUtils` API](https://pub.dev/documentation/nepali_utils/latest/nepali_utils/NepaliUtils-class.html)
