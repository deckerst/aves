import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

mixin AppSettings on SettingsAccess {
  static const int _recentFilterHistoryMax = 10;

  bool get hasAcceptedTerms => getBool(SettingKeys.hasAcceptedTermsKey) ?? SettingsDefaults.hasAcceptedTerms;

  set hasAcceptedTerms(bool newValue) => set(SettingKeys.hasAcceptedTermsKey, newValue);

  bool get canUseAnalysisService => getBool(SettingKeys.canUseAnalysisServiceKey) ?? SettingsDefaults.canUseAnalysisService;

  set canUseAnalysisService(bool newValue) => set(SettingKeys.canUseAnalysisServiceKey, newValue);

  bool get isInstalledAppAccessAllowed => getBool(SettingKeys.isInstalledAppAccessAllowedKey) ?? SettingsDefaults.isInstalledAppAccessAllowed;

  set isInstalledAppAccessAllowed(bool newValue) => set(SettingKeys.isInstalledAppAccessAllowedKey, newValue);

  bool get isErrorReportingAllowed => getBool(SettingKeys.isErrorReportingAllowedKey) ?? SettingsDefaults.isErrorReportingAllowed;

  set isErrorReportingAllowed(bool newValue) => set(SettingKeys.isErrorReportingAllowedKey, newValue);

  static const localeSeparator = '-';

  Locale? get locale {
    // exceptionally allow getting locale before settings are initialized
    final tag = initialized ? getString(SettingKeys.localeKey) : null;
    if (tag != null) {
      final codes = tag.split(localeSeparator);
      return Locale.fromSubtags(
        languageCode: codes[0],
        scriptCode: codes[1] == '' ? null : codes[1],
        countryCode: codes[2] == '' ? null : codes[2],
      );
    }
    return null;
  }

  set locale(Locale? newValue) {
    String? tag;
    if (newValue != null) {
      tag = [
        newValue.languageCode,
        newValue.scriptCode ?? '',
        newValue.countryCode ?? '',
      ].join(localeSeparator);
    }
    set(SettingKeys.localeKey, tag);
    resetAppliedLocale();
  }

  List<Locale> _systemLocalesFallback = [];

  set systemLocalesFallback(List<Locale> locales) => _systemLocalesFallback = locales;

  Locale? _appliedLocale;

  void resetAppliedLocale() => _appliedLocale = null;

  Locale get appliedLocale {
    if (_appliedLocale == null) {
      final _locale = locale;
      final preferredLocales = <Locale>[];
      if (_locale != null) {
        preferredLocales.add(_locale);
      } else {
        preferredLocales.addAll(WidgetsBinding.instance.platformDispatcher.locales);
        if (preferredLocales.isEmpty) {
          // the `window` locales may be empty in a window-less service context
          preferredLocales.addAll(_systemLocalesFallback);
        }
      }
      _appliedLocale = basicLocaleListResolution(preferredLocales, AvesApp.supportedLocales);
    }
    return _appliedLocale!;
  }

  int get catalogTimeZoneRawOffsetMillis => getInt(SettingKeys.catalogTimeZoneRawOffsetMillisKey) ?? 0;

  set catalogTimeZoneRawOffsetMillis(int newValue) => set(SettingKeys.catalogTimeZoneRawOffsetMillisKey, newValue);

  double getTileExtent(String routeName) => getDouble(SettingKeys.tileExtentPrefixKey + routeName) ?? 0;

  void setTileExtent(String routeName, double newValue) => set(SettingKeys.tileExtentPrefixKey + routeName, newValue);

  TileLayout getTileLayout(String routeName) => getEnumOrDefault(SettingKeys.tileLayoutPrefixKey + routeName, SettingsDefaults.tileLayout, TileLayout.values);

  void setTileLayout(String routeName, TileLayout newValue) => set(SettingKeys.tileLayoutPrefixKey + routeName, newValue.toString());

  String get entryRenamingPattern => getString(SettingKeys.entryRenamingPatternKey) ?? SettingsDefaults.entryRenamingPattern;

  set entryRenamingPattern(String newValue) => set(SettingKeys.entryRenamingPatternKey, newValue);

  List<int>? get topEntryIds => getStringList(SettingKeys.topEntryIdsKey)?.map(int.tryParse).whereNotNull().toList();

  set topEntryIds(List<int>? newValue) => set(SettingKeys.topEntryIdsKey, newValue?.map((id) => id.toString()).whereNotNull().toList());

  List<String> get recentDestinationAlbums => getStringList(SettingKeys.recentDestinationAlbumsKey) ?? [];

  set recentDestinationAlbums(List<String> newValue) => set(SettingKeys.recentDestinationAlbumsKey, newValue.take(_recentFilterHistoryMax).toList());

  List<CollectionFilter> get recentTags => (getStringList(SettingKeys.recentTagsKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toList();

  set recentTags(List<CollectionFilter> newValue) => set(SettingKeys.recentTagsKey, newValue.take(_recentFilterHistoryMax).map((filter) => filter.toJson()).toList());
}
