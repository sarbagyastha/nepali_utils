import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils_example/calendar/pick_date.dart';
import 'package:nepali_utils_example/state/settings.dart';
import 'package:nepali_utils_example/util/dates.dart';
import 'package:nepali_utils_example/widgets/common.dart';

/// Converts dates between Bikram Sambat and Gregorian, formats them, and
/// counts the time between two dates.
class const ConverterPage({super.key}) extends StatefulWidget {
  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Parses `yyyy-mm-dd` with `-`, `/` or `.` and ASCII or Devanagari digits.
DateTime? parseDateInput(String text, {required bool bs}) {
  final parts = Devanagari.toEnglishDigits(text.trim())
      .split(RegExp(r'[-/.\s]+'));
  if (parts.length != 3) return null;
  final numbers = parts.map(int.tryParse).toList();
  if (numbers.contains(null)) return null;
  final [year!, month!, day!] = numbers;
  if (month < 1 || month > 12 || day < 1 || year < 1000) return null;
  try {
    if (bs) {
      if (year < firstBsDate.year || year > lastBsDate.year) return null;
      if (day > NepaliDateTime(year, month).totalDays) return null;
      final ad = NepaliDateTime(year, month, day).toDateTime();
      return DateTime(ad.year, ad.month, ad.day);
    }
    final date = DateTime(year, month, day);
    return date.month == month ? date : null;
  } on Object {
    return null;
  }
}

class _ConverterPageState extends State<ConverterPage> {
  bool _fromBs = true;
  DateTime _date = _today();
  bool _invalid = false;
  late final TextEditingController _input = TextEditingController(
    text: _textFor(_date),
  );
  final TextEditingController _pattern = TextEditingController(
    text: "EEEE, d MMMM y G 'at' h:mm a",
  );

  DateTime _from = DateTime(2000);
  DateTime _to = _today();

  String _textFor(DateTime date) => _fromBs
      ? NepaliDateFormat('yyyy-MM-dd').format(date.toNepaliDateTime())
      : '${date.year}-${'${date.month}'.padLeft(2, '0')}-'
            '${'${date.day}'.padLeft(2, '0')}';

  @override
  void dispose() {
    _input.dispose();
    _pattern.dispose();
    super.dispose();
  }

  void _setDirection(bool fromBs) {
    setState(() {
      _fromBs = fromBs;
      _invalid = false;
      _input.text = _textFor(_date);
    });
  }

  void _onInput(String text) {
    final parsed = parseDateInput(text, bs: _fromBs);
    setState(() {
      _invalid = parsed == null;
      if (parsed != null) _date = parsed;
    });
  }

  Future<void> _pickMain() async {
    final picked = await pickDate(context, initial: _date, bs: _fromBs);
    if (picked == null) return;
    setState(() {
      _date = picked;
      _invalid = false;
      _input.text = _textFor(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final bs = _date.toNepaliDateTime();
    final converted = _fromBs
        ? formatAd(_date, language, weekday: true)
        : NepaliDateFormat.yMMMMEEEEd(language).format(bs);

    return ToolPage(
      children: [
        SectionCard(
          icon: Icons.swap_horiz_rounded,
          title: context.tr('Convert a date', 'मिति रूपान्तरण'),
          subtitle: context.tr(
            'Bikram Sambat ⇄ Gregorian',
            'विक्रम संवत् ⇄ ईस्वी संवत्',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(context.tr('BS → AD', 'वि.सं. → ई.सं.')),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(context.tr('AD → BS', 'ई.सं. → वि.सं.')),
                  ),
                ],
                selected: {_fromBs},
                onSelectionChanged: (value) => _setDirection(value.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _input,
                onChanged: _onInput,
                decoration: InputDecoration(
                  labelText: _fromBs
                      ? context.tr('Date in BS', 'वि.सं. मिति')
                      : context.tr('Date in AD', 'ई.सं. मिति'),
                  hintText: 'yyyy-mm-dd',
                  errorText: _invalid
                      ? context.tr(
                          'Enter a valid date as yyyy-mm-dd',
                          'yyyy-mm-dd ढाँचामा सही मिति लेख्नुहोस्',
                        )
                      : null,
                  suffixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 4),
                    child: IconButton(
                      tooltip: context.tr('Open calendar', 'पात्रो खोल्नुहोस्'),
                      onPressed: _pickMain,
                      icon: const Icon(Icons.calendar_month_rounded),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ResultTile(
                label: _fromBs
                    ? context.tr('In AD', 'ईस्वी संवत्मा')
                    : context.tr('In BS', 'विक्रम संवत्मा'),
                value: converted,
                emphasis: true,
              ),
              const SizedBox(height: 8),
              ResultList(
                results: [
                  (
                    context.tr('Relative to today', 'आजको तुलनामा'),
                    _relativeDays(context, _date),
                  ),
                  ('ISO 8601 (BS)', NepaliDateFormat('yyyy-MM-dd').format(bs)),
                ],
              ),
            ],
          ),
        ),
        _FormatsCard(date: bs),
        _AgeCard(
          from: _from,
          to: _to,
          bs: _fromBs,
          onFrom: (value) => setState(() => _from = value),
          onTo: (value) => setState(() => _to = value),
        ),
        _PatternCard(date: bs, controller: _pattern),
      ],
    );
  }
}

String _relativeDays(BuildContext context, DateTime date) {
  final days = date.difference(_today()).inDays;
  if (days == 0) return context.tr('Today', 'आज');
  return NepaliMoment(language: context.language)
      .formatUnit(days, MomentUnit.day, numeric: days.abs() > 1);
}

class const _FormatsCard({required final NepaliDateTime date})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final formats = <(String, NepaliDateFormat)>[
      ('yMd', NepaliDateFormat.yMd(language)),
      ('yMMMd', NepaliDateFormat.yMMMd(language)),
      ('yMMMMEEEEd', NepaliDateFormat.yMMMMEEEEd(language)),
      ('MMMMEEEEd', NepaliDateFormat.MMMMEEEEd(language)),
      ('yyyy.MM.dd G', NepaliDateFormat('yyyy.MM.dd G', language)),
      ("EEE, MMM d, ''yy", NepaliDateFormat("EEE, MMM d, ''yy", language)),
      ('yyyy MMMM GGGG', NepaliDateFormat('yyyy MMMM GGGG', language)),
      ('yQQQQ', NepaliDateFormat.yQQQQ(language)),
    ];
    return SectionCard(
      icon: Icons.text_format_rounded,
      title: context.tr('Ready-made formats', 'तयारी ढाँचाहरू'),
      subtitle: context.tr(
        'Tap any line to copy it',
        'कपी गर्न कुनै पनि हरफमा थिच्नुहोस्',
      ),
      child: ResultList(
        results: [
          for (final (name, format) in formats) (name, format.format(date)),
        ],
      ),
    );
  }
}

const _tokens = [
  'yyyy',
  'yy',
  'MMMM',
  'MMM',
  'MM',
  'd',
  'dd',
  'EEEE',
  'EEE',
  'G',
  'GGGG',
  'QQQ',
  'h:mm a',
  'HH:mm:ss',
  "'text'",
];

class const _PatternCard({
  required final NepaliDateTime date,
  required final TextEditingController controller,
}) extends StatefulWidget {
  @override
  State<_PatternCard> createState() => _PatternCardState();
}

class _PatternCardState extends State<_PatternCard> {
  void _insert(String token) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final inserted = text.substring(0, start) + token + text.substring(end);
    widget.controller.value = TextEditingValue(
      text: inserted,
      selection: TextSelection.collapsed(offset: start + token.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    // Use the current Nepal time so time fields show something useful.
    final now = NepaliDateTime.nepalNow();
    final date = widget.date.mergeTime(now.hour, now.minute, now.second);
    String? result;
    String? error;
    try {
      result = NepaliDateFormat(widget.controller.text, language).format(date);
    } on Object catch (e) {
      error = '$e';
    }

    return SectionCard(
      icon: Icons.code_rounded,
      title: context.tr('Pattern playground', 'ढाँचा प्लेग्राउन्ड'),
      subtitle: context.tr(
        'Same pattern letters as intl DateFormat',
        'intl DateFormat जस्तै ढाँचा अक्षरहरू',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: widget.controller,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: InputDecoration(
              labelText: context.tr('Pattern', 'ढाँचा'),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final token in _tokens)
                ActionChip(label: Text(token), onPressed: () => _insert(token)),
            ],
          ),
          const SizedBox(height: 16),
          if (error != null)
            InfoBanner(message: error, error: true)
          else
            ResultTile(
              label: context.tr('Result', 'नतिजा'),
              value: result ?? '',
              emphasis: true,
            ),
        ],
      ),
    );
  }
}

class const _AgeCard({
  required final DateTime from,
  required final DateTime to,
  required final bool bs,
  required final ValueChanged<DateTime> onFrom,
  required final ValueChanged<DateTime> onTo,
}) extends StatelessWidget {
  String _label(BuildContext context, DateTime date) {
    final language = context.language;
    return bs
        ? NepaliDateFormat.yMMMMd(language).format(date.toNepaliDateTime())
        : formatAd(date, language);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final theme = Theme.of(context);
    final (years, months, days) = bsDifference(
      from.toNepaliDateTime(),
      to.toNepaliDateTime(),
    );
    final total = to.difference(from).inDays.abs();
    final number = NepaliNumberFormat.decimalPattern(language);
    final moment = NepaliMoment(language: language);
    final shortMoment = NepaliMoment(
      language: language,
      style: MomentStyle.short,
      useWeeks: true,
    );

    // Next anniversary of [from] in Bikram Sambat.
    final birth = from.toNepaliDateTime();
    final today = _today().toNepaliDateTime();
    NepaliDateTime anniversary(int year) => NepaliDateTime(
      year,
      birth.month,
      birth.day.clamp(1, NepaliDateTime(year, birth.month).totalDays),
    );
    var next = anniversary(today.year);
    if (next.isBefore(today)) next = anniversary(today.year + 1);
    final untilNext = next.difference(today).inDays;

    String n(int value) => number.format(value);
    final countdown = untilNext == 0
        ? context.tr('Today!', 'आज!')
        : moment.formatUnit(untilNext, MomentUnit.day);

    return SectionCard(
      icon: Icons.cake_rounded,
      title: context.tr('Age & days between', 'उमेर र दिन गणना'),
      subtitle: context.tr(
        'Counted in Bikram Sambat months',
        'विक्रम संवत्का महिनामा गणना',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: context.tr('From', 'देखि'),
                  value: _label(context, from),
                  onPressed: () async {
                    final picked = await pickDate(
                      context,
                      initial: from,
                      bs: bs,
                    );
                    if (picked != null) onFrom(picked);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateButton(
                  label: context.tr('To', 'सम्म'),
                  value: _label(context, to),
                  onPressed: () async {
                    final picked = await pickDate(context, initial: to, bs: bs);
                    if (picked != null) onTo(picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ResultTile(
            label: context.tr('Difference', 'फरक'),
            value: context.tr(
              '${n(years)} years, ${n(months)} months, ${n(days)} days',
              '${n(years)} वर्ष, ${n(months)} महिना, ${n(days)} दिन',
            ),
            emphasis: true,
          ),
          const SizedBox(height: 8),
          ResultList(
            results: [
              (
                context.tr('Total days', 'जम्मा दिन'),
                context.tr('${n(total)} days', '${n(total)} दिन'),
              ),
              (
                context.tr('Roughly', 'लगभग'),
                moment.format(from, reference: to),
              ),
              (
                context.tr('Short form', 'छोटकरीमा'),
                shortMoment.formatDuration(Duration(days: total)),
              ),
              (
                context.tr('Next anniversary', 'अर्को वार्षिकोत्सव'),
                '${NepaliDateFormat.yMMMMd(language).format(next)} · '
                    '$countdown',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              'Tip: set "From" to a birthday to get an age.',
              'सुझाव: उमेर निकाल्न "देखि" मा जन्म मिति राख्नुहोस्।',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class const _DateButton({
  required final String label,
  required final String value,
  required final VoidCallback onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        alignment: AlignmentDirectional.centerStart,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          Text(
            value,
            style: theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
