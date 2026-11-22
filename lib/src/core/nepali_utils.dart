// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:nepali_utils/src/core/language/language.dart';

/// Global settings for Nepali Utilities.
///
/// Works like `package:intl`'s `Intl.defaultLocale` and `Intl.withLocale`:
///
/// ```dart
/// NepaliUtils.defaultLanguage = .nepali;
///
/// // From a Flutter or intl locale.
/// NepaliUtils.defaultLanguage = Language.fromLocale('ne_NP');
///
/// // Only for the code run inside the callback.
/// final text = NepaliUtils.withLanguage(.english, () {
///   return NepaliDateFormat.yMd().format(date);
/// });
/// ```
abstract final class NepaliUtils {
  static final Object _zoneKey = Object();

  /// The language used when no language is passed explicitly and no
  /// [withLanguage] override is active.
  ///
  /// Default is [Language.english].
  static Language defaultLanguage = .english;

  /// The language in effect: the innermost [withLanguage] override, or
  /// [defaultLanguage] when there is none.
  static Language get currentLanguage =>
      Zone.current[_zoneKey] as Language? ?? defaultLanguage;

  /// Runs [body] with [currentLanguage] set to [language] and returns its
  /// result.
  ///
  /// The override covers everything [body] runs, including asynchronous work
  /// it starts, and doesn't change [defaultLanguage].
  static R withLanguage<R>(Language language, R Function() body) =>
      runZoned(body, zoneValues: {_zoneKey: language});
}
