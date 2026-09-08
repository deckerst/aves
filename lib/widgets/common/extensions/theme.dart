import 'package:material_ui/material_ui.dart';

extension ExtraThemeData on ThemeData {
  bool get isDark => brightness == Brightness.dark;
}
