// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/language.dart';

/// Global settings for Nepali Utilities.
final class NepaliUtils {
  /// Global settings for Nepali Utilities.
  ///
  /// The default language for nepali utilities can be set using [lang].
  factory([Language? lang]) {
    if (lang != null) _instance.language = lang;
    return _instance;
  }

  /// Sets the default language from a locale identifier such as `ne`,
  /// `ne_NP` or `en-US`. See [Language.tryParse].
  ///
  /// Unsupported locales leave the current default unchanged.
  factory fromLocale(String locale) => NepaliUtils(Language.tryParse(locale));

  new _();

  static final NepaliUtils _instance = NepaliUtils._();

  /// Language for Nepali Utilities.
  ///
  /// Default is [Language.english], if not set.
  Language language = .english;
}
