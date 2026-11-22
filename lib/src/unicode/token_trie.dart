// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// A prefix tree of string keys for longest-match tokenizing.
final class TokenTrie<T extends Object> {
  /// Creates an empty trie.
  new();

  final _Node<T> _root = _Node<T>();

  /// The length of the longest key, in code units.
  int get maxLength => _maxLength;
  int _maxLength = 0;

  /// Adds [key] with [value]. When [key] was already added, the first value
  /// is kept.
  void add(String key, T value) {
    var node = _root;
    for (final unit in key.codeUnits) {
      node = node.children.putIfAbsent(unit, _Node<T>.new);
    }
    node.value ??= value;
    if (key.length > _maxLength) _maxLength = key.length;
  }

  /// Whether some key starts with [unit].
  bool startsWith(int unit) => _root.children.containsKey(unit);

  /// The longest key that starts at [start] in [text] and whose value passes
  /// [accept], as `(length, value)`, or `null` if there is none.
  (int, T)? match(String text, int start, [bool Function(T value)? accept]) {
    var node = _root;
    (int, T)? best;
    for (var i = start; i < text.length; i++) {
      final next = node.children[text.codeUnitAt(i)];
      if (next == null) break;
      node = next;
      final value = node.value;
      if (value != null && (accept == null || accept(value))) {
        best = (i + 1 - start, value);
      }
    }
    return best;
  }
}

final class _Node<T extends Object> {
  final Map<int, _Node<T>> children = {};
  T? value;
}
