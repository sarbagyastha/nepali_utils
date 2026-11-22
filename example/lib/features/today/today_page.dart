import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils_example/state/settings.dart';
import 'package:nepali_utils_example/util/dates.dart';
import 'package:nepali_utils_example/widgets/common.dart';
import 'package:nepali_utils_example/widgets/morphing_shape.dart';

/// Today's date in Nepal, a live Nepal Time clock and a month calendar.
class const TodayPage({super.key}) extends StatefulWidget {
  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  NepaliDateTime _now = NepaliDateTime.nepalNow();
  late (int, int) _month = (_now.year, _now.month);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = NepaliDateTime.nepalNow());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _shiftMonth(int delta) {
    final (year, month) = _month;
    final next = NepaliDateTime(year, month + delta);
    if (next.isBefore(firstBsDate) || next.isAfter(lastBsDate)) return;
    setState(() => _month = (next.year, next.month));
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      children: [
        _TodayHero(now: _now),
        _MonthCalendar(
          year: _month.$1,
          month: _month.$2,
          today: _now,
          onPrevious: () => _shiftMonth(-1),
          onNext: () => _shiftMonth(1),
          onToday: () => setState(() => _month = (_now.year, _now.month)),
        ),
        _ClockCard(now: _now),
        const _UpcomingCard(),
      ],
    );
  }
}

final List<RoundedPolygon> _heroShapes = [
  MaterialShapes.cookie12Sided,
  MaterialShapes.sunny,
  MaterialShapes.flower,
  MaterialShapes.softBurst,
  MaterialShapes.clover8Leaf,
  MaterialShapes.puffy,
];

class const _TodayHero({required final NepaliDateTime now})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onHero = scheme.onPrimaryContainer;
    final bs = NepaliDateFormat.yMMMMEEEEd(language).format(now);
    final ad = formatAd(now.toDateTime(), language, weekday: true);

    return Card(
      color: scheme.primaryContainer,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: MorphingShape(
              // Drifts to a new shape every ten seconds.
              shape: _heroShapes[now.second ~/ 10 % _heroShapes.length],
              size: 220,
              color: scheme.primary.withValues(alpha: 0.14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Today in Nepal', 'नेपालमा आज'),
                  style: theme.textTheme.labelLarge?.copyWith(color: onHero),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NepaliDateFormat.d(language).format(now),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: onHero,
                        fontSize: 96,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              NepaliDateFormat.EEEE(language).format(now),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: onHero,
                              ),
                            ),
                            Text(
                              NepaliDateFormat.yMMMM(language).format(now),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: onHero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.event_rounded, size: 18),
                      label: Text(bs),
                      onPressed: () => copyToClipboard(context, bs),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.public_rounded, size: 18),
                      label: Text(ad),
                      onPressed: () => copyToClipboard(context, ad),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class const _ClockCard({required final NepaliDateTime now})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final theme = Theme.of(context);
    final local = NepaliDateTime.now();
    final differs = local.timeZoneOffset != now.timeZoneOffset;
    final number = NepaliNumberFormat.decimalPattern(language);
    final dayProgress = (now.hour * 60 + now.minute) / (24 * 60);

    return SectionCard(
      icon: Icons.schedule_rounded,
      title: context.tr('Nepal Time', 'नेपाली समय'),
      subtitle: context.tr('UTC+05:45, live', 'UTC+०५:४५, लाइभ'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            NepaliDateFormat.jms(language).format(now),
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: dayProgress, minHeight: 10),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              '${number.format((dayProgress * 100).round())}% of the day '
                  'has passed',
              'दिनको ${number.format((dayProgress * 100).round())}% बित्यो',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          if (differs) ...[
            const SizedBox(height: 16),
            ResultTile(
              label: context.tr(
                'Your local time (${local.timeZoneName})',
                'तपाईंको स्थानीय समय (${local.timeZoneName})',
              ),
              value:
                  '${NepaliDateFormat.yMMMd(language).format(local)}, '
                  '${NepaliDateFormat.jm(language).format(local)}',
            ),
          ],
        ],
      ),
    );
  }
}

class const _MonthCalendar({
  required final int year,
  required final int month,
  required final NepaliDateTime today,
  required final VoidCallback onPrevious,
  required final VoidCallback onNext,
  required final VoidCallback onToday,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final first = NepaliDateTime(year, month);
    final offset = first.weekday - 1;
    final days = first.totalDays;
    final isThisMonth = today.year == year && today.month == month;
    final names = weekdayNames(language);

    return SectionCard(
      icon: Icons.calendar_month_rounded,
      title: NepaliDateFormat.yMMMM(language).format(first),
      subtitle: adSpanOfMonth(year, month, language),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            tooltip: context.tr('Previous month', 'अघिल्लो महिना'),
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            tooltip: context.tr('Next month', 'अर्को महिना'),
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final (i, name) in names.indexed)
                Expanded(
                  child: Center(
                    child: Text(
                      name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: i == 6 ? scheme.error : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.9,
            children: [
              for (var i = 0; i < offset; i++) const SizedBox.shrink(),
              for (var day = 1; day <= days; day++)
                _DayCell(
                  date: NepaliDateTime(year, month, day),
                  isToday: isThisMonth && today.day == day,
                ),
            ],
          ),
          if (!isThisMonth) ...[
            const SizedBox(height: 12),
            Align(
              child: FilledButton.tonalIcon(
                onPressed: onToday,
                icon: const Icon(Icons.today_rounded),
                label: Text(context.tr('Back to today', 'आजमा फर्कनुहोस्')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class const _DayCell({
  required final NepaliDateTime date,
  required final bool isToday,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ad = date.toDateTime();
    // NepaliDateTime.weekday runs from Sunday (1) to Saturday (7).
    final saturday = date.weekday == 7;
    final foreground = isToday
        ? scheme.onPrimary
        : saturday
        ? scheme.error
        : scheme.onSurface;

    final cell = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          NepaliDateFormat.d(language).format(date),
          style: theme.textTheme.titleMedium?.copyWith(
            color: foreground,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        Text(
          localDigits(ad.day, language),
          style: theme.textTheme.labelSmall?.copyWith(
            color: foreground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );

    return Tooltip(
      message: formatAd(ad, language),
      child: Material(
        color: isToday ? scheme.primary : Colors.transparent,
        shape: isToday
            ? MaterialShapeBorder(shape: MaterialShapes.cookie9Sided)
            : const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: () => showDayDetails(context, date), child: cell),
      ),
    );
  }
}

/// Shows everything about [date] in a bottom sheet.
Future<void> showDayDetails(BuildContext context, NepaliDateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final language = context.language;
      final theme = Theme.of(context);
      final moment = NepaliMoment(language: language);
      final today = NepaliDateTime.now();
      final midnight = NepaliDateTime(today.year, today.month, today.day);
      final days = date.difference(midnight).inDays;
      final relative = days == 0
          ? context.tr('Today', 'आज')
          : moment.formatUnit(days, MomentUnit.day, numeric: days.abs() > 1);

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                NepaliDateFormat.yMMMMEEEEd(language).format(date),
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                relative,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              ResultList(
                results: [
                  (
                    context.tr('Gregorian (AD)', 'ईस्वी संवत्'),
                    formatAd(date.toDateTime(), language, weekday: true),
                  ),
                  (
                    context.tr('Short', 'छोटो'),
                    NepaliDateFormat.yMd(language).format(date),
                  ),
                  ('ISO 8601', date.toIso8601String().substring(0, 10)),
                  (
                    context.tr('Relative', 'सापेक्ष'),
                    moment.format(date, reference: midnight),
                  ),
                  (
                    context.tr('Days in this month', 'यस महिनाका दिन'),
                    localDigits(date.totalDays, language),
                  ),
                  (
                    context.tr('Day of the year', 'वर्षको दिन'),
                    localDigits(
                      date.difference(NepaliDateTime(date.year)).inDays + 1,
                      language,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Countdown to the next notable dates of the Nepali year.
class const _UpcomingCard() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final now = NepaliDateTime.nepalNow();
    final today = NepaliDateTime(now.year, now.month, now.day);
    final moment = NepaliMoment(language: language);

    NepaliDateTime next(int month, int day) {
      final thisYear = NepaliDateTime(today.year, month, day);
      return thisYear.isBefore(today)
          ? NepaliDateTime(today.year + 1, month, day)
          : thisYear;
    }

    final events = [
      (context.tr('Nepali New Year', 'नयाँ वर्ष'), next(1, 1)),
      (context.tr('Constitution Day', 'संविधान दिवस'), next(6, 3)),
      (context.tr('Fiscal year starts', 'आर्थिक वर्ष सुरु'), next(4, 1)),
      (
        context.tr('Next month starts', 'अर्को महिना सुरु'),
        NepaliDateTime(today.year, today.month + 1),
      ),
    ]..sort((a, b) => a.$2.compareTo(b.$2));

    return SectionCard(
      icon: Icons.hourglass_bottom_rounded,
      title: context.tr('Coming up', 'आउँदै'),
      child: Column(
        children: [
          for (final (label, date) in events)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              subtitle: Text(
                NepaliDateFormat.yMMMMEEEEd(language).format(date),
              ),
              trailing: Text(
                moment.formatUnit(
                  date.difference(today).inDays,
                  MomentUnit.day,
                  numeric: false,
                ),
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              onTap: () => showDayDetails(context, date),
            ),
        ],
      ),
    );
  }
}
