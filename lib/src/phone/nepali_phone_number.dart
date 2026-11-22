// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/nepali_digits.dart';
import 'package:nepali_utils/src/core/nepali_utils.dart';
import 'package:nepali_utils/src/phone/phone_data.dart';

/// The kind of a [NepaliPhoneNumber].
enum PhoneType {
  /// A 10 digit cellular mobile number, e.g. `984-1234567`.
  mobile,

  /// A fixed line (PSTN) number, e.g. `01-4412345` or `061-523456`.
  landline,
}

/// A mobile operator, identified by the first three digits of a mobile
/// number.
///
/// The prefixes are the ones allocated in Nepal Telecommunications
/// Authority's National Numbering Allocation Plan, 2079.
enum MobileOperator(
  final List<String> prefixes,
  final String _english,
  final String _nepali,
) {
  /// Nepal Telecom (Nepal Doorsanchar Company Limited): 974, 975, 976, 984,
  /// 985 and 986.
  nepalTelecom(
    ['974', '975', '976', '984', '985', '986'],
    'Nepal Telecom',
    'नेपाल टेलिकम',
  ),

  /// Ncell: 970, 980, 981 and 982.
  ncell(['970', '980', '981', '982'], 'Ncell', 'एनसेल'),

  /// Smart Telecom: 961, 962 and 988.
  smart(['961', '962', '988'], 'Smart Telecom', 'स्मार्ट टेलिकम'),

  /// United Telecom Limited (UTL): 972.
  utl(['972'], 'UTL', 'युटिएल');

  /// The name of the operator in [language], e.g. `Ncell` / `एनसेल`.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  String label([Language? language]) =>
      (language ?? NepaliUtils.currentLanguage) == .nepali ? _nepali : _english;

  /// The operator of mobile numbers starting with [prefix], e.g. `984`, or
  /// `null` if the prefix isn't allocated.
  static MobileOperator? forPrefix(String prefix) {
    for (final operator in values) {
      if (operator.prefixes.contains(prefix)) return operator;
    }
    return null;
  }
}

/// How [NepaliPhoneNumber.format] writes a number.
enum PhoneFormat {
  /// As dialled inside Nepal: `984-1234567`, `01-4412345`, `061-523456`.
  national,

  /// With the country code: `+977 984-1234567`, `+977 1-4412345`.
  international,

  /// E.164, without separators: `+9779841234567`, `+97714412345`.
  e164,
}

/// A valid Nepali mobile or landline phone number.
///
/// Use it to validate, format and find phone numbers in text:
///
/// ```dart
/// final phone = NepaliPhoneNumber.parse('+977 ९८४१२३४५६७');
/// phone.type;                     // PhoneType.mobile
/// phone.operator;                 // MobileOperator.nepalTelecom
/// phone.format();                 // 984-1234567
/// phone.format(style: .international); // +977 984-1234567
/// phone.e164;                     // +9779841234567
///
/// final office = NepaliPhoneNumber.parse('061 523456');
/// office.areaCode;                // 061
/// office.areaName();              // Kaski
///
/// NepaliPhoneNumber.isValid('9801234567');       // true
/// NepaliPhoneNumber.isValid('9901234567');       // false
///
/// NepaliPhoneNumber.findAll('Call 9841234567 or 01-4412345.')
///     .map((match) => match.number.format()); // (984-1234567, 01-4412345)
/// ```
///
/// Accepted input:
/// * ASCII or Devanagari digits.
/// * An optional country code: `+977`, `00977` or `977`. After it, the
///   landline's leading `0` may be kept or left out.
/// * Spaces, `-`, `.`, `(` and `)` anywhere between the digits.
///
/// Mobile numbers have 10 digits, and their first three must be a prefix
/// allocated to a [MobileOperator]. Landline numbers have a trunk `0`
/// followed by 8 digits: area code `1` (Kathmandu Valley) and 7 digits, or a
/// two digit area code and 6 digits. The digit after the area code is the
/// operator code, `4`, `5` or `6`.
///
/// Instances are immutable and compare by [nationalNumber].
final class NepaliPhoneNumber {
  const new _(this.nationalNumber, this.type);

  /// Parses [text] as a Nepali phone number.
  ///
  /// See [NepaliPhoneNumber] for the accepted input.
  ///
  /// Throws a [FormatException] if [text] isn't a valid Nepali phone number.
  factory parse(String text) =>
      tryParse(text) ?? (throw FormatException('Invalid phone number', text));

  /// Like [NepaliPhoneNumber.parse], but returns `null` if [text] isn't a
  /// valid Nepali phone number.
  static NepaliPhoneNumber? tryParse(String text) {
    final ascii = toEnglishDigits(text.trim());
    if (!_allowed.hasMatch(ascii)) return null;
    final digits = ascii.replaceAll(_nonDigits, '');
    if (ascii.startsWith('+') || ascii.startsWith('(+')) {
      return digits.startsWith('977')
          ? _international(digits.substring(3))
          : null;
    }
    if (digits.startsWith('00977')) return _international(digits.substring(5));
    return _national(digits) ??
        (digits.startsWith('977') ? _international(digits.substring(3)) : null);
  }

  /// Whether [text] is a valid Nepali phone number, of [type] if given.
  static bool isValid(String text, {PhoneType? type}) {
    final number = tryParse(text);
    return number != null && (type == null || number.type == type);
  }

  /// Whether [text] is a valid Nepali mobile number.
  static bool isMobile(String text) => isValid(text, type: .mobile);

  /// Whether [text] is a valid Nepali landline number.
  static bool isLandline(String text) => isValid(text, type: .landline);

  /// Finds the phone numbers in [text], of [type] if given, in order.
  ///
  /// Numbers can be written in any form [NepaliPhoneNumber.parse] accepts.
  /// A number must not be preceded by a digit, a Latin letter or `+`, nor
  /// followed by a digit, so `98412345678` and `ID9841234567` have no
  /// matches. Devanagari text may follow directly, e.g. `९८४१२३४५६७मा`.
  ///
  /// ```dart
  /// final matches = NepaliPhoneNumber.findAll('Call 9841234567 now');
  /// matches.single.start; // 5
  /// matches.single.number.format(); // 984-1234567
  /// ```
  static Iterable<PhoneNumberMatch> findAll(
    String text, {
    PhoneType? type,
  }) sync* {
    for (final run in _run.allMatches(text)) {
      final groups = _digitGroup.allMatches(run[0]!).toList();
      var i = 0;
      while (i < groups.length) {
        // Try the longest candidate first, so `+977 984 1234567` is one
        // number rather than nothing.
        var last = i;
        var digits = groups[i].end - groups[i].start;
        while (last + 1 < groups.length) {
          final next = groups[last + 1];
          if (digits + next.end - next.start > _maxDigits) break;
          digits += next.end - next.start;
          last++;
        }
        PhoneNumberMatch? match;
        for (var j = last; j >= i && match == null; j--) {
          final start = run.start + (i == 0 ? 0 : groups[i].start);
          final end = run.start + groups[j].end;
          final candidate = text.substring(start, end);
          if (tryParse(candidate) case final number?) {
            match = ._(start, end, candidate, number);
            i = j + 1;
          }
        }
        if (match == null) {
          i++;
        } else if (type == null || match.number.type == type) {
          yield match;
        }
      }
    }
  }

  /// Returns [text] with every phone number found by [findAll] replaced by
  /// the result of [replace].
  ///
  /// When [type] is given, only numbers of that type are replaced.
  ///
  /// ```dart
  /// NepaliPhoneNumber.replaceAll(
  ///   'Call 9841234567',
  ///   (match) => '${match.text.substring(0, 3)}*******',
  /// ); // Call 984*******
  /// ```
  static String replaceAll(
    String text,
    String Function(PhoneNumberMatch match) replace, {
    PhoneType? type,
  }) {
    final buffer = StringBuffer();
    var last = 0;
    for (final match in findAll(text, type: type)) {
      buffer
        ..write(text.substring(last, match.start))
        ..write(replace(match));
      last = match.end;
    }
    return (buffer..write(text.substring(last))).toString();
  }

  /// The number as dialled inside Nepal, without separators, e.g.
  /// `9841234567` or `014412345`.
  final String nationalNumber;

  /// Whether this is a mobile or a landline number.
  final PhoneType type;

  /// The operator of a mobile number, or `null` for a landline.
  MobileOperator? get operator => switch (type) {
    .mobile => MobileOperator.forPrefix(nationalNumber.substring(0, 3)),
    .landline => null,
  };

  /// The area code of a landline number with its trunk `0`, e.g. `01` or
  /// `061`, or `null` for a mobile number.
  String? get areaCode => switch (type) {
    .mobile => null,
    .landline when nationalNumber[1] == '1' && _isOperatorCode(2) => '01',
    .landline => nationalNumber.substring(0, 3),
  };

  /// The district(s) served by the [areaCode] in [language], e.g. `Kaski` /
  /// `कास्की`.
  ///
  /// Returns `null` for a mobile number, or an area code that isn't listed.
  /// [language] defaults to [NepaliUtils.currentLanguage].
  String? areaName([Language? language]) {
    final (english, nepali) = areaCodes[areaCode] ?? (null, null);
    return (language ?? NepaliUtils.currentLanguage) == .nepali
        ? nepali
        : english;
  }

  /// The number in E.164 format, e.g. `+9779841234567` or `+97714412345`.
  String get e164 => '+977$_significant';

  // The number without the landline's trunk `0`.
  String get _significant => switch (type) {
    .mobile => nationalNumber,
    .landline => nationalNumber.substring(1),
  };

  /// Formats the number in [style]: `984-1234567`, `+977 984-1234567` or
  /// `+9779841234567`.
  ///
  /// Digits are Devanagari when [language] is Nepali, e.g. `९८४-१२३४५६७`.
  /// [language] defaults to [NepaliUtils.currentLanguage].
  String format({PhoneFormat style = .national, Language? language}) {
    final split = areaCode?.length ?? 3;
    final prefix = nationalNumber.substring(0, split);
    final subscriber = nationalNumber.substring(split);
    final text = switch (style) {
      .national => '$prefix-$subscriber',
      // The landline's trunk `0` isn't dialled after the country code.
      .international =>
        '+977 ${type == .landline ? prefix.substring(1) : prefix}-$subscriber',
      .e164 => e164,
    };
    return (language ?? NepaliUtils.currentLanguage) == .nepali
        ? toNepaliDigits(text)
        : text;
  }

  bool _isOperatorCode(int index) =>
      _operatorCodes.contains(nationalNumber[index]);

  @override
  bool operator ==(Object other) =>
      other is NepaliPhoneNumber && other.nationalNumber == nationalNumber;

  @override
  int get hashCode => nationalNumber.hashCode;

  @override
  String toString() => format(language: .english);

  static NepaliPhoneNumber? _international(String rest) => rest.startsWith('9')
      ? _mobile(rest)
      : _landline(rest.startsWith('0') ? rest : '0$rest');

  static NepaliPhoneNumber? _national(String digits) => switch (digits) {
    _ when digits.startsWith('9') => _mobile(digits),
    _ when digits.startsWith('0') => _landline(digits),
    _ => null,
  };

  static NepaliPhoneNumber? _mobile(String digits) =>
      digits.length == 10 &&
          MobileOperator.forPrefix(digits.substring(0, 3)) != null
      ? ._(digits, .mobile)
      : null;

  static NepaliPhoneNumber? _landline(String digits) {
    if (digits.length != 9 || digits[1] == '0') return null;
    final kathmandu = digits[1] == '1' && _operatorCodes.contains(digits[2]);
    return kathmandu || _operatorCodes.contains(digits[3])
        ? ._(digits, .landline)
        : null;
  }
}

/// A phone number found in text by [NepaliPhoneNumber.findAll].
final class PhoneNumberMatch {
  const new _(this.start, this.end, this.text, this.number);

  /// The index of the first character of the number in the searched text.
  final int start;

  /// The index after the last character of the number in the searched text.
  final int end;

  /// The number as written, e.g. `+977 ९८४-१२३४५६७`.
  final String text;

  /// The parsed number.
  final NepaliPhoneNumber number;

  @override
  String toString() => 'PhoneNumberMatch($start-$end: $text)';
}

const String _operatorCodes = '456';

// The most digits a number can be written with: `00977` and 10 digits.
const int _maxDigits = 15;

const String _separatorChars = ' \\t\\-.()\u00A0\u202F';

final RegExp _allowed = RegExp('^\\(?\\+?[0-9$_separatorChars]+\$');
final RegExp _nonDigits = RegExp('[^0-9]');

final RegExp _run = RegExp(
  '(?<![0-9०-९A-Za-z+])\\+?[0-9०-९]+(?:[$_separatorChars]{1,3}[0-9०-९]+)*',
);
final RegExp _digitGroup = RegExp('[0-9०-९]+');
