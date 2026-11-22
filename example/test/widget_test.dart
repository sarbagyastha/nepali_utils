import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils_example/app.dart';
import 'package:nepali_utils_example/calendar/bs_calendar_delegate.dart';
import 'package:nepali_utils_example/features/converter/converter_page.dart';
import 'package:nepali_utils_example/features/numbers/numbers_page.dart';
import 'package:nepali_utils_example/state/settings.dart';
import 'package:nepali_utils_example/util/dates.dart';

Future<void> _pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(NepaliUtilsApp(settings: AppSettings()));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => NepaliUtils.defaultLanguage = Language.english);

  group('app', () {
    for (final (name, size) in [
      ('phone', const Size(400, 900)),
      ('desktop', const Size(1400, 900)),
    ]) {
      testWidgets('opens every tool on $name', (tester) async {
        await _pumpApp(tester, size);
        for (final label in ['Dates', 'Money', 'Type', 'Units', 'Phone']) {
          await tester.tap(find.text(label).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: label);
        }
        await tester.tap(find.text('Today').last);
        await tester.pumpAndSettle();
        expect(find.text('Today in Nepal'), findsOneWidget);
      });
    }

    testWidgets('switches the whole UI to Nepali', (tester) async {
      await _pumpApp(tester, const Size(1400, 900));
      await tester.tap(find.byTooltip('नेपालीमा हेर्नुहोस्'));
      await tester.pumpAndSettle();
      expect(find.text('नेपालमा आज'), findsOneWidget);
      expect(NepaliUtils.defaultLanguage, Language.nepali);
    });

    testWidgets('spells the amount for a cheque', (tester) async {
      await _pumpApp(tester, const Size(1400, 1600));
      await tester.tap(find.text('Money').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.pumpAndSettle();
      expect(
        find.text(
          'One lakh twenty-three thousand four hundred fifty-six rupees only',
        ),
        findsOneWidget,
      );
    });
  });

  group('parsing', () {
    test('parseDateInput reads BS and AD dates', () {
      // Constitution Day.
      expect(parseDateInput('२०७२-०६-०३', bs: true), DateTime(2015, 9, 20));
      expect(parseDateInput('2072/6/3', bs: true), DateTime(2015, 9, 20));
      expect(parseDateInput('2015-09-20', bs: false), DateTime(2015, 9, 20));
      expect(parseDateInput('2015-02-30', bs: false), isNull);
      expect(parseDateInput('2080-01-35', bs: true), isNull);
      expect(parseDateInput('hello', bs: true), isNull);
    });

    test('parseAmount reads digits, grouping and compact forms', () {
      expect(parseAmount('१२,३४,५६७.८९'), 1234567.89);
      expect(parseAmount('12.5L'), 1250000);
      expect(parseAmount('३ करोड'), 30000000);
      expect(parseAmount('abc'), isNull);
    });

    test('bsDifference counts in BS months', () {
      expect(
        bsDifference(NepaliDateTime(2050, 5, 20), NepaliDateTime(2083, 8, 25)),
        (33, 3, 5),
      );
      // Borrows the length of the month before the end date (Kartik 2083).
      final kartik = NepaliDateTime(2083, 7).totalDays;
      expect(
        bsDifference(NepaliDateTime(2050, 5, 20), NepaliDateTime(2083, 8, 6)),
        (33, 2, kartik + 6 - 20),
      );
    });
  });

  group('BsCalendarDelegate', () {
    const delegate = BsCalendarDelegate(language: Language.english);
    const localizations = DefaultMaterialLocalizations();

    test('first day offset follows the BS weekday', () {
      // 2082-08-01 is a Monday.
      expect(delegate.firstDayOffset(2082, 8, localizations), 1);
    });

    test('adds months across years', () {
      final next = delegate.addMonthsToMonthDate(NepaliDateTime(2082, 12), 1);
      expect((next.year, next.month), (2083, 1));
      expect(
        delegate.monthDelta(NepaliDateTime(2082, 12), NepaliDateTime(2083, 2)),
        2,
      );
    });

    test('parses compact dates', () {
      expect(
        delegate.parseCompactDate('2072-06-03', localizations),
        NepaliDateTime(2072, 6, 3),
      );
      expect(delegate.parseCompactDate('2072-13-03', localizations), isNull);
    });
  });
}
