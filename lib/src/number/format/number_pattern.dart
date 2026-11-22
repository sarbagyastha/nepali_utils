// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// A piece of a pattern prefix or suffix.
sealed class AffixPart;

/// Text copied to the output as-is.
final class LiteralAffix implements AffixPart {
  /// Creates a literal affix part.
  const new(this.text);

  /// The literal text.
  final String text;
}

/// The `¤` placeholder, replaced by the currency symbol.
final class CurrencyAffix implements AffixPart {
  /// Creates the currency placeholder.
  const new();
}

// The pattern syntax is documented on NepaliNumberFormat.

/// A compiled number pattern, in the syntax of intl's `NumberFormat`.
final class NumberPattern {
  const new _({
    required this.positivePrefix,
    required this.positiveSuffix,
    required this.negativePrefix,
    required this.negativeSuffix,
    required this.minimumIntegerDigits,
    required this.minimumFractionDigits,
    required this.maximumFractionDigits,
    required this.groupingSize,
    required this.secondaryGroupingSize,
    required this.multiplierExponent,
  });

  /// Compiles [pattern].
  ///
  /// Throws a [FormatException] when [pattern] has no digits or is malformed.
  factory parse(String pattern) {
    final subpatterns = _splitUnquoted(pattern);
    if (subpatterns.length > 2) {
      throw FormatException('More than one ";" in pattern', pattern);
    }
    final positive = _Subpattern.parse(subpatterns.first, pattern);
    final negative = subpatterns.length == 2
        ? _Subpattern.parse(subpatterns.last, pattern)
        : null;

    final body = positive.body;
    final dot = body.indexOf('.');
    final integer = dot < 0 ? body : body.substring(0, dot);
    final fraction = dot < 0 ? '' : body.substring(dot + 1);
    if (fraction.contains(',') || fraction.contains('.')) {
      throw FormatException('Malformed fraction in pattern', pattern);
    }

    final groups = integer.split(',');
    final hasGrouping = groups.length > 1;
    final primary = hasGrouping ? groups.last.length : 0;
    final secondary = groups.length > 2
        ? groups[groups.length - 2].length
        : primary;

    return ._(
      positivePrefix: positive.prefix,
      positiveSuffix: positive.suffix,
      negativePrefix:
          negative?.prefix ?? [const LiteralAffix('-'), ...positive.prefix],
      negativeSuffix: negative?.suffix ?? positive.suffix,
      minimumIntegerDigits: '0'.allMatches(integer).length,
      minimumFractionDigits: '0'.allMatches(fraction).length,
      maximumFractionDigits: fraction.length,
      groupingSize: primary,
      secondaryGroupingSize: secondary,
      multiplierExponent: positive.multiplierExponent,
    );
  }

  /// Text before a positive number.
  final List<AffixPart> positivePrefix;

  /// Text after a positive number.
  final List<AffixPart> positiveSuffix;

  /// Text before a negative number.
  final List<AffixPart> negativePrefix;

  /// Text after a negative number.
  final List<AffixPart> negativeSuffix;

  /// Number of `0`s before the decimal point.
  final int minimumIntegerDigits;

  /// Number of `0`s after the decimal point.
  final int minimumFractionDigits;

  /// Number of `0`s and `#`s after the decimal point.
  final int maximumFractionDigits;

  /// Size of the group nearest the decimal point; 0 disables grouping.
  final int groupingSize;

  /// Size of the other groups, e.g. 2 for `#,##,##0`.
  final int secondaryGroupingSize;

  /// 2 for `%`, 3 for `‰`, otherwise 0.
  final int multiplierExponent;

  /// Whether a prefix or suffix contains the currency placeholder.
  bool get hasCurrency => [
    ...positivePrefix,
    ...positiveSuffix,
  ].any((part) => part is CurrencyAffix);
}

// Splits [pattern] on the `;` characters which aren't quoted.
List<String> _splitUnquoted(String pattern) {
  final parts = <String>[];
  var start = 0;
  var quoted = false;
  for (var i = 0; i < pattern.length; i++) {
    final char = pattern[i];
    if (char == "'") {
      quoted = !quoted;
    } else if (char == ';' && !quoted) {
      parts.add(pattern.substring(start, i));
      start = i + 1;
    }
  }
  return parts..add(pattern.substring(start));
}

const String _bodyChars = '#0,.';

final class _Subpattern {
  const new _(this.prefix, this.body, this.suffix, this.multiplierExponent);

  factory parse(String text, String pattern) {
    final prefix = _Affix();
    final suffix = _Affix();
    final body = StringBuffer();
    var section = 0; // 0: prefix, 1: body, 2: suffix.
    var i = 0;
    while (i < text.length) {
      final char = text[i];
      if (section < 2 && _bodyChars.contains(char)) {
        if (char == '0' && body.toString().contains(RegExp(r'\.[0#]*#'))) {
          throw FormatException('"0" after "#" in fraction', pattern);
        }
        section = 1;
        body.write(char);
        i++;
        continue;
      }
      if (section == 1) section = 2;
      final affix = section == 0 ? prefix : suffix;
      if (char == "'") {
        final end = text.indexOf("'", i + 1);
        if (end < 0) throw FormatException('Unterminated quote', pattern);
        affix.write(end == i + 1 ? "'" : text.substring(i + 1, end));
        i = end + 1;
        continue;
      }
      switch (char) {
        case '¤':
          affix.parts.add(const CurrencyAffix());
        case '%':
          affix
            ..write('%')
            ..multiplierExponent = 2;
        case '‰':
          affix
            ..write('‰')
            ..multiplierExponent = 3;
        default:
          affix.write(char);
      }
      i++;
    }
    final digits = body.toString();
    if (!digits.contains(RegExp('[#0]'))) {
      throw FormatException('No digits in pattern', pattern);
    }
    return ._(
      prefix.parts,
      digits,
      suffix.parts,
      prefix.multiplierExponent + suffix.multiplierExponent,
    );
  }

  final List<AffixPart> prefix;
  final String body;
  final List<AffixPart> suffix;
  final int multiplierExponent;
}

final class _Affix {
  final List<AffixPart> parts = [];
  int multiplierExponent = 0;

  void write(String text) {
    if (parts.lastOrNull case LiteralAffix(text: final previous)) {
      parts.last = LiteralAffix('$previous$text');
    } else {
      parts.add(LiteralAffix(text));
    }
  }
}
