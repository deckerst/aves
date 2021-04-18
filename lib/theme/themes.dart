import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Themes {
  static const _accentColor = Colors.indigoAccent;

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    accentColor: _accentColor,
    scaffoldBackgroundColor: Colors.grey[900],
    dialogBackgroundColor: Colors.grey[850],
    toggleableActiveColor: _accentColor,
    tooltipTheme: TooltipThemeData(
      verticalOffset: 32,
    ),
    appBarTheme: AppBarTheme(
      textTheme: TextTheme(
        headline6: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal,
          fontFeatures: [FontFeature.enable('smcp')],
        ),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: _accentColor,
      secondary: _accentColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey[800],
      contentTextStyle: TextStyle(
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
