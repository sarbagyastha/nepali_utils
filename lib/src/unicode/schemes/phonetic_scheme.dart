// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nepali_utils/src/unicode/devanagari_chars.dart';
import 'package:nepali_utils/src/unicode/token_trie.dart';

/// What a romanized token writes.
enum TokenKind {
  /// A consonant (or a fixed cluster such as क्ष) that takes a halant before
  /// another consonant and a matra before a vowel.
  consonant,

  /// A vowel: the independent letter, or its matra after a consonant.
  vowel,

  /// A sign that follows a syllable, like ं; it leaves a consonant bare.
  sign,

  /// A standalone symbol, like । or ॐ.
  symbol,

  /// An explicit halant on the consonant before it.
  halant,
}

/// A romanized token.
final class PhoneticToken {
  /// Creates a token.
  const new(
    this.kind,
    this.text, {
    this.matra = '',
    this.independentOnly = false,
  });

  /// What the token writes.
  final TokenKind kind;

  /// The Devanagari text, or the independent letter for a vowel.
  final String text;

  /// The matra of a vowel, empty for the inherent `a`.
  final String matra;

  /// Whether the token only applies where no consonant is pending, like
  /// `om` for ॐ, which after a consonant is the matra ो followed by म.
  final bool independentOnly;
}

// Tokens are matched longest first. Every table lists the canonical
// spelling of a letter first; reverse lookups use it.
/// A romanization scheme, compiled into a token trie and reverse tables.
final class PhoneticScheme {
  /// Compiles a scheme.
  ///
  /// [halantAtEnd] tells whether a consonant ending the text keeps its
  /// halant; [halantBeforeSpace] whether a consonant before whitespace does.
  /// Before any other character that isn't part of a token, a consonant
  /// keeps its halant exactly when [halantAtEnd] does. [separator] is written
  /// between two tokens that would otherwise merge into another.
  factory({
    required Map<String, String> consonants,
    required Map<String, (String, String)> vowels,
    required Map<String, String> signs,
    required Map<String, String> symbols,
    required bool halantAtEnd,
    required bool halantBeforeSpace,
    required String separator,
    Map<String, String> independentSymbols = const {},
    String? halantKey,
  }) {
    final trie = TokenTrie<PhoneticToken>();
    final consonantRoman = TokenTrie<String>();
    final independentRoman = <int, String>{};
    final matraRoman = <int, String>{};
    final signRoman = <int, String>{};
    final symbolRoman = <String, String>{};
    for (final MapEntry(:key, :value) in consonants.entries) {
      trie.add(key, PhoneticToken(.consonant, value));
      if (isConsonant(value.codeUnitAt(0))) consonantRoman.add(value, key);
    }
    for (final MapEntry(:key, value: (independent, matra)) in vowels.entries) {
      trie.add(key, PhoneticToken(.vowel, independent, matra: matra));
      independentRoman.putIfAbsent(independent.codeUnitAt(0), () => key);
      if (matra.isNotEmpty) {
        matraRoman.putIfAbsent(matra.codeUnitAt(0), () => key);
      }
    }
    for (final MapEntry(:key, :value) in signs.entries) {
      trie.add(key, PhoneticToken(.sign, value));
      signRoman.putIfAbsent(value.codeUnitAt(0), () => key);
    }
    for (final MapEntry(:key, :value) in symbols.entries) {
      trie.add(key, PhoneticToken(.symbol, value));
      symbolRoman.putIfAbsent(value, () => key);
    }
    for (final MapEntry(:key, :value) in independentSymbols.entries) {
      trie.add(key, PhoneticToken(.symbol, value, independentOnly: true));
      symbolRoman.putIfAbsent(value, () => key);
    }
    if (halantKey != null) {
      trie.add(halantKey, const PhoneticToken(.halant, ''));
    }
    return ._(
      trie,
      consonantRoman,
      independentRoman,
      matraRoman,
      signRoman,
      symbolRoman,
      halantKey,
      separator,
      halantAtEnd,
      halantBeforeSpace,
    );
  }

  new _(
    this.trie,
    this.consonantRoman,
    this.independentRoman,
    this.matraRoman,
    this.signRoman,
    this.symbolRoman,
    this.halantKey,
    this.separator,
    this.halantAtEnd,
    this.halantBeforeSpace,
  );

  /// The tokens.
  final TokenTrie<PhoneticToken> trie;

  /// Canonical spelling of each consonant and cluster, like क्ष.
  final TokenTrie<String> consonantRoman;

  /// Canonical spelling of each independent vowel.
  final Map<int, String> independentRoman;

  /// Canonical spelling of each matra.
  final Map<int, String> matraRoman;

  /// Canonical spelling of each sign.
  final Map<int, String> signRoman;

  /// Canonical spelling of each symbol.
  final Map<String, String> symbolRoman;

  /// The token for an explicit halant, if the scheme has one.
  final String? halantKey;

  /// Written between tokens that would otherwise merge.
  final String separator;

  /// Whether a consonant at the end of the text keeps its halant.
  final bool halantAtEnd;

  /// Whether a consonant before whitespace keeps its halant.
  final bool halantBeforeSpace;
}

/// The rules of `NepaliUnicode` before 4.0, with its bugs fixed.
final PhoneticScheme classicScheme = .new(
  consonants: {
    ..._withAspirates({
      'k': 'क', 'K': 'क', 'q': 'क', 'Q': 'क', 'g': 'ग', 'G': 'ग', //
      'c': 'च', 'C': 'च', 'j': 'ज', 'J': 'ज', 'z': 'ज', 'Z': 'ज',
      'T': 'ट', 'D': 'ड', 'N': 'ण', 't': 'त', 'd': 'द', 'n': 'न',
      'p': 'प', 'P': 'प', 'f': 'फ', 'F': 'फ', 'b': 'ब', 'B': 'ब',
      'm': 'म', 'M': 'म', 'y': 'य', 'Y': 'य', 'r': 'र', 'R': 'र',
      'l': 'ल', 'L': 'ल', 'w': 'व', 'W': 'व', 'v': 'व', 'V': 'व',
      's': 'स', 'S': 'ष', 'h': 'ह', 'H': 'ह', 'x': 'क्स', 'X': 'क्स',
    }),
    // Clusters typed as a whole.
    for (final g in ['g', 'G'])
      for (final y in ['y', 'Y']) '$g$y': 'ज्ञ',
    'ng': 'ङ', 'nG': 'ङ', 'yn': 'ञ', 'nj': 'ञ', 'nJ': 'ञ', 'nz': 'ञ', //
    'nZ': 'ञ',
    // ङ before ह is how anusvara is written in words like सिंह.
    'ngh': 'ंह', 'ngH': 'ंह', 'nGh': 'ंह', 'nGH': 'ंह',
  },
  vowels: {
    'a': ('अ', ''), 'aa': ('आ', 'ा'), 'A': ('आ', 'ा'), //
    'i': ('इ', 'ि'), 'ii': ('ई', 'ी'), 'I': ('ई', 'ी'),
    'u': ('उ', 'ु'), 'uu': ('ऊ', 'ू'), 'U': ('ऊ', 'ू'),
    'e': ('ए', 'े'), 'ai': ('ऐ', 'ै'), 'E': ('ऐ', 'ै'),
    'o': ('ओ', 'ो'), 'O': ('ओ', 'ो'), 'au': ('औ', 'ौ'),
    '-r': ('ऋ', 'ृ'), '-ri': ('ॠ', 'ॄ'), '-l': ('ऌ', 'ॢ'),
  },
  signs: {"'": 'ं', "''": 'ँ', ':': 'ः'},
  symbols: {
    for (final a in ['.', '|', '/', r'\']) ...{
      a: '।',
      for (final b in ['.', '|', '/', r'\']) '$a$b': '॥',
    },
  },
  independentSymbols: {'om': 'ॐ', 'Om': 'ॐ', 'oM': 'ॐ', 'OM': 'ॐ'},
  halantAtEnd: true,
  halantBeforeSpace: false,
  separator: '{}',
);

/// Google Input Tools style romanization.
final PhoneticScheme googleScheme = .new(
  consonants: {
    'k': 'क', 'kh': 'ख', 'g': 'ग', 'gh': 'घ', 'ng': 'ङ', //
    'ch': 'च', 'chh': 'छ', 'j': 'ज', 'z': 'ज', 'jh': 'झ', 'ny': 'ञ',
    'yn': 'ञ', 'T': 'ट', 'Th': 'ठ', 'D': 'ड', 'Dh': 'ढ', 'N': 'ण',
    't': 'त', 'th': 'थ', 'd': 'द', 'dh': 'ध', 'n': 'न', 'p': 'प',
    'ph': 'फ', 'f': 'फ', 'b': 'ब', 'bh': 'भ', 'm': 'म', 'y': 'य',
    'r': 'र', 'l': 'ल', 'w': 'व', 'v': 'व', 'sh': 'श', 'Sh': 'ष',
    'shh': 'ष', 's': 'स', 'h': 'ह', 'q': 'क', 'ksh': 'क्ष', 'x': 'क्ष',
    'tr': 'त्र', 'gy': 'ज्ञ',
  },
  vowels: {
    'a': ('अ', ''), 'aa': ('आ', 'ा'), 'A': ('आ', 'ा'), //
    'i': ('इ', 'ि'), 'ii': ('ई', 'ी'), 'ee': ('ई', 'ी'), 'I': ('ई', 'ी'),
    'u': ('उ', 'ु'), 'uu': ('ऊ', 'ू'), 'oo': ('ऊ', 'ू'), 'U': ('ऊ', 'ू'),
    'e': ('ए', 'े'), 'ai': ('ऐ', 'ै'), 'o': ('ओ', 'ो'),
    'au': ('औ', 'ौ'), 'ou': ('औ', 'ौ'), 'R': ('ऋ', 'ृ'), 'rri': ('ऋ', 'ृ'),
  },
  signs: {'M': 'ं', '^': 'ँ', 'H': 'ः'},
  symbols: {
    for (final a in ['.', '|']) ...{
      a: '।',
      for (final b in ['.', '|']) '$a$b': '॥',
    },
  },
  independentSymbols: {'OM': 'ॐ'},
  halantKey: '~',
  halantAtEnd: false,
  halantBeforeSpace: false,
  separator: '~',
);

const _aspirates = {
  'क': 'ख', 'ग': 'घ', 'च': 'छ', 'ज': 'झ', 'ट': 'ठ', 'ड': 'ढ', //
  'त': 'थ', 'द': 'ध', 'प': 'फ', 'ब': 'भ', 'स': 'श', 'ष': 'श',
};

// [letters], followed by every letter that has an aspirate spelt with `h`
// or `H` after it (`kh` → ख). `chh` is also छ.
Map<String, String> _withAspirates(Map<String, String> letters) => {
  ...letters,
  for (final MapEntry(:key, :value) in letters.entries)
    if (_aspirates[value] case final aspirate?)
      for (final h in ['h', 'H']) ...{
        '$key$h': aspirate,
        if (aspirate == 'छ')
          for (final h2 in ['h', 'H']) '$key$h$h2': aspirate,
      },
};
