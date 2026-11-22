---
title: Installation
description: Add nepali_utils to a Dart or Flutter project and import it.
---

`nepali_utils` is a pure Dart package with no platform code. It works anywhere Dart runs: Flutter (mobile, desktop and web), the Dart VM, servers and command-line tools.

## Requirements

- **Dart SDK 3.13 or later.** The package's `pubspec.yaml` requires `sdk: ^3.13.0`. The library uses newer language features such as primary constructors and dot shorthands.
- With Flutter, use a Flutter release that ships Dart 3.13 or later. Run `flutter --version` to see which Dart SDK you have.

## Add the dependency

For a Dart project:

```sh
dart pub add nepali_utils
```

For a Flutter project:

```sh
flutter pub add nepali_utils
```

Either command adds a line like this to your `pubspec.yaml`:

```yaml
dependencies:
  nepali_utils: ^4.0.0
```

## Import it

Everything is exported from one library:

```dart
import 'package:nepali_utils/nepali_utils.dart';
```

:::caution
Don't import files under `package:nepali_utils/src/...`. They are internal and can change in any release. Everything public is exported by `nepali_utils.dart`.
:::

## Check that it works

```dart
import 'package:nepali_utils/nepali_utils.dart';

void main() {
  final date = NepaliDateTime.parse('2072-06-03T17:00:00');
  print(NepaliDateFormat.yMMMMEEEEd().format(date)); // Sunday, Ashwin 3, 2072
  print(date.toDateTime()); // 2015-09-20 17:00:00.000
}
```

## Flutter notes

- There's nothing extra to set up. No plugins, assets or platform channels are involved.
- To show text in the app's language, set [`NepaliUtils.defaultLanguage`](/getting-started/language/) from the app's `Locale`, or pass a `Language` to each formatter.
- Devanagari text needs a font with Devanagari glyphs. Android, iOS, macOS and Windows include one. On Linux and the web, you may need to add a font such as Noto Sans Devanagari to your app.
- `NepaliDateTime.now()` returns **local** time, like `DateTime.now()`. To show the time in Nepal whatever the device's time zone, use `NepaliDateTime.nepalNow()`. See [Time zones](/guides/date-time/#time-zones).

## Next steps

- [Choose a language](/getting-started/language/) for formatted output.
- [Work with Nepali dates](/guides/date-time/).
- Coming from 3.x? Read [Upgrading to 4.0](/migration/v4/).
