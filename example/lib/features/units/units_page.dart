import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils_example/features/numbers/numbers_page.dart';
import 'package:nepali_utils_example/state/settings.dart';
import 'package:nepali_utils_example/widgets/common.dart';

/// Land area, gold and weight, and grain volume converters.
class const UnitsPage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ToolPage(
      children: [_LandCard(), _WeightCard(), _VolumeCard()],
    );
  }
}

/// How a measurement is typed: dash separated parts of a traditional system,
/// or a plain number in one unit.
enum _Entry { system1, system2, unit }

String _number(BuildContext context, double value, {int digits = 2}) =>
    NepaliNumberFormat.decimalPatternDigits(
      language: context.language,
      decimalDigits: digits,
    ).format(value);

/// The entry field shared by all three converters.
class const _EntryField({
  required final TextEditingController controller,
  required final String label,
  required final String helper,
  required final bool invalid,
  required final ValueChanged<String> onChanged,
  final Widget? unitPicker,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.text,
      style: Theme.of(context).textTheme.titleLarge,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        errorText: invalid
            ? context.tr('Check the value', 'मान जाँच्नुहोस्')
            : null,
      ),
    );
    if (unitPicker == null) return field;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field),
        const SizedBox(width: 8),
        unitPicker!,
      ],
    );
  }
}

/// Quick presets shown as chips.
class const _Presets<T>({
  required final List<(String, T)> presets,
  required final ValueChanged<T> onSelected,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final (label, value) in presets)
        ActionChip(label: Text(label), onPressed: () => onSelected(value)),
    ],
  );
}

class const _LandCard() extends StatefulWidget {
  @override
  State<_LandCard> createState() => _LandCardState();
}

class _LandCardState extends State<_LandCard> {
  _Entry _entry = _Entry.system1;
  AreaUnit _unit = AreaUnit.squareFoot;
  final TextEditingController _input = TextEditingController(text: '2-3-1-0');
  NepaliArea? _area = NepaliArea.ropani(2, aana: 3, paisa: 1);

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  NepaliArea? _parse(String text) {
    final ascii = Devanagari.toEnglishDigits(text);
    return switch (_entry) {
      _Entry.system1 => NepaliArea.tryParse(ascii, AreaSystem.ropani),
      _Entry.system2 => NepaliArea.tryParse(ascii, AreaSystem.bigha),
      _Entry.unit => switch (parseAmount(text)) {
        final value? => NepaliArea(value, _unit),
        null => null,
      },
    };
  }

  /// Shows [area] in the current entry mode.
  void _show(NepaliArea area) {
    setState(() {
      _area = area;
      _input.text = switch (_entry) {
        _Entry.system1 => area.format(AreaSystem.ropani, language: .english),
        _Entry.system2 => area.format(AreaSystem.bigha, language: .english),
        _Entry.unit => '${double.parse(area.to(_unit).toStringAsFixed(4))}',
      };
    });
  }

  void _setEntry(_Entry entry) {
    final area = _area;
    _entry = entry;
    if (area != null) {
      _show(area);
    } else {
      setState(_input.clear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final area = _area;

    return SectionCard(
      icon: Icons.landscape_rounded,
      title: context.tr('Land area', 'जग्गाको क्षेत्रफल'),
      subtitle: context.tr(
        'Ropani, bigha and metric, all at once',
        'रोपनी, बिघा र मेट्रिक एकैपटक',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_Entry>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _Entry.system1,
                label: Text(context.tr('Ropani', 'रोपनी')),
              ),
              ButtonSegment(
                value: _Entry.system2,
                label: Text(context.tr('Bigha', 'बिघा')),
              ),
              ButtonSegment(
                value: _Entry.unit,
                label: Text(context.tr('Other', 'अन्य')),
              ),
            ],
            selected: {_entry},
            onSelectionChanged: (v) => _setEntry(v.first),
          ),
          const SizedBox(height: 16),
          _EntryField(
            controller: _input,
            invalid: _input.text.isNotEmpty && area == null,
            onChanged: (text) => setState(() => _area = _parse(text)),
            label: switch (_entry) {
              _Entry.system1 => context.tr(
                'Ropani-Aana-Paisa-Daam',
                'रोपनी-आना-पैसा-दाम',
              ),
              _Entry.system2 => context.tr(
                'Bigha-Kattha-Dhur',
                'बिघा-कट्ठा-धुर',
              ),
              _Entry.unit => context.tr('Area', 'क्षेत्रफल'),
            },
            helper: switch (_entry) {
              _Entry.system1 => context.tr(
                'e.g. 2-3-1-0, or just 4-8',
                'जस्तै २-३-१-०, वा ४-८ मात्र',
              ),
              _Entry.system2 => context.tr('e.g. 1-5-2.5', 'जस्तै १-५-२.५'),
              _Entry.unit => context.tr('Any number', 'कुनै पनि संख्या'),
            },
            unitPicker: _entry == _Entry.unit
                ? DropdownMenu<AreaUnit>(
                    width: 150,
                    initialSelection: _unit,
                    onSelected: (unit) {
                      if (unit == null) return;
                      setState(() {
                        _unit = unit;
                        _area = _parse(_input.text);
                      });
                    },
                    dropdownMenuEntries: [
                      for (final unit in AreaUnit.values)
                        DropdownMenuEntry(
                          value: unit,
                          label: unit.label(language),
                        ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 12),
          _Presets<NepaliArea>(
            onSelected: _show,
            presets: [
              (context.tr('1 ropani', '१ रोपनी'), NepaliArea.ropani(1)),
              (context.tr('4 aana', '४ आना'), NepaliArea.ropani(0, aana: 4)),
              (context.tr('1 bigha', '१ बिघा'), NepaliArea.bigha(1)),
              (
                context.tr('1 kattha', '१ कट्ठा'),
                NepaliArea.bigha(0, kattha: 1),
              ),
              (
                context.tr('1000 sq. ft', '१००० वर्ग फिट'),
                NepaliArea(1000, AreaUnit.squareFoot),
              ),
            ],
          ),
          if (area != null) ...[
            const SizedBox(height: 16),
            ResultTile(
              label: context.tr('In ropani', 'रोपनीमा'),
              value: area.format(AreaSystem.ropani, long: true),
              emphasis: true,
            ),
            const SizedBox(height: 8),
            ResultTile(
              label: context.tr('In bigha', 'बिघामा'),
              value: area.format(AreaSystem.bigha, long: true),
              emphasis: true,
            ),
            const SizedBox(height: 8),
            ResultList(
              results: [
                (
                  context.tr('Short (R-A-P-D)', 'छोटो (रो-आ-पै-दा)'),
                  area.format(AreaSystem.ropani),
                ),
                for (final unit in [
                  AreaUnit.squareFoot,
                  AreaUnit.squareMeter,
                  AreaUnit.ropani,
                  AreaUnit.aana,
                  AreaUnit.kattha,
                  AreaUnit.dhur,
                  AreaUnit.acre,
                  AreaUnit.hectare,
                ])
                  (
                    unit.label(language),
                    _number(context, area.to(unit), digits: 4),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class const _WeightCard() extends StatefulWidget {
  @override
  State<_WeightCard> createState() => _WeightCardState();
}

class _WeightCardState extends State<_WeightCard> {
  _Entry _entry = _Entry.system1;
  WeightUnit _unit = WeightUnit.gram;
  final TextEditingController _input = TextEditingController(text: '1-0');
  final TextEditingController _rate = TextEditingController();
  NepaliWeight? _weight = NepaliWeight.tola(1);

  @override
  void dispose() {
    _input.dispose();
    _rate.dispose();
    super.dispose();
  }

  NepaliWeight? _parse(String text) {
    final ascii = Devanagari.toEnglishDigits(text);
    return switch (_entry) {
      _Entry.system1 => NepaliWeight.tryParse(ascii, WeightSystem.tola),
      _Entry.system2 => NepaliWeight.tryParse(ascii, WeightSystem.dharni),
      _Entry.unit => switch (parseAmount(text)) {
        final value? => NepaliWeight(value, _unit),
        null => null,
      },
    };
  }

  void _show(NepaliWeight weight) {
    setState(() {
      _weight = weight;
      _input.text = switch (_entry) {
        _Entry.system1 => weight.format(WeightSystem.tola, language: .english),
        _Entry.system2 => weight.format(
          WeightSystem.dharni,
          language: .english,
        ),
        _Entry.unit => '${double.parse(weight.to(_unit).toStringAsFixed(4))}',
      };
    });
  }

  void _setEntry(_Entry entry) {
    final weight = _weight;
    _entry = entry;
    if (weight != null) {
      _show(weight);
    } else {
      setState(_input.clear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final weight = _weight;
    final rate = parseAmount(_rate.text);
    final money = NepaliNumberFormat.simpleCurrency(
      language: language,
      decimalDigits: 2,
    );

    return SectionCard(
      icon: Icons.diamond_rounded,
      title: context.tr('Gold & weight', 'सुन र तौल'),
      subtitle: context.tr(
        'Tola-lal, dharni-ser and grams',
        'तोला-लाल, धार्नी-सेर र ग्राम',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_Entry>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _Entry.system1,
                label: Text(context.tr('Tola', 'तोला')),
              ),
              ButtonSegment(
                value: _Entry.system2,
                label: Text(context.tr('Dharni', 'धार्नी')),
              ),
              ButtonSegment(
                value: _Entry.unit,
                label: Text(context.tr('Other', 'अन्य')),
              ),
            ],
            selected: {_entry},
            onSelectionChanged: (v) => _setEntry(v.first),
          ),
          const SizedBox(height: 16),
          _EntryField(
            controller: _input,
            invalid: _input.text.isNotEmpty && weight == null,
            onChanged: (text) => setState(() => _weight = _parse(text)),
            label: switch (_entry) {
              _Entry.system1 => context.tr('Tola-Lal', 'तोला-लाल'),
              _Entry.system2 => context.tr(
                'Dharni-Ser-Pau-Chhatak',
                'धार्नी-सेर-पाउ-छटाक',
              ),
              _Entry.unit => context.tr('Weight', 'तौल'),
            },
            helper: switch (_entry) {
              _Entry.system1 => context.tr('e.g. 2-50', 'जस्तै २-५०'),
              _Entry.system2 => context.tr('e.g. 1-2-1-0', 'जस्तै १-२-१-०'),
              _Entry.unit => context.tr('Any number', 'कुनै पनि संख्या'),
            },
            unitPicker: _entry == _Entry.unit
                ? DropdownMenu<WeightUnit>(
                    width: 150,
                    initialSelection: _unit,
                    onSelected: (unit) {
                      if (unit == null) return;
                      setState(() {
                        _unit = unit;
                        _weight = _parse(_input.text);
                      });
                    },
                    dropdownMenuEntries: [
                      for (final unit in WeightUnit.values)
                        DropdownMenuEntry(
                          value: unit,
                          label: unit.label(language),
                        ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 12),
          _Presets<NepaliWeight>(
            onSelected: _show,
            presets: [
              (context.tr('1 tola', '१ तोला'), NepaliWeight.tola(1)),
              (context.tr('50 lal', '५० लाल'), NepaliWeight.tola(0, lal: 50)),
              (context.tr('1 dharni', '१ धार्नी'), NepaliWeight.dharni(1)),
              (context.tr('1 ser', '१ सेर'), NepaliWeight.dharni(0, ser: 1)),
              (
                context.tr('10 grams', '१० ग्राम'),
                NepaliWeight(10, WeightUnit.gram),
              ),
            ],
          ),
          if (weight != null) ...[
            const SizedBox(height: 16),
            ResultTile(
              label: context.tr('In tola', 'तोलामा'),
              value: weight.format(WeightSystem.tola, long: true),
              emphasis: true,
            ),
            const SizedBox(height: 8),
            ResultList(
              results: [
                (
                  context.tr('In dharni', 'धार्नीमा'),
                  weight.format(WeightSystem.dharni, long: true),
                ),
                for (final unit in [
                  WeightUnit.gram,
                  WeightUnit.kilogram,
                  WeightUnit.tola,
                  WeightUnit.lal,
                ])
                  (
                    unit.label(language),
                    _number(context, weight.to(unit), digits: 3),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            NumberField(
              controller: _rate,
              onChanged: (_) => setState(() {}),
              label: context.tr(
                'Gold or silver rate per tola',
                'प्रति तोला सुन वा चाँदीको दर',
              ),
              suffix: context.tr('per tola', 'प्रति तोला'),
            ),
            if (rate != null) ...[
              const SizedBox(height: 8),
              ResultTile(
                label: context.tr('Price', 'मूल्य'),
                value: money.format(weight.to(WeightUnit.tola) * rate),
                emphasis: true,
              ),
              const SizedBox(height: 8),
              ResultTile(
                label: context.tr('Rate per gram', 'प्रति ग्राम दर'),
                value: money.format(rate / WeightUnit.tola.grams),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class const _VolumeCard() extends StatefulWidget {
  @override
  State<_VolumeCard> createState() => _VolumeCardState();
}

class _VolumeCardState extends State<_VolumeCard> {
  _Entry _entry = _Entry.system1;
  VolumeUnit _unit = VolumeUnit.liter;
  final TextEditingController _input = TextEditingController(text: '1-5-4');
  NepaliVolume? _volume = NepaliVolume.muri(1, pathi: 5, mana: 4);

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  NepaliVolume? _parse(String text) => switch (_entry) {
    _Entry.unit => switch (parseAmount(text)) {
      final value? => NepaliVolume(value, _unit),
      null => null,
    },
    _ => NepaliVolume.tryParse(Devanagari.toEnglishDigits(text)),
  };

  void _show(NepaliVolume volume) {
    setState(() {
      _volume = volume;
      _input.text = _entry == _Entry.unit
          ? '${double.parse(volume.to(_unit).toStringAsFixed(4))}'
          : volume.format(language: .english);
    });
  }

  void _setEntry(_Entry entry) {
    final volume = _volume;
    _entry = entry;
    if (volume != null) {
      _show(volume);
    } else {
      setState(_input.clear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final volume = _volume;

    return SectionCard(
      icon: Icons.grass_rounded,
      title: context.tr('Grain volume', 'अन्नको परिमाण'),
      subtitle: context.tr(
        'Muri, pathi and mana for rice and grains',
        'चामल र अन्नका लागि मुरी, पाथी र माना',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_Entry>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _Entry.system1,
                label: Text(context.tr('Muri-Pathi', 'मुरी-पाथी')),
              ),
              ButtonSegment(
                value: _Entry.unit,
                label: Text(context.tr('Other', 'अन्य')),
              ),
            ],
            selected: {_entry},
            onSelectionChanged: (v) => _setEntry(v.first),
          ),
          const SizedBox(height: 16),
          _EntryField(
            controller: _input,
            invalid: _input.text.isNotEmpty && volume == null,
            onChanged: (text) => setState(() => _volume = _parse(text)),
            label: _entry == _Entry.unit
                ? context.tr('Volume', 'परिमाण')
                : context.tr('Muri-Pathi-Mana-Muthi', 'मुरी-पाथी-माना-मुठी'),
            helper: _entry == _Entry.unit
                ? context.tr('Any number', 'कुनै पनि संख्या')
                : context.tr('e.g. 1-5-4', 'जस्तै १-५-४'),
            unitPicker: _entry == _Entry.unit
                ? DropdownMenu<VolumeUnit>(
                    width: 150,
                    initialSelection: _unit,
                    onSelected: (unit) {
                      if (unit == null) return;
                      setState(() {
                        _unit = unit;
                        _volume = _parse(_input.text);
                      });
                    },
                    dropdownMenuEntries: [
                      for (final unit in VolumeUnit.values)
                        DropdownMenuEntry(
                          value: unit,
                          label: unit.label(language),
                        ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 12),
          _Presets<NepaliVolume>(
            onSelected: _show,
            presets: [
              (context.tr('1 muri', '१ मुरी'), NepaliVolume.muri(1)),
              (context.tr('1 pathi', '१ पाथी'), NepaliVolume.muri(0, pathi: 1)),
              (context.tr('1 mana', '१ माना'), NepaliVolume.muri(0, mana: 1)),
              (
                context.tr('25 litres', '२५ लिटर'),
                NepaliVolume(25, VolumeUnit.liter),
              ),
            ],
          ),
          if (volume != null) ...[
            const SizedBox(height: 16),
            ResultTile(
              label: context.tr('In muri-pathi', 'मुरी-पाथीमा'),
              value: volume.format(long: true),
              emphasis: true,
            ),
            const SizedBox(height: 8),
            ResultList(
              results: [
                for (final unit in VolumeUnit.values)
                  (
                    unit.label(language),
                    _number(context, volume.to(unit), digits: 3),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
