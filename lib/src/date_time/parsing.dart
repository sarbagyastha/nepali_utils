// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Components of a parsed date-time string.
typedef ParsedDateTime = ({
  int year,
  int month,
  int day,
  int hour,
  int minute,
  int second,
  int millisecond,
  int microsecond,

  /// `null` when the input had no time zone designator, otherwise the
  /// offset from UTC in minutes (`Z` is 0).
  int? offsetMinutes,
});

/// Same grammar as [DateTime.parse].
final RegExp _parseFormat = RegExp(
  r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)' // Day part.
  r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,](\d+))?)?)?' // Time part.
  r'( ?[zZ]| ?([-+])(\d\d)(?::?(\d\d))?)?)?$', // Time zone part.
);

/// Parses [input] using the grammar of [DateTime.parse].
///
/// Returns `null` if [input] doesn't match.
ParsedDateTime? parseDateTime(String input) {
  if (_parseFormat.firstMatch(input) case final match?) {
    int intOrZero(int group) => switch (match[group]) {
      final String digits => int.parse(digits),
      null => 0,
    };

    // Only the first 6 fractional digits are significant (microseconds).
    final fraction = switch (match[7]) {
      final String digits => int.parse(
        digits.length > 6 ? digits.substring(0, 6) : digits.padRight(6, '0'),
      ),
      null => 0,
    };

    final offsetMinutes = switch ((match[8], match[9])) {
      (null, _) => null,
      (_, null) => 0, // 'Z'
      (_, final String sign) =>
        (sign == '-' ? -1 : 1) * (intOrZero(10) * 60 + intOrZero(11)),
    };

    return (
      year: int.parse(match[1]!),
      month: int.parse(match[2]!),
      day: int.parse(match[3]!),
      hour: intOrZero(4),
      minute: intOrZero(5),
      second: intOrZero(6),
      millisecond: fraction ~/ 1000,
      microsecond: fraction % 1000,
      offsetMinutes: offsetMinutes,
    );
  }
  return null;
}
