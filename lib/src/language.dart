// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Languages supported by Nepali Utilities.
///
/// Easily convertible to and from locale identifiers, so it can be bridged
/// with `package:intl` or Flutter's `Locale`:
///
/// ```dart
/// final language = Language.fromLocale(locale.toLanguageTag()); // Flutter
/// final locale = Locale(language.languageCode, language.countryCode);
/// ```
enum Language(final String languageCode, final String countryCode) {
  /// English Language.
  english('en', 'US'),

  /// Nepali Language.
  nepali('ne', 'NP');

  /// Locale name in the `ll_CC` form used by intl and CLDR, e.g. `ne_NP`.
  String get localeName => '${languageCode}_$countryCode';

  /// BCP-47 language tag, e.g. `ne-NP`.
  String toLanguageTag() => '$languageCode-$countryCode';

  /// The [Language] for [locale], or `null` if it isn't supported.
  ///
  /// Accepts any locale identifier whose language subtag is supported,
  /// case-insensitively and with either `_` or `-` separators, e.g. `ne`,
  /// `ne_NP`, `ne-NP`, `NE-np` or `ne_Deva_NP`.
  static Language? tryParse(String locale) {
    final code = locale.trim().split(RegExp('[-_]')).first.toLowerCase();
    for (final language in values) {
      if (language.languageCode == code) return language;
    }
    return null;
  }

  /// The [Language] for [locale].
  ///
  /// Throws an [ArgumentError] if [locale] isn't supported.
  /// See [tryParse] for the accepted formats.
  static Language parse(String locale) =>
      tryParse(locale) ??
      (throw ArgumentError.value(locale, 'locale', 'Unsupported locale'));

  /// The [Language] for [locale], falling back to [orElse] when unsupported.
  static Language fromLocale(String locale, {Language orElse = .english}) =>
      tryParse(locale) ?? orElse;
}
