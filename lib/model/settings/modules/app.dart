import 'dart:ui' as ui;

import 'package:aves/model/settings/defaults.dart';
import 'package:aves/utils/calendar/aves_locale.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

mixin AppSettings on SettingsAccess {
  bool get hasAcceptedTerms => getBool(SettingKeys.hasAcceptedTermsKey) ?? SettingsDefaults.hasAcceptedTerms;

  set hasAcceptedTerms(bool newValue) => set(SettingKeys.hasAcceptedTermsKey, newValue);

  bool get canUseAnalysisService => getBool(SettingKeys.canUseAnalysisServiceKey) ?? SettingsDefaults.canUseAnalysisService;

  set canUseAnalysisService(bool newValue) => set(SettingKeys.canUseAnalysisServiceKey, newValue);

  bool get isInstalledAppAccessAllowed => getBool(SettingKeys.isInstalledAppAccessAllowedKey) ?? SettingsDefaults.isInstalledAppAccessAllowed;

  set isInstalledAppAccessAllowed(bool newValue) => set(SettingKeys.isInstalledAppAccessAllowedKey, newValue);

  bool get isErrorReportingAllowed => getBool(SettingKeys.isErrorReportingAllowedKey) ?? SettingsDefaults.isErrorReportingAllowed;

  set isErrorReportingAllowed(bool newValue) => set(SettingKeys.isErrorReportingAllowedKey, newValue);

  String? get autoExportPath => getString(SettingKeys.autoExportPathKey);

  set autoExportPath(String? newValue) => set(SettingKeys.autoExportPathKey, newValue);

  static const localeSeparator = '-';

  // basic identifier, without extensions, used for language setup
  // may be null to pick up system locale
  ui.Locale? get basicLocale {
    // exceptionally allow getting locale before settings are initialized
    final tag = initialized ? getString(SettingKeys.localeKey) : null;
    if (tag != null) {
      final codes = tag.split(localeSeparator);
      return ui.Locale.fromSubtags(
        languageCode: codes[0],
        scriptCode: codes[1] == '' ? null : codes[1],
        countryCode: codes[2] == '' ? null : codes[2],
      );
    }
    return null;
  }

  set basicLocale(ui.Locale? newValue) {
    String? tag;
    if (newValue != null) {
      tag = [
        newValue.languageCode,
        newValue.scriptCode ?? '',
        newValue.countryCode ?? '',
      ].join(localeSeparator);
    }
    set(SettingKeys.localeKey, tag);
    resetResolvedLocale();
  }

  List<ui.Locale> _systemLocalesFallback = [];

  set systemLocalesFallback(List<ui.Locale> locales) => _systemLocalesFallback = locales;

  ui.Locale? _resolvedLocale;

  void resetResolvedLocale() {
    _resolvedLocale = null;
    _resetAvesLocale();
  }

  // basic identifier, without extensions, resolved to match user settings
  ui.Locale get resolvedLocale {
    if (_resolvedLocale == null) {
      final preferredLocales = <ui.Locale>[
        ?basicLocale,
      ];
      if (preferredLocales.isEmpty) {
        preferredLocales.addAll(WidgetsBinding.instance.platformDispatcher.locales);
      }
      if (preferredLocales.isEmpty) {
        // the `window` locales may be empty in a window-less service context
        preferredLocales.addAll(_systemLocalesFallback);
      }
      _resolvedLocale = basicLocaleListResolution(preferredLocales, AvesApp.supportedLocales);
    }
    return _resolvedLocale!;
  }

  AvesLocale? _avesLocale;

  void _resetAvesLocale() {
    _avesLocale = null;
  }

  // advanced identifier, resolved to match user settings
  AvesLocale get avesLocale {
    _avesLocale ??= AvesLocale(
      languageTag: resolvedLocale.toLanguageTag(),
      calendar: calendar,
      forceWesternArabicNumerals: forceWesternArabicNumerals,
    );
    return _avesLocale!;
  }

  ACalendar get calendar => getEnumOrDefault(SettingKeys.calendarKey, SettingsDefaults.calendar, ACalendar.values);

  set calendar(ACalendar newValue) {
    _resetAvesLocale();
    set(SettingKeys.calendarKey, newValue.name);
  }

  bool get forceWesternArabicNumerals => getBool(SettingKeys.forceWesternArabicNumeralsKey) ?? false;

  set forceWesternArabicNumerals(bool newValue) {
    _resetAvesLocale();
    set(SettingKeys.forceWesternArabicNumeralsKey, newValue);
  }

  int get catalogTimeZoneOffsetMillis => getInt(SettingKeys.catalogTimeZoneOffsetMillisKey) ?? 0;

  set catalogTimeZoneOffsetMillis(int newValue) => set(SettingKeys.catalogTimeZoneOffsetMillisKey, newValue);

  double getTileExtent(String routeName) => getDouble(SettingKeys.tileExtentPrefixKey + routeName) ?? 0;

  void setTileExtent(String routeName, double newValue) => set(SettingKeys.tileExtentPrefixKey + routeName, newValue);

  TileLayout getTileLayout(String routeName) => getEnumOrDefault(SettingKeys.tileLayoutPrefixKey + routeName, SettingsDefaults.tileLayout, TileLayout.values);

  void setTileLayout(String routeName, TileLayout newValue) => set(SettingKeys.tileLayoutPrefixKey + routeName, newValue.name);

  String get entryRenamingPattern => getString(SettingKeys.entryRenamingPatternKey) ?? SettingsDefaults.entryRenamingPattern;

  set entryRenamingPattern(String newValue) => set(SettingKeys.entryRenamingPatternKey, newValue);

  List<int>? get topEntryIds => getStringList(SettingKeys.topEntryIdsKey)?.map(int.tryParse).nonNulls.toList();

  set topEntryIds(List<int>? newValue) => set(SettingKeys.topEntryIdsKey, newValue?.map((id) => id.toString()).nonNulls.toList());
}
