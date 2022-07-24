import 'dart:ui';

import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Themes {
  static const defaultAccent = Colors.indigoAccent;

  static const _tooltipTheme = TooltipThemeData(
    verticalOffset: 32,
  );

  static const _appBarTitleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    fontFeatures: [FontFeature.enable('smcp')],
  );

  static SnackBarThemeData _snackBarTheme(Color accentColor) => SnackBarThemeData(
        actionTextColor: accentColor,
        behavior: SnackBarBehavior.floating,
      );

  static final _typography = Typography.material2018(platform: TargetPlatform.android);

  static final _lightThemeTypo = _typography.black;
  static final _lightTitleColor = _lightThemeTypo.titleMedium!.color!;
  static final _lightBodyColor = _lightThemeTypo.bodyMedium!.color!;
  static final _lightLabelColor = _lightThemeTypo.labelMedium!.color!;
  static const _lightActionIconColor = Color(0xAA000000);
  static const _lightFirstLayer = Color(0xFFFAFAFA); // aka `Colors.grey[50]`
  static const _lightSecondLayer = Color(0xFFF5F5F5); // aka `Colors.grey[100]`
  static const _lightThirdLayer = Color(0xFFEEEEEE); // aka `Colors.grey[200]`

  static ThemeData lightTheme(Color accentColor) => ThemeData(
        colorScheme: ColorScheme.light(
          primary: accentColor,
          secondary: accentColor,
          onPrimary: _lightBodyColor,
          onSecondary: _lightBodyColor,
        ),
        brightness: Brightness.light,
        // `canvasColor` is used by `Drawer`, `DropdownButton` and `ExpansionTileCard`
        canvasColor: _lightSecondLayer,
        scaffoldBackgroundColor: _lightFirstLayer,
        // `cardColor` is used by `ExpansionPanel`
        cardColor: _lightSecondLayer,
        dialogBackgroundColor: _lightSecondLayer,
        indicatorColor: accentColor,
        toggleableActiveColor: accentColor,
        typography: _typography,
        appBarTheme: AppBarTheme(
          backgroundColor: _lightFirstLayer,
          // `foregroundColor` is used by icons
          foregroundColor: _lightActionIconColor,
          // `titleTextStyle.color` is used by text
          titleTextStyle: _appBarTitleTextStyle.copyWith(color: _lightTitleColor),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: _lightActionIconColor,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: _lightSecondLayer,
        ),
        snackBarTheme: _snackBarTheme(accentColor),
        tabBarTheme: TabBarTheme(
          labelColor: _lightTitleColor,
          unselectedLabelColor: Colors.black54,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _lightLabelColor,
          ),
        ),
        tooltipTheme: _tooltipTheme,
      );

  static final _darkThemeTypo = _typography.white;
  static final _darkTitleColor = _darkThemeTypo.titleMedium!.color!;
  static final _darkBodyColor = _darkThemeTypo.bodyMedium!.color!;
  static final _darkLabelColor = _darkThemeTypo.labelMedium!.color!;
  static const _darkFirstLayer = Color(0xFF212121); // aka `Colors.grey[900]`
  static const _darkSecondLayer = Color(0xFF363636);
  static const _darkThirdLayer = Color(0xFF424242); // aka `Colors.grey[800]`

  static ThemeData darkTheme(Color accentColor) => ThemeData(
        colorScheme: ColorScheme.dark(
          primary: accentColor,
          secondary: accentColor,
          // surface color is used by the date/time pickers
          surface: Colors.grey.shade800,
          onPrimary: _darkBodyColor,
          onSecondary: _darkBodyColor,
        ),
        brightness: Brightness.dark,
        // `canvasColor` is used by `Drawer`, `DropdownButton` and `ExpansionTileCard`
        canvasColor: _darkSecondLayer,
        scaffoldBackgroundColor: _darkFirstLayer,
        // `cardColor` is used by `ExpansionPanel`
        cardColor: _darkSecondLayer,
        dialogBackgroundColor: _darkSecondLayer,
        indicatorColor: accentColor,
        toggleableActiveColor: accentColor,
        typography: _typography,
        appBarTheme: AppBarTheme(
          backgroundColor: _darkFirstLayer,
          // `foregroundColor` is used by icons
          foregroundColor: _darkTitleColor,
          // `titleTextStyle.color` is used by text
          titleTextStyle: _appBarTitleTextStyle.copyWith(color: _darkTitleColor),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: _darkSecondLayer,
        ),
        snackBarTheme: _snackBarTheme(accentColor).copyWith(
          backgroundColor: Colors.grey.shade800,
          contentTextStyle: TextStyle(
            color: _darkBodyColor,
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: _darkTitleColor,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _darkLabelColor,
          ),
        ),
        tooltipTheme: _tooltipTheme,
      );

  static const _blackFirstLayer = Colors.black;
  static const _blackSecondLayer = Color(0xFF212121); // aka `Colors.grey[900]`
  static const _blackThirdLayer = Color(0xFF303030); // aka `Colors.grey[850]`

  static ThemeData blackTheme(Color accentColor) {
    final baseTheme = darkTheme(accentColor);
    return baseTheme.copyWith(
      // `canvasColor` is used by `Drawer`, `DropdownButton` and `ExpansionTileCard`
      canvasColor: _blackSecondLayer,
      scaffoldBackgroundColor: _blackFirstLayer,
      // `cardColor` is used by `ExpansionPanel`
      cardColor: _blackSecondLayer,
      dialogBackgroundColor: _blackSecondLayer,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: _blackFirstLayer,
      ),
      popupMenuTheme: baseTheme.popupMenuTheme.copyWith(
        color: _blackSecondLayer,
      ),
    );
  }

  static Color overlayBackgroundColor({
    required Brightness brightness,
    required bool blurred,
  }) {
    switch (brightness) {
      case Brightness.dark:
        return blurred ? Colors.black26 : Colors.black45;
      case Brightness.light:
        return blurred ? Colors.white54 : const Color(0xCCFFFFFF);
    }
  }

  static Color thirdLayerColor(BuildContext context) {
    final isBlack = context.select<Settings, bool>((v) => v.themeBrightness == AvesThemeBrightness.black);
    if (isBlack) {
      return _blackThirdLayer;
    } else {
      switch (Theme.of(context).brightness) {
        case Brightness.dark:
          return _darkThirdLayer;
        case Brightness.light:
          return _lightThirdLayer;
      }
    }
  }
}
