import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  group('isDevanagari', () {
    test('ignores whitespace and punctuation', () {
      expect(Devanagari.isDevanagari('नमस्ते, संसार!'), isTrue);
      expect(Devanagari.isDevanagari('क्‍ष — “नेपाल”…'), isTrue);
      expect(Devanagari.isDevanagari('२०८१/०१/१५'), isTrue);
    });
    test('is false with other letters or digits', () {
      expect(Devanagari.isDevanagari('नेपाल Nepal'), isFalse);
      expect(Devanagari.isDevanagari('नेपाल 2081'), isFalse);
      expect(Devanagari.isDevanagari('नेपाल 🇳🇵'), isFalse);
    });
    test('is false without Devanagari', () {
      expect(Devanagari.isDevanagari(''), isFalse);
      expect(Devanagari.isDevanagari(' , '), isFalse);
    });
  });

  test('containsDevanagari', () {
    expect(Devanagari.containsDevanagari('Hello नेपाल'), isTrue);
    expect(Devanagari.containsDevanagari('Hello'), isFalse);
  });

  test('digits', () {
    expect(Devanagari.toNepaliDigits('2081/01/15'), '२०८१/०१/१५');
    expect(Devanagari.toEnglishDigits('२०८१/०१/१५'), '2081/01/15');
    expect(Devanagari.toEnglishDigits('नेपाल'), 'नेपाल');
  });

  group('aksharas', () {
    test('keeps clusters with their signs', () {
      expect(Devanagari.aksharas('क्षमा'), ['क्ष', 'मा']);
      expect(Devanagari.aksharas('संस्कृति'), ['सं', 'स्कृ', 'ति']);
      expect(Devanagari.aksharas('प्रधानमन्त्री'), [
        'प्र',
        'धा',
        'न',
        'म',
        'न्त्री',
      ]);
      expect(Devanagari.aksharas('चाँद'), ['चाँ', 'द']);
      expect(Devanagari.aksharas('आँखा'), ['आँ', 'खा']);
    });
    test('a final halant', () {
      expect(Devanagari.aksharas('भगवान्'), ['भ', 'ग', 'वा', 'न्']);
    });
    test('nukta and joiners', () {
      expect(Devanagari.aksharas('क़लम'), ['क़', 'ल', 'म']);
      expect(Devanagari.aksharas('क्‍ष'), ['क्‍ष']);
      expect(Devanagari.aksharas('क्‌'), ['क्‌']);
    });
    test('other characters are items of their own', () {
      expect(Devanagari.aksharas('ok नेपाल!'), [
        'o',
        'k',
        ' ',
        'ने',
        'पा',
        'ल',
        '!',
      ]);
      expect(Devanagari.aksharas('🇳🇵'), ['🇳', '🇵']);
      expect(Devanagari.aksharas(''), isEmpty);
    });
  });
}
