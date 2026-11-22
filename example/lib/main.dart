import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_utils_example/app.dart';
import 'package:nepali_utils_example/state/settings.dart';

/// Links can pick the first tool, language and theme, e.g.
/// `?tool=money&lang=ne&theme=dark`.
void main() {
  final query = Uri.base.queryParameters;
  final settings = AppSettings();
  if (Language.tryParse(query['lang'] ?? '') case final language?) {
    settings.language = language;
  }
  settings.themeMode = switch (query['theme']) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };
  runApp(
    NepaliUtilsApp(
      settings: settings,
      initialTool: query['tool']?.toLowerCase(),
    ),
  );
}
