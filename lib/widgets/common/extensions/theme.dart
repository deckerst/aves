import 'package:flutter/material.dart';

extension ExtraThemeData on ThemeData {
  bool get isDark => brightness == Brightness.dark;
}
