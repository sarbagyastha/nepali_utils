// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/nepali_utils.dart';
import 'package:nepali_utils/src/measurement/mixed_units.dart';

const double _tola = 11.6638038;
const double _dharni = 2393.4096;

/// A unit of weight used by [NepaliWeight].
///
/// Gold and silver are weighed in tola-lal, and goods in the market in
/// dharni-ser-pau-chhatak:
///
/// | Unit    | Equals    | Grams        |
/// |---------|-----------|--------------|
/// | tola    | 100 lal   | 11.6638038   |
/// | lal     |           | 0.116638038  |
/// | dharni  | 3 ser     | 2393.4096    |
/// | ser     | 4 pau     | 797.8032     |
/// | pau     | 4 chhatak | 199.4508     |
/// | chhatak |           | 49.8627      |
///
/// The tola is the 180 grain tola and the dharni the one set by Nepal's
/// Standard Measurement and Weight Act, 2025 BS (1968). Local usage varies.
enum WeightUnit(
  final double grams,
  final String _english,
  final String _nepali,
) {
  /// Tola (तोला), 11.6638038 grams.
  tola(_tola, 'tola', 'तोला'),

  /// Lal (लाल), 1/100 tola.
  lal(_tola / 100, 'lal', 'लाल'),

  /// Dharni (धार्नी), 2.3934096 kilograms.
  dharni(_dharni, 'dharni', 'धार्नी'),

  /// Ser (सेर), 1/3 dharni.
  ser(_dharni / 3, 'ser', 'सेर'),

  /// Pau (पाउ), 1/4 ser.
  pau(_dharni / 12, 'pau', 'पाउ'),

  /// Chhatak (छटाक), 1/4 pau.
  chhatak(_dharni / 48, 'chhatak', 'छटाक'),

  /// Grams.
  gram(1, 'g', 'ग्राम'),

  /// Kilograms.
  kilogram(1000, 'kg', 'किलोग्राम');

  /// The name of the unit in [language], e.g. `tola` / `तोला`.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  String label([Language? language]) =>
      (language ?? NepaliUtils.currentLanguage) == .nepali ? _nepali : _english;
}

/// A system of mixed weight units.
enum WeightSystem(final List<WeightUnit> units) {
  /// Tola-lal, used for gold and silver.
  tola([.tola, .lal]),

  /// Dharni-ser-pau-chhatak, used in the market.
  dharni([.dharni, .ser, .pau, .chhatak]);

  List<double> get _factors => [for (final unit in units) unit.grams];
}

/// A weight, convertible between the Nepali units, grams and kilograms.
///
/// ```dart
/// final gold = NepaliWeight.tola(2, lal: 50);
/// gold.to(.gram);                       // 29.1595095
/// gold.tolaParts;                       // (tola: 2, lal: 50.0)
/// gold.format(.tola);                   // 2-50
/// gold.format(.tola, long: true);       // 2 tola 50 lal
///
/// NepaliWeight(5, .kilogram).format(.dharni); // 2-0-1-0.28
/// NepaliWeight.dharni(1, ser: 2).to(.kilogram); // 3.989016
/// NepaliWeight.parse('२-५०', .tola) == gold;    // true
/// ```
///
/// The weight is kept in grams.
///
/// Instances are immutable and compare by weight.
final class NepaliWeight implements Comparable<NepaliWeight> {
  /// A weight of [value] [unit]s.
  factory(num value, WeightUnit unit) => ._(value * unit.grams);

  /// A weight of [tola] tola and [lal] lal.
  factory tola(num tola, {num lal = 0}) =>
      ._(tola * WeightUnit.tola.grams + lal * WeightUnit.lal.grams);

  /// A weight of [dharni] dharni, [ser] ser, [pau] pau and [chhatak]
  /// chhatak.
  factory dharni(num dharni, {num ser = 0, num pau = 0, num chhatak = 0}) => ._(
    dharni * WeightUnit.dharni.grams +
        ser * WeightUnit.ser.grams +
        pau * WeightUnit.pau.grams +
        chhatak * WeightUnit.chhatak.grams,
  );

  const new _(this.grams);

  /// No weight.
  static const NepaliWeight zero = ._(0);

  /// The weight of [text], written as dash separated parts of [system], e.g.
  /// `2-50` or `२-५०` for 2 tola 50 lal, or `1-2-0-3` for 1 dharni 2 ser
  /// 3 chhatak.
  ///
  /// Missing trailing parts are zero, so `1-2` is 1 dharni 2 ser.
  ///
  /// Throws a [FormatException] if [text] isn't valid.
  static NepaliWeight parse(String text, WeightSystem system) =>
      tryParse(text, system) ??
      (throw FormatException('Invalid ${system.name} weight', text));

  /// Like [parse], but returns `null` if [text] isn't valid.
  static NepaliWeight? tryParse(String text, WeightSystem system) =>
      switch (parseParts(text, system._factors)) {
        final value? => ._(value),
        null => null,
      };

  /// The weight in grams.
  final double grams;

  /// The weight in [unit]s.
  double to(WeightUnit unit) => grams / unit.grams;

  /// The weight in whole tola, and the rest in lal.
  ///
  /// The parts of a negative weight are all negative.
  ({int tola, double lal}) get tolaParts {
    final [tola, lal] = _parts(.tola);
    return (tola: tola.toInt(), lal: lal.toDouble());
  }

  /// The weight in whole dharni, ser and pau, and the rest in chhatak.
  ///
  /// The parts of a negative weight are all negative.
  ({int dharni, int ser, int pau, double chhatak}) get dharniParts {
    final [dharni, ser, pau, chhatak] = _parts(.dharni);
    return (
      dharni: dharni.toInt(),
      ser: ser.toInt(),
      pau: pau.toInt(),
      chhatak: chhatak.toDouble(),
    );
  }

  List<num> _parts(WeightSystem system) => signedParts(grams, system._factors);

  /// The weight in the units of [system].
  ///
  /// By default the parts are separated by dashes, e.g. `2-50` for tola-lal.
  /// When [long] is true the units are named and zero parts left out, e.g.
  /// `2 tola 50 lal` / `२ तोला ५० लाल`.
  ///
  /// The last unit has up to [fractionDigits] decimal digits; rounding
  /// carries into the bigger units.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  String format(
    WeightSystem system, {
    bool long = false,
    Language? language,
    int fractionDigits = 2,
  }) {
    final lang = language ?? NepaliUtils.currentLanguage;
    return formatParts(
      grams,
      system._factors,
      [for (final unit in system.units) unit.label(lang)],
      long: long,
      language: lang,
      fractionDigits: fractionDigits,
    );
  }

  /// The sum of this weight and [other].
  NepaliWeight operator +(NepaliWeight other) => ._(grams + other.grams);

  /// The difference of this weight and [other].
  NepaliWeight operator -(NepaliWeight other) => ._(grams - other.grams);

  /// This weight multiplied by [factor].
  NepaliWeight operator *(num factor) => ._(grams * factor);

  /// This weight divided by [divisor].
  NepaliWeight operator /(num divisor) => ._(grams / divisor);

  /// The negation of this weight.
  NepaliWeight operator -() => ._(-grams);

  /// Whether this weight is lighter than [other].
  bool operator <(NepaliWeight other) => grams < other.grams;

  /// Whether this weight is lighter than or equal to [other].
  bool operator <=(NepaliWeight other) => grams <= other.grams;

  /// Whether this weight is heavier than [other].
  bool operator >(NepaliWeight other) => grams > other.grams;

  /// Whether this weight is heavier than or equal to [other].
  bool operator >=(NepaliWeight other) => grams >= other.grams;

  @override
  int compareTo(NepaliWeight other) => grams.compareTo(other.grams);

  @override
  bool operator ==(Object other) =>
      other is NepaliWeight && other.grams == grams;

  @override
  int get hashCode => grams.hashCode;

  @override
  String toString() => 'NepaliWeight($grams g)';
}
