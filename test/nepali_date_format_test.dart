// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  final date = NepaliDateTime(2076, 8, 5, 21, 4, 25);

  group('NepaliDateFormat time format tests:', () {
    test('H', () {
      expect(NepaliDateFormat.H().format(date), '21');
      expect(
        NepaliDateFormat.H(Language.nepali).format(date),
        '२१',
      );
    });

    test('Hm', () {
      expect(NepaliDateFormat.Hm().format(date), '21:04');
      expect(
        NepaliDateFormat.Hm(Language.nepali).format(date),
        '२१:०४',
      );
    });

    test('Hms', () {
      expect(NepaliDateFormat.Hms().format(date), '21:04:25');
      expect(
        NepaliDateFormat.Hms(Language.nepali).format(date),
        '२१:०४:२५',
      );
    });

    test('m', () {
      expect(NepaliDateFormat.m().format(date), '4');
      expect(
        NepaliDateFormat.m(Language.nepali).format(date),
        '४',
      );
    });

    test('ms', () {
      expect(NepaliDateFormat.ms().format(date), '04:25');
      expect(
        NepaliDateFormat.ms(Language.nepali).format(date),
        '०४:२५',
      );
    });

    test('s', () {
      expect(NepaliDateFormat.s().format(date), '25');
      expect(
        NepaliDateFormat.s(Language.nepali).format(date),
        '२५',
      );
    });

    test('j, jm, jms in English', () {
      expect(NepaliDateFormat.j().format(date), '9 PM');
      expect(NepaliDateFormat.jm().format(date), '9:04 PM');
      expect(NepaliDateFormat.jms().format(date), '9:04:25 PM');
    });

    test('j, jm, jms in Nepali', () {
      expect(NepaliDateFormat.j(Language.nepali).format(date), 'बेलुकी ९');
      expect(
        NepaliDateFormat.jm(Language.nepali).format(date),
        'बेलुकी ९:०४',
      );
      expect(
        NepaliDateFormat.jms(Language.nepali).format(date),
        'बेलुकी ९:०४:२५',
      );
    });
  });

  group('NepaliDateFormat date & month format tests:', () {
    test('yMd', () {
      expect(NepaliDateFormat.yMd().format(date), '2076/08/05');
      expect(
        NepaliDateFormat.yMd(Language.nepali).format(date),
        '२०७६/०८/०५',
      );
    });

    test('yMMMMd', () {
      expect(NepaliDateFormat.yMMMMd().format(date), 'Mangsir 5, 2076');
      expect(
        NepaliDateFormat.yMMMMd(Language.nepali).format(date),
        'मंसिर ५, २०७६',
      );
    });

    test('month names across patterns', () {
      expect(NepaliDateFormat.MMM().format(date), 'Marg');
      expect(NepaliDateFormat.MMMM().format(date), 'Mangsir');
      expect(NepaliDateFormat('MMMMM').format(date), 'Marga');
      expect(NepaliDateFormat.MMM(Language.nepali).format(date), 'मं');
      expect(NepaliDateFormat.MMMM(Language.nepali).format(date), 'मंसिर');
      expect(
        NepaliDateFormat('MMMMM', Language.nepali).format(date),
        'मार्ग',
      );
    });

    test('weekday names', () {
      expect(NepaliDateFormat.E().format(date), 'Thu');
      expect(NepaliDateFormat.EEEE().format(date), 'Thursday');
      expect(NepaliDateFormat.E(Language.nepali).format(date), 'बिहि');
      expect(NepaliDateFormat.EEEE(Language.nepali).format(date), 'बिहिबार');
    });
  });
}
