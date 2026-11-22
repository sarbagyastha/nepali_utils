import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils_example/state/settings.dart';
import 'package:nepali_utils_example/widgets/common.dart';

/// Validates, formats and finds Nepali phone numbers.
class const PhonePage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ToolPage(
      children: [_CheckCard(), _FindCard(), _OperatorsCard()],
    );
  }
}

String _describe(BuildContext context, NepaliPhoneNumber number) {
  final language = context.language;
  return switch (number.type) {
    PhoneType.mobile =>
      '${context.tr('Mobile', 'मोबाइल')} · '
          '${number.operator?.label(language) ?? '?'}',
    PhoneType.landline =>
      '${context.tr('Landline', 'ल्यान्डलाइन')} · '
          '${number.areaName(language) ?? number.areaCode ?? '?'}',
  };
}

class const _CheckCard() extends StatefulWidget {
  @override
  State<_CheckCard> createState() => _CheckCardState();
}

class _CheckCardState extends State<_CheckCard> {
  final TextEditingController _input = TextEditingController(
    text: '+977 ९८४१२३४५६७',
  );

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final theme = Theme.of(context);
    final text = _input.text;
    final number = NepaliPhoneNumber.tryParse(text);
    final valid = number != null;

    return SectionCard(
      icon: Icons.phone_rounded,
      title: context.tr('Check a number', 'नम्बर जाँच्नुहोस्'),
      subtitle: context.tr(
        'Mobile or landline, in any style',
        'मोबाइल वा ल्यान्डलाइन, जुनसुकै शैलीमा',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _input,
            onChanged: (_) => setState(() {}),
            keyboardType: TextInputType.phone,
            style: theme.textTheme.titleLarge,
            decoration: InputDecoration(
              labelText: context.tr('Phone number', 'फोन नम्बर'),
              helperText: context.tr(
                'e.g. 9801234567 · 01-4412345 · +977 061 523456',
                'जस्तै ९८०१२३४५६७ · ०१-४४१२३४५',
              ),
              suffixIcon: text.isEmpty
                  ? null
                  : Icon(
                      valid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: valid
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (number == null)
            InfoBanner(
              error: text.isNotEmpty,
              message: text.isEmpty
                  ? context.tr(
                      'Type a number to check it.',
                      'जाँच्न नम्बर लेख्नुहोस्।',
                    )
                  : context.tr(
                      'Not a valid Nepali phone number.',
                      'यो मान्य नेपाली फोन नम्बर होइन।',
                    ),
            )
          else ...[
            ResultTile(
              label: _describe(context, number),
              value: number.format(language: language),
              emphasis: true,
            ),
            const SizedBox(height: 8),
            ResultList(
              results: [
                (
                  context.tr('International', 'अन्तर्राष्ट्रिय'),
                  number.format(
                    style: PhoneFormat.international,
                    language: language,
                  ),
                ),
                ('E.164', number.format(style: PhoneFormat.e164)),
                (
                  context.tr('National number', 'राष्ट्रिय नम्बर'),
                  number.nationalNumber,
                ),
                if (number.areaCode != null)
                  (context.tr('Area code', 'क्षेत्र कोड'), number.areaCode!),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Flag(
                  label: context.tr('Mobile', 'मोबाइल'),
                  on: NepaliPhoneNumber.isMobile(text),
                ),
                _Flag(
                  label: context.tr('Landline', 'ल्यान्डलाइन'),
                  on: NepaliPhoneNumber.isLandline(text),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class const _Flag({required final String label, required final bool on})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(on ? Icons.check_rounded : Icons.close_rounded, size: 18),
    label: Text(label),
  );
}

enum _View { found, formatted, masked }

class const _FindCard() extends StatefulWidget {
  @override
  State<_FindCard> createState() => _FindCardState();
}

class _FindCardState extends State<_FindCard> {
  final TextEditingController _input = TextEditingController(
    text:
        'Contact Ram at 9801234567 or the office on ०१-४४१२३४५. '
        'For Pokhara branch call 061 523456, Smart: 9612345678.',
  );
  PhoneType? _type;
  _View _view = _View.found;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  String _mask(PhoneNumberMatch match) {
    final digits = match.number.nationalNumber;
    if (digits.length <= 4) return digits;
    return digits.substring(0, 3) +
        '•' * (digits.length - 5) +
        digits.substring(digits.length - 2);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final text = _input.text;
    final matches = NepaliPhoneNumber.findAll(text, type: _type).toList();
    final count = NepaliNumberFormat.decimalPattern(language)
        .format(matches.length);

    return SectionCard(
      icon: Icons.manage_search_rounded,
      title: context.tr('Find numbers in text', 'पाठबाट नम्बर खोज्नुहोस्'),
      subtitle: context.tr(
        'Paste an SMS, notice or contact list',
        'एसएमएस, सूचना वा सम्पर्क सूची टाँस्नुहोस्',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _input,
            onChanged: (_) => setState(() {}),
            minLines: 3,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: context.tr('Text', 'पाठ'),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (type, label) in [
                (null, context.tr('All', 'सबै')),
                (PhoneType.mobile, context.tr('Mobile', 'मोबाइल')),
                (PhoneType.landline, context.tr('Landline', 'ल्यान्डलाइन')),
              ])
                FilterChip(
                  label: Text(label),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<_View>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _View.found,
                label: Text(context.tr('Found ($count)', 'भेटिएका ($count)')),
              ),
              ButtonSegment(
                value: _View.formatted,
                label: Text(context.tr('Tidy', 'मिलाइएको')),
              ),
              ButtonSegment(
                value: _View.masked,
                label: Text(context.tr('Hide', 'लुकाइएको')),
              ),
            ],
            selected: {_view},
            onSelectionChanged: (v) => setState(() => _view = v.first),
          ),
          const SizedBox(height: 12),
          switch (_view) {
            _View.found when matches.isEmpty => InfoBanner(
              message: context.tr('No numbers found.', 'कुनै नम्बर भेटिएन।'),
            ),
            _View.found => Column(
              children: [
                for (final match in matches)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Icon(
                        match.number.type == PhoneType.mobile
                            ? Icons.smartphone_rounded
                            : Icons.call_rounded,
                      ),
                    ),
                    title: Text(match.number.format(language: language)),
                    subtitle: Text(
                      '${_describe(context, match.number)} · "${match.text}"',
                    ),
                    trailing: IconButton(
                      tooltip: context.tr('Copy', 'कपी'),
                      onPressed: () =>
                          copyToClipboard(context, match.number.e164),
                      icon: const Icon(Icons.content_copy_rounded),
                    ),
                  ),
              ],
            ),
            _View.formatted => ResultTile(
              label: context.tr(
                'Every number in one style',
                'सबै नम्बर एउटै शैलीमा',
              ),
              value: NepaliPhoneNumber.replaceAll(
                text,
                (m) => m.number.format(language: language),
                type: _type,
              ),
            ),
            _View.masked => ResultTile(
              label: context.tr(
                'Safe to share publicly',
                'सार्वजनिक रूपमा बाँड्न सुरक्षित',
              ),
              value: NepaliPhoneNumber.replaceAll(text, _mask, type: _type),
            ),
          },
        ],
      ),
    );
  }
}

class const _OperatorsCard() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.language;
    return SectionCard(
      icon: Icons.cell_tower_rounded,
      title: context.tr('Mobile prefixes', 'मोबाइल प्रिफिक्स'),
      subtitle: context.tr(
        'Which operator a number belongs to',
        'नम्बर कुन अपरेटरको हो',
      ),
      child: Column(
        children: [
          for (final operator in MobileOperator.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(operator.label(language)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final prefix in operator.prefixes)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(localPrefix(prefix, language)),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String localPrefix(String prefix, Language language) =>
      language == Language.nepali ? Devanagari.toNepaliDigits(prefix) : prefix;
}
