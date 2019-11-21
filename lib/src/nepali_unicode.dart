// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Converts English literal (Roman Literals) into Nepali Unicode.
class NepaliUnicode {
  static String _text;

  /// Converts sepecifies [text] into nepali literals.
  ///
  /// if live is true, texts will convert in live manner.
  /// i.e. as you go on typing
  /// Default for live is false.
  static String convert(String text, {bool live = false}) {
    if (live) {
      return _unicode(text);
    }
    _text = '';
    for (var index = 0; index < text.length; index++) {
      if (index == 0) {
        _text = _unicode(text[0]);
      } else {
        _text = _unicode(_text + text[index]);
      }
    }
    return _text;
  }

  static String _unicode(String data) {
    _text = data;
    _replace('a', '\u0905');
    _replace('A', '\u0906');
    _replaceRunes('\u0905\u0905', '\u0906');
    _replace('i', '\u0907');
    _replace('I', '\u0908');
    _replaceRunes('\u0907\u0907', '\u0908');
    _replace('u', '\u0909');
    _replace('U', '\u090a');
    _replaceRunes('\u0909\u0909', '\u090a');
    _replace('e', '\u090f');
    _replace('E', '\u0910');
    _replaceRunes('\u0905\u0907', '\u0910');
    _replace('o', '\u0913');
    _replace('O', '\u0913');
    _replaceRunes('\u0905\u0909', '\u0914');
    _replaceRunes('\u094d\u0905', '\u200b');
    _replaceRunes('\u094d\u0906', '\u093e');
    _replaceRunes('\u200b\u0905', '\u093e');
    _replaceRunes('\u094d\u0907', '\u093f');
    _replaceRunes('\u094d\u0908', '\u0940');
    _replaceRunes('\u093f\u0907', '\u0940');
    _replaceRunes('\u0941\u0909', '\u0942');
    _replaceRunes('\u200b\u0909', '\u094C');
    _replaceRunes('\u094d\u0909', '\u0941');
    _replaceRunes('\u094d\u090a', '\u0942');
    _replaceRunes('\u094d\u090f', '\u0947');
    _replaceRunes('\u094d\u0910', '\u0948');
    _replaceRunes('\u200b\u0907', '\u0948');
    _replaceRunes('\u094d\u0913', '\u094b');
    _replaceRunes('\u094d ', '\u0020');
    _replaceRunes('\u094d\u090b', '\u0943');
    _replaceRunes('\u094d\u0960', '\u0944');
    _replaceRunes('\u094d\u090c', '\u0962');
    _replaceRunes('\u094d-\u0930\u094d', '\u0943');
    _replaceRunes('-\u0930\u094d', '\u090b');
    _replaceRunes('\u090b\u0907', '\u0960');
    _replaceRunes('\u0943\u0907', '\u0944');
    _replaceRunes('-\u0932\u094d', '\u090c');
    _replace('k', '\u0915\u094d');
    _replace('K', '\u0915\u094d');
    _replace('q', '\u0915\u094d');
    _replace('Q', '\u0915\u094d');
    _replace('g', '\u0917\u094d');
    _replace('G', '\u0917\u094d');
    _replace('c', '\u091a\u094d');
    _replace('C', '\u091a\u094d');
    _replace('j', '\u091c\u094d');
    _replace('J', '\u091c\u094d');
    _replace('z', '\u091c\u094d');
    _replace('Z', '\u091c\u094d');
    _replace('T', '\u091f\u094d');
    _replace('D', '\u0921\u094d');
    _replace('N', '\u0923\u094d');
    _replace('t', '\u0924\u094d');
    _replace('d', '\u0926\u094d');
    _replace('n', '\u0928\u094d');
    _replace('p', '\u092a\u094d');
    _replace('P', '\u092a\u094d');
    _replace('f', '\u092b\u094d');
    _replace('F', '\u092b\u094d');
    _replace('b', '\u092c\u094d');
    _replace('B', '\u092c\u094d');
    _replace('m', '\u092e\u094d');
    _replace('M', '\u092e\u094d');
    _replace('y', '\u092f\u094d');
    _replace('Y', '\u092f\u094d');
    _replace('r', '\u0930\u094d');
    _replace('R', '\u0930\u094d');
    _replace('l', '\u0932\u094d');
    _replace('L', '\u0932\u094d');
    _replace('v', '\u0935\u094d');
    _replace('V', '\u0935\u094d');
    _replace('w', '\u0935\u094d');
    _replace('W', '\u0935\u094d');
    _replace('s', '\u0938\u094d');
    _replace('S', '\u0937\u094d');
    _replace('h', '\u0939\u094d');
    _replace('H', '\u0939\u094d');
    _replaceRunes('\u0915\u094d\u0939\u094d', '\u0916\u094d');
    _replaceRunes('\u0917\u094d\u0939\u094d', '\u0918\u094d');
    _replaceRunes('\u0928\u094d\u0917\u094d', '\u0919\u094d');
    _replaceRunes('\u091a\u094d\u0939\u094d', '\u091b\u094d');
    _replaceRunes('\u091b\u094d\u0939', '\u091b\u094d');
    _replaceRunes('\u091c\u094d\u0939\u094d', '\u091d\u094d');
    _replaceRunes('\u092f\u094d\u0928', '\u091e\u094d');
    _replaceRunes('\u0928\u094d\u091c\u094d', '\u091e\u094d');
    _replaceRunes('\u091f\u094d\u0939\u094d', '\u0920\u094d');
    _replaceRunes('\u095c\u094d\u0939\u094d', '\u095d\u094d');
    _replaceRunes('\u0921\u094d\u0939\u094d', '\u0922\u094d');
    _replaceRunes('\u0924\u094d\u0939\u094d', '\u0925\u094d');
    _replaceRunes('\u0926\u094d\u0939\u094d', '\u0927\u094d');
    _replaceRunes('\u092a\u094d\u0939\u094d', '\u092b\u094d');
    _replaceRunes('\u092c\u094d\u0939\u094d', '\u092d\u094d');
    _replaceRunes('\u0938\u094d\u0939\u094d', '\u0936\u094d');
    _replaceRunes('\u0937\u094d\u0939\u094d', '\u0936\u094d');
    _replaceRunes('\u0915\u094d\u091b\u094d\u092f', '\u0915\u094d\u0937\u094d');
    _replaceRunes('\u0917\u094d\u092f', '\u091c\u094d\u091e\u094d');
    _replace('x', '\u0915\u094d\u0938\u094d');
    _replace('X', '\u0915\u094d\u0938\u094d');
    _replaceRunes('\u200b\u0915', '\u0915');
    _replaceRunes('\u200b\u0916', '\u0916');
    _replaceRunes('\u200b\u0917', '\u0917');
    _replaceRunes('\u200b\u0918', '\u0918');
    _replaceRunes('\u200b\u0919', '\u0919');
    _replaceRunes('\u200b\u091a', '\u091a');
    _replaceRunes('\u200b\u091b', '\u091b');
    _replaceRunes('\u200b\u091c', '\u091c');
    _replaceRunes('\u200b\u091d', '\u091d');
    _replaceRunes('\u200b\u091e', '\u091e');
    _replaceRunes('\u200b\u091f', '\u091f');
    _replaceRunes('\u200b\u0920', '\u0920');
    _replaceRunes('\u200b\u0921', '\u0921');
    _replaceRunes('\u200b\u0922', '\u0922');
    _replaceRunes('\u200b\u0923', '\u0923');
    _replaceRunes('\u200b\u0924', '\u0924');
    _replaceRunes('\u200b\u0925', '\u0925');
    _replaceRunes('\u200b\u0926', '\u0926');
    _replaceRunes('\u200b\u0927', '\u0927');
    _replaceRunes('\u200b\u0928', '\u0928');
    _replaceRunes('\u200b\u092a', '\u092a');
    _replaceRunes('\u200b\u092b', '\u092b');
    _replaceRunes('\u200b\u092c', '\u092c');
    _replaceRunes('\u200b\u092d', '\u092d');
    _replaceRunes('\u200b\u092e', '\u092f');
    _replaceRunes('\u200b\u0930', '\u0930');
    _replaceRunes('\u200b\u0932', '\u0932');
    _replaceRunes('\u200b\u0935', '\u0935');
    _replaceRunes('\u200b\u0938', '\u0938');
    _replaceRunes('\u200b\u0937', '\u0937');
    _replaceRunes('\u200b\u0936', '\u0936');
    _replaceRunes('\u200b\u0939', '\u0939');
    _replaceRunes('\u200b\u0915\u094d\u0937', '\u0915\u094d\u0937');
    _replaceRunes('\u200b\u0924\u094d\u0930', '\u0924\u094d\u0930');
    _replaceRunes('\u200b\u091c\u094d\u091e', '\u091c\u094d\u091e');
    _replace('\'', '\u0902');
    _replaceRunes('\u094d\u0902', '\u0902');
    _replaceRunes('\u0902\u0902', '\u0901');
    _replaceRunes('\u0913\u092e\u094d', '\u0950');
    _replaceRunes('\u0950\u0902', '\u0950');
    _replaceRunes('\u200b ', '\u0020');
    _replaceRunes('\u200b\\u0902', '\u0902');
    _replaceRunes('\u200b\\u0903', '\u0903');
    _replace(':', '\u0903');
    _replaceRunes('\u094d\u0903', '\u0903');
    _replace('.', '\u0964');
    _replace('|', '\u0964');
    _replace('/', '\u0964');
    _replace('\\', '\u0964');
    _replaceRunes('\u0964\u0964', '\u0965');
    _replace('0', '\u0966');
    _replace('1', '\u0967');
    _replace('2', '\u0968');
    _replace('3', '\u0969');
    _replace('4', '\u096a');
    _replace('5', '\u096b');
    _replace('6', '\u096c');
    _replace('7', '\u096d');
    _replace('8', '\u096e');
    _replace('9', '\u096f');
    _replaceRunes('\u0939\u094d\u0910', '\u0939\u0948');
    _replaceRunes('\u0939\u094d\u0910', '\u0939\u0948');
    _replaceRunes('\u0919\u094d\u0939\u094d', '\u0939\u0902');
    _replaceRunes('\u0919\u094d\u0939', '\u0939\u0902');
    return _text;
  }

  static _replace(x, y) {
    _text = _text.replaceAll(
      x,
      String.fromCharCodes(
        Runes(y),
      ),
    );
  }

  static _replaceRunes(x, y) {
    _text = _text.replaceAll(
      String.fromCharCodes(Runes(x)),
      String.fromCharCodes(
        Runes(y),
      ),
    );
  }
}
