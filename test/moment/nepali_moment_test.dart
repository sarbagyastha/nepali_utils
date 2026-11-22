import 'package:nepali_utils/nepali_utils.dart';
import 'package:test/test.dart';

void main() {
  final reference = DateTime.utc(2024, 1, 10, 12);
  final english = NepaliMoment(language: .english);
  final nepali = NepaliMoment(language: .nepali);

  String ago(NepaliMoment moment, Duration duration) =>
      moment.format(reference.subtract(duration), reference: reference);

  group('format thresholds', () {
    const cases = <(Duration, String)>[
      (Duration.zero, 'a few seconds ago'),
      (Duration(seconds: 44), 'a few seconds ago'),
      (Duration(seconds: 45), 'a minute ago'),
      (Duration(seconds: 89), 'a minute ago'),
      (Duration(seconds: 90), '2 minutes ago'),
      (Duration(minutes: 44), '44 minutes ago'),
      (Duration(minutes: 45), 'an hour ago'),
      (Duration(minutes: 90), '2 hours ago'),
      (Duration(hours: 21), '21 hours ago'),
      (Duration(hours: 22), 'a day ago'),
      (Duration(hours: 36), '2 days ago'),
      (Duration(days: 25), '25 days ago'),
      (Duration(days: 26), 'a month ago'),
      (Duration(days: 100), '3 months ago'),
      (Duration(days: 319), '10 months ago'),
      (Duration(days: 320), 'a year ago'),
      (Duration(days: 547), 'a year ago'),
      (Duration(days: 548), '2 years ago'),
      (Duration(days: 365243), '1,000 years ago'),
    ];
    for (final (duration, expected) in cases) {
      test(expected, () => expect(ago(english, duration), expected));
    }
  });

  test('future', () {
    final date = reference.add(const Duration(hours: 3));
    expect(english.format(date, reference: reference), 'in 3 hours');
    expect(nepali.format(date, reference: reference), '३ घण्टा पछि');
  });

  test('Nepali', () {
    expect(ago(nepali, const Duration(seconds: 10)), 'केही क्षण पहिले');
    expect(ago(nepali, const Duration(minutes: 1)), 'एक मिनेट पहिले');
    expect(ago(nepali, const Duration(days: 13)), '१३ दिन पहिले');
    expect(ago(nepali, const Duration(days: 800)), '२ वर्ष पहिले');
  });

  test('accepts NepaliDateTime and DateTime together', () {
    final date = reference
        .subtract(const Duration(days: 3))
        .toNepaliDateTime()
        .toNepalTime();
    expect(english.format(date, reference: reference), '3 days ago');
    expect(
      NepaliMoment.fromBS(
        date,
        referenceDate: reference.toNepaliDateTime(),
        language: .english,
      ),
      '3 days ago',
    );
  });

  test('weeks', () {
    final weeks = NepaliMoment(language: .english, useWeeks: true);
    expect(ago(weeks, const Duration(days: 5)), '5 days ago');
    expect(ago(weeks, const Duration(days: 7)), 'a week ago');
    expect(ago(weeks, const Duration(days: 20)), '3 weeks ago');
    expect(ago(weeks, const Duration(days: 40)), 'a month ago');
  });

  test('short style', () {
    final short = NepaliMoment(language: .english, style: .short);
    expect(ago(short, const Duration(hours: 3)), '3 hr. ago');
    expect(ago(short, const Duration(seconds: 50)), '1 min. ago');
    expect(
      ago(
        NepaliMoment(language: .nepali, style: .short),
        const Duration(hours: 3),
      ),
      '३ घ. पहिले',
    );
  });

  test('formatDuration', () {
    expect(english.formatDuration(const Duration(days: 3)), '3 days');
    expect(
      english.formatDuration(const Duration(days: -3), withSuffix: true),
      '3 days ago',
    );
    expect(
      english.formatDuration(const Duration(hours: 2), withSuffix: true),
      'in 2 hours',
    );
    expect(nepali.formatDuration(const Duration(minutes: 5)), '५ मिनेट');
  });

  group('formatUnit', () {
    test('numeric', () {
      expect(english.formatUnit(-1, .day), '1 day ago');
      expect(english.formatUnit(3, .week), 'in 3 weeks');
      expect(english.formatUnit(1.5, .hour), 'in 1.5 hours');
      expect(english.formatUnit(0, .minute), 'in 0 minutes');
      expect(english.formatUnit(-1200, .year), '1,200 years ago');
      expect(nepali.formatUnit(-2, .month), '२ महिना पहिले');
    });
    test('words', () {
      expect(english.formatUnit(-1, .day, numeric: false), 'yesterday');
      expect(english.formatUnit(0, .day, numeric: false), 'today');
      expect(english.formatUnit(1, .day, numeric: false), 'tomorrow');
      expect(english.formatUnit(0, .second, numeric: false), 'now');
      expect(english.formatUnit(-1, .year, numeric: false), 'last year');
      expect(english.formatUnit(2, .day, numeric: false), 'in 2 days');
      expect(english.formatUnit(-1, .hour, numeric: false), '1 hour ago');
      expect(nepali.formatUnit(-1, .day, numeric: false), 'हिजो');
      expect(nepali.formatUnit(1, .month, numeric: false), 'आउँदो महिना');
    });
    test('short', () {
      expect(
        NepaliMoment(language: .english, style: .short).formatUnit(-5, .minute),
        '5 min. ago',
      );
    });
    test(
      'throws on non-finite values',
      () => expect(
        () => english.formatUnit(double.nan, .day),
        throwsArgumentError,
      ),
    );
  });

  group('calendar', () {
    final now = DateTime.utc(2024, 1, 10, 8); // Wednesday
    String calendar(NepaliMoment moment, DateTime date) =>
        moment.calendar(date, reference: now);

    test('English', () {
      expect(
        calendar(english, DateTime.utc(2024, 1, 10, 21, 4)),
        'Today at 9:04 PM',
      );
      expect(
        calendar(english, DateTime.utc(2024, 1, 9, 21, 4)),
        'Yesterday at 9:04 PM',
      );
      expect(
        calendar(english, DateTime.utc(2024, 1, 11, 9)),
        'Tomorrow at 9:00 AM',
      );
      expect(
        calendar(english, DateTime.utc(2024, 1, 7, 21, 4)),
        'Last Sunday at 9:04 PM',
      );
      expect(
        calendar(english, DateTime.utc(2024, 1, 12, 21, 4)),
        'Friday at 9:04 PM',
      );
      expect(calendar(english, DateTime.utc(2024, 1, 20)), '10/6/2080');
    });

    test('Nepali', () {
      expect(calendar(nepali, DateTime.utc(2024, 1, 10, 21, 4)), 'आज २१:०४');
      expect(calendar(nepali, DateTime.utc(2024, 1, 9, 21, 4)), 'हिजो २१:०४');
      expect(
        calendar(nepali, DateTime.utc(2024, 1, 7, 21, 4)),
        'गएको आइतबार, २१:०४',
      );
      expect(calendar(nepali, DateTime.utc(2024, 1, 20)), '२०८०-१०-०६');
    });

    test('counts days in the time zone of the date', () {
      // 2024-01-10 00:30 in Nepal is 2024-01-09 18:45 UTC.
      final date = NepaliDateTime.nepal(2080, 9, 25, 0, 30);
      final lateThatNight = DateTime.utc(2024, 1, 10, 18); // 23:45 in Nepal.
      expect(
        english.calendar(date, reference: lateThatNight),
        'Today at 12:30 AM',
      );
    });
  });

  test('defaults to the current language', () {
    expect(
      NepaliUtils.withLanguage(
        .nepali,
        () => NepaliMoment().formatUnit(-1, .day, numeric: false),
      ),
      'हिजो',
    );
  });
}
