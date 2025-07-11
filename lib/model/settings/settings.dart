import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:aves/app_flavor.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/modules/app.dart';
import 'package:aves/model/settings/modules/collection.dart';
import 'package:aves/model/settings/modules/debug.dart';
import 'package:aves/model/settings/modules/display.dart';
import 'package:aves/model/settings/modules/filter_grids.dart';
import 'package:aves/model/settings/modules/info.dart';
import 'package:aves/model/settings/modules/navigation.dart';
import 'package:aves/model/settings/modules/privacy.dart';
import 'package:aves/model/settings/modules/screen_saver.dart';
import 'package:aves/model/settings/modules/search.dart';
import 'package:aves/model/settings/modules/slideshow.dart';
import 'package:aves/model/settings/modules/viewer.dart';
import 'package:aves/model/settings/modules/widget.dart';
import 'package:aves/ref/bursts.dart';
import 'package:aves/services/accessibility_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/places_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:aves_video/aves_video.dart';
import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

final Settings settings = Settings._private();

class Settings with ChangeNotifier, SettingsAccess, SearchSettings, AppSettings, CollectionSettings, DebugSettings, DisplaySettings, FilterGridsSettings, InfoSettings, NavigationSettings, PrivacySettings, ScreenSaverSettings, SlideshowSettings, SubtitlesSettings, VideoSettings, ViewerSettings, WidgetSettings {
  final Set<StreamSubscription> _subscriptions = {};
  final EventChannel _platformSettingsChangeChannel = const OptionalEventChannel('deckers.thibault/aves/settings_change');
  final StreamController<SettingsChangedEvent> _updateStreamController = StreamController.broadcast();
  final StreamController<SettingsChangedEvent> _updateTileExtentStreamController = StreamController.broadcast();

  @override
  Stream<SettingsChangedEvent> get updateStream => _updateStreamController.stream;

  Stream<SettingsChangedEvent> get updateTileExtentStream => _updateTileExtentStreamController.stream;

  @override
  bool get initialized => store.initialized;

  @override
  SettingsStore get store => settingsStore;

  Settings._private() {
    if (kFlutterMemoryAllocationsEnabled) ChangeNotifier.maybeDispatchObjectCreation(this);
  }

  Future<void> init({required bool monitorPlatformSettings}) async {
    await store.init();
    resetAppliedLocale();
    _unregister();
    _register(monitorPlatformSettings);
    initAppSettings();
  }

  void _unregister() {
    albumGrouping.removeListener(saveAlbumGroups);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  void _register(bool monitorPlatformSettings) {
    albumGrouping.addListener(saveAlbumGroups);
    _subscriptions.add(dynamicAlbums.eventBus.on<DynamicAlbumChangedEvent>().listen((e) {
      final changes = e.changes;
      updateBookmarkedDynamicAlbums(changes);
      updatePinnedDynamicAlbums(changes);
    }));
    _subscriptions.add(albumGrouping.eventBus.on<GroupUriChangedEvent>().listen((e) {
      final oldGroupUri = e.oldGroupUri;
      final newGroupUri = e.newGroupUri;
      updateBookmarkedGroup(oldGroupUri, newGroupUri);
      updatePinnedGroup(oldGroupUri, newGroupUri);
    }));
    if (monitorPlatformSettings) {
      _subscriptions.add(_platformSettingsChangeChannel.receiveBroadcastStream().listen((event) => _onPlatformSettingsChanged(event as Map?)));
    }
  }

  Future<void> reload() => store.reload();

  Future<void> reset({required bool includeInternalKeys}) async {
    if (includeInternalKeys) {
      await store.clear();
    } else {
      await Future.forEach<String>(store.getKeys().whereNot(SettingKeys.isInternalKey), store.remove);
    }
  }

  Future<void> setContextualDefaults(AppFlavor flavor) async {
    // performance
    final performanceClass = await deviceService.getPerformanceClass();
    enableBlurEffect = performanceClass >= 29;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final manufacturer = androidInfo.manufacturer.toLowerCase();
    final pattern = BurstPatterns.byManufacturer[manufacturer];
    collectionBurstPatterns = pattern != null ? [pattern] : [];

    // availability
    if (flavor.hasMapStyleDefault) {
      final defaultMapStyle = mobileServices.defaultMapStyle;
      if (defaultMapStyle != null && mobileServices.mapStyles.contains(defaultMapStyle)) {
        mapStyle = defaultMapStyle;
      } else {
        final styles = EntryMapStyles.baseStyles;
        mapStyle = styles[Random().nextInt(styles.length)];
      }
    }

    if (settings.useTvLayout) {
      applyTvSettings();
    }
  }

  void applyTvSettings() {
    themeBrightness = AvesThemeBrightness.dark;
    maxBrightness = MaxBrightness.never;
    mustBackTwiceToExit = false;
    // address `TV-BU` / `TV-BY` requirements from https://developer.android.com/docs/quality-guidelines/tv-app-quality
    keepScreenOn = KeepScreenOn.videoPlayback;
    enableBottomNavigationBar = false;
    drawerTypeBookmarks = [
      null,
      MimeFilter.video,
      FavouriteFilter.instance,
    ];
    drawerPageBookmarks = [
      AlbumListPage.routeName,
      CountryListPage.routeName,
      PlaceListPage.routeName,
      TagListPage.routeName,
      SearchPage.routeName,
    ];
    showOverlayOnOpening = false;
    showOverlayMinimap = false;
    showOverlayThumbnailPreview = false;
    viewerGestureSideTapNext = false;
    viewerUseCutout = true;
    videoBackgroundMode = VideoBackgroundMode.disabled;
    videoControlActions = [];
    videoGestureDoubleTapTogglePlay = false;
    videoGestureSideDoubleTapSeek = false;
    enableBin = false;
    showPinchGestureAlternatives = true;
  }

  Future<void> sanitize() async {
    if (timeToTakeAction == AccessibilityTimeout.system && !await AccessibilityService.hasRecommendedTimeouts()) {
      set(SettingKeys.timeToTakeActionKey, null);
    }
    if (viewerUseCutout != SettingsDefaults.viewerUseCutout && !await windowService.isCutoutAware()) {
      set(SettingKeys.viewerUseCutoutKey, null);
    }
    if (videoBackgroundMode == VideoBackgroundMode.pip && !device.supportPictureInPicture) {
      set(SettingKeys.videoBackgroundModeKey, null);
    }
    collectionBurstPatterns = collectionBurstPatterns.where(BurstPatterns.options.contains).toList();
  }

  // tag editor

  bool get tagEditorCurrentFilterSectionExpanded => getBool(SettingKeys.tagEditorCurrentFilterSectionExpandedKey) ?? SettingsDefaults.tagEditorCurrentFilterSectionExpanded;

  set tagEditorCurrentFilterSectionExpanded(bool newValue) => set(SettingKeys.tagEditorCurrentFilterSectionExpandedKey, newValue);

  String? get tagEditorExpandedSection => getString(SettingKeys.tagEditorExpandedSectionKey);

  set tagEditorExpandedSection(String? newValue) => set(SettingKeys.tagEditorExpandedSectionKey, newValue);

  // converter

  String get convertMimeType => getString(SettingKeys.convertMimeTypeKey) ?? SettingsDefaults.convertMimeType;

  set convertMimeType(String newValue) => set(SettingKeys.convertMimeTypeKey, newValue);

  int get convertQuality => getInt(SettingKeys.convertQualityKey) ?? SettingsDefaults.convertQuality;

  set convertQuality(int newValue) => set(SettingKeys.convertQualityKey, newValue);

  bool get convertWriteMetadata => getBool(SettingKeys.convertWriteMetadataKey) ?? SettingsDefaults.convertWriteMetadata;

  set convertWriteMetadata(bool newValue) => set(SettingKeys.convertWriteMetadataKey, newValue);

  // map

  EntryMapStyle? get mapStyle {
    var preferred = getString(SettingKeys.mapStyleKey);

    // backward compatibility with definition as enum
    const oldEnumPrefix = 'EntryMapStyle.';
    if (preferred != null && preferred.startsWith(oldEnumPrefix)) {
      preferred = preferred.substring(oldEnumPrefix.length);
      if (preferred.isEmpty) preferred = null;
    }

    if (preferred == null) return null;

    final styles = [...availability.mapStyles, ...customMapStyles];
    return styles.firstWhereOrNull((v) => v.key == preferred) ?? styles.first;
  }

  set mapStyle(EntryMapStyle? newValue) => set(SettingKeys.mapStyleKey, newValue?.key);

  LatLng? get mapDefaultCenter {
    final json = getString(SettingKeys.mapDefaultCenterKey);
    return json != null ? LatLng.fromJson(jsonDecode(json)) : null;
  }

  set mapDefaultCenter(LatLng? newValue) => set(SettingKeys.mapDefaultCenterKey, newValue != null ? jsonEncode(newValue.toJson()) : null);

  Set<EntryMapStyle> get customMapStyles => (getStringList(SettingKeys.customMapStylesKey) ?? []).map(EntryMapStyle.fromJson).nonNulls.toSet();

  set customMapStyles(Set<EntryMapStyle> newValue) => set(SettingKeys.customMapStylesKey, newValue.map((filter) => filter.toJson()).toList());

  // bin

  bool get enableBin => getBool(SettingKeys.enableBinKey) ?? SettingsDefaults.enableBin;

  set enableBin(bool newValue) => set(SettingKeys.enableBinKey, newValue);

  // accessibility

  bool get showPinchGestureAlternatives => getBool(SettingKeys.showPinchGestureAlternativesKey) ?? SettingsDefaults.showPinchGestureAlternatives;

  set showPinchGestureAlternatives(bool newValue) => set(SettingKeys.showPinchGestureAlternativesKey, newValue);

  AccessibilityAnimations get accessibilityAnimations => getEnumOrDefault(SettingKeys.accessibilityAnimationsKey, SettingsDefaults.accessibilityAnimations, AccessibilityAnimations.values);

  bool get animate => accessibilityAnimations.animate;

  set accessibilityAnimations(AccessibilityAnimations newValue) => set(SettingKeys.accessibilityAnimationsKey, newValue.toString());

  AccessibilityTimeout get timeToTakeAction => getEnumOrDefault(SettingKeys.timeToTakeActionKey, SettingsDefaults.timeToTakeAction, AccessibilityTimeout.values);

  set timeToTakeAction(AccessibilityTimeout newValue) => set(SettingKeys.timeToTakeActionKey, newValue.toString());

  // platform settings

  void _onPlatformSettingsChanged(Map? fields) {
    fields?.forEach((key, value) {
      switch (key) {
        case SettingKeys.platformAccelerometerRotationKey:
          if (value is num) {
            isRotationLocked = value == 0;
          }
        case SettingKeys.platformTransitionAnimationScaleKey:
          if (value is num) {
            areAnimationsRemoved = value == 0;
          }
        case SettingKeys.platformLongPressTimeoutMillisKey:
          if (value is num) {
            longPressTimeoutMillis = value.toInt();
          }
      }
    });
  }

  bool get isRotationLocked => getBool(SettingKeys.platformAccelerometerRotationKey) ?? SettingsDefaults.isRotationLocked;

  set isRotationLocked(bool newValue) => set(SettingKeys.platformAccelerometerRotationKey, newValue);

  bool get areAnimationsRemoved => getBool(SettingKeys.platformTransitionAnimationScaleKey) ?? SettingsDefaults.areAnimationsRemoved;

  set areAnimationsRemoved(bool newValue) => set(SettingKeys.platformTransitionAnimationScaleKey, newValue);

  Duration get longPressTimeout => Duration(milliseconds: getInt(SettingKeys.platformLongPressTimeoutMillisKey) ?? kLongPressTimeout.inMilliseconds);

  set longPressTimeoutMillis(int newValue) => set(SettingKeys.platformLongPressTimeoutMillisKey, newValue);

  // import/export

  Map<String, dynamic> export() => Map.fromEntries(
        store.getKeys().whereNot(SettingKeys.isInternalKey).map((k) => MapEntry(k, store.get(k))),
      );

  Future<void> import(dynamic jsonMap) async {
    if (jsonMap is Map<String, dynamic>) {
      // clear to restore defaults
      await reset(includeInternalKeys: false);

      // apply user modifications
      jsonMap.forEach((key, newValue) {
        final oldValue = store.get(key);

        if (newValue == null) {
          store.remove(key);
        } else if (key.startsWith(SettingKeys.tileExtentPrefixKey)) {
          if (newValue is double) {
            store.setDouble(key, newValue);
          } else {
            debugPrint('failed to import key=$key, value=$newValue is not a double');
          }
        } else if (key.startsWith(SettingKeys.tileLayoutPrefixKey)) {
          if (newValue is String) {
            store.setString(key, newValue);
          } else {
            debugPrint('failed to import key=$key, value=$newValue is not a string');
          }
        } else if (key.startsWith(SettingKeys.showTitleQueryPrefixKey)) {
          if (newValue is bool) {
            store.setBool(key, newValue);
          } else {
            debugPrint('failed to import key=$key, value=$newValue is not a bool');
          }
        } else {
          switch (key) {
            case SettingKeys.convertQualityKey:
            case SettingKeys.screenSaverIntervalKey:
            case SettingKeys.slideshowIntervalKey:
              if (newValue is int) {
                store.setInt(key, newValue);
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not an int');
              }
            case SettingKeys.subtitleFontSizeKey:
            case SettingKeys.infoMapZoomKey:
              if (newValue is double) {
                store.setDouble(key, newValue);
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not a double');
              }
            case SettingKeys.isInstalledAppAccessAllowedKey:
            case SettingKeys.isErrorReportingAllowedKey:
            case SettingKeys.forceWesternArabicNumeralsKey:
            case SettingKeys.enableDynamicColorKey:
            case SettingKeys.enableBlurEffectKey:
            case SettingKeys.enableBottomNavigationBarKey:
            case SettingKeys.mustBackTwiceToExitKey:
            case SettingKeys.confirmCreateVaultKey:
            case SettingKeys.confirmDeleteForeverKey:
            case SettingKeys.confirmMoveToBinKey:
            case SettingKeys.confirmMoveUndatedItemsKey:
            case SettingKeys.confirmAfterMoveToBinKey:
            case SettingKeys.setMetadataDateBeforeFileOpKey:
            case SettingKeys.collectionSortReverseKey:
            case SettingKeys.showThumbnailFavouriteKey:
            case SettingKeys.showThumbnailHdrKey:
            case SettingKeys.showThumbnailMotionPhotoKey:
            case SettingKeys.showThumbnailRatingKey:
            case SettingKeys.showThumbnailRawKey:
            case SettingKeys.showThumbnailVideoDurationKey:
            case SettingKeys.albumSortReverseKey:
            case SettingKeys.countrySortReverseKey:
            case SettingKeys.stateSortReverseKey:
            case SettingKeys.placeSortReverseKey:
            case SettingKeys.tagSortReverseKey:
            case SettingKeys.showOverlayOnOpeningKey:
            case SettingKeys.showOverlayMinimapKey:
            case SettingKeys.showOverlayInfoKey:
            case SettingKeys.showOverlayDescriptionKey:
            case SettingKeys.showOverlayRatingTagsKey:
            case SettingKeys.showOverlayShootingDetailsKey:
            case SettingKeys.showOverlayThumbnailPreviewKey:
            case SettingKeys.viewerGestureSideTapNextKey:
            case SettingKeys.viewerUseCutoutKey:
            case SettingKeys.enableMotionPhotoAutoPlayKey:
            case SettingKeys.enableVideoHardwareAccelerationKey:
            case SettingKeys.videoGestureDoubleTapTogglePlayKey:
            case SettingKeys.videoGestureSideDoubleTapSeekKey:
            case SettingKeys.videoGestureVerticalDragBrightnessVolumeKey:
            case SettingKeys.subtitleShowOutlineKey:
            case SettingKeys.tagEditorCurrentFilterSectionExpandedKey:
            case SettingKeys.convertWriteMetadataKey:
            case SettingKeys.saveSearchHistoryKey:
            case SettingKeys.showPinchGestureAlternativesKey:
            case SettingKeys.screenSaverFillScreenKey:
            case SettingKeys.screenSaverAnimatedZoomEffectKey:
            case SettingKeys.slideshowRepeatKey:
            case SettingKeys.slideshowShuffleKey:
            case SettingKeys.slideshowFillScreenKey:
            case SettingKeys.slideshowAnimatedZoomEffectKey:
              if (newValue is bool) {
                store.setBool(key, newValue);
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not a bool');
              }
            case SettingKeys.localeKey:
            case SettingKeys.displayRefreshRateModeKey:
            case SettingKeys.themeBrightnessKey:
            case SettingKeys.themeColorModeKey:
            case SettingKeys.maxBrightnessKey:
            case SettingKeys.keepScreenOnKey:
            case SettingKeys.homePageKey:
            case SettingKeys.homeCustomExplorerPathKey:
            case SettingKeys.collectionGroupFactorKey:
            case SettingKeys.collectionSortFactorKey:
            case SettingKeys.thumbnailLocationIconKey:
            case SettingKeys.thumbnailTagIconKey:
            case SettingKeys.albumSectionFactorKey:
            case SettingKeys.albumSortFactorKey:
            case SettingKeys.countrySortFactorKey:
            case SettingKeys.stateSortFactorKey:
            case SettingKeys.placeSortFactorKey:
            case SettingKeys.tagSortFactorKey:
            case SettingKeys.albumGroupsKey:
            case SettingKeys.imageBackgroundKey:
            case SettingKeys.videoAutoPlayModeKey:
            case SettingKeys.videoBackgroundModeKey:
            case SettingKeys.videoLoopModeKey:
            case SettingKeys.videoResumptionModeKey:
            case SettingKeys.subtitleTextAlignmentKey:
            case SettingKeys.subtitleTextPositionKey:
            case SettingKeys.subtitleTextColorKey:
            case SettingKeys.subtitleBackgroundColorKey:
            case SettingKeys.tagEditorExpandedSectionKey:
            case SettingKeys.convertMimeTypeKey:
            case SettingKeys.mapStyleKey:
            case SettingKeys.mapDefaultCenterKey:
            case SettingKeys.coordinateFormatKey:
            case SettingKeys.unitSystemKey:
            case SettingKeys.accessibilityAnimationsKey:
            case SettingKeys.timeToTakeActionKey:
            case SettingKeys.screenSaverTransitionKey:
            case SettingKeys.screenSaverVideoPlaybackKey:
            case SettingKeys.slideshowTransitionKey:
            case SettingKeys.slideshowVideoPlaybackKey:
              if (newValue is String) {
                store.setString(key, newValue);
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not a string');
              }
            case SettingKeys.customMapStylesKey:
            case SettingKeys.homeCustomCollectionKey:
            case SettingKeys.drawerTypeBookmarksKey:
            case SettingKeys.drawerAlbumBookmarksKey:
            case SettingKeys.drawerPageBookmarksKey:
            case SettingKeys.collectionBurstPatternsKey:
            case SettingKeys.pinnedFiltersKey:
            case SettingKeys.hiddenFiltersKey:
            case SettingKeys.deactivatedHiddenFiltersKey:
            case SettingKeys.collectionBrowsingQuickActionsKey:
            case SettingKeys.collectionSelectionQuickActionsKey:
            case SettingKeys.viewerQuickActionsKey:
            case SettingKeys.videoControlActionsKey:
            case SettingKeys.screenSaverCollectionFiltersKey:
              if (newValue is List) {
                store.setStringList(key, newValue.cast<String>());
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not a list');
              }
          }
        }
        if (oldValue != newValue) {
          notifyKeyChange(key, oldValue, newValue);
        }
      });
      await sanitize();
      notifyListeners();
    }
  }

  @override
  void notifyKeyChange(String key, dynamic oldValue, dynamic newValue) {
    _updateStreamController.add(SettingsChangedEvent(key, oldValue, newValue));
    if (key.startsWith(SettingKeys.tileExtentPrefixKey)) {
      _updateTileExtentStreamController.add(SettingsChangedEvent(key, oldValue, newValue));
    }
  }
}
