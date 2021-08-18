import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Themes {
  static const _accentColor = Colors.indigoAccent;

  static const debugGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Colors.red,
      Colors.amber,
    ],
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    accentColor: _accentColor,
    // canvas color is used as background for the drawer and popups
    // when using a popup menu on a dialog, lighten the background via `PopupMenuTheme`
    canvasColor: Colors.grey[850],
    scaffoldBackgroundColor: Colors.grey.shade900,
    dialogBackgroundColor: Colors.grey[850],
    toggleableActiveColor: _accentColor,
    tooltipTheme: const TooltipThemeData(
      verticalOffset: 32,
    ),
    appBarTheme: const AppBarTheme(
      textTheme: TextTheme(
        headline6: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal,
          fontFeatures: [FontFeature.enable('smcp')],
        ),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: _accentColor,
      secondary: _accentColor,
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
