// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/language/language_symbols.dart';
import 'package:nepali_utils/src/core/nepali_utils.dart';
import 'package:nepali_utils/src/number/format/compact.dart';
import 'package:nepali_utils/src/number/format/decimal.dart';
import 'package:nepali_utils/src/number/format/number_pattern.dart';
import 'package:nepali_utils/src/number/parsing.dart';
import 'package:nepali_utils/src/number/words/number_words.dart';

enum _Style { pattern, compactShort, compactLong, words, currencyWords }

/// Formats and parses numbers the Nepali way, with the same API as
/// `package:intl`'s `NumberFormat`.
///
/// Numbers are grouped in thousands, lakhs and crores (`1,23,45,678`) and
/// use Devanagari digits when the language is [Language.nepali]:
///
/// ```dart
/// NepaliNumberFormat.decimalPattern().format(1234567.891); // 12,34,567.891
/// NepaliNumberFormat.simpleCurrency(language: .nepali).format(123456);
/// // रु. १,२३,४५६.००
/// NepaliNumberFormat.compact().format(1234567); // 12.3L
/// NepaliNumberFormat.words().format(123456);
/// // one lakh twenty-three thousand four hundred fifty-six
/// NepaliNumberFormat.decimalPattern().parse('१२,३४,५६७.८९'); // 1234567.89
/// ```
///
/// Patterns use the same syntax as intl:
///
/// | Symbol | Meaning                                           |
/// |--------|---------------------------------------------------|
/// | 0      | a digit, always shown                             |
/// | #      | a digit, hidden when it's a leading/trailing zero |
/// | ,      | grouping separator                                |
/// | .      | decimal separator                                 |
/// | ;      | separates the positive and negative subpatterns   |
/// | %      | multiply by 100 and show as a percentage          |
/// | ‰      | multiply by 1000 and show as per mille            |
/// | ¤      | the currency symbol                               |
/// | '      | quotes literal text, `''` for a single quote      |
///
/// The size of the last group sets the grouping: `#,##,##0` groups in
/// lakhs and crores (3-2-2) and `#,##0` in thousands and millions (3-3-3).
///
/// The built-in patterns are those of intl's `ne` locale. They are used for
/// English as well; only the digits and words differ.
///
/// Beyond intl:
/// * [format] accepts numeric strings and keeps every digit of large or
///   precise values, e.g. `format('12345678901234567890.12')`.
/// * Doubles are rounded as written, so `1.005` rounds to `1.01`.
/// * [NepaliNumberFormat.words] spells numbers out.
/// * Compact formats use thousand, lakh, crore, arab and kharab.
/// * [parse] accepts both ASCII and Devanagari digits.
///
/// Instances are immutable: use [copyWith] instead of intl's setters.
final class NepaliNumberFormat {
  /// Creates a formatter for [newPattern] in [language].
  ///
  /// Without a pattern, this is [NepaliNumberFormat.decimalPattern]. A `¤`
  /// in the pattern shows `NPR`; use [NepaliNumberFormat.currency] for
  /// another symbol.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage] at the time the
  /// formatter is created.
  ///
  /// Throws a [FormatException] when [newPattern] is malformed.
  factory([String? newPattern, Language? language]) => ._fromPattern(
    newPattern ?? decimalPatternString,
    language,
    currencyName: _nepaleseRupee,
    currencySymbol: _nepaleseRupee,
  );

  new _({
    required this.language,
    required this.pattern,
    required this._compiled,
    required this.minimumIntegerDigits,
    required this.minimumFractionDigits,
    required this.maximumFractionDigits,
    required this.groupSeparator,
    required this._style,
    this.currencyName,
    this.currencySymbol,
    this.minimumSignificantDigits,
    this.maximumSignificantDigits,
    this.includeDecimalIfZero = true,
    this._explicitSign = false,
    this._useDigits = false,
  });

  factory _fromPattern(
    String pattern,
    Language? language, {
    String? currencyName,
    String? currencySymbol,
    int? decimalDigits,
    _Style style = .pattern,
    bool explicitSign = false,
  }) {
    final compiled = NumberPattern.parse(pattern);
    return ._(
      language: language ?? NepaliUtils.currentLanguage,
      pattern: pattern,
      compiled: compiled,
      minimumIntegerDigits: compiled.minimumIntegerDigits,
      minimumFractionDigits: decimalDigits ?? compiled.minimumFractionDigits,
      maximumFractionDigits: decimalDigits ?? compiled.maximumFractionDigits,
      groupSeparator: ',',
      style: style,
      currencyName: currencyName,
      currencySymbol: currencySymbol,
      explicitSign: explicitSign,
    );
  }

  /// 1234567.891 => 12,34,567.891 / १२,३४,५६७.८९१
  factory decimalPattern([Language? language]) =>
      ._fromPattern(decimalPatternString, language);

  /// [NepaliNumberFormat.decimalPattern] with exactly [decimalDigits]
  /// fraction digits, e.g. 1234.5 => 1,234.50 for 2.
  factory decimalPatternDigits({Language? language, int? decimalDigits}) =>
      ._fromPattern(
        decimalPatternString,
        language,
        decimalDigits: decimalDigits,
      );

  /// 0.1234 => 12%
  factory percentPattern([Language? language]) =>
      ._fromPattern(percentPatternString, language);

  /// [NepaliNumberFormat.percentPattern] with exactly [decimalDigits]
  /// fraction digits, e.g. 0.12345 => 12.35% for 2.
  factory decimalPercentPattern({Language? language, int? decimalDigits}) =>
      ._fromPattern(
        percentPatternString,
        language,
        decimalDigits: decimalDigits,
      );

  /// 123456 => NPR 1,23,456.00 / NPR १,२३,४५६.००
  ///
  /// [symbol] defaults to [name], which defaults to `NPR`. [customPattern]
  /// replaces the default `¤ #,##,##0.00` (with a no-break space), e.g.
  /// `'#,##,##0.00 ¤'` puts the symbol after the amount. [decimalDigits]
  /// overrides the fraction digits of the pattern.
  factory currency({
    Language? language,
    String? name,
    String? symbol,
    int? decimalDigits,
    String? customPattern,
  }) => ._fromPattern(
    customPattern ?? currencyPatternString,
    language,
    currencyName: name ?? _nepaleseRupee,
    currencySymbol: symbol ?? name ?? _nepaleseRupee,
    decimalDigits: decimalDigits,
  );

  /// 123456 => Rs. 1,23,456.00 / रु. १,२३,४५६.००
  ///
  /// Like [NepaliNumberFormat.currency], but shows the symbol of the
  /// Nepalese rupee instead of its code. Any other [name] is shown as is.
  factory simpleCurrency({
    Language? language,
    String? name,
    int? decimalDigits,
  }) {
    final lang = language ?? NepaliUtils.currentLanguage;
    return .currency(
      language: lang,
      name: name,
      symbol: _simpleSymbol(name, lang),
      decimalDigits: decimalDigits,
    );
  }

  /// 1234 => 1.23K, 1234567 => 12.3L, 123456789 => 12.3Cr
  ///
  /// In Nepali, the place value is a word: १.२३ हजार, १२.३ लाख, १२.३ करोड.
  ///
  /// At most three significant digits are shown, but digits before the
  /// decimal point are never dropped. When [explicitSign] is true, positive
  /// numbers get a `+`.
  factory compact({Language? language, bool explicitSign = false}) =>
      ._fromPattern(
        _compactPattern,
        language,
        style: .compactShort,
        explicitSign: explicitSign,
      );

  /// 1234 => 1.23 thousand, 1234567 => 12.3 lakh / १२.३ लाख
  ///
  /// See [NepaliNumberFormat.compact].
  factory compactLong({Language? language, bool explicitSign = false}) =>
      ._fromPattern(
        _compactPattern,
        language,
        style: .compactLong,
        explicitSign: explicitSign,
      );

  /// 1234567 => NPR 12.3L
  ///
  /// A compact currency format, see [NepaliNumberFormat.compact] and
  /// [NepaliNumberFormat.currency].
  factory compactCurrency({Language? language, String? name, String? symbol}) =>
      ._fromPattern(
        currencyPatternString,
        language,
        currencyName: name ?? _nepaleseRupee,
        currencySymbol: symbol ?? name ?? _nepaleseRupee,
        style: .compactShort,
      );

  /// 1234567 => Rs. 12.3L / रु. १२.३ लाख
  ///
  /// A compact currency format, see [NepaliNumberFormat.compact] and
  /// [NepaliNumberFormat.simpleCurrency].
  factory compactSimpleCurrency({Language? language, String? name}) {
    final lang = language ?? NepaliUtils.currentLanguage;
    return .compactCurrency(
      language: lang,
      name: name,
      symbol: _simpleSymbol(name, lang),
    );
  }

  /// Spells numbers out:
  ///
  /// ```text
  /// 123456   => one lakh twenty-three thousand four hundred fifty-six
  ///          => एक लाख तेइस हजार चार सय छपन्न
  /// -12.05   => minus twelve point zero five
  /// ```
  ///
  /// When [currency] is true, the number is an amount of rupees rounded to
  /// the paisa: `123.45` => `one hundred twenty-three rupees forty-five
  /// paisa`.
  ///
  /// When [useDigits] is true, each group is written in digits:
  /// `1 lakh 23 thousand 4 hundred 56` / `१ लाख २३ हजार ४ सय ५६`.
  ///
  /// [parse] isn't supported by this format.
  factory words({
    Language? language,
    bool currency = false,
    bool useDigits = false,
  }) => ._(
    language: language ?? NepaliUtils.currentLanguage,
    pattern: null,
    compiled: null,
    minimumIntegerDigits: 1,
    minimumFractionDigits: 0,
    maximumFractionDigits: currency ? 2 : 3,
    groupSeparator: ',',
    style: currency ? .currencyWords : .words,
    useDigits: useDigits,
  );

  /// The pattern of [NepaliNumberFormat.decimalPattern].
  static const String decimalPatternString = '#,##,##0.###';

  /// The pattern of [NepaliNumberFormat.percentPattern].
  static const String percentPatternString = '#,##,##0%';

  /// The pattern of [NepaliNumberFormat.currency], with a no-break space
  /// after the symbol.
  static const String currencyPatternString = '¤ #,##,##0.00';

  static const String _compactPattern = '#,##,##0';
  static const String _nepaleseRupee = 'NPR';

  static String _simpleSymbol(String? name, Language language) =>
      name == null || name == _nepaleseRupee
      ? symbolsOf(language).numbers.currencySymbol
      : name;

  /// The language used for digits and words.
  final Language language;

  /// The pattern this formatter was created with, or `null` for
  /// [NepaliNumberFormat.words].
  final String? pattern;

  /// The currency code, e.g. `NPR`, for currency formats.
  final String? currencyName;

  /// The symbol shown for `¤`, e.g. `NPR` or `Rs.`.
  final String? currencySymbol;

  /// The minimum number of digits before the decimal point, padded with
  /// zeros.
  final int minimumIntegerDigits;

  /// The minimum number of digits after the decimal point, padded with
  /// zeros.
  final int minimumFractionDigits;

  /// The maximum number of digits after the decimal point; the number is
  /// rounded half away from zero to fit.
  final int maximumFractionDigits;

  /// When set, at least this many significant digits are shown.
  final int? minimumSignificantDigits;

  /// When set, the number is rounded to this many significant digits instead
  /// of [maximumFractionDigits].
  final int? maximumSignificantDigits;

  /// The character(s) between digit groups. Default is `,`.
  final String groupSeparator;

  /// Whether the fraction is shown when all its digits are zero.
  ///
  /// When false, `2.00` is formatted as `2` while `2.01` stays `2.01`.
  /// Default is true.
  final bool includeDecimalIfZero;

  final NumberPattern? _compiled;
  final _Style _style;
  final bool _explicitSign;
  final bool _useDigits;

  /// The fixed number of fraction digits, or `null` when the minimum and
  /// maximum differ.
  int? get decimalDigits => minimumFractionDigits == maximumFractionDigits
      ? maximumFractionDigits
      : null;

  /// Whether numbers are rounded to [maximumSignificantDigits].
  bool get significantDigitsInUse => maximumSignificantDigits != null;

  LanguageSymbols get _symbols => symbolsOf(language);

  /// A copy of this formatter with the given fields replaced.
  ///
  /// When the fraction digits conflict, the one passed wins: e.g. a
  /// [minimumFractionDigits] above the current maximum raises the maximum.
  NepaliNumberFormat copyWith({
    int? minimumIntegerDigits,
    int? minimumFractionDigits,
    int? maximumFractionDigits,
    int? minimumSignificantDigits,
    int? maximumSignificantDigits,
    String? groupSeparator,
    bool? includeDecimalIfZero,
  }) {
    var minFraction = minimumFractionDigits ?? this.minimumFractionDigits;
    var maxFraction = maximumFractionDigits ?? this.maximumFractionDigits;
    if (minFraction > maxFraction) {
      if (maximumFractionDigits != null) {
        minFraction = maxFraction;
      } else {
        maxFraction = minFraction;
      }
    }
    return ._(
      language: language,
      pattern: pattern,
      compiled: _compiled,
      minimumIntegerDigits: minimumIntegerDigits ?? this.minimumIntegerDigits,
      minimumFractionDigits: RangeError.checkNotNegative(minFraction),
      maximumFractionDigits: maxFraction,
      groupSeparator: groupSeparator ?? this.groupSeparator,
      style: _style,
      currencyName: currencyName,
      currencySymbol: currencySymbol,
      minimumSignificantDigits:
          minimumSignificantDigits ?? this.minimumSignificantDigits,
      maximumSignificantDigits:
          maximumSignificantDigits ?? this.maximumSignificantDigits,
      includeDecimalIfZero: includeDecimalIfZero ?? this.includeDecimalIfZero,
      explicitSign: _explicitSign,
      useDigits: _useDigits,
    );
  }

  /// Formats [number].
  ///
  /// [number] is an [int], a [double], a [BigInt] or a numeric [String]
  /// such as `'-1234.5'` or `'1e21'`. Strings keep every digit, which is
  /// useful for amounts of money.
  ///
  /// `NaN` is formatted as `NaN` and infinities as `∞`, except by
  /// [NepaliNumberFormat.words] which throws an [ArgumentError].
  ///
  /// Throws an [ArgumentError] when [number] is of another type or isn't a
  /// number.
  String format(Object number) {
    if (number is double && !number.isFinite) {
      if (_compiled case final compiled?) {
        if (number.isNaN) return 'NaN';
        return _wrap('∞', compiled, negative: number.isNegative);
      }
      throw ArgumentError.value(number, 'number', 'Must be finite');
    }
    final value = Decimal.from(number);
    return switch (_style) {
      .pattern => _formatPattern(value, _compiled!),
      .compactShort || .compactLong => _formatCompact(value, _compiled!),
      .words => NumberWords(
        _symbols,
        useDigits: _useDigits,
      ).format(value.round(maximumFractionDigits)),
      .currencyWords => NumberWords(
        _symbols,
        useDigits: _useDigits,
      ).currency(value),
    };
  }

  /// Parses [text], which may use ASCII or Devanagari digits.
  ///
  /// Returns an [int] when the number is integral and fits, otherwise a
  /// [double]. `NaN` and `∞` give [double.nan] and [double.infinity].
  ///
  /// Grouping separators may appear anywhere in the integer part, spaces
  /// are ignored, and the currency symbol of a currency format is optional.
  ///
  /// Throws a [FormatException] when [text] isn't a number in this format,
  /// and an [UnsupportedError] for [NepaliNumberFormat.words].
  num parse(String text) =>
      tryParse(text) ?? (throw FormatException('Not a number', text));

  /// Like [parse], but returns `null` instead of throwing a
  /// [FormatException].
  num? tryParse(String text) {
    final compiled = _compiled;
    if (compiled == null) {
      throw UnsupportedError('Parsing words is not supported');
    }
    final trimmed = text.trim();
    if (trimmed == 'NaN') return double.nan;
    if (trimmed.contains('∞')) {
      return trimmed.contains(RegExp('[-−]'))
          ? double.negativeInfinity
          : double.infinity;
    }

    final numbers = _symbols.numbers;
    final compact = _style == .compactShort || _style == .compactLong;
    final value = parseNumber(
      text,
      positive: (
        prefix: _affix(compiled.positivePrefix),
        suffix: _affix(compiled.positiveSuffix),
      ),
      negative: (
        prefix: _affix(compiled.negativePrefix),
        suffix: _affix(compiled.negativeSuffix),
      ),
      groupSeparator: groupSeparator,
      multiplierExponent: compiled.multiplierExponent,
      lenient: compiled.hasCurrency,
      suffixExponents: compact
          ? {
              for (final suffixes in [
                numbers.compactLong,
                numbers.compactShort,
              ])
                for (final (i, suffix) in suffixes.indexed)
                  suffix.trim().toLowerCase(): compactExponents[i],
            }
          : const {},
    );
    return value?.toNum();
  }

  String _formatPattern(Decimal value, NumberPattern compiled) {
    final scaled = value.shift(compiled.multiplierExponent);
    final rounded = switch (maximumSignificantDigits) {
      final digits? => scaled.roundSignificant(digits),
      null => scaled.round(maximumFractionDigits),
    };
    return _wrap(
      _digits(rounded, minimumFractionDigits),
      compiled,
      negative: rounded.negative,
    );
  }

  String _formatCompact(Decimal value, NumberPattern compiled) {
    final (:mantissa, :scale) = compact(value);
    final numbers = _symbols.numbers;
    final suffixes = _style == .compactShort
        ? numbers.compactShort
        : numbers.compactLong;
    final digits = _digits(mantissa, 0);
    final text = scale < 0 ? digits : '$digits${suffixes[scale]}';
    final sign = _explicitSign && !mantissa.negative && !mantissa.isZero
        ? '+'
        : '';
    return sign + _wrap(text, compiled, negative: mantissa.negative);
  }

  /// The digits of [value] (ignoring its sign), grouped and localized.
  String _digits(Decimal value, int minimumFraction) {
    final integer = _group(
      value.integerDigits.padLeft(minimumIntegerDigits, '0'),
    );

    var fraction = value.fractionDigits;
    var keep = minimumFraction;
    if (minimumSignificantDigits case final minimum?) {
      final significant = value.integerDigits.isEmpty
          ? fraction.replaceFirst(RegExp('^0+'), '').length
          : value.integerDigits.length + fraction.length;
      if (significant < minimum) {
        fraction = fraction.padRight(
          fraction.length + minimum - significant,
          '0',
        );
      }
      keep = keep > fraction.length ? keep : fraction.length;
    }
    while (fraction.length > keep && fraction.endsWith('0')) {
      fraction = fraction.substring(0, fraction.length - 1);
    }
    fraction = fraction.padRight(keep, '0');
    if (!includeDecimalIfZero && !fraction.contains(RegExp('[1-9]'))) {
      fraction = '';
    }

    final symbols = _symbols;
    return fraction.isEmpty ? integer : '$integer.${symbols.digits(fraction)}';
  }

  /// Localizes [digits] and inserts [groupSeparator] between the groups.
  String _group(String digits) {
    final localized = _symbols.digits(digits);
    final compiled = _compiled!;
    final primary = compiled.groupingSize;
    if (primary <= 0 || localized.length <= primary) return localized;

    final secondary = compiled.secondaryGroupingSize;
    final groups = [localized.substring(localized.length - primary)];
    var end = localized.length - primary;
    while (end > 0) {
      final start = end > secondary ? end - secondary : 0;
      groups.add(localized.substring(start, end));
      end = start;
    }
    return groups.reversed.join(groupSeparator);
  }

  String _wrap(
    String digits,
    NumberPattern compiled, {
    required bool negative,
  }) {
    final prefix = negative ? compiled.negativePrefix : compiled.positivePrefix;
    final suffix = negative ? compiled.negativeSuffix : compiled.positiveSuffix;
    return '${_affix(prefix)}$digits${_affix(suffix)}';
  }

  String _affix(List<AffixPart> parts) => parts
      .map(
        (part) => switch (part) {
          LiteralAffix(:final text) => text,
          CurrencyAffix() => currencySymbol ?? currencyName ?? '',
        },
      )
      .join();

  @override
  String toString() =>
      'NepaliNumberFormat(${pattern ?? _style.name}, ${language.name})';
}
