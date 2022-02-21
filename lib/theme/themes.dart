import 'dart:ui';

import 'package:flutter/material.dart';

class Themes {
  static const _accentColor = Colors.indigoAccent;

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    // canvas color is used as background for the drawer and popups
    // when using a popup menu on a dialog, lighten the background via `PopupMenuTheme`
    canvasColor: Colors.grey[850],
    scaffoldBackgroundColor: Colors.grey.shade900,
    dialogBackgroundColor: Colors.grey[850],
    indicatorColor: _accentColor,
    toggleableActiveColor: _accentColor,
    tooltipTheme: const TooltipThemeData(
      verticalOffset: 32,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        fontFeatures: [FontFeature.enable('smcp')],
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: _accentColor,
      secondary: _accentColor,
      // surface color is used as background for the date picker header
      surface: Colors.grey.shade800,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey.shade800,
      actionTextColor: _accentColor,
      contentTextStyle: const TextStyle(
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.white,
      ),
    ),
  );
}
