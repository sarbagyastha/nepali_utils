import 'dart:io';

import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils/src/core/nepali_digits.dart';
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
    final formatter = NepaliDateFormat("EEEE, MMM d, ''yy 'at' hh:mm a");
    final first = formatter.format(date);
    expect(first, "Thursday, Marg 5, '76 at 09:04 PM");
    expect(formatter.format(date), first);
    expect(
      formatter.format(NepaliDateTime(2080)),
      "Friday, Bai 1, '80 at 12:00 AM",
    );
  });

  test('hour letters h, H, K and k', () {
    final f = NepaliDateFormat('h hh H HH K KK k kk');
    expect(f.format(date.mergeTime(0, 0, 0)), '12 12 0 00 0 00 24 24');
    expect(f.format(date.mergeTime(9, 0, 0)), '9 09 9 09 9 09 9 09');
    expect(f.format(date.mergeTime(12, 0, 0)), '12 12 12 12 0 00 12 12');
    expect(f.format(date.mergeTime(13, 0, 0)), '1 01 13 13 1 01 13 13');
  });

  group('named constructors', () {
    String fmt(NepaliDateFormat f) => f.format(date);
    const en = Language.english;
    const ne = Language.nepali;

    test('english follows the intl en skeletons', () {
      final expected = {
        NepaliDateFormat.d(en): '5',
        NepaliDateFormat.E(en): 'Thu',
        NepaliDateFormat.EEEE(en): 'Thursday',
        NepaliDateFormat.EEEEE(en): 'T',
        NepaliDateFormat.LLL(en): 'Marg',
        NepaliDateFormat.LLLL(en): 'Mangsir',
        NepaliDateFormat.M(en): '8',
        NepaliDateFormat.Md(en): '8/5',
        NepaliDateFormat.MEd(en): 'Thu, 8/5',
        NepaliDateFormat.MMM(en): 'Marg',
        NepaliDateFormat.MMMd(en): 'Marg 5',
        NepaliDateFormat.MMMEd(en): 'Thu, Marg 5',
        NepaliDateFormat.MMMM(en): 'Mangsir',
        NepaliDateFormat.MMMMd(en): 'Mangsir 5',
        NepaliDateFormat.MMMMEEEEd(en): 'Thursday, Mangsir 5',
        NepaliDateFormat.QQQ(en): 'Q3',
        NepaliDateFormat.QQQQ(en): '3rd quarter',
        NepaliDateFormat.y(en): '2076',
        NepaliDateFormat.yM(en): '8/2076',
        NepaliDateFormat.yMd(en): '8/5/2076',
        NepaliDateFormat.yMEd(en): 'Thu, 8/5/2076',
        NepaliDateFormat.yMMM(en): 'Marg 2076',
        NepaliDateFormat.yMMMd(en): 'Marg 5, 2076',
        NepaliDateFormat.yMMMEd(en): 'Thu, Marg 5, 2076',
        NepaliDateFormat.yMMMM(en): 'Mangsir 2076',
        NepaliDateFormat.yMMMMd(en): 'Mangsir 5, 2076',
        NepaliDateFormat.yMMMMEEEEd(en): 'Thursday, Mangsir 5, 2076',
        NepaliDateFormat.yQQQ(en): 'Q3 2076',
        NepaliDateFormat.yQQQQ(en): '3rd quarter 2076',
        NepaliDateFormat.H(en): '21',
        NepaliDateFormat.Hm(en): '21:04',
        NepaliDateFormat.Hms(en): '21:04:25',
        NepaliDateFormat.j(en): '9\u202fPM',
        NepaliDateFormat.jm(en): '9:04\u202fPM',
        NepaliDateFormat.jms(en): '9:04:25\u202fPM',
        NepaliDateFormat.m(en): '4',
        NepaliDateFormat.ms(en): '04:25',
        NepaliDateFormat.s(en): '25',
      };
      for (final MapEntry(key: f, :value) in expected.entries) {
        expect(fmt(f), value, reason: f.pattern);
      }
    });

    test('nepali follows the intl ne skeletons', () {
      final expected = {
        NepaliDateFormat.d(ne): '५',
        NepaliDateFormat.E(ne): 'बिहि',
        NepaliDateFormat.EEEE(ne): 'बिहिबार',
        NepaliDateFormat.EEEEE(ne): 'बि',
        NepaliDateFormat.Md(ne): '०८-०५',
        NepaliDateFormat.MEd(ne): '०८-०५, बिहि',
        NepaliDateFormat.MMMd(ne): 'मं ५',
        NepaliDateFormat.MMMMEEEEd(ne): 'मंसिर ५, बिहिबार',
        NepaliDateFormat.QQQQ(ne): 'तेस्रो त्रैमासिक',
        NepaliDateFormat.yM(ne): '२०७६-०८',
        NepaliDateFormat.yMd(ne): '२०७६-०८-०५',
        NepaliDateFormat.yMEd(ne): '२०७६-०८-०५, बिहि',
        NepaliDateFormat.yMMMd(ne): '२०७६ मं ५',
        NepaliDateFormat.yMMMMd(ne): '२०७६ मंसिर ५',
        NepaliDateFormat.yMMMMEEEEd(ne): '२०७६ मंसिर ५, बिहिबार',
        NepaliDateFormat.yQQQ(ne): '२०७६ तेस्रो त्रैमासिक',
        NepaliDateFormat.H(ne): '२१',
        NepaliDateFormat.j(ne): '२१',
        NepaliDateFormat.jm(ne): '२१:०४',
        NepaliDateFormat.jms(ne): '२१:०४:२५',
        NepaliDateFormat.ms(ne): '०४:२५',
      };
      for (final MapEntry(key: f, :value) in expected.entries) {
        expect(fmt(f), value, reason: f.pattern);
      }
    });

    test('time zone skeletons', () {
      final npt = NepaliDateTime.nepal(2076, 8, 5, 21, 4, 25);
      final utc = NepaliDateTime.utc(2076, 8, 5, 21, 4, 25);
      expect(NepaliDateFormat.jmv(en).format(npt), '9:04\u202fPM NPT');
      expect(NepaliDateFormat.jmz(en).format(utc), '9:04\u202fPM UTC');
      expect(NepaliDateFormat.jv(en).format(npt), '9\u202fPM NPT');
      expect(NepaliDateFormat.jz(ne).format(npt), '२१h NPT');
      expect(NepaliDateFormat.jmz(ne).format(npt), '२१:०४ NPT');
    });

    test('a skeleton passed to the default constructor is resolved', () {
      expect(NepaliDateFormat('yMd', en).pattern, 'M/d/y');
      expect(NepaliDateFormat('yMd', ne).pattern, 'y-MM-dd');
      expect(NepaliDateFormat('y/MM/dd', en).pattern, 'y/MM/dd');
      expect(
        NepaliDateFormat(NepaliDateFormat.YEAR_MONTH_DAY, en).format(date),
        'Mangsir 5, 2076',
      );
    });
  });

  group('addPattern', () {
    const en = Language.english;

    test('appends resolved skeletons and raw patterns', () {
      final f = NepaliDateFormat.yMd(en).add_jms();
      expect(f.pattern, 'M/d/y h:mm:ss\u202fa');
      expect(f.format(date), '8/5/2076 9:04:25\u202fPM');
      expect(
        NepaliDateFormat.yMMMd(en).addPattern("'at' HH:mm").format(date),
        'Marg 5, 2076 at 21:04',
      );
      expect(NepaliDateFormat.Hm(en).addPattern('ss', ':').pattern, 'HH:mm:ss');
    });

    test('returns a new formatter', () {
      final base = NepaliDateFormat.yMd(en);
      final added = base.add_Hm();
      expect(base.pattern, 'M/d/y');
      expect(added.pattern, 'M/d/y HH:mm');
      expect(identical(base.addPattern(null), base), isTrue);
    });

    test('without a pattern uses yMMMMd jms, and add_* replaces it', () {
      expect(NepaliDateFormat(null, en).pattern, 'MMMM d, y h:mm:ss\u202fa');
      expect(
        NepaliDateFormat(null, en).format(date),
        'Mangsir 5, 2076 9:04:25\u202fPM',
      );
      expect(NepaliDateFormat(null, en).add_yMd().pattern, 'M/d/y');
    });
  });

  test('fractional seconds', () {
    expect(NepaliDateFormat('S').format(date), '123');
    expect(NepaliDateFormat('SS').format(date), '123');
    expect(NepaliDateFormat('SSS').format(date), '123');
    expect(NepaliDateFormat('SSSS').format(date), '1234');
    expect(NepaliDateFormat('SSSSSS').format(date), '123456');
    expect(NepaliDateFormat('SSSSSSS').format(date), '1234560');
    expect(NepaliDateFormat('SSSS', Language.nepali).format(date), '१२३४');
  });

  test('era, quarter, month and weekday widths', () {
    const ne = Language.nepali;
    String en(String p) => NepaliDateFormat(p, Language.english).format(date);
    String np(String p) => NepaliDateFormat(p, ne).format(date);

    expect(['G', 'GG', 'GGG', 'GGGG'].map(en), [
      'BS',
      'BS',
      'BS',
      'Bikram Sambat',
    ]);
    expect(np('G'), 'बि सं');
    expect(np('GGGG'), 'बिक्रम संबत');

    expect(['Q', 'QQ', 'QQQ', 'QQQQ'].map(en), [
      '3',
      '03',
      'Q3',
      '3rd quarter',
    ]);
    expect(['Q', 'QQ', 'QQQ'].map(np), ['३', '०३', 'तेस्रो त्रैमासिक']);

    expect(['M', 'MM', 'MMM', 'MMMM', 'MMMMM', 'MMMMMM'].map(en), [
      '8',
      '08',
      'Marg',
      'Mangsir',
      'M',
      'Marga',
    ]);
    expect(['L', 'LL', 'LLL', 'LLLL', 'LLLLL', 'LLLLLL'].map(np), [
      '८',
      '०८',
      'मं',
      'मंसिर',
      'मं',
      'मार्ग',
    ]);

    expect(['E', 'EE', 'EEE', 'EEEE', 'EEEEE'].map(en), [
      'Thu',
      'Thu',
      'Thu',
      'Thursday',
      'T',
    ]);
    expect(() => en('EEEEEE'), throwsUnsupportedError);
    expect(['c', 'cc', 'ccc', 'cccc', 'ccccc'].map(en), [
      '5',
      '5',
      'Thu',
      'Thursday',
      'T',
    ]);
    expect(np('cccc'), 'बिहिबार');
  });

  test('day of year', () {
    var expected = date.day;
    for (var month = 1; month < date.month; month++) {
      expected += NepaliDateTime(date.year, month).totalDays;
    }
    expect(NepaliDateFormat('D').format(date), '$expected');
    expect(NepaliDateFormat('D').format(NepaliDateTime(2080)), '1');
    expect(NepaliDateFormat('DDD').format(NepaliDateTime(2080, 1, 9)), '009');
    final lastDay = NepaliDateTime(
      2080,
      12,
      NepaliDateTime(2080, 12).totalDays,
    );
    expect(
      NepaliDateFormat('D').format(lastDay),
      '${NepaliDateTime(2080).totalDaysInYear}',
    );
  });

  test('AM/PM marker', () {
    const ne = Language.nepali;
    for (final pattern in ['a', 'aa', 'aaa']) {
      expect(NepaliDateFormat(pattern).format(date), 'PM');
      expect(NepaliDateFormat(pattern).format(date.mergeTime(9, 0, 0)), 'AM');
    }
    String np(int hour) =>
        NepaliDateFormat('a', ne).format(date.mergeTime(hour, 0, 0));
    expect([9, 12, 14, 18, 21].map(np), [
      'बिहान',
      'मध्यान्न',
      'दिउसो',
      'साँझ',
      'बेलुकी',
    ]);
  });

  test('time zones', () {
    const ne = Language.nepali;
    final npt = NepaliDateTime.nepal(2076, 8, 5, 21, 4);
    final utc = NepaliDateTime.utc(2076, 8, 5, 21, 4);
    String fmt(String p, DateTime d, [Language l = .english]) =>
        NepaliDateFormat(p, l).format(d);

    expect(fmt('z', npt), 'NPT');
    expect(fmt('v', npt), 'NPT');
    expect(fmt('zzzz', npt), 'Nepal Time');
    expect(fmt('zzzz', npt, ne), 'नेपाल समय');
    expect(fmt('z', utc), 'UTC');
    expect(fmt('zzzz', utc), 'Coordinated Universal Time');
    expect(fmt('Z', npt), '+0545');
    expect(fmt('ZZZZ', npt), 'GMT+05:45');
    expect(fmt('ZZZZZ', npt), '+05:45');
    expect(fmt('Z', npt, ne), '+०५४५');
    expect(fmt('Z', utc), '+0000');
    expect(fmt('ZZZZ', utc), 'GMT');
    expect(fmt('ZZZZZ', utc), 'Z');

    final local = NepaliDateTime(2076, 8, 5, 21, 4);
    expect(fmt('z', local), local.timeZoneName);
    expect(fmt('zzzz', local), local.timeZoneName);
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

  test('quotes and literals', () {
    expect(NepaliDateFormat("'o''clock'").format(date), "o'clock");
    expect(NepaliDateFormat("''").format(date), "'");
    expect(NepaliDateFormat('j-x').format(date), 'j-x');
    expect(
      NepaliDateFormat("y 'unterminated").format(date),
      "2076 'unterminated",
    );
  });

  test('uses the NepaliUtils default language', () {
    addTearDown(() => NepaliUtils.defaultLanguage = .english);
    NepaliUtils.defaultLanguage = .nepali;
    expect(NepaliDateFormat('MMMM d').format(date), 'मंसिर ५');
    expect(NepaliDateFormat.yMd().format(date), '२०७६-०८-०५');
    expect(NepaliDateFormat.j().format(date), '२१');
    expect(date.format('y'), '२०७६');
  });

  test('uses the NepaliUtils.withLanguage override', () {
    NepaliUtils.withLanguage(.nepali, () {
      expect(NepaliDateFormat('MMMM d').format(date), 'मंसिर ५');
      expect(date.format('y'), '२०७६');
    });
    expect(NepaliDateFormat('MMMM d').format(date), 'Mangsir 5');
  });

  test('toNepaliDigits matches NepaliUnicode for digits', () {
    expect(
      toNepaliDigits('0123456789'),
      const NepaliUnicode().convert('0123456789'),
    );
    expect(toNepaliDigits('a1-b2'), 'a१-b२');
    expect(toNepaliDigits('abc'), 'abc');
  });
}
