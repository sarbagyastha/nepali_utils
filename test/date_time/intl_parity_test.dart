import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

/// NepaliDateFormat must lay out fields exactly like intl's DateFormat.
///
/// Only letters without names are compared, by giving intl a [DateTime]
/// whose fields are the BS fields (days are kept <= 28 so they stay valid in
/// the Gregorian calendar).
void main() {
  setUpAll(() => initializeDateFormatting('ne'));

  final dates = [
    for (final (y, m, d, h, min, s, ms) in const [
      (2076, 8, 5, 21, 4, 25, 123),
      (2080, 1, 1, 0, 0, 0, 0),
      (2081, 12, 28, 12, 5, 9, 7),
      (2000, 6, 3, 9, 30, 59, 999),
      (2090, 11, 9, 13, 59, 1, 45),
    ])
      (
        NepaliDateTime(y, m, d, h, min, s, ms),
        DateTime(y, m, d, h, min, s, ms),
      ),
  ];

  const letters = [
    'y', 'yy', 'yyyy', 'M', 'MM', 'L', 'LL', 'd', 'dd', 'c', 'cc', //
    'h', 'hh', 'H', 'HH', 'K', 'KK', 'k', 'kk', 'm', 'mm', 's', 'ss',
    'S', 'SS', 'SSS', 'Q', 'QQ',
    "y-MM-dd'T'HH:mm:ss.SSS", "h 'o''clock'", "''",
  ];

  const numericSkeletons = [
    'd', 'M', 'Md', 'y', 'yM', 'yMd', 'H', 'Hm', 'Hms', //
    'j', 'jm', 'jms', 'm', 'ms', 's',
  ];

  void expectParity(String pattern, Language language, String locale) {
    for (final (bs, ad) in dates) {
      expect(
        NepaliDateFormat(pattern, language).format(bs),
        DateFormat(pattern, locale).format(ad),
        reason: '$locale "$pattern" $bs',
      );
    }
  }

  test('pattern letters match intl', () {
    for (final pattern in [...letters, 'a', 'h:mm a']) {
      expectParity(pattern, .english, 'en');
    }
    for (final pattern in letters) {
      expectParity(pattern, .nepali, 'ne');
    }
  });

  test('numeric skeletons match intl en and ne', () {
    for (final skeleton in numericSkeletons) {
      expectParity(skeleton, .english, 'en');
      expectParity(skeleton, .nepali, 'ne');
    }
  });
}
