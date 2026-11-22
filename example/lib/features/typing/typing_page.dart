import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils_example/state/settings.dart';
import 'package:nepali_utils_example/widgets/common.dart';

/// Romanized and Preeti text to Unicode, and Devanagari helpers.
class const TypingPage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ToolPage(
      children: [_RomanizedCard(), _PreetiCard(), _DevanagariCard()],
    );
  }
}

String _styleLabel(BuildContext context, NepaliUnicodeStyle style) =>
    switch (style) {
      NepaliUnicodeStyle.classic => context.tr('Classic', 'क्लासिक'),
      NepaliUnicodeStyle.google => 'Google',
      NepaliUnicodeStyle.mppRomanized => context.tr(
        'Romanized keyboard',
        'रोमनाइज्ड किबोर्ड',
      ),
      NepaliUnicodeStyle.mppTraditional => context.tr(
        'Traditional keyboard',
        'परम्परागत किबोर्ड',
      ),
    };

const Map<NepaliUnicodeStyle, List<String>> _samples = {
  NepaliUnicodeStyle.classic: [
    'namaste',
    "sayau' thu''gaa fUlakaa haamii",
    'mero naam {Sarbagya} ho',
  ],
  NepaliUnicodeStyle.google: [
    'namaste',
    'nepaal ko maayaa',
    'bhagawaan~ ko dayaa',
  ],
  NepaliUnicodeStyle.mppRomanized: ['nepal', 'nms/te'],
  NepaliUnicodeStyle.mppTraditional: ['g]kfn', r'gd;\t]'],
};

class const _RomanizedCard() extends StatefulWidget {
  @override
  State<_RomanizedCard> createState() => _RomanizedCardState();
}

class _RomanizedCardState extends State<_RomanizedCard> {
  final TextEditingController _input = TextEditingController(text: 'namaste');
  NepaliUnicodeStyle _style = NepaliUnicodeStyle.classic;
  bool _digits = true;
  bool _inPlace = false;

  NepaliUnicode get _converter =>
      NepaliUnicode(style: _style, nepaliDigits: _digits);

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    if (_inPlace) {
      // Convert while typing, like a Nepali keyboard.
      final converted = _converter.convertLive(text);
      if (converted != text) {
        _input.value = TextEditingValue(
          text: converted,
          selection: TextSelection.collapsed(offset: converted.length),
        );
      }
    }
    setState(() {});
  }

  void _useSample(String sample) {
    setState(() {
      _inPlace = false;
      _input.text = sample;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final output = _converter.convert(_input.text);
    final roman = _converter.toRoman(output);

    return SectionCard(
      icon: Icons.keyboard_rounded,
      title: context.tr('Type in Nepali', 'नेपालीमा टाइप गर्नुहोस्'),
      subtitle: context.tr(
        'Romanized or keyboard input → Unicode',
        'रोमन वा किबोर्ड इनपुट → युनिकोड',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final style in NepaliUnicodeStyle.values)
                ChoiceChip(
                  label: Text(_styleLabel(context, style)),
                  selected: style == _style,
                  onSelected: (_) => setState(() => _style = style),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _input,
            onChanged: _onChanged,
            minLines: 2,
            maxLines: 6,
            style: theme.textTheme.titleMedium,
            decoration: InputDecoration(
              labelText: _inPlace
                  ? context.tr('Type here', 'यहाँ टाइप गर्नुहोस्')
                  : context.tr('Romanized text', 'रोमन अक्षरमा'),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final sample in _samples[_style]!)
                ActionChip(
                  avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: Text(sample),
                  onPressed: () => _useSample(sample),
                ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              context.tr('Convert as I type', 'टाइप गर्दै रूपान्तरण'),
            ),
            subtitle: Text(
              context.tr(
                'Replaces the text in the box itself',
                'बाकसभित्रकै अक्षर बदलिन्छ',
              ),
            ),
            value: _inPlace,
            onChanged: (v) => setState(() {
              _inPlace = v;
              if (v) _input.text = _converter.convertLive(_input.text);
            }),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('Nepali digits', 'नेपाली अंक')),
            value: _digits,
            onChanged: (v) => setState(() => _digits = v),
          ),
          const SizedBox(height: 8),
          ResultTile(
            label: context.tr('Unicode', 'युनिकोड'),
            value: output,
            emphasis: true,
          ),
          const SizedBox(height: 8),
          ResultTile(
            label: context.tr('Back to Roman', 'फेरि रोमनमा'),
            value: roman,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton.icon(
                style: const ButtonStyle(sizeVariant: ButtonSizeVariant.medium),
                onPressed: output.isEmpty
                    ? null
                    : () => copyToClipboard(context, output),
                icon: const Icon(Icons.content_copy_rounded),
                label: Text(context.tr('Copy Nepali', 'नेपाली कपी')),
              ),
              IconButton.outlined(
                style: const ButtonStyle(sizeVariant: ButtonSizeVariant.medium),
                tooltip: context.tr('Clear', 'मेटाउनुहोस्'),
                onPressed: () => setState(_input.clear),
                icon: const Icon(Icons.backspace_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              'Wrap English words in {braces} to keep them as they are.',
              'अंग्रेजी शब्द जस्ताको तस्तै राख्न {कोष्ठ} भित्र लेख्नुहोस्।',
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

class const _PreetiCard() extends StatefulWidget {
  @override
  State<_PreetiCard> createState() => _PreetiCardState();
}

class _PreetiCardState extends State<_PreetiCard> {
  final TextEditingController _input = TextEditingController(
    text: 'g]kfn ;/sf/',
  );
  bool _toUnicode = true;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _swap() {
    final output = _convert();
    setState(() {
      _toUnicode = !_toUnicode;
      _input.text = output;
    });
  }

  String _convert() => _toUnicode
      ? Preeti.toUnicode(_input.text)
      : Preeti.fromUnicode(_input.text);

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.font_download_rounded,
      title: context.tr('Preeti ⇄ Unicode', 'प्रीति ⇄ युनिकोड'),
      subtitle: context.tr(
        'Rescue text from old Preeti documents',
        'पुराना प्रीति फन्टका कागजातबाट अक्षर निकाल्नुहोस्',
      ),
      trailing: IconButton.filledTonal(
        tooltip: context.tr('Swap direction', 'दिशा बदल्नुहोस्'),
        onPressed: _swap,
        icon: const Icon(Icons.swap_vert_rounded),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _input,
            onChanged: (_) => setState(() {}),
            minLines: 2,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: _toUnicode
                  ? context.tr('Text typed in Preeti', 'प्रीतिमा टाइप गरिएको')
                  : context.tr('Unicode text', 'युनिकोड अक्षर'),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          ResultTile(
            label: _toUnicode
                ? context.tr('Unicode', 'युनिकोड')
                : context.tr(
                    'Preeti (paste into a Preeti font)',
                    'प्रीति (प्रीति फन्टमा टाँस्नुहोस्)',
                  ),
            value: _convert(),
            emphasis: true,
          ),
        ],
      ),
    );
  }
}

class const _DevanagariCard() extends StatefulWidget {
  @override
  State<_DevanagariCard> createState() => _DevanagariCardState();
}

class _DevanagariCardState extends State<_DevanagariCard> {
  final TextEditingController _input = TextEditingController(
    text: 'संस्कृति २०८३',
  );

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final text = _input.text;
    final aksharas = Devanagari.aksharas(text)
        .where((a) => a.trim().isNotEmpty)
        .toList();
    final number = NepaliNumberFormat.decimalPattern(language);
    final yes = context.tr('Yes', 'हो');
    final no = context.tr('No', 'होइन');

    return SectionCard(
      icon: Icons.translate_rounded,
      title: context.tr('Devanagari tools', 'देवनागरी औजार'),
      subtitle: context.tr(
        'Digits, syllables and script checks',
        'अंक, अक्षर र लिपि जाँच',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _input,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: context.tr('Any text', 'कुनै पनि पाठ'),
            ),
          ),
          const SizedBox(height: 12),
          ResultList(
            results: [
              (
                context.tr('With English digits', 'अंग्रेजी अंकमा'),
                Devanagari.toEnglishDigits(text),
              ),
              (
                context.tr('With Nepali digits', 'नेपाली अंकमा'),
                Devanagari.toNepaliDigits(text),
              ),
              (
                context.tr('Only Devanagari?', 'देवनागरी मात्र?'),
                Devanagari.isDevanagari(text) ? yes : no,
              ),
              (
                context.tr('Contains Devanagari?', 'देवनागरी छ?'),
                Devanagari.containsDevanagari(text) ? yes : no,
              ),
              (
                context.tr('Syllables (aksharas)', 'अक्षर संख्या'),
                number.format(aksharas.length),
              ),
            ],
          ),
          if (aksharas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final akshara in aksharas)
                  Chip(
                    label: Text(
                      akshara,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
