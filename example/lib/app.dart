import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils_example/features/converter/converter_page.dart';
import 'package:nepali_utils_example/features/numbers/numbers_page.dart';
import 'package:nepali_utils_example/features/phone/phone_page.dart';
import 'package:nepali_utils_example/features/today/today_page.dart';
import 'package:nepali_utils_example/features/typing/typing_page.dart';
import 'package:nepali_utils_example/features/units/units_page.dart';
import 'package:nepali_utils_example/state/settings.dart';
import 'package:nepali_utils_example/theme.dart';
import 'package:nepali_utils_example/widgets/morphing_shape.dart';

/// The root of Nepali Utils.
class const NepaliUtilsApp({
  required final AppSettings settings,

  /// The tool to open first, by its English name, e.g. `money`.
  final String? initialTool,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      settings: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          title: 'Nepali Utils',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: buildTheme(
            brightness: Brightness.light,
            seed: settings.seed,
            contrast: settings.contrast,
          ),
          darkTheme: buildTheme(
            brightness: Brightness.dark,
            seed: settings.seed,
            contrast: settings.contrast,
          ),
          locale: Locale(settings.language.languageCode),
          supportedLocales: const [Locale('en'), Locale('ne')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: HomeShell(initialTool: initialTool),
        ),
      ),
    );
  }
}

/// One tool in the navigation.
class const _Destination({
  required final IconData icon,
  required final IconData selectedIcon,
  required final String english,
  required final String nepali,
  required final String englishSubtitle,
  required final String nepaliSubtitle,
  required final RoundedPolygon shape,
  required final Widget page,
});

final List<_Destination> _destinations = [
  _Destination(
    icon: Icons.today_outlined,
    selectedIcon: Icons.today_rounded,
    english: 'Today',
    nepali: 'आज',
    englishSubtitle: 'Nepali calendar and Nepal Time',
    nepaliSubtitle: 'नेपाली पात्रो र नेपाली समय',
    shape: MaterialShapes.sunny,
    page: const TodayPage(),
  ),
  _Destination(
    icon: Icons.swap_horiz_outlined,
    selectedIcon: Icons.swap_horiz_rounded,
    english: 'Dates',
    nepali: 'मिति',
    englishSubtitle: 'Convert BS ⇄ AD, format dates, count days',
    nepaliSubtitle: 'वि.सं. ⇄ ई.सं., ढाँचा र दिन गणना',
    shape: MaterialShapes.cookie9Sided,
    page: const ConverterPage(),
  ),
  _Destination(
    icon: Icons.payments_outlined,
    selectedIcon: Icons.payments_rounded,
    english: 'Money',
    nepali: 'रकम',
    englishSubtitle: 'Lakh-crore formatting, cheque words, VAT',
    nepaliSubtitle: 'लाख-करोड, चेकका लागि अक्षर, भ्याट',
    shape: MaterialShapes.pill,
    page: const NumbersPage(),
  ),
  _Destination(
    icon: Icons.keyboard_outlined,
    selectedIcon: Icons.keyboard_rounded,
    english: 'Type',
    nepali: 'टाइप',
    englishSubtitle: 'Romanized and Preeti to Unicode',
    nepaliSubtitle: 'रोमन र प्रीतिबाट युनिकोड',
    shape: MaterialShapes.clover4Leaf,
    page: const TypingPage(),
  ),
  _Destination(
    icon: Icons.square_foot_outlined,
    selectedIcon: Icons.square_foot_rounded,
    english: 'Units',
    nepali: 'नापतौल',
    englishSubtitle: 'Land, gold and grain measures',
    nepaliSubtitle: 'जग्गा, सुन र अन्नको नापतौल',
    shape: MaterialShapes.gem,
    page: const UnitsPage(),
  ),
  _Destination(
    icon: Icons.phone_outlined,
    selectedIcon: Icons.phone_rounded,
    english: 'Phone',
    nepali: 'फोन',
    englishSubtitle: 'Check, tidy and find phone numbers',
    nepaliSubtitle: 'फोन नम्बर जाँच, मिलाउने र खोज्ने',
    shape: MaterialShapes.softBurst,
    page: const PhonePage(),
  ),
];

/// The adaptive navigation shell: a bottom bar on phones and a rail on
/// larger screens.
class const HomeShell({final String? initialTool, super.key})
    extends StatefulWidget {
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  late int _index = _destinations
      .indexWhere((d) => d.english.toLowerCase() == widget.initialTool)
      .clamp(0, _destinations.length - 1);
  late final AnimationController _enter = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    if (MediaQuery.disableAnimationsOf(context)) return;
    _enter.animateWith(
      SpringSimulation(Springs.expressiveFastSpatial, 0, 1, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final destination = _destinations[_index];

    // Keeps every tool alive so typed input survives switching tools, and
    // slides the new tool in with an expressive spring.
    final pages = AnimatedBuilder(
      animation: _enter,
      builder: (context, child) => Opacity(
        opacity: _enter.value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - _enter.value)),
          child: child,
        ),
      ),
      child: IndexedStack(
        index: _index,
        children: [
          for (final (i, d) in _destinations.indexed)
            TickerMode(enabled: i == _index, child: d.page),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 600;
        final body = Column(
          children: [
            _Header(destination: destination, compact: compact),
            Expanded(child: pages),
          ],
        );

        if (compact) {
          return Scaffold(
            body: SafeArea(bottom: false, child: body),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: context.tr(d.english, d.nepali),
                  ),
              ],
            ),
          );
        }

        final extended = width >= 1100;
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: extended,
                selectedIndex: _index,
                onDestinationSelected: _select,
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                groupAlignment: -1,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _Brand(extended: extended),
                ),
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(context.tr(d.english, d.nepali)),
                    ),
                ],
              ),
              Expanded(
                child: ColoredBox(
                  color: scheme.surface,
                  child: SafeArea(child: body),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class const _Brand({required final bool extended}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mark = MorphingShape(
      shape: MaterialShapes.cookie12Sided,
      size: 48,
      color: scheme.primary,
      child: Text(
        'ने',
        style: theme.textTheme.titleLarge?.copyWith(color: scheme.onPrimary),
      ),
    );
    if (!extended) return mark;
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          mark,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nepali Utils', style: theme.textTheme.titleMedium),
                Text(
                  'नेपाली युटिल्स',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class const _Header({
  required final _Destination destination,
  required final bool compact,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings = SettingsScope.of(context);
    final nepali = context.isNepali;
    final dark = switch (settings.themeMode) {
      ThemeMode.system => theme.brightness == Brightness.dark,
      ThemeMode.dark => true,
      ThemeMode.light => false,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 24, 16, 12, 12),
      child: Row(
        children: [
          MorphingShape(
            shape: destination.shape,
            size: compact ? 52 : 64,
            color: scheme.primary,
            child: Icon(
              destination.selectedIcon,
              color: scheme.onPrimary,
              size: compact ? 24 : 28,
            ),
          ),
          SizedBox(width: compact ? 12 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(destination.english, destination.nepali),
                  style: compact
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.headlineMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  context.tr(
                    destination.englishSubtitle,
                    destination.nepaliSubtitle,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: nepali ? 'Switch to English' : 'नेपालीमा हेर्नुहोस्',
            isSelected: nepali,
            onPressed: () =>
                settings.language = nepali ? Language.english : Language.nepali,
            icon: Text(
              nepali ? 'EN' : 'ने',
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
            selectedIcon: Text(
              nepali ? 'EN' : 'ने',
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSecondary,
              ),
            ),
          ),
          if (!compact)
            IconButton(
              tooltip: context.tr('Toggle theme', 'थिम बदल्नुहोस्'),
              onPressed: () =>
                  settings.themeMode = dark ? ThemeMode.light : ThemeMode.dark,
              icon: Icon(
                dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
            ),
          IconButton(
            tooltip: context.tr('Settings', 'सेटिङ'),
            onPressed: () => showSettingsSheet(context),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
    );
  }
}

/// Language, theme, color and contrast settings.
Future<void> showSettingsSheet(BuildContext context) {
  final settings = SettingsScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        Widget heading(String text) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(text, style: theme.textTheme.titleSmall),
        );

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.tr('Settings', 'सेटिङ'),
                  style: theme.textTheme.headlineSmall,
                ),
                heading(context.tr('Language', 'भाषा')),
                SegmentedButton<Language>(
                  segments: const [
                    ButtonSegment(
                      value: Language.english,
                      label: Text('English'),
                    ),
                    ButtonSegment(
                      value: Language.nepali,
                      label: Text('नेपाली'),
                    ),
                  ],
                  selected: {settings.language},
                  onSelectionChanged: (v) => settings.language = v.first,
                ),
                heading(context.tr('Theme', 'थिम')),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_rounded),
                      label: Text(context.tr('Auto', 'स्वतः')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_rounded),
                      label: Text(context.tr('Light', 'उज्यालो')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_rounded),
                      label: Text(context.tr('Dark', 'अँध्यारो')),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (v) => settings.themeMode = v.first,
                ),
                heading(context.tr('Color', 'रङ')),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final color in seedColors)
                      _Swatch(
                        color: color,
                        selected: color == settings.seed,
                        onTap: () => settings.seed = color,
                      ),
                  ],
                ),
                heading(context.tr('Contrast', 'कन्ट्रास्ट')),
                SegmentedButton<double>(
                  segments: [
                    ButtonSegment(
                      value: 0,
                      label: Text(context.tr('Standard', 'सामान्य')),
                    ),
                    ButtonSegment(
                      value: 0.5,
                      label: Text(context.tr('Medium', 'मध्यम')),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text(context.tr('High', 'उच्च')),
                    ),
                  ],
                  selected: {settings.contrast},
                  onSelectionChanged: (v) => settings.contrast = v.first,
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr(
                    'Built with the nepali_utils Dart package and Material 3 '
                        'Expressive.',
                    'nepali_utils डार्ट प्याकेज र Material 3 Expressive '
                        'प्रयोग गरी बनाइएको।',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class const _Swatch({
  required final Color color,
  required final bool selected,
  required final VoidCallback onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: MorphingShape(
          // Selected swatches morph from a circle into a scalloped badge.
          shape: selected ? MaterialShapes.cookie9Sided : MaterialShapes.circle,
          size: 48,
          color: color,
          child: selected
              ? const Icon(Icons.check_rounded, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
