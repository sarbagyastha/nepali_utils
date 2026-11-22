import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  group('mobile', () {
    test('operators', () {
      const expected = {
        '9741234567': MobileOperator.nepalTelecom,
        '9751234567': MobileOperator.nepalTelecom,
        '9761234567': MobileOperator.nepalTelecom,
        '9841234567': MobileOperator.nepalTelecom,
        '9851234567': MobileOperator.nepalTelecom,
        '9861234567': MobileOperator.nepalTelecom,
        '9701234567': MobileOperator.ncell,
        '9801234567': MobileOperator.ncell,
        '9811234567': MobileOperator.ncell,
        '9821234567': MobileOperator.ncell,
        '9611234567': MobileOperator.smart,
        '9621234567': MobileOperator.smart,
        '9881234567': MobileOperator.smart,
        '9721234567': MobileOperator.utl,
      };
      for (final MapEntry(:key, :value) in expected.entries) {
        final number = NepaliPhoneNumber.parse(key);
        expect(number.type, PhoneType.mobile, reason: key);
        expect(number.operator, value, reason: key);
        expect(number.areaCode, isNull);
        expect(number.areaName(), isNull);
      }
    });

    test('accepted spellings', () {
      final expected = NepaliPhoneNumber.parse('9841234567');
      for (final text in [
        '984-1234567',
        '984 123 4567',
        '984.123.4567',
        '(984) 1234567',
        ' 9841234567 ',
        '९८४१२३४५६७',
        '९८४-१२३४५६७',
        '+9779841234567',
        '+977 984-1234567',
        '+977-9841234567',
        '(+977) 9841234567',
        '009779841234567',
        '9779841234567',
        '+९७७ ९८४१२३४५६७',
      ]) {
        expect(NepaliPhoneNumber.tryParse(text), expected, reason: text);
      }
    });

    test('invalid', () {
      for (final text in [
        '',
        '984123456', // 9 digits
        '98412345678', // 11 digits
        '9901234567', // unallocated prefix
        '9631234567', // unallocated prefix
        '9001234567', // IoT range
        '09841234567', // trunk 0 on a mobile
        '+9789841234567', // other country
        '+97809841234567',
        '98412a4567',
        '984+1234567',
        '984_1234567',
      ]) {
        expect(NepaliPhoneNumber.tryParse(text), isNull, reason: text);
      }
      expect(
        () => NepaliPhoneNumber.parse('123'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('landline', () {
    test('Kathmandu Valley', () {
      final number = NepaliPhoneNumber.parse('01-4412345');
      expect(number.type, PhoneType.landline);
      expect(number.nationalNumber, '014412345');
      expect(number.areaCode, '01');
      expect(number.operator, isNull);
      expect(number.areaName(.english), 'Kathmandu Valley');
      expect(number.areaName(.nepali), 'काठमाडौं उपत्यका');
      expect(number.e164, '+97714412345');
    });

    test('outside the valley', () {
      final number = NepaliPhoneNumber.parse('061-523456');
      expect(number.areaCode, '061');
      expect(number.areaName(.english), 'Kaski');
      expect(number.areaName(.nepali), 'कास्की');
      expect(number.e164, '+97761523456');
    });

    test('unlisted area codes are valid without a name', () {
      final number = NepaliPhoneNumber.parse('087-520123');
      expect(number.areaCode, '087');
      expect(number.areaName(), isNull);
    });

    test('accepted spellings', () {
      final expected = NepaliPhoneNumber.parse('014412345');
      for (final text in [
        '01 4412345',
        '01-441-2345',
        '(01) 4412345',
        '०१-४४१२३४५',
        '+977 1 4412345',
        '+977-1-4412345',
        '+977-01-4412345',
        '+97714412345',
        '0097714412345',
        '97714412345',
      ]) {
        expect(NepaliPhoneNumber.tryParse(text), expected, reason: text);
      }
    });

    test('invalid', () {
      for (final text in [
        '01-3312345', // operator code must be 4, 5 or 6
        '061-323456',
        '01-441234', // too short
        '01-44123456', // too long
        '001-4412345',
        '4412345', // no area code
        '+977-001-4412345',
      ]) {
        expect(NepaliPhoneNumber.tryParse(text), isNull, reason: text);
      }
    });
  });

  test('isValid, isMobile and isLandline', () {
    expect(NepaliPhoneNumber.isValid('9841234567'), isTrue);
    expect(NepaliPhoneNumber.isValid('01-4412345'), isTrue);
    expect(NepaliPhoneNumber.isValid('9901234567'), isFalse);
    expect(NepaliPhoneNumber.isValid('9841234567', type: .landline), isFalse);
    expect(NepaliPhoneNumber.isMobile('9841234567'), isTrue);
    expect(NepaliPhoneNumber.isMobile('01-4412345'), isFalse);
    expect(NepaliPhoneNumber.isLandline('01-4412345'), isTrue);
    expect(NepaliPhoneNumber.isLandline('9841234567'), isFalse);
  });

  group('format', () {
    final mobile = NepaliPhoneNumber.parse('9841234567');
    final valley = NepaliPhoneNumber.parse('014412345');
    final pokhara = NepaliPhoneNumber.parse('061523456');

    test('English', () {
      expect(mobile.format(language: .english), '984-1234567');
      expect(valley.format(language: .english), '01-4412345');
      expect(pokhara.format(language: .english), '061-523456');

      const international = PhoneFormat.international;
      expect(
        mobile.format(style: international, language: .english),
        '+977 984-1234567',
      );
      expect(
        valley.format(style: international, language: .english),
        '+977 1-4412345',
      );
      expect(
        pokhara.format(style: international, language: .english),
        '+977 61-523456',
      );

      expect(mobile.format(style: .e164, language: .english), '+9779841234567');
      expect(valley.format(style: .e164, language: .english), '+97714412345');
    });

    test('Nepali', () {
      expect(mobile.format(language: .nepali), '९८४-१२३४५६७');
      expect(
        valley.format(style: .international, language: .nepali),
        '+९७७ १-४४१२३४५',
      );
    });

    test('defaults to the current language', () {
      NepaliUtils.withLanguage(.nepali, () {
        expect(mobile.format(), '९८४-१२३४५६७');
        expect(mobile.operator!.label(), 'नेपाल टेलिकम');
      });
      NepaliUtils.withLanguage(.english, () {
        expect(mobile.format(), '984-1234567');
        expect(mobile.operator!.label(), 'Nepal Telecom');
      });
    });

    test('formatted numbers parse back', () {
      for (final number in [mobile, valley, pokhara]) {
        for (final style in PhoneFormat.values) {
          for (final language in Language.values) {
            final text = number.format(style: style, language: language);
            expect(NepaliPhoneNumber.parse(text), number, reason: text);
          }
        }
      }
    });

    test('toString', () {
      expect(mobile.toString(), '984-1234567');
    });
  });

  test('equality', () {
    expect(
      NepaliPhoneNumber.parse('+977 ९८४१२३४५६७'),
      NepaliPhoneNumber.parse('984-1234567'),
    );
    expect(
      NepaliPhoneNumber.parse('+977 ९८४१२३४५६७').hashCode,
      NepaliPhoneNumber.parse('984-1234567').hashCode,
    );
    expect(
      NepaliPhoneNumber.parse('9841234567'),
      isNot(NepaliPhoneNumber.parse('9851234567')),
    );
  });

  group('findAll', () {
    List<(String, String)> found(String text, {PhoneType? type}) => [
      for (final match in NepaliPhoneNumber.findAll(text, type: type))
        (match.text, match.number.nationalNumber),
    ];

    test('in English text', () {
      const text = 'Call 9841234567 or +977-1-4412345, fax (061) 523456.';
      expect(found(text), [
        ('9841234567', '9841234567'),
        ('+977-1-4412345', '014412345'),
        ('061) 523456', '061523456'),
      ]);
    });

    test('positions', () {
      const text = 'Call 984-1234567 now';
      final [match] = NepaliPhoneNumber.findAll(text).toList();
      expect(match.start, 5);
      expect(match.end, 16);
      expect(text.substring(match.start, match.end), match.text);
    });

    test('in Nepali text', () {
      const text = 'सम्पर्क: ९८४१२३४५६७ वा ०१-४४१२३४५मा फोन गर्नुहोस्।';
      expect(found(text), [
        ('९८४१२३४५६७', '9841234567'),
        ('०१-४४१२३४५', '014412345'),
      ]);
    });

    test('numbers separated only by spaces', () {
      expect(found('9841234567 9851234567'), [
        ('9841234567', '9841234567'),
        ('9851234567', '9851234567'),
      ]);
      expect(found('1234 9841234567'), [('9841234567', '9841234567')]);
    });

    test('numbers on separate lines', () {
      expect(found('9841234567\n9851234567'), [
        ('9841234567', '9841234567'),
        ('9851234567', '9851234567'),
      ]);
    });

    test('no partial matches', () {
      expect(found('98412345678'), isEmpty);
      expect(found('19841234567'), isEmpty);
      expect(found('ID9841234567'), isEmpty);
      expect(found('Order 9901234567'), isEmpty);
      expect(found('Total 2,500,000'), isEmpty);
    });

    test('type filter', () {
      const text = '9841234567, 01-4412345';
      expect(found(text, type: .mobile), [('9841234567', '9841234567')]);
      expect(found(text, type: .landline), [('01-4412345', '014412345')]);
    });

    test('empty and plain text', () {
      expect(found(''), isEmpty);
      expect(found('no numbers here'), isEmpty);
    });
  });

  test('replaceAll', () {
    expect(
      NepaliPhoneNumber.replaceAll(
        'Call 984-1234567 or 01-4412345.',
        (match) => match.number.format(style: .e164, language: .english),
      ),
      'Call +9779841234567 or +97714412345.',
    );
    expect(
      NepaliPhoneNumber.replaceAll(
        'Call 9841234567 or 01-4412345.',
        (match) => '*' * match.text.length,
        type: .mobile,
      ),
      'Call ********** or 01-4412345.',
    );
  });
}
