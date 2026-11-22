// Copyright 2026 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// Simple micro-benchmark for BS <-> AD conversion.
// Run with: dart run benchmark/conversion_benchmark.dart
// ignore_for_file: avoid_print

import 'package:nepali_utils/nepali_utils.dart';

const _iterations = 20000;

void main() {
  // Warm up the JIT and the calendar index.
  for (var i = 0; i < 3; i++) {
    _run(print: false);
  }
  _run(print: true);
}

void _run({required bool print}) {
  var checksum = 0;
  final sw = Stopwatch()..start();

  final base = DateTime(1990);
  for (var i = 0; i < _iterations; i++) {
    checksum += base.add(Duration(days: i)).toNepaliDateTime().day;
  }
  final adToBs = sw.elapsedMicroseconds;

  sw.reset();
  for (var i = 0; i < _iterations; i++) {
    checksum += NepaliDateTime(
      2000 + i % 150,
      i % 12 + 1,
      i % 28 + 1,
    ).toDateTime().day;
  }
  final bsToAd = sw.elapsedMicroseconds;

  sw.reset();
  final date = NepaliDateTime(2080, 5, 5);
  for (var i = 0; i < _iterations; i++) {
    checksum += date.weekday;
  }
  final weekday = sw.elapsedMicroseconds;

  sw.reset();
  final formatter = NepaliDateFormat('EEE, MMMM d, y hh:mm aa');
  for (var i = 0; i < _iterations; i++) {
    checksum += formatter.format(date).length;
  }
  final format = sw.elapsedMicroseconds;

  if (print) {
    _print('AD -> BS', adToBs);
    _print('BS -> AD', bsToAd);
    _print('weekday', weekday);
    _print('format', format);
    _print('(checksum $checksum)', 0);
  }
}

void _print(String label, int micros) => print(
  '${label.padRight(22)} ${micros == 0 ? '' : '${micros}us '
            '(${(micros * 1000 / _iterations).toStringAsFixed(0)} ns/op)'}',
);
