import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils_example/state/settings.dart';
import 'package:nepali_utils_example/widgets/common.dart';

/// Formats amounts the Nepali way, spells them out for cheques and adds VAT.
class const NumbersPage({super.key}) extends StatefulWidget {
  @override
  State<NumbersPage> createState() => _NumbersPageState();
}

/// Parses ASCII or Devanagari numbers, with or without grouping, and
/// compact forms such as `12.5L`, `3 करोड`.
num? parseAmount(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  for (final language in Language.values) {
    final value =
        NepaliNumberFormat.decimalPattern(language).tryParse(trimmed) ??
        NepaliNumberFormat.compact(language: language).tryParse(trimmed) ??
        NepaliNumberFormat.compactLong(language: language).tryParse(trimmed);
    if (value != null) return value;
  }
  return null;
}

class _NumbersPageState extends State<NumbersPage> {
  final TextEditingController _amount = TextEditingController(
    text: '125000.50',
  );
  int _decimals = 2;
  bool _grouping = true;
  bool _vatInclusive = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  NepaliNumberFormat _grouped(NepaliNumberFormat format) =>
      _grouping ? format : format.copyWith(groupSeparator: '');

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final value = parseAmount(_amount.text);
    final decimal = NepaliNumberFormat.decimalPattern(language);

    return ToolPage(
      children: [
        SectionCard(
          icon: Icons.payments_rounded,
          title: context.tr('Amount', 'रकम'),
          subtitle: context.tr(
            'Type digits in English or Nepali, e.g. 12,34,567 · १२५०० · 12.5L',
            'अंग्रेजी वा नेपाली अंकमा लेख्नुहोस्, जस्तै १२,३४,५६७ · 12.5L',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _amount,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: InputDecoration(
                  prefixText: language == Language.nepali ? 'रु. ' : 'Rs. ',
                  errorText: _amount.text.isNotEmpty && value == null
                      ? context.tr('Not a number', 'संख्या होइन')
                      : null,
                  suffixIcon: IconButton(
                    tooltip: context.tr('Clear', 'मेटाउनुहोस्'),
                    onPressed: () => setState(_amount.clear),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'Understood as ${decimal.format(value)}',
                    '${decimal.format(value)} बुझियो',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(context.tr('Decimals', 'दशमलव')),
                  Expanded(
                    child: Slider(
                      value: _decimals.toDouble(),
                      max: 4,
                      divisions: 4,
                      label: NepaliNumberFormat(
                        '0',
                        language,
                      ).format(_decimals),
                      onChanged: (v) => setState(() => _decimals = v.round()),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('Group digits', 'अंक समूह (अल्पविराम)')),
                subtitle: Text(
                  context.tr('Lakh and crore commas', 'लाख र करोडका अल्पविराम'),
                ),
                value: _grouping,
                onChanged: (v) => setState(() => _grouping = v),
              ),
            ],
          ),
        ),
        if (value == null)
          InfoBanner(
            message: context.tr(
              'Enter an amount to see it formatted and in words.',
              'ढाँचा र शब्दमा हेर्न रकम लेख्नुहोस्।',
            ),
          )
        else ...[
          _ChequeCard(value: value),
          SectionCard(
            icon: Icons.format_list_numbered_rounded,
            title: context.tr('Formats', 'ढाँचाहरू'),
            child: ResultList(
              results: [
                (
                  context.tr('Lakh / crore', 'लाख / करोड'),
                  _grouped(
                    NepaliNumberFormat.decimalPatternDigits(
                      language: language,
                      decimalDigits: _decimals,
                    ),
                  ).format(value),
                ),
                (
                  context.tr('International', 'अन्तर्राष्ट्रिय'),
                  _grouped(
                    NepaliNumberFormat(
                      _decimals == 0 ? '#,##0' : '#,##0.${'0' * _decimals}',
                      language,
                    ),
                  ).format(value),
                ),
                (
                  context.tr('Currency', 'मुद्रा'),
                  _grouped(
                    NepaliNumberFormat.simpleCurrency(
                      language: language,
                      decimalDigits: _decimals,
                    ),
                  ).format(value),
                ),
                (
                  context.tr('Currency code', 'मुद्रा कोड'),
                  _grouped(
                    NepaliNumberFormat.currency(
                      language: language,
                      decimalDigits: _decimals,
                    ),
                  ).format(value),
                ),
                (
                  context.tr('Compact', 'छोटकरी'),
                  NepaliNumberFormat.compact(language: language).format(value),
                ),
                (
                  context.tr('Compact, long', 'छोटकरी, लामो'),
                  NepaliNumberFormat.compactLong(language: language)
                      .format(value),
                ),
                (
                  context.tr('Compact money', 'छोटकरी रकम'),
                  NepaliNumberFormat.compactSimpleCurrency(language: language)
                      .format(value),
                ),
                (
                  context.tr('Spelled with digits', 'अंकसहित शब्दमा'),
                  NepaliNumberFormat.words(
                    language: language,
                    useDigits: true,
                  ).format(value),
                ),
              ],
            ),
          ),
          _VatCard(
            value: value,
            inclusive: _vatInclusive,
            onInclusive: (v) => setState(() => _vatInclusive = v),
          ),
        ],
      ],
    );
  }
}

class const _ChequeCard({required final num value}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    String words(Language language) => NepaliNumberFormat.words(
      language: language,
      currency: true,
    ).format(value);
    String figure(Language language) => NepaliNumberFormat.decimalPatternDigits(
      language: language,
      decimalDigits: 2,
    ).format(value);

    return SectionCard(
      icon: Icons.edit_note_rounded,
      title: context.tr('Amount in words', 'रकम अक्षरमा'),
      subtitle: context.tr(
        'For cheques, invoices and receipts',
        'चेक, बिल र रसिदका लागि',
      ),
      color: scheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResultTile(
            label: 'English · Rs. ${figure(Language.english)}',
            value: '${_capitalize(words(Language.english))} only',
            emphasis: true,
          ),
          const SizedBox(height: 8),
          ResultTile(
            label: 'नेपाली · रु. ${figure(Language.nepali)}',
            value: '${words(Language.nepali)} मात्र',
            emphasis: true,
          ),
        ],
      ),
    );
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

class const _VatCard({
  required final num value,
  required final bool inclusive,
  required final ValueChanged<bool> onInclusive,
}) extends StatelessWidget {
  static const double _rate = 0.13;

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final money = NepaliNumberFormat.simpleCurrency(
      language: language,
      decimalDigits: 2,
    );
    final percent = NepaliNumberFormat.percentPattern(language);
    final base = inclusive ? value / (1 + _rate) : value;
    final vat = base * _rate;
    final total = base + vat;

    return SectionCard(
      icon: Icons.receipt_long_rounded,
      title: context.tr('VAT calculator', 'भ्याट गणना'),
      subtitle: context.tr(
        '${percent.format(_rate)} VAT in Nepal',
        'नेपालमा ${percent.format(_rate)} भ्याट',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(context.tr('Add VAT', 'भ्याट थप्नुहोस्')),
              ),
              ButtonSegment(
                value: true,
                label: Text(context.tr('VAT included', 'भ्याट समावेश')),
              ),
            ],
            selected: {inclusive},
            onSelectionChanged: (v) => onInclusive(v.first),
          ),
          const SizedBox(height: 16),
          ResultList(
            results: [
              (context.tr('Taxable amount', 'करयोग्य रकम'), money.format(base)),
              (
                '${context.tr('VAT', 'भ्याट')} (${percent.format(_rate)})',
                money.format(vat),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ResultTile(
            label: context.tr('Total', 'जम्मा'),
            value: money.format(total),
            emphasis: true,
          ),
        ],
      ),
    );
  }
}
