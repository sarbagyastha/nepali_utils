// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/language.dart';

/// Names of the Bikram Sambat months, in [Language] order (Baishakh first).
enum BsMonthName(
  /// English name.
  final String english,

  /// Colloquial English name.
  final String englishAlt,

  /// Abbreviated English name.
  final String englishShort,

  /// Nepali name.
  final String nepali,

  /// Colloquial Nepali name.
  final String nepaliAlt,

  /// Abbreviated Nepali name.
  final String nepaliShort,
) {
  /// Baishakh.
  baishakh('Baishakh', 'Baisak', 'Bai', 'बैशाख', 'बैशाख', 'बै'),

  /// Jestha.
  jestha('Jestha', 'Jeth', 'Jes', 'जेष्ठ', 'जेठ', 'जे'),

  /// Ashadh.
  ashadh('Ashadh', 'Asar', 'Asar', 'आषाढ', 'असार', 'अ'),

  /// Shrawan.
  shrawan('Shrawan', 'Saun', 'Shr', 'श्रावण', 'साउन', 'श्रा'),

  /// Bhadra.
  bhadra('Bhadra', 'Bhadau', 'Bha', 'भाद्र', 'भदौ', 'भा'),

  /// Ashwin.
  ashwin('Ashwin', 'Asoj', 'Ash', 'आश्विन', 'असोज', 'आ'),

  /// Kartik.
  kartik('Kartik', 'Kartik', 'Kar', 'कार्तिक', 'कात्तिक', 'का'),

  /// Mangsir.
  mangsir('Mangsir', 'Marga', 'Marg', 'मंसिर', 'मार्ग', 'मं'),

  /// Poush.
  poush('Poush', 'Pus', 'Pou', 'पौष', 'पुस', 'पौ'),

  /// Magh.
  magh('Magh', 'Magh', 'Mag', 'माघ', 'माघ', 'मा'),

  /// Falgun.
  falgun('Falgun', 'Fagun', 'Fal', 'फाल्गुण', 'फागुन', 'फा'),

  /// Chaitra.
  chaitra('Chaitra', 'Chait', 'Cha', 'चैत्र', 'चैत', 'चै');

  /// The name of [month] (1-12).
  static BsMonthName of(int month) => values[month - 1];

  /// Full name, e.g. Mangsir / मंसिर.
  String full(Language language) => language == .nepali ? nepali : english;

  /// Colloquial name, e.g. Marga / मार्ग.
  String alt(Language language) => language == .nepali ? nepaliAlt : englishAlt;

  /// Abbreviated name, e.g. Marg / मं.
  String short(Language language) =>
      language == .nepali ? nepaliShort : englishShort;

  /// Narrow name, e.g. M / मं.
  String narrow(Language language) =>
      language == .nepali ? nepaliShort : english[0];
}

/// The era, e.g. BS / बि सं, or Bikram Sambat / बिक्रम संबत when [long].
String eraName(Language language, {required bool long}) =>
    switch ((language, long)) {
      (.nepali, false) => 'बि सं',
      (.nepali, true) => 'बिक्रम संबत',
      (_, false) => 'BS',
      (_, true) => 'Bikram Sambat',
    };

/// The [quarter] (1-4), e.g. Q3 or 3rd quarter when [long].
///
/// Nepali uses the same name for both, like `package:intl`'s `ne` locale.
String quarterName(int quarter, Language language, {required bool long}) {
  if (language == .nepali) {
    const names = ['पहिलो', 'दोस्रो', 'तेस्रो', 'चौथो'];
    return '${names[quarter - 1]} त्रैमासिक';
  }
  if (!long) return 'Q$quarter';
  const ordinals = ['1st', '2nd', '3rd', '4th'];
  return '${ordinals[quarter - 1]} quarter';
}

/// Long name of Nepal Time, or of UTC when [nepal] is false.
String longZoneName(Language language, {required bool nepal}) =>
    switch ((nepal, language)) {
      (true, .nepali) => 'नेपाल समय',
      (true, _) => 'Nepal Time',
      (false, .nepali) => 'समन्वित विश्व समय',
      (false, _) => 'Coordinated Universal Time',
    };

/// Names of the week days, Sunday first.
enum WeekdayName(
  /// English name.
  final String english,

  /// English initial.
  final String englishInitial,

  /// Nepali name.
  final String nepali,

  /// Nepali initial.
  final String nepaliInitial,
) {
  /// Sunday.
  sunday('Sunday', 'S', 'आइतबार', 'आ'),

  /// Monday.
  monday('Monday', 'M', 'सोमबार', 'सो'),

  /// Tuesday.
  tuesday('Tuesday', 'T', 'मंगलबार', 'मं'),

  /// Wednesday.
  wednesday('Wednesday', 'W', 'बुधबार', 'बु'),

  /// Thursday.
  thursday('Thursday', 'T', 'बिहिबार', 'बि'),

  /// Friday.
  friday('Friday', 'F', 'शुक्रबार', 'शु'),

  /// Saturday.
  saturday('Saturday', 'S', 'शनिबार', 'श');

  /// The name of [weekday], from Sunday (1) to Saturday (7).
  static WeekdayName of(int weekday) => values[weekday - 1];

  /// Full name, e.g. Thursday / बिहिबार.
  String full(Language language) => language == .nepali ? nepali : english;

  /// Abbreviated name, e.g. Thu / बिहि.
  String short(Language language) => language == .nepali
      ? nepali.replaceFirst('बार', '')
      : english.substring(0, 3);

  /// Initial, e.g. T / बि.
  String initial(Language language) =>
      language == .nepali ? nepaliInitial : englishInitial;
}
