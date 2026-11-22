import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  group('MPP romanized', () {
    const unicode = NepaliUnicode(style: .mppRomanized);

    test('maps each key', () {
      expect(
        unicode.convert('abcdefghijklmnopqrstuvwxyz'),
        'ाबछदेउगहिजकलमनोपटरसतुवौडयष',
      );
      expect(
        unicode.convert('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
        'आभचधैऊघअीझखळंणओफठृशथूँऔढञऋ',
      );
      expect(unicode.convert('0123456789'), '०१२३४५६७८९');
      expect(unicode.convert(r'`~_+=[{]}\|<.>/'), 'ऽ़॒‌‍इईएऐॐःङ।॥्');
    });
    test('writes words', () {
      expect(unicode.convert('nepal'), 'नेपाल');
      expect(unicode.convert('kQmaxw'), 'कठमाडौ');
      expect(unicode.convert('ram/'), 'राम्');
    });
    test('keeps other keys', () {
      expect(unicode.convert('-?!, '), '-?!, ');
    });
    test('nepaliDigits: false keeps digits', () {
      expect(
        const NepaliUnicode(
          style: .mppRomanized,
          nepaliDigits: false,
        ).convert('2081'),
        '2081',
      );
    });
    test('toRoman gives the keys', () {
      expect(unicode.toRoman('नेपाल'), 'nepal');
      expect(unicode.toRoman('राम्'), 'ram/');
      expect(unicode.convertLive('nepal'), 'नेपाल');
    });
  });

  group('MPP traditional', () {
    const unicode = NepaliUnicode(style: .mppTraditional);

    test('writes words', () {
      expect(unicode.convert('g]kfn'), 'नेपाल');
      expect(unicode.convert('sf7df8B|'), 'का७मा८ौं');
      expect(unicode.convert('If!'), 'क्षाज्ञ');
    });
    test('toRoman gives the keys', () {
      expect(unicode.toRoman('नेपाल'), 'g]kfn');
      expect(unicode.toRoman('क्षत्र'), 'Iq');
    });
  });
}
