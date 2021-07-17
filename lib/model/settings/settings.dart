import 'dart:convert';

import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/screen_on.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/services.dart';
import 'package:aves/utils/pedantic.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Settings settings = Settings._private();

class Settings extends ChangeNotifier {
  final EventChannel _platformSettingsChangeChannel = const EventChannel('deckers.thibault/aves/settingschange');

  static SharedPreferences? _prefs;

  Settings._private() {
    _platformSettingsChangeChannel.receiveBroadcastStream().listen((event) => _onPlatformSettingsChange(event as Map?));
  }

  static const Set<String> internalKeys = {
    hasAcceptedTermsKey,
    catalogTimeZoneKey,
    videoShowRawTimedTextKey,
    searchHistoryKey,
    lastVersionCheckDateKey,
  };

  // app
  static const hasAcceptedTermsKey = 'has_accepted_terms';
  static const isCrashlyticsEnabledKey = 'is_crashlytics_enabled';
  static const localeKey = 'locale';
  static const mustBackTwiceToExitKey = 'must_back_twice_to_exit';
  static const keepScreenOnKey = 'keep_screen_on';
  static const homePageKey = 'home_page';
  static const catalogTimeZoneKey = 'catalog_time_zone';
  static const tileExtentPrefixKey = 'tile_extent_';

  // collection
  static const collectionGroupFactorKey = 'collection_group_factor';
  static const collectionSortFactorKey = 'collection_sort_factor';
  static const showThumbnailLocationKey = 'show_thumbnail_location';
  static const showThumbnailRawKey = 'show_thumbnail_raw';
  static const showThumbnailVideoDurationKey = 'show_thumbnail_video_duration';

  // filter grids
  static const albumGroupFactorKey = 'album_group_factor';
  static const albumSortFactorKey = 'album_sort_factor';
  static const countrySortFactorKey = 'country_sort_factor';
  static const tagSortFactorKey = 'tag_sort_factor';
  static const pinnedFiltersKey = 'pinned_filters';
  static const hiddenFiltersKey = 'hidden_filters';

  // viewer
  static const viewerQuickActionsKey = 'viewer_quick_actions';
  static const showOverlayMinimapKey = 'show_overlay_minimap';
  static const showOverlayInfoKey = 'show_overlay_info';
  static const showOverlayShootingDetailsKey = 'show_overlay_shooting_details';
  static const enableOverlayBlurEffectKey = 'enable_overlay_blur_effect';
  static const viewerUseCutoutKey = 'viewer_use_cutout';

  // video
  static const videoQuickActionsKey = 'video_quick_actions';
  static const enableVideoHardwareAccelerationKey = 'video_hwaccel_mediacodec';
  static const enableVideoAutoPlayKey = 'video_auto_play';
  static const videoLoopModeKey = 'video_loop';
  static const videoShowRawTimedTextKey = 'video_show_raw_timed_text';

  // subtitles
  static const subtitleFontSizeKey = 'subtitle_font_size';
  static const subtitleTextAlignmentKey = 'subtitle_text_alignment';
  static const subtitleShowOutlineKey = 'subtitle_show_outline';
  static const subtitleTextColorKey = 'subtitle_text_color';
  static const subtitleBackgroundColorKey = 'subtitle_background_color';

  // info
  static const infoMapStyleKey = 'info_map_style';
  static const infoMapZoomKey = 'info_map_zoom';
  static const coordinateFormatKey = 'coordinates_format';

  // rendering
  static const imageBackgroundKey = 'image_background';

  // search
  static const saveSearchHistoryKey = 'save_search_history';
  static const searchHistoryKey = 'search_history';

  // version
  static const lastVersionCheckDateKey = 'last_version_check_date';

  // defaults
  static const viewerQuickActionsDefault = [
    EntryAction.toggleFavourite,
    EntryAction.share,
    EntryAction.rotateScreen,
  ];
  static const videoQuickActionsDefault = [
    VideoAction.replay10,
    VideoAction.togglePlay,
  ];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isRotationLocked = await windowService.isRotationLocked();
  }

  // Crashlytics initialization is separated from the main settings initialization
  // to allow settings customization without Firebase context (e.g. before a Flutter Driver test)
  Future<void> initFirebase() async {
    await Firebase.app().setAutomaticDataCollectionEnabled(isCrashlyticsEnabled);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(isCrashlyticsEnabled);
  }

  Future<void> reset({required bool includeInternalKeys}) async {
    if (includeInternalKeys) {
      await _prefs!.clear();
    } else {
      await Future.forEach(_prefs!.getKeys().whereNot(internalKeys.contains), _prefs!.remove);
    }
  }

  // app

  bool get hasAcceptedTerms => getBoolOrDefault(hasAcceptedTermsKey, false);

  set hasAcceptedTerms(bool newValue) => setAndNotify(hasAcceptedTermsKey, newValue);

  bool get isCrashlyticsEnabled => getBoolOrDefault(isCrashlyticsEnabledKey, false);

  set isCrashlyticsEnabled(bool newValue) {
    setAndNotify(isCrashlyticsEnabledKey, newValue);
    unawaited(initFirebase());
  }

  static const localeSeparator = '-';

  Locale? get locale {
    // exceptionally allow getting locale before settings are initialized
    final tag = _prefs?.getString(localeKey);
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
    setAndNotify(localeKey, tag);
  }

  bool get mustBackTwiceToExit => getBoolOrDefault(mustBackTwiceToExitKey, true);

  set mustBackTwiceToExit(bool newValue) => setAndNotify(mustBackTwiceToExitKey, newValue);

  KeepScreenOn get keepScreenOn => getEnumOrDefault(keepScreenOnKey, KeepScreenOn.viewerOnly, KeepScreenOn.values);

  set keepScreenOn(KeepScreenOn newValue) {
    setAndNotify(keepScreenOnKey, newValue.toString());
    newValue.apply();
  }

  HomePageSetting get homePage => getEnumOrDefault(homePageKey, HomePageSetting.collection, HomePageSetting.values);

  set homePage(HomePageSetting newValue) => setAndNotify(homePageKey, newValue.toString());

  String get catalogTimeZone => _prefs!.getString(catalogTimeZoneKey) ?? '';

  set catalogTimeZone(String newValue) => setAndNotify(catalogTimeZoneKey, newValue);

  double getTileExtent(String routeName) => _prefs!.getDouble(tileExtentPrefixKey + routeName) ?? 0;

  void setTileExtent(String routeName, double newValue) => setAndNotify(tileExtentPrefixKey + routeName, newValue);

  // collection

  EntryGroupFactor get collectionGroupFactor => getEnumOrDefault(collectionGroupFactorKey, EntryGroupFactor.month, EntryGroupFactor.values);

  set collectionGroupFactor(EntryGroupFactor newValue) => setAndNotify(collectionGroupFactorKey, newValue.toString());

  EntrySortFactor get collectionSortFactor => getEnumOrDefault(collectionSortFactorKey, EntrySortFactor.date, EntrySortFactor.values);

  set collectionSortFactor(EntrySortFactor newValue) => setAndNotify(collectionSortFactorKey, newValue.toString());

  bool get showThumbnailLocation => getBoolOrDefault(showThumbnailLocationKey, true);

  set showThumbnailLocation(bool newValue) => setAndNotify(showThumbnailLocationKey, newValue);

  bool get showThumbnailRaw => getBoolOrDefault(showThumbnailRawKey, true);

  set showThumbnailRaw(bool newValue) => setAndNotify(showThumbnailRawKey, newValue);

  bool get showThumbnailVideoDuration => getBoolOrDefault(showThumbnailVideoDurationKey, true);

  set showThumbnailVideoDuration(bool newValue) => setAndNotify(showThumbnailVideoDurationKey, newValue);

  // filter grids

  AlbumChipGroupFactor get albumGroupFactor => getEnumOrDefault(albumGroupFactorKey, AlbumChipGroupFactor.importance, AlbumChipGroupFactor.values);

  set albumGroupFactor(AlbumChipGroupFactor newValue) => setAndNotify(albumGroupFactorKey, newValue.toString());

  ChipSortFactor get albumSortFactor => getEnumOrDefault(albumSortFactorKey, ChipSortFactor.name, ChipSortFactor.values);

  set albumSortFactor(ChipSortFactor newValue) => setAndNotify(albumSortFactorKey, newValue.toString());

  ChipSortFactor get countrySortFactor => getEnumOrDefault(countrySortFactorKey, ChipSortFactor.name, ChipSortFactor.values);

  set countrySortFactor(ChipSortFactor newValue) => setAndNotify(countrySortFactorKey, newValue.toString());

  ChipSortFactor get tagSortFactor => getEnumOrDefault(tagSortFactorKey, ChipSortFactor.name, ChipSortFactor.values);

  set tagSortFactor(ChipSortFactor newValue) => setAndNotify(tagSortFactorKey, newValue.toString());

  Set<CollectionFilter> get pinnedFilters => (_prefs!.getStringList(pinnedFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set pinnedFilters(Set<CollectionFilter> newValue) => setAndNotify(pinnedFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  Set<CollectionFilter> get hiddenFilters => (_prefs!.getStringList(hiddenFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set hiddenFilters(Set<CollectionFilter> newValue) => setAndNotify(hiddenFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  // viewer

  List<EntryAction> get viewerQuickActions => getEnumListOrDefault(viewerQuickActionsKey, viewerQuickActionsDefault, EntryAction.values);

  set viewerQuickActions(List<EntryAction> newValue) => setAndNotify(viewerQuickActionsKey, newValue.map((v) => v.toString()).toList());

  bool get showOverlayMinimap => getBoolOrDefault(showOverlayMinimapKey, false);

  set showOverlayMinimap(bool newValue) => setAndNotify(showOverlayMinimapKey, newValue);

  bool get showOverlayInfo => getBoolOrDefault(showOverlayInfoKey, true);

  set showOverlayInfo(bool newValue) => setAndNotify(showOverlayInfoKey, newValue);

  bool get showOverlayShootingDetails => getBoolOrDefault(showOverlayShootingDetailsKey, false);

  set showOverlayShootingDetails(bool newValue) => setAndNotify(showOverlayShootingDetailsKey, newValue);

  bool get enableOverlayBlurEffect => getBoolOrDefault(enableOverlayBlurEffectKey, true);

  set enableOverlayBlurEffect(bool newValue) => setAndNotify(enableOverlayBlurEffectKey, newValue);

  bool get viewerUseCutout => getBoolOrDefault(viewerUseCutoutKey, true);

  set viewerUseCutout(bool newValue) => setAndNotify(viewerUseCutoutKey, newValue);

  // video

  List<VideoAction> get videoQuickActions => getEnumListOrDefault(videoQuickActionsKey, videoQuickActionsDefault, VideoAction.values);

  set videoQuickActions(List<VideoAction> newValue) => setAndNotify(videoQuickActionsKey, newValue.map((v) => v.toString()).toList());

  bool get enableVideoHardwareAcceleration => getBoolOrDefault(enableVideoHardwareAccelerationKey, true);

  set enableVideoHardwareAcceleration(bool newValue) => setAndNotify(enableVideoHardwareAccelerationKey, newValue);

  bool get enableVideoAutoPlay => getBoolOrDefault(enableVideoAutoPlayKey, false);

  set enableVideoAutoPlay(bool newValue) => setAndNotify(enableVideoAutoPlayKey, newValue);

  VideoLoopMode get videoLoopMode => getEnumOrDefault(videoLoopModeKey, VideoLoopMode.shortOnly, VideoLoopMode.values);

  set videoLoopMode(VideoLoopMode newValue) => setAndNotify(videoLoopModeKey, newValue.toString());

  bool get videoShowRawTimedText => getBoolOrDefault(videoShowRawTimedTextKey, false);

  set videoShowRawTimedText(bool newValue) => setAndNotify(videoShowRawTimedTextKey, newValue);

  // subtitles

  double get subtitleFontSize => _prefs!.getDouble(subtitleFontSizeKey) ?? 20;

  set subtitleFontSize(double newValue) => setAndNotify(subtitleFontSizeKey, newValue);

  TextAlign get subtitleTextAlignment => getEnumOrDefault(subtitleTextAlignmentKey, TextAlign.center, TextAlign.values);

  set subtitleTextAlignment(TextAlign newValue) => setAndNotify(subtitleTextAlignmentKey, newValue.toString());

  bool get subtitleShowOutline => getBoolOrDefault(subtitleShowOutlineKey, true);

  set subtitleShowOutline(bool newValue) => setAndNotify(subtitleShowOutlineKey, newValue);

  Color get subtitleTextColor => Color(_prefs!.getInt(subtitleTextColorKey) ?? Colors.white.value);

  set subtitleTextColor(Color newValue) => setAndNotify(subtitleTextColorKey, newValue.value);

  Color get subtitleBackgroundColor => Color(_prefs!.getInt(subtitleBackgroundColorKey) ?? Colors.transparent.value);

  set subtitleBackgroundColor(Color newValue) => setAndNotify(subtitleBackgroundColorKey, newValue.value);

  // info

  EntryMapStyle get infoMapStyle => getEnumOrDefault(infoMapStyleKey, EntryMapStyle.stamenWatercolor, EntryMapStyle.values);

  set infoMapStyle(EntryMapStyle newValue) => setAndNotify(infoMapStyleKey, newValue.toString());

  double get infoMapZoom => _prefs!.getDouble(infoMapZoomKey) ?? 12;

  set infoMapZoom(double newValue) => setAndNotify(infoMapZoomKey, newValue);

  CoordinateFormat get coordinateFormat => getEnumOrDefault(coordinateFormatKey, CoordinateFormat.dms, CoordinateFormat.values);

  set coordinateFormat(CoordinateFormat newValue) => setAndNotify(coordinateFormatKey, newValue.toString());

  // rendering

  EntryBackground get imageBackground => getEnumOrDefault(imageBackgroundKey, EntryBackground.white, EntryBackground.values);

  set imageBackground(EntryBackground newValue) => setAndNotify(imageBackgroundKey, newValue.toString());

  // search

  bool get saveSearchHistory => getBoolOrDefault(saveSearchHistoryKey, true);

  set saveSearchHistory(bool newValue) => setAndNotify(saveSearchHistoryKey, newValue);

  List<CollectionFilter> get searchHistory => (_prefs!.getStringList(searchHistoryKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toList();

  set searchHistory(List<CollectionFilter> newValue) => setAndNotify(searchHistoryKey, newValue.map((filter) => filter.toJson()).toList());

  // version

  DateTime get lastVersionCheckDate => DateTime.fromMillisecondsSinceEpoch(_prefs!.getInt(lastVersionCheckDateKey) ?? 0);

  set lastVersionCheckDate(DateTime newValue) => setAndNotify(lastVersionCheckDateKey, newValue.millisecondsSinceEpoch);

  // convenience methods

  // ignore: avoid_positional_boolean_parameters
  bool getBoolOrDefault(String key, bool defaultValue) => _prefs!.getBool(key) ?? defaultValue;

  T getEnumOrDefault<T>(String key, T defaultValue, Iterable<T> values) {
    final valueString = _prefs!.getString(key);
    for (final v in values) {
      if (v.toString() == valueString) {
        return v;
      }
    }
    return defaultValue;
  }

  List<T> getEnumListOrDefault<T extends Object>(String key, List<T> defaultValue, Iterable<T> values) {
    return _prefs!.getStringList(key)?.map((s) => values.firstWhereOrNull((v) => v.toString() == s)).whereNotNull().toList() ?? defaultValue;
  }

  void setAndNotify(String key, dynamic newValue) {
    var oldValue = _prefs!.get(key);
    if (newValue == null) {
      _prefs!.remove(key);
    } else if (newValue is String) {
      oldValue = _prefs!.getString(key);
      _prefs!.setString(key, newValue);
    } else if (newValue is List<String>) {
      oldValue = _prefs!.getStringList(key);
      _prefs!.setStringList(key, newValue);
    } else if (newValue is int) {
      oldValue = _prefs!.getInt(key);
      _prefs!.setInt(key, newValue);
    } else if (newValue is double) {
      oldValue = _prefs!.getDouble(key);
      _prefs!.setDouble(key, newValue);
    } else if (newValue is bool) {
      oldValue = _prefs!.getBool(key);
      _prefs!.setBool(key, newValue);
    }
    if (oldValue != newValue) {
      notifyListeners();
    }
  }

  // platform settings

  void _onPlatformSettingsChange(Map? fields) {
    fields?.forEach((key, value) {
      switch (key) {
        // cf Android `Settings.System.ACCELEROMETER_ROTATION`
        case 'accelerometer_rotation':
          if (value is int) {
            final newValue = value == 0;
            if (_isRotationLocked != newValue) {
              _isRotationLocked = newValue;
              if (!_isRotationLocked) {
                windowService.requestOrientation();
              }
              notifyListeners();
            }
          }
          break;
      }
    });
  }

  bool _isRotationLocked = false;

  bool get isRotationLocked => _isRotationLocked;

  // import/export

  String toJson() => jsonEncode(Map.fromEntries(
        _prefs!.getKeys().whereNot(internalKeys.contains).map((k) => MapEntry(k, _prefs!.get(k))),
      ));

  Future<void> fromJson(String jsonString) async {
    final jsonMap = jsonDecode(jsonString);
    if (jsonMap is Map<String, dynamic>) {
      // clear to restore defaults
      await reset(includeInternalKeys: false);

      // apply user modifications
      jsonMap.forEach((key, value) {
        if (key.startsWith(tileExtentPrefixKey)) {
          if (value is double) {
            _prefs!.setDouble(key, value);
          } else {
            debugPrint('failed to import key=$key, value=$value is not a double');
          }
        } else {
          switch (key) {
            case subtitleTextColorKey:
            case subtitleBackgroundColorKey:
              if (value is int) {
                _prefs!.setInt(key, value);
              } else {
                debugPrint('failed to import key=$key, value=$value is not an int');
              }
              break;
            case subtitleFontSizeKey:
            case infoMapZoomKey:
              if (value is double) {
                _prefs!.setDouble(key, value);
              } else {
                debugPrint('failed to import key=$key, value=$value is not a double');
              }
              break;
            case isCrashlyticsEnabledKey:
            case mustBackTwiceToExitKey:
            case showThumbnailLocationKey:
            case showThumbnailRawKey:
            case showThumbnailVideoDurationKey:
            case showOverlayMinimapKey:
            case showOverlayInfoKey:
            case showOverlayShootingDetailsKey:
            case enableOverlayBlurEffectKey:
            case viewerUseCutoutKey:
            case enableVideoHardwareAccelerationKey:
            case enableVideoAutoPlayKey:
            case subtitleShowOutlineKey:
            case saveSearchHistoryKey:
              if (value is bool) {
                _prefs!.setBool(key, value);
              } else {
                debugPrint('failed to import key=$key, value=$value is not a bool');
              }
              break;
            case localeKey:
            case keepScreenOnKey:
            case homePageKey:
            case collectionGroupFactorKey:
            case collectionSortFactorKey:
            case albumGroupFactorKey:
            case albumSortFactorKey:
            case countrySortFactorKey:
            case tagSortFactorKey:
            case videoLoopModeKey:
            case subtitleTextAlignmentKey:
            case infoMapStyleKey:
            case coordinateFormatKey:
            case imageBackgroundKey:
              if (value is String) {
                _prefs!.setString(key, value);
              } else {
                debugPrint('failed to import key=$key, value=$value is not a string');
              }
              break;
            case pinnedFiltersKey:
            case hiddenFiltersKey:
            case viewerQuickActionsKey:
            case videoQuickActionsKey:
              if (value is List) {
                _prefs!.setStringList(key, value.cast<String>());
              } else {
                debugPrint('failed to import key=$key, value=$value is not a list');
              }
              break;
          }
        }
      });
      notifyListeners();
    }
  }
}
