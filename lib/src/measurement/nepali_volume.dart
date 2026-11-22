// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/core/language/language.dart';
import 'package:nepali_utils/src/core/nepali_utils.dart';
import 'package:nepali_utils/src/measurement/mixed_units.dart';

const double _pathi = 4.54596;

/// A unit of volume used by [NepaliVolume].
///
/// Grain is measured in muri-pathi-mana-muthi:
///
/// | Unit  | Equals   | Litres     |
/// |-------|----------|------------|
/// | muri  | 20 pathi | 90.9192    |
/// | pathi | 8 mana   | 4.54596    |
/// | mana  | 10 muthi | 0.568245   |
/// | muthi |          | 0.0568245  |
///
/// The pathi is the one set by Nepal's Standard Measurement and Weight Act,
/// 2025 BS (1968). Local usage varies.
enum VolumeUnit(
  final double liters,
  final String _english,
  final String _nepali,
) {
  /// Muri (मुरी), 20 pathi.
  muri(20 * _pathi, 'muri', 'मुरी'),

  /// Pathi (पाथी), 4.54596 litres.
  pathi(_pathi, 'pathi', 'पाथी'),

  /// Mana (माना), 1/8 pathi.
  mana(_pathi / 8, 'mana', 'माना'),

  /// Muthi (मुठी), 1/10 mana.
  muthi(_pathi / 80, 'muthi', 'मुठी'),

  /// Litres.
  liter(1, 'L', 'लिटर');

  /// The name of the unit in [language], e.g. `pathi` / `पाथी`.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  String label([Language? language]) =>
      (language ?? NepaliUtils.currentLanguage) == .nepali ? _nepali : _english;
}

const List<VolumeUnit> _units = [.muri, .pathi, .mana, .muthi];
final List<double> _factors = [for (final unit in _units) unit.liters];

/// A volume of grain, convertible between muri, pathi, mana, muthi and
/// litres:
///
/// ```dart
/// final rice = NepaliVolume.muri(1, pathi: 5, mana: 4);
/// rice.to(.pathi);                // 25.5
/// rice.to(.liter);                // 115.92198
/// rice.muriParts;                 // (muri: 1, pathi: 5, mana: 4, muthi: 0.0)
/// rice.format();                  // 1-5-4-0
/// rice.format(long: true);        // 1 muri 5 pathi 4 mana
/// rice.format(language: .nepali); // १-५-४-०
///
/// NepaliVolume(10, .liter).format(); // 0-2-1-5.98
/// NepaliVolume.parse('१-५-४') == rice; // true
/// ```
///
/// The volume is kept in litres.
///
/// Instances are immutable and compare by volume.
final class NepaliVolume implements Comparable<NepaliVolume> {
  /// A volume of [value] [unit]s.
  factory(num value, VolumeUnit unit) => ._(value * unit.liters);

  /// A volume of [muri] muri, [pathi] pathi, [mana] mana and [muthi] muthi.
  factory muri(num muri, {num pathi = 0, num mana = 0, num muthi = 0}) => ._(
    muri * VolumeUnit.muri.liters +
        pathi * VolumeUnit.pathi.liters +
        mana * VolumeUnit.mana.liters +
        muthi * VolumeUnit.muthi.liters,
  );

  const new _(this.liters);

  /// No volume.
  static const NepaliVolume zero = ._(0);

  /// The volume of [text], written as dash separated muri-pathi-mana-muthi,
  /// e.g. `1-5-4-0` or `१-५-४-०` for 1 muri 5 pathi 4 mana.
  ///
  /// Missing trailing parts are zero, so `1-5` is 1 muri 5 pathi.
  ///
  /// Throws a [FormatException] if [text] isn't valid.
  static NepaliVolume parse(String text) =>
      tryParse(text) ?? (throw FormatException('Invalid volume', text));

  /// Like [parse], but returns `null` if [text] isn't valid.
  static NepaliVolume? tryParse(String text) =>
      switch (parseParts(text, _factors)) {
        final value? => ._(value),
        null => null,
      };

  /// The volume in litres.
  final double liters;

  /// The volume in [unit]s.
  double to(VolumeUnit unit) => liters / unit.liters;

  /// The volume in whole muri, pathi and mana, and the rest in muthi.
  ///
  /// The parts of a negative volume are all negative.
  ({int muri, int pathi, int mana, double muthi}) get muriParts {
    final [muri, pathi, mana, muthi] = signedParts(liters, _factors);
    return (
      muri: muri.toInt(),
      pathi: pathi.toInt(),
      mana: mana.toInt(),
      muthi: muthi.toDouble(),
    );
  }

  /// The volume in muri-pathi-mana-muthi.
  ///
  /// By default the parts are separated by dashes, e.g. `1-5-4-0`. When
  /// [long] is true the units are named and zero parts left out, e.g.
  /// `1 muri 5 pathi 4 mana` / `१ मुरी ५ पाथी ४ माना`.
  ///
  /// Muthi have up to [fractionDigits] decimal digits; rounding carries into
  /// the bigger units.
  ///
  /// [language] defaults to [NepaliUtils.currentLanguage].
  String format({
    bool long = false,
    Language? language,
    int fractionDigits = 2,
  }) {
    final lang = language ?? NepaliUtils.currentLanguage;
    return formatParts(
      liters,
      _factors,
      [for (final unit in _units) unit.label(lang)],
      long: long,
      language: lang,
      fractionDigits: fractionDigits,
    );
  }

  /// The sum of this volume and [other].
  NepaliVolume operator +(NepaliVolume other) => ._(liters + other.liters);

  /// The difference of this volume and [other].
  NepaliVolume operator -(NepaliVolume other) => ._(liters - other.liters);

  /// This volume multiplied by [factor].
  NepaliVolume operator *(num factor) => ._(liters * factor);

  /// This volume divided by [divisor].
  NepaliVolume operator /(num divisor) => ._(liters / divisor);

  /// The negation of this volume.
  NepaliVolume operator -() => ._(-liters);

  /// Whether this volume is smaller than [other].
  bool operator <(NepaliVolume other) => liters < other.liters;

  /// Whether this volume is smaller than or equal to [other].
  bool operator <=(NepaliVolume other) => liters <= other.liters;

  /// Whether this volume is larger than [other].
  bool operator >(NepaliVolume other) => liters > other.liters;

  /// Whether this volume is larger than or equal to [other].
  bool operator >=(NepaliVolume other) => liters >= other.liters;

  @override
  int compareTo(NepaliVolume other) => liters.compareTo(other.liters);

  @override
  bool operator ==(Object other) =>
      other is NepaliVolume && other.liters == liters;

  @override
  int get hashCode => liters.hashCode;

  @override
  String toString() => 'NepaliVolume($liters L)';
}
