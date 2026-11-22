// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// A piece of a compiled date format pattern.
sealed class FormatToken;

/// Text copied to the output as-is.
final class LiteralToken(
  /// The literal text.
  final String text,
) implements FormatToken {
  /// Creates a literal token for [text].
  this;
}

/// A run of [count] identical pattern letters, e.g. `MMMM` or `dd`.
final class FieldToken(
  /// The pattern letter, e.g. `M`.
  final String letter,

  /// How many times [letter] is repeated.
  final int count,
) implements FormatToken {
  /// Creates a field token of [count] repetitions of [letter].
  this;

  /// The original pattern text, e.g. `MMMM`.
  String get text => letter * count;
}

// Letters which start a field; the same set as intl's DateFormat.
const String _fieldLetters = 'GyMkSEahKHcLQdDmsvzZ';
const int _quote = 0x27; // '

/// Compiles [pattern] into tokens, using the same rules as `package:intl`:
///
/// * Runs of the same field letter form a [FieldToken] (`hh`, `mm`).
/// * Text between single quotes is literal; `''` is an escaped quote,
///   both inside quoted text and on its own.
/// * Everything else is literal.
List<FormatToken> tokenize(String pattern) {
  final tokens = <FormatToken>[];
  final literal = StringBuffer();

  void flushLiteral() {
    if (literal.isEmpty) return;
    tokens.add(LiteralToken(literal.toString()));
    literal.clear();
  }

  final length = pattern.length;
  var i = 0;
  while (i < length) {
    final char = pattern[i];
    if (pattern.codeUnitAt(i) == _quote) {
      final end = _closingQuote(pattern, i);
      if (end == null) {
        // Unterminated quote: keep the rest verbatim.
        literal.write(pattern.substring(i));
        break;
      }
      final inner = pattern.substring(i + 1, end);
      literal.write(inner.isEmpty ? "'" : inner.replaceAll("''", "'"));
      i = end + 1;
    } else if (_fieldLetters.contains(char)) {
      var end = i + 1;
      while (end < length && pattern[end] == char) {
        end++;
      }
      flushLiteral();
      tokens.add(FieldToken(char, end - i));
      i = end;
    } else {
      literal.write(char);
      i++;
    }
  }
  flushLiteral();
  return List.unmodifiable(tokens);
}

// Index of the quote closing the quoted section opened at start, or null if
// there is none.
int? _closingQuote(String pattern, int start) {
  // `''` on its own is an escaped quote.
  if (start + 1 < pattern.length && pattern.codeUnitAt(start + 1) == _quote) {
    return start + 1;
  }
  var i = start + 1;
  while (i < pattern.length) {
    if (pattern.codeUnitAt(i) == _quote) {
      final escaped =
          i + 1 < pattern.length && pattern.codeUnitAt(i + 1) == _quote;
      if (!escaped) return i;
      i += 2;
    } else {
      i++;
    }
  }
  return null;
}
