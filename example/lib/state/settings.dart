import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';

/// The crimson of the Nepali flag, used as the default seed color.
const Color nepalCrimson = Color(0xFFDC143C);

/// Seed colors offered in the settings sheet.
const List<Color> seedColors = [
  nepalCrimson,
  Color(0xFF003893), // Flag blue
  Color(0xFFE65100), // Marigold (sayapatri)
  Color(0xFF2E7D32), // Rhododendron leaf
  Color(0xFF6A1B9A), // Jacaranda
  Color(0xFF00838F), // Glacier
];

/// App wide preferences: language, theme mode, seed color and contrast.
class AppSettings extends ChangeNotifier {
  Language _language = NepaliUtils.defaultLanguage;
  ThemeMode _themeMode = ThemeMode.system;
  Color _seed = nepalCrimson;
  double _contrast = 0;

  /// The language of both the UI and every nepali_utils formatter.
  Language get language => _language;
  set language(Language value) {
    if (value == _language) return;
    _language = value;
    // Formatters created without an explicit language follow this.
    NepaliUtils.defaultLanguage = value;
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    if (value == _themeMode) return;
    _themeMode = value;
    notifyListeners();
  }

  Color get seed => _seed;
  set seed(Color value) {
    if (value == _seed) return;
    _seed = value;
    notifyListeners();
  }

  /// The contrast level of the color scheme, from 0 (standard) to 1 (high).
  double get contrast => _contrast;
  set contrast(double value) {
    if (value == _contrast) return;
    _contrast = value;
    notifyListeners();
  }
}

/// Makes [AppSettings] available to the widget tree.
class const SettingsScope({
  required AppSettings settings,
  required super.child,
  super.key,
}) extends InheritedNotifier<AppSettings> {
  this : super(notifier: settings);

  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}

/// Language helpers for widgets.
extension LanguageContext on BuildContext {
  /// The language chosen in the settings.
  Language get language => SettingsScope.of(this).language;

  /// Whether the UI is in Nepali.
  bool get isNepali => language == Language.nepali;

  /// Picks the [english] or [nepali] text for the current language.
  String tr(String english, String nepali) => isNepali ? nepali : english;
}
