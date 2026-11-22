import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

/// The Nepali built-in patterns must format exactly like intl's `ne`
/// locale.
///
/// Excluded on purpose: negative values that round to zero (intl prints
/// `-०`), compact values above a kharab (intl uses its own place values),
/// and doubles like `1.005` that intl rounds from their binary value.
void main() {
  const values = <num>[
    0, 1, -1, 7.5, 12.345, 999.9995, 1000, 1234, -1234.5678, 12345, //
    99999, 123456, 1234567, 123456789.987, 0.1234, 0.5, 1e15,
  ];

  final formats = {
    'decimalPattern': (
      NepaliNumberFormat.decimalPattern(.nepali),
      NumberFormat.decimalPattern('ne'),
    ),
    'percentPattern': (
      NepaliNumberFormat.percentPattern(.nepali),
      NumberFormat.percentPattern('ne'),
    ),
    'currency': (
      NepaliNumberFormat.currency(language: .nepali),
      NumberFormat.currency(locale: 'ne', name: 'NPR'),
    ),
    'custom pattern': (
      NepaliNumberFormat('#,##0.00;(#,##0.00)', .nepali),
      NumberFormat('#,##0.00;(#,##0.00)', 'ne'),
    ),
  };

  for (final MapEntry(key: name, value: (ours, intl)) in formats.entries) {
    test(name, () {
      for (final value in values) {
        expect(ours.format(value), intl.format(value), reason: '$value');
      }
    });
  }

  test('compact', () {
    final ours = NepaliNumberFormat.compact(language: .nepali);
    final intl = NumberFormat.compact(locale: 'ne');
    for (final value in values.where((v) => v.abs() < 1e11)) {
      expect(ours.format(value), intl.format(value), reason: '$value');
    }
  });
}
