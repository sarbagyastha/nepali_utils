import 'dart:io';

import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils/src/nepali_digits.dart';
import 'package:test/test.dart';

void main() {
  final date = NepaliDateTime(2076, 8, 5, 21, 4, 25, 123, 456);

  test('matches the golden outputs', () {
    final lines = File('test/fixtures/format_golden.tsv').readAsLinesSync();
    expect(lines, isNotEmpty);
    for (final line in lines) {
      final [language, pattern, iso, expected] = line.split('\t');
      final formatter = NepaliDateFormat(
        pattern,
        Language.values.byName(language),
      );
      expect(
        formatter.format(NepaliDateTime.parse(iso)),
        expected,
        reason: '$language "$pattern" $iso',
      );
    }
  });

  test('a formatter can be reused', () {
    final formatter = NepaliDateFormat("EEE, MMM d, ''yy 'at' hh:mm aa");
    final first = formatter.format(date);
    expect(first, "Thursday, Marg 5, '76 at 09:04 PM");
    expect(formatter.format(date), first);
    expect(
      formatter.format(NepaliDateTime(2080)),
      "Friday, Bai 1, '80 at 12:00 AM",
    );
  });

  test('12-hour clock', () {
    final f = NepaliDateFormat('h hh');
    expect(f.format(date.mergeTime(0, 0, 0)), '12 12');
    expect(f.format(date.mergeTime(9, 0, 0)), '9 09');
    expect(f.format(date.mergeTime(12, 0, 0)), '12 12');
    expect(f.format(date.mergeTime(13, 0, 0)), '1 01');
  });

  test('named constructors', () {
    String fmt(NepaliDateFormat f) => f.format(date);
    const en = Language.english;
    expect(fmt(NepaliDateFormat.d(en)), '5');
    expect(fmt(NepaliDateFormat.E(en)), 'Thu');
    expect(fmt(NepaliDateFormat.EEEE(en)), 'Thursday');
    expect(fmt(NepaliDateFormat.yMMMMEEEEd(en)), 'Thursday, Mangsir 5, 2076');
    expect(fmt(NepaliDateFormat.yQQQQ(en)), '3rd quarter 2076');
    expect(fmt(NepaliDateFormat.Hm(en)), '21:04');
    expect(fmt(NepaliDateFormat.Hms(en)), '21:04:25');
    expect(fmt(NepaliDateFormat.jms(en)), '9:04:25 PM');
    expect(fmt(NepaliDateFormat.m(en)), '4');
    expect(fmt(NepaliDateFormat.ms(en)), '04:25');
    expect(fmt(NepaliDateFormat.s(en)), '25');
    expect(fmt(NepaliDateFormat.jm(Language.nepali)), 'बेलुकी ९:०४');
  });

  test('fractional seconds', () {
    expect(NepaliDateFormat('S').format(date), '1');
    expect(NepaliDateFormat('SSS').format(date), '123');
    expect(NepaliDateFormat('SSSSSS').format(date), '123456');
    expect(NepaliDateFormat('SSSSSSS').format(date), '1234560');
    expect(NepaliDateFormat('SSSS', Language.nepali).format(date), '१२३४');
  });

  test('accepts plain DateTime', () {
    final ad = DateTime.utc(2015, 4, 25, 6, 11);
    expect(NepaliDateFormat('y-MM-dd HH:mm').format(ad), '2072-01-12 06:11');
    expect(
      NepaliDateFormat('y-MM-dd HH:mm')
          .format(ad.toNepaliDateTime().toNepalTime()),
      '2072-01-12 11:56',
    );
  });

  test('quotes and unknown letters', () {
    expect(NepaliDateFormat("'o''clock'").format(date), "o'clock");
    expect(NepaliDateFormat("''").format(date), "'");
    expect(NepaliDateFormat('D k').format(date), 'D k');
    expect(
      NepaliDateFormat("y 'unterminated").format(date),
      "2076 'unterminated",
    );
  });

  test('uses the NepaliUtils default language', () {
    addTearDown(() => NepaliUtils(Language.english));
    NepaliUtils(Language.nepali);
    expect(NepaliDateFormat('MMMM d').format(date), 'मंसिर ५');
    expect(NepaliDateFormat.j().format(date), 'बेलुकी ९');
    expect(date.format('y'), '२०७६');
  });

  test('toNepaliDigits matches NepaliUnicode for digits', () {
    expect(toNepaliDigits('0123456789'), NepaliUnicode.convert('0123456789'));
    expect(toNepaliDigits('a1-b2'), 'a१-b२');
    expect(toNepaliDigits('abc'), 'abc');
  });
}
