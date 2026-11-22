import 'package:material_ui/material_ui.dart';

/// Builds a Material 3 Expressive theme from a [seed] color.
ThemeData buildTheme({
  required Brightness brightness,
  required Color seed,
  required double contrast,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    contrastLevel: contrast,
  );
  final base = ThemeData(colorScheme: scheme);
  final text = base.textTheme;
  const fieldRadius = BorderRadius.all(Radius.circular(20));

  return base.copyWith(
    // Emphasized, heavier type for hero numbers and headings.
    textTheme: text.copyWith(
      displayLarge: text.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      displayMedium: text.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
      displaySmall: text.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineLarge: text.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: text.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    // Opt the components that support it into Material 3 Expressive.
    iconButtonTheme: const IconButtonThemeData(
      variant: StyleVariant.material3Expressive,
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      variant: StyleVariant.material3Expressive,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: const OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),
    segmentedButtonTheme: const SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(StadiumBorder()),
        visualDensity: VisualDensity.standard,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      side: BorderSide(color: scheme.outlineVariant),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
  );
}
