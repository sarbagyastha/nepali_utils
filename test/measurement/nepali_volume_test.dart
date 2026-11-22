import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  group('unit sizes', () {
    test('grain units', () {
      expect(NepaliVolume(1, .muri).to(.pathi), 20);
      expect(NepaliVolume(1, .pathi).to(.mana), 8);
      expect(NepaliVolume(1, .mana).to(.muthi), 10);
      expect(NepaliVolume(1, .muri).to(.mana), 160);
      expect(NepaliVolume(1, .pathi).to(.liter), 4.54596);
    });

    test('round trips through every unit', () {
      const value = 12.34;
      for (final from in VolumeUnit.values) {
        for (final to in VolumeUnit.values) {
          final converted = NepaliVolume(value, from).to(to);
          expect(
            NepaliVolume(converted, to).to(from),
            closeTo(value, 1e-9),
            reason: '$from → $to',
          );
        }
      }
    });
  });

  test('parts', () {
    expect(NepaliVolume.muri(1, pathi: 19, mana: 7, muthi: 9.5).muriParts, (
      muri: 1,
      pathi: 19,
      mana: 7,
      muthi: 9.5,
    ));
    expect(NepaliVolume(-25.5, .pathi).muriParts, (
      muri: -1,
      pathi: -5,
      mana: -4,
      muthi: 0.0,
    ));
  });

  group('format', () {
    final rice = NepaliVolume.muri(1, pathi: 5, mana: 4);

    test('short', () {
      expect(rice.format(language: .english), '1-5-4-0');
      expect(rice.format(language: .nepali), '१-५-४-०');
      expect(NepaliVolume(10, .liter).format(language: .english), '0-2-1-5.98');
    });

    test('long', () {
      expect(
        rice.format(long: true, language: .english),
        '1 muri 5 pathi 4 mana',
      );
      expect(
        rice.format(long: true, language: .nepali),
        '१ मुरी ५ पाथी ४ माना',
      );
    });
  });

  test('parse', () {
    final rice = NepaliVolume.muri(1, pathi: 5, mana: 4);
    expect(NepaliVolume.parse('१-५-४'), rice);
    expect(NepaliVolume.parse(rice.format()), rice);
    expect(NepaliVolume.tryParse('1-2-3-4-5'), isNull);
    expect(() => NepaliVolume.parse('one'), throwsFormatException);
  });

  test('arithmetic and comparison', () {
    final pathi = NepaliVolume(1, .pathi);
    expect(pathi * 20, NepaliVolume(1, .muri));
    expect(
      (NepaliVolume(1, .muri) - pathi * 19).liters,
      closeTo(pathi.liters, 1e-12),
    );
    expect(pathi > NepaliVolume(1, .mana), isTrue);
  });

  test('labels', () {
    expect(VolumeUnit.pathi.label(.english), 'pathi');
    expect(VolumeUnit.pathi.label(.nepali), 'पाथी');
  });
}
