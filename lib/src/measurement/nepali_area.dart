// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/nepali_utils.dart';
import 'package:nepali_utils/src/measurement/mixed_units.dart';

const double _squareMeter = 1 / 0.09290304;

/// A unit of land area used by [NepaliArea].
///
/// Hill land is measured in ropani-aana-paisa-daam and Terai land in
/// bigha-kattha-dhur:
///
/// | Unit   | Equals     | Square feet           | Square metres |
/// |--------|------------|-----------------------|---------------|
/// | ropani | 16 aana    | 5476 (74 × 74)        | ≈ 508.737     |
/// | aana   | 4 paisa    | 342.25                | ≈ 31.796      |
/// | paisa  | 4 daam     | 85.5625               | ≈ 7.949       |
/// | daam   |            | 21.390625             | ≈ 1.987       |
/// | bigha  | 20 kattha  | 72900 (270 × 270)     | ≈ 6772.632    |
/// | kattha | 20 dhur    | 3645                  | ≈ 338.632     |
/// | dhur   |            | 182.25                | ≈ 16.932      |
enum AreaUnit(
  final double squareFeet,
  final String _english,
  final String _nepali,
) {
  /// Ropani (रोपनी), 5476 square feet.
  ropani(5476, 'ropani', 'रोपनी'),

  /// Aana (आना), 1/16 ropani.
  aana(342.25, 'aana', 'आना'),

  /// Paisa (पैसा), 1/4 aana.
  paisa(85.5625, 'paisa', 'पैसा'),

  /// Daam (दाम), 1/4 paisa.
  daam(21.390625, 'daam', 'दाम'),

  /// Bigha (बिघा), 72900 square feet.
  bigha(72900, 'bigha', 'बिघा'),

  /// Kattha (कट्ठा), 1/20 bigha.
  kattha(3645, 'kattha', 'कट्ठा'),

  /// Dhur (धुर), 1/20 kattha.
  dhur(182.25, 'dhur', 'धुर'),

  /// Square feet.
  squareFoot(1, 'sq. ft', 'वर्ग फिट'),

  /// Square metres.
  squareMeter(_squareMeter, 'sq. m', 'वर्ग मिटर'),

  /// Acres, 43560 square feet.
  acre(43560, 'acre', 'एकड'),

  /// Hectares, 10000 square metres.
  hectare(10000 * _squareMeter, 'hectare', 'हेक्टर');

  /// The name of the unit in [language], e.g. `ropani` / `रोपनी`.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  String label([Language? language]) =>
      (language ?? NepaliUtils.currentLanguage) == .nepali ? _nepali : _english;
}

/// A system of mixed land units.
enum AreaSystem(final List<AreaUnit> units) {
  /// Ropani-aana-paisa-daam, used in the hills.
  ropani([.ropani, .aana, .paisa, .daam]),

  /// Bigha-kattha-dhur, used in the Terai.
  bigha([.bigha, .kattha, .dhur]);

  List<double> get _factors => [for (final unit in units) unit.squareFeet];
}

/// An amount of land, convertible between the Nepali units and square feet,
/// square metres, acres and hectares:
///
/// ```dart
/// final plot = NepaliArea.ropani(2, aana: 3, paisa: 1);
/// plot.to(.squareFoot);           // 12064.3125
/// plot.to(.squareMeter);          // 1120.81...
/// plot.ropaniParts;               // (ropani: 2, aana: 3, paisa: 1, daam: 0.0)
/// plot.format(.ropani);           // 2-3-1-0
/// plot.format(.ropani, long: true); // 2 ropani 3 aana 1 paisa
/// plot.format(.bigha, language: .nepali); // ०-३-६.२
///
/// NepaliArea.bigha(1, kattha: 5).to(.ropani); // 16.64...
/// NepaliArea(1000, .squareMeter).format(.ropani); // 1-15-1-3.21
/// NepaliArea.parse('२-३-१-०', .ropani) == plot;   // true
/// ```
///
/// The area is kept in square feet. Every ropani and bigha unit is a whole
/// number of 1/64 square feet, so conversions among them, square feet and
/// acres are exact; those through square metres and hectares are rounded
/// like any [double].
///
/// Instances are immutable and compare by area.
final class NepaliArea implements Comparable<NepaliArea> {
  /// An area of [value] [unit]s.
  factory(num value, AreaUnit unit) => ._(value * unit.squareFeet);

  /// An area of [ropani] ropani, [aana] aana, [paisa] paisa and [daam] daam.
  factory ropani(num ropani, {num aana = 0, num paisa = 0, num daam = 0}) => ._(
    ropani * AreaUnit.ropani.squareFeet +
        aana * AreaUnit.aana.squareFeet +
        paisa * AreaUnit.paisa.squareFeet +
        daam * AreaUnit.daam.squareFeet,
  );

  /// An area of [bigha] bigha, [kattha] kattha and [dhur] dhur.
  factory bigha(num bigha, {num kattha = 0, num dhur = 0}) => ._(
    bigha * AreaUnit.bigha.squareFeet +
        kattha * AreaUnit.kattha.squareFeet +
        dhur * AreaUnit.dhur.squareFeet,
  );

  const new _(this.squareFeet);

  /// No area.
  static const NepaliArea zero = ._(0);

  /// The area of [text], written as dash separated parts of [system], e.g.
  /// `2-3-1-0` or `२-३-१-०` for 2 ropani 3 aana 1 paisa, or `1-5-2.5` for 1
  /// bigha 5 kattha 2.5 dhur.
  ///
  /// Missing trailing parts are zero, so `2-3` is 2 ropani 3 aana.
  ///
  /// Throws a [FormatException] if [text] isn't valid.
  static NepaliArea parse(String text, AreaSystem system) =>
      tryParse(text, system) ??
      (throw FormatException('Invalid ${system.name} area', text));

  /// Like [parse], but returns `null` if [text] isn't valid.
  static NepaliArea? tryParse(String text, AreaSystem system) =>
      switch (parseParts(text, system._factors)) {
        final value? => ._(value),
        null => null,
      };

  /// The area in square feet.
  final double squareFeet;

  /// The area in [unit]s.
  double to(AreaUnit unit) => squareFeet / unit.squareFeet;

  /// The area in whole ropani, aana and paisa, and the rest in daam.
  ///
  /// The parts of a negative area are all negative.
  ({int ropani, int aana, int paisa, double daam}) get ropaniParts {
    final [ropani, aana, paisa, daam] = _parts(.ropani);
    return (
      ropani: ropani.toInt(),
      aana: aana.toInt(),
      paisa: paisa.toInt(),
      daam: daam.toDouble(),
    );
  }

  /// The area in whole bigha and kattha, and the rest in dhur.
  ///
  /// The parts of a negative area are all negative.
  ({int bigha, int kattha, double dhur}) get bighaParts {
    final [bigha, kattha, dhur] = _parts(.bigha);
    return (
      bigha: bigha.toInt(),
      kattha: kattha.toInt(),
      dhur: dhur.toDouble(),
    );
  }

  List<num> _parts(AreaSystem system) =>
      signedParts(squareFeet, system._factors);

  /// The area in the units of [system].
  ///
  /// By default the parts are separated by dashes, e.g. `2-3-1-0` for
  /// ropani-aana-paisa-daam. When [long] is true the units are named and
  /// zero parts left out, e.g. `2 ropani 3 aana 1 paisa` /
  /// `२ रोपनी ३ आना १ पैसा`.
  ///
  /// The last unit has up to [fractionDigits] decimal digits; rounding
  /// carries into the bigger units.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  String format(
    AreaSystem system, {
    bool long = false,
    Language? language,
    int fractionDigits = 2,
  }) {
    final lang = language ?? NepaliUtils.currentLanguage;
    return formatParts(
      squareFeet,
      system._factors,
      [for (final unit in system.units) unit.label(lang)],
      long: long,
      language: lang,
      fractionDigits: fractionDigits,
    );
  }

  /// The sum of this area and [other].
  NepaliArea operator +(NepaliArea other) => ._(squareFeet + other.squareFeet);

  /// The difference of this area and [other].
  NepaliArea operator -(NepaliArea other) => ._(squareFeet - other.squareFeet);

  /// This area multiplied by [factor].
  NepaliArea operator *(num factor) => ._(squareFeet * factor);

  /// This area divided by [divisor].
  NepaliArea operator /(num divisor) => ._(squareFeet / divisor);

  /// The negation of this area.
  NepaliArea operator -() => ._(-squareFeet);

  /// Whether this area is smaller than [other].
  bool operator <(NepaliArea other) => squareFeet < other.squareFeet;

  /// Whether this area is smaller than or equal to [other].
  bool operator <=(NepaliArea other) => squareFeet <= other.squareFeet;

  /// Whether this area is larger than [other].
  bool operator >(NepaliArea other) => squareFeet > other.squareFeet;

  /// Whether this area is larger than or equal to [other].
  bool operator >=(NepaliArea other) => squareFeet >= other.squareFeet;

  @override
  int compareTo(NepaliArea other) => squareFeet.compareTo(other.squareFeet);

  @override
  bool operator ==(Object other) =>
      other is NepaliArea && other.squareFeet == squareFeet;

  @override
  int get hashCode => squareFeet.hashCode;

  @override
  String toString() => 'NepaliArea($squareFeet sq. ft)';
}
