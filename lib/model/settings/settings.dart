import 'dart:async';
import 'dart:math';

import 'package:aves/l10n/l10n.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/map_style.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/accessibility_service.dart';
import 'package:aves/services/common/optional_event_channel.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_map/aves_map.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final Settings settings = Settings._private();

class Settings extends ChangeNotifier {
  final EventChannel _platformSettingsChangeChannel = const OptionalEventChannel('deckers.thibault/aves/settings_change');
  final StreamController<SettingsChangedEvent> _updateStreamController = StreamController.broadcast();

  Stream<SettingsChangedEvent> get updateStream => _updateStreamController.stream;

  Settings._private();

  static const Set<String> _internalKeys = {
    hasAcceptedTermsKey,
    catalogTimeZoneKey,
    videoShowRawTimedTextKey,
    searchHistoryKey,
    platformAccelerometerRotationKey,
    platformTransitionAnimationScaleKey,
    topEntryIdsKey,
  };
  static const _widgetKeyPrefix = 'widget_';

  // app
  static const hasAcceptedTermsKey = 'has_accepted_terms';
  static const canUseAnalysisServiceKey = 'can_use_analysis_service';
  static const isInstalledAppAccessAllowedKey = 'is_installed_app_access_allowed';
  static const isErrorReportingAllowedKey = 'is_crashlytics_enabled';
  static const localeKey = 'locale';
  static const catalogTimeZoneKey = 'catalog_time_zone';
  static const tileExtentPrefixKey = 'tile_extent_';
  static const tileLayoutPrefixKey = 'tile_layout_';
  static const entryRenamingPatternKey = 'entry_renaming_pattern';
  static const topEntryIdsKey = 'top_entry_ids';

  // display
  static const displayRefreshRateModeKey = 'display_refresh_rate_mode';
  static const themeBrightnessKey = 'theme_brightness';
  static const themeColorModeKey = 'theme_color_mode';
  static const enableDynamicColorKey = 'dynamic_color';
  static const enableBlurEffectKey = 'enable_overlay_blur_effect';

  // navigation
  static const mustBackTwiceToExitKey = 'must_back_twice_to_exit';
  static const keepScreenOnKey = 'keep_screen_on';
  static const homePageKey = 'home_page';
  static const enableBottomNavigationBarKey = 'show_bottom_navigation_bar';
  static const confirmDeleteForeverKey = 'confirm_delete_forever';
  static const confirmMoveToBinKey = 'confirm_move_to_bin';
  static const confirmMoveUndatedItemsKey = 'confirm_move_undated_items';
  static const setMetadataDateBeforeFileOpKey = 'set_metadata_date_before_file_op';
  static const drawerTypeBookmarksKey = 'drawer_type_bookmarks';
  static const drawerAlbumBookmarksKey = 'drawer_album_bookmarks';
  static const drawerPageBookmarksKey = 'drawer_page_bookmarks';

  // collection
  static const collectionGroupFactorKey = 'collection_group_factor';
  static const collectionSortFactorKey = 'collection_sort_factor';
  static const collectionBrowsingQuickActionsKey = 'collection_browsing_quick_actions';
  static const collectionSelectionQuickActionsKey = 'collection_selection_quick_actions';
  static const showThumbnailFavouriteKey = 'show_thumbnail_favourite';
  static const showThumbnailTagKey = 'show_thumbnail_tag';
  static const showThumbnailLocationKey = 'show_thumbnail_location';
  static const showThumbnailMotionPhotoKey = 'show_thumbnail_motion_photo';
  static const showThumbnailRatingKey = 'show_thumbnail_rating';
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
  static const showOverlayOnOpeningKey = 'show_overlay_on_opening';
  static const showOverlayMinimapKey = 'show_overlay_minimap';
  static const showOverlayInfoKey = 'show_overlay_info';
  static const showOverlayShootingDetailsKey = 'show_overlay_shooting_details';
  static const showOverlayThumbnailPreviewKey = 'show_overlay_thumbnail_preview';
  static const viewerGestureSideTapNextKey = 'viewer_gesture_side_tap_next';
  static const viewerUseCutoutKey = 'viewer_use_cutout';
  static const viewerMaxBrightnessKey = 'viewer_max_brightness';
  static const enableMotionPhotoAutoPlayKey = 'motion_photo_auto_play';
  static const imageBackgroundKey = 'image_background';

  // video
  static const enableVideoHardwareAccelerationKey = 'video_hwaccel_mediacodec';
  static const enableVideoAutoPlayKey = 'video_auto_play';
  static const videoLoopModeKey = 'video_loop';
  static const videoShowRawTimedTextKey = 'video_show_raw_timed_text';
  static const videoControlsKey = 'video_controls';
  static const videoGestureDoubleTapTogglePlayKey = 'video_gesture_double_tap_toggle_play';
  static const videoGestureSideDoubleTapSeekKey = 'video_gesture_side_double_tap_skip';

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
  static const unitSystemKey = 'unit_system';

  // search
  static const saveSearchHistoryKey = 'save_search_history';
  static const searchHistoryKey = 'search_history';

  // bin
  static const enableBinKey = 'enable_bin';

  // accessibility
  static const accessibilityAnimationsKey = 'accessibility_animations';
  static const timeToTakeActionKey = 'time_to_take_action';

  // file picker
  static const filePickerShowHiddenFilesKey = 'file_picker_show_hidden_files';

  // screen saver
  static const screenSaverFillScreenKey = 'screen_saver_fill_screen';
  static const screenSaverTransitionKey = 'screen_saver_transition';
  static const screenSaverVideoPlaybackKey = 'screen_saver_video_playback';
  static const screenSaverIntervalKey = 'screen_saver_interval';
  static const screenSaverCollectionFiltersKey = 'screen_saver_collection_filters';

  // slideshow
  static const slideshowRepeatKey = 'slideshow_loop';
  static const slideshowShuffleKey = 'slideshow_shuffle';
  static const slideshowFillScreenKey = 'slideshow_fill_screen';
  static const slideshowTransitionKey = 'slideshow_transition';
  static const slideshowVideoPlaybackKey = 'slideshow_video_playback';
  static const slideshowIntervalKey = 'slideshow_interval';

  // widget
  static const widgetOutlinePrefixKey = '${_widgetKeyPrefix}outline_';
  static const widgetShapePrefixKey = '${_widgetKeyPrefix}shape_';
  static const widgetCollectionFiltersPrefixKey = '${_widgetKeyPrefix}collection_filters_';
  static const widgetUriPrefixKey = '${_widgetKeyPrefix}uri_';

  // platform settings
  // cf Android `Settings.System.ACCELEROMETER_ROTATION`
  static const platformAccelerometerRotationKey = 'accelerometer_rotation';

  // cf Android `Settings.Global.TRANSITION_ANIMATION_SCALE`
  static const platformTransitionAnimationScaleKey = 'transition_animation_scale';

  bool get initialized => settingsStore.initialized;

  Future<void> init({required bool monitorPlatformSettings}) async {
    await settingsStore.init();
    if (monitorPlatformSettings) {
      _platformSettingsChangeChannel.receiveBroadcastStream().listen((event) => _onPlatformSettingsChange(event as Map?));
    }
  }

  Future<void> reload() => settingsStore.reload();

  Future<void> reset({required bool includeInternalKeys}) async {
    if (includeInternalKeys) {
      await settingsStore.clear();
    } else {
      await Future.forEach<String>(settingsStore.getKeys().whereNot(isInternalKey), settingsStore.remove);
    }
  }

  bool isInternalKey(String key) => _internalKeys.contains(key) || key.startsWith(_widgetKeyPrefix);

  Future<void> setContextualDefaults() async {
    // performance
    final performanceClass = await deviceService.getPerformanceClass();
    enableBlurEffect = performanceClass >= 29;

    // availability
    final defaultMapStyle = mobileServices.defaultMapStyle;
    if (mobileServices.mapStyles.contains(defaultMapStyle)) {
      infoMapStyle = defaultMapStyle;
    } else {
      final styles = EntryMapStyle.values.whereNot((v) => v.needMobileService).toList();
      infoMapStyle = styles[Random().nextInt(styles.length)];
    }

    // accessibility
    final hasRecommendedTimeouts = await AccessibilityService.hasRecommendedTimeouts();
    timeToTakeAction = hasRecommendedTimeouts ? AccessibilityTimeout.system : AccessibilityTimeout.appDefault;
  }

  // app

  bool get hasAcceptedTerms => getBoolOrDefault(hasAcceptedTermsKey, SettingsDefaults.hasAcceptedTerms);

  set hasAcceptedTerms(bool newValue) => setAndNotify(hasAcceptedTermsKey, newValue);

  bool get canUseAnalysisService => getBoolOrDefault(canUseAnalysisServiceKey, SettingsDefaults.canUseAnalysisService);

  set canUseAnalysisService(bool newValue) => setAndNotify(canUseAnalysisServiceKey, newValue);

  bool get isInstalledAppAccessAllowed => getBoolOrDefault(isInstalledAppAccessAllowedKey, SettingsDefaults.isInstalledAppAccessAllowed);

  set isInstalledAppAccessAllowed(bool newValue) => setAndNotify(isInstalledAppAccessAllowedKey, newValue);

  bool get isErrorReportingAllowed => getBoolOrDefault(isErrorReportingAllowedKey, SettingsDefaults.isErrorReportingAllowed);

  set isErrorReportingAllowed(bool newValue) => setAndNotify(isErrorReportingAllowedKey, newValue);

  static const localeSeparator = '-';

  Locale? get locale {
    // exceptionally allow getting locale before settings are initialized
    final tag = initialized ? getString(localeKey) : null;
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
    _appliedLocale = null;
  }

  List<Locale> _systemLocalesFallback = [];

  set systemLocalesFallback(List<Locale> locales) => _systemLocalesFallback = locales;

  Locale? _appliedLocale;

  Locale get appliedLocale {
    if (_appliedLocale == null) {
      final _locale = locale;
      final preferredLocales = <Locale>[];
      if (_locale != null) {
        preferredLocales.add(_locale);
      } else {
        preferredLocales.addAll(WidgetsBinding.instance.window.locales);
        if (preferredLocales.isEmpty) {
          // the `window` locales may be empty in a window-less service context
          preferredLocales.addAll(_systemLocalesFallback);
        }
      }
      _appliedLocale = basicLocaleListResolution(preferredLocales, AppLocalizations.supportedLocales);
    }
    return _appliedLocale!;
  }

  String get catalogTimeZone => getString(catalogTimeZoneKey) ?? '';

  set catalogTimeZone(String newValue) => setAndNotify(catalogTimeZoneKey, newValue);

  double getTileExtent(String routeName) => getDouble(tileExtentPrefixKey + routeName) ?? 0;

  void setTileExtent(String routeName, double newValue) => setAndNotify(tileExtentPrefixKey + routeName, newValue);

  TileLayout getTileLayout(String routeName) => getEnumOrDefault(tileLayoutPrefixKey + routeName, SettingsDefaults.tileLayout, TileLayout.values);

  void setTileLayout(String routeName, TileLayout newValue) => setAndNotify(tileLayoutPrefixKey + routeName, newValue.toString());

  String get entryRenamingPattern => getString(entryRenamingPatternKey) ?? SettingsDefaults.entryRenamingPattern;

  set entryRenamingPattern(String newValue) => setAndNotify(entryRenamingPatternKey, newValue);

  List<int>? get topEntryIds => getStringList(topEntryIdsKey)?.map(int.tryParse).whereNotNull().toList();

  set topEntryIds(List<int>? newValue) => setAndNotify(topEntryIdsKey, newValue?.map((id) => id.toString()).whereNotNull().toList());

  // display

  DisplayRefreshRateMode get displayRefreshRateMode => getEnumOrDefault(displayRefreshRateModeKey, SettingsDefaults.displayRefreshRateMode, DisplayRefreshRateMode.values);

  set displayRefreshRateMode(DisplayRefreshRateMode newValue) => setAndNotify(displayRefreshRateModeKey, newValue.toString());

  AvesThemeBrightness get themeBrightness => getEnumOrDefault(themeBrightnessKey, SettingsDefaults.themeBrightness, AvesThemeBrightness.values);

  set themeBrightness(AvesThemeBrightness newValue) => setAndNotify(themeBrightnessKey, newValue.toString());

  AvesThemeColorMode get themeColorMode => getEnumOrDefault(themeColorModeKey, SettingsDefaults.themeColorMode, AvesThemeColorMode.values);

  set themeColorMode(AvesThemeColorMode newValue) => setAndNotify(themeColorModeKey, newValue.toString());

  bool get enableDynamicColor => getBoolOrDefault(enableDynamicColorKey, SettingsDefaults.enableDynamicColor);

  set enableDynamicColor(bool newValue) => setAndNotify(enableDynamicColorKey, newValue);

  bool get enableBlurEffect => getBoolOrDefault(enableBlurEffectKey, SettingsDefaults.enableBlurEffect);

  set enableBlurEffect(bool newValue) => setAndNotify(enableBlurEffectKey, newValue);

  // navigation

  bool get mustBackTwiceToExit => getBoolOrDefault(mustBackTwiceToExitKey, SettingsDefaults.mustBackTwiceToExit);

  set mustBackTwiceToExit(bool newValue) => setAndNotify(mustBackTwiceToExitKey, newValue);

  KeepScreenOn get keepScreenOn => getEnumOrDefault(keepScreenOnKey, SettingsDefaults.keepScreenOn, KeepScreenOn.values);

  set keepScreenOn(KeepScreenOn newValue) => setAndNotify(keepScreenOnKey, newValue.toString());

  HomePageSetting get homePage => getEnumOrDefault(homePageKey, SettingsDefaults.homePage, HomePageSetting.values);

  set homePage(HomePageSetting newValue) => setAndNotify(homePageKey, newValue.toString());

  bool get enableBottomNavigationBar => getBoolOrDefault(enableBottomNavigationBarKey, SettingsDefaults.enableBottomNavigationBar);

  set enableBottomNavigationBar(bool newValue) => setAndNotify(enableBottomNavigationBarKey, newValue);

  bool get confirmDeleteForever => getBoolOrDefault(confirmDeleteForeverKey, SettingsDefaults.confirmDeleteForever);

  set confirmDeleteForever(bool newValue) => setAndNotify(confirmDeleteForeverKey, newValue);

  bool get confirmMoveToBin => getBoolOrDefault(confirmMoveToBinKey, SettingsDefaults.confirmMoveToBin);

  set confirmMoveToBin(bool newValue) => setAndNotify(confirmMoveToBinKey, newValue);

  bool get confirmMoveUndatedItems => getBoolOrDefault(confirmMoveUndatedItemsKey, SettingsDefaults.confirmMoveUndatedItems);

  set confirmMoveUndatedItems(bool newValue) => setAndNotify(confirmMoveUndatedItemsKey, newValue);

  bool get setMetadataDateBeforeFileOp => getBoolOrDefault(setMetadataDateBeforeFileOpKey, SettingsDefaults.setMetadataDateBeforeFileOp);

  set setMetadataDateBeforeFileOp(bool newValue) => setAndNotify(setMetadataDateBeforeFileOpKey, newValue);

  List<CollectionFilter?> get drawerTypeBookmarks =>
      (getStringList(drawerTypeBookmarksKey))?.map((v) {
        if (v.isEmpty) return null;
        return CollectionFilter.fromJson(v);
      }).toList() ??
      SettingsDefaults.drawerTypeBookmarks;

  set drawerTypeBookmarks(List<CollectionFilter?> newValue) => setAndNotify(drawerTypeBookmarksKey, newValue.map((filter) => filter?.toJson() ?? '').toList());

  List<String>? get drawerAlbumBookmarks => getStringList(drawerAlbumBookmarksKey);

  set drawerAlbumBookmarks(List<String>? newValue) => setAndNotify(drawerAlbumBookmarksKey, newValue);

  List<String> get drawerPageBookmarks => getStringList(drawerPageBookmarksKey) ?? SettingsDefaults.drawerPageBookmarks;

  set drawerPageBookmarks(List<String> newValue) => setAndNotify(drawerPageBookmarksKey, newValue);

  // collection

  EntryGroupFactor get collectionSectionFactor => getEnumOrDefault(collectionGroupFactorKey, SettingsDefaults.collectionSectionFactor, EntryGroupFactor.values);

  set collectionSectionFactor(EntryGroupFactor newValue) => setAndNotify(collectionGroupFactorKey, newValue.toString());

  EntrySortFactor get collectionSortFactor => getEnumOrDefault(collectionSortFactorKey, SettingsDefaults.collectionSortFactor, EntrySortFactor.values);

  set collectionSortFactor(EntrySortFactor newValue) => setAndNotify(collectionSortFactorKey, newValue.toString());

  List<EntrySetAction> get collectionBrowsingQuickActions => getEnumListOrDefault(collectionBrowsingQuickActionsKey, SettingsDefaults.collectionBrowsingQuickActions, EntrySetAction.values);

  set collectionBrowsingQuickActions(List<EntrySetAction> newValue) => setAndNotify(collectionBrowsingQuickActionsKey, newValue.map((v) => v.toString()).toList());

  List<EntrySetAction> get collectionSelectionQuickActions => getEnumListOrDefault(collectionSelectionQuickActionsKey, SettingsDefaults.collectionSelectionQuickActions, EntrySetAction.values);

  set collectionSelectionQuickActions(List<EntrySetAction> newValue) => setAndNotify(collectionSelectionQuickActionsKey, newValue.map((v) => v.toString()).toList());

  bool get showThumbnailFavourite => getBoolOrDefault(showThumbnailFavouriteKey, SettingsDefaults.showThumbnailFavourite);

  set showThumbnailFavourite(bool newValue) => setAndNotify(showThumbnailFavouriteKey, newValue);

  bool get showThumbnailTag => getBoolOrDefault(showThumbnailTagKey, SettingsDefaults.showThumbnailTag);

  set showThumbnailTag(bool newValue) => setAndNotify(showThumbnailTagKey, newValue);

  bool get showThumbnailLocation => getBoolOrDefault(showThumbnailLocationKey, SettingsDefaults.showThumbnailLocation);

  set showThumbnailLocation(bool newValue) => setAndNotify(showThumbnailLocationKey, newValue);

  bool get showThumbnailMotionPhoto => getBoolOrDefault(showThumbnailMotionPhotoKey, SettingsDefaults.showThumbnailMotionPhoto);

  set showThumbnailMotionPhoto(bool newValue) => setAndNotify(showThumbnailMotionPhotoKey, newValue);

  bool get showThumbnailRating => getBoolOrDefault(showThumbnailRatingKey, SettingsDefaults.showThumbnailRating);

  set showThumbnailRating(bool newValue) => setAndNotify(showThumbnailRatingKey, newValue);

  bool get showThumbnailRaw => getBoolOrDefault(showThumbnailRawKey, SettingsDefaults.showThumbnailRaw);

  set showThumbnailRaw(bool newValue) => setAndNotify(showThumbnailRawKey, newValue);

  bool get showThumbnailVideoDuration => getBoolOrDefault(showThumbnailVideoDurationKey, SettingsDefaults.showThumbnailVideoDuration);

  set showThumbnailVideoDuration(bool newValue) => setAndNotify(showThumbnailVideoDurationKey, newValue);

  // filter grids

  AlbumChipGroupFactor get albumGroupFactor => getEnumOrDefault(albumGroupFactorKey, SettingsDefaults.albumGroupFactor, AlbumChipGroupFactor.values);

  set albumGroupFactor(AlbumChipGroupFactor newValue) => setAndNotify(albumGroupFactorKey, newValue.toString());

  ChipSortFactor get albumSortFactor => getEnumOrDefault(albumSortFactorKey, SettingsDefaults.albumSortFactor, ChipSortFactor.values);

  set albumSortFactor(ChipSortFactor newValue) => setAndNotify(albumSortFactorKey, newValue.toString());

  ChipSortFactor get countrySortFactor => getEnumOrDefault(countrySortFactorKey, SettingsDefaults.countrySortFactor, ChipSortFactor.values);

  set countrySortFactor(ChipSortFactor newValue) => setAndNotify(countrySortFactorKey, newValue.toString());

  ChipSortFactor get tagSortFactor => getEnumOrDefault(tagSortFactorKey, SettingsDefaults.tagSortFactor, ChipSortFactor.values);

  set tagSortFactor(ChipSortFactor newValue) => setAndNotify(tagSortFactorKey, newValue.toString());

  Set<CollectionFilter> get pinnedFilters => (getStringList(pinnedFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set pinnedFilters(Set<CollectionFilter> newValue) => setAndNotify(pinnedFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  Set<CollectionFilter> get hiddenFilters => (getStringList(hiddenFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set hiddenFilters(Set<CollectionFilter> newValue) => setAndNotify(hiddenFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  void changeFilterVisibility(Set<CollectionFilter> filters, bool visible) {
    final _hiddenFilters = hiddenFilters;
    if (visible) {
      _hiddenFilters.removeAll(filters);
    } else {
      _hiddenFilters.addAll(filters);
      searchHistory = searchHistory..removeWhere(filters.contains);
    }
    hiddenFilters = _hiddenFilters;
  }

  // viewer

  List<EntryAction> get viewerQuickActions => getEnumListOrDefault(viewerQuickActionsKey, SettingsDefaults.viewerQuickActions, EntryAction.values);

  set viewerQuickActions(List<EntryAction> newValue) => setAndNotify(viewerQuickActionsKey, newValue.map((v) => v.toString()).toList());

  bool get showOverlayOnOpening => getBoolOrDefault(showOverlayOnOpeningKey, SettingsDefaults.showOverlayOnOpening);

  set showOverlayOnOpening(bool newValue) => setAndNotify(showOverlayOnOpeningKey, newValue);

  bool get showOverlayMinimap => getBoolOrDefault(showOverlayMinimapKey, SettingsDefaults.showOverlayMinimap);

  set showOverlayMinimap(bool newValue) => setAndNotify(showOverlayMinimapKey, newValue);

  bool get showOverlayInfo => getBoolOrDefault(showOverlayInfoKey, SettingsDefaults.showOverlayInfo);

  set showOverlayInfo(bool newValue) => setAndNotify(showOverlayInfoKey, newValue);

  bool get showOverlayShootingDetails => getBoolOrDefault(showOverlayShootingDetailsKey, SettingsDefaults.showOverlayShootingDetails);

  set showOverlayShootingDetails(bool newValue) => setAndNotify(showOverlayShootingDetailsKey, newValue);

  bool get showOverlayThumbnailPreview => getBoolOrDefault(showOverlayThumbnailPreviewKey, SettingsDefaults.showOverlayThumbnailPreview);

  set showOverlayThumbnailPreview(bool newValue) => setAndNotify(showOverlayThumbnailPreviewKey, newValue);

  bool get viewerGestureSideTapNext => getBoolOrDefault(viewerGestureSideTapNextKey, SettingsDefaults.viewerGestureSideTapNext);

  set viewerGestureSideTapNext(bool newValue) => setAndNotify(viewerGestureSideTapNextKey, newValue);

  bool get viewerUseCutout => getBoolOrDefault(viewerUseCutoutKey, SettingsDefaults.viewerUseCutout);

  set viewerUseCutout(bool newValue) => setAndNotify(viewerUseCutoutKey, newValue);

  bool get viewerMaxBrightness => getBoolOrDefault(viewerMaxBrightnessKey, SettingsDefaults.viewerMaxBrightness);

  set viewerMaxBrightness(bool newValue) => setAndNotify(viewerMaxBrightnessKey, newValue);

  bool get enableMotionPhotoAutoPlay => getBoolOrDefault(enableMotionPhotoAutoPlayKey, SettingsDefaults.enableMotionPhotoAutoPlay);

  set enableMotionPhotoAutoPlay(bool newValue) => setAndNotify(enableMotionPhotoAutoPlayKey, newValue);

  EntryBackground get imageBackground => getEnumOrDefault(imageBackgroundKey, SettingsDefaults.imageBackground, EntryBackground.values);

  set imageBackground(EntryBackground newValue) => setAndNotify(imageBackgroundKey, newValue.toString());

  // video

  bool get enableVideoHardwareAcceleration => getBoolOrDefault(enableVideoHardwareAccelerationKey, SettingsDefaults.enableVideoHardwareAcceleration);

  set enableVideoHardwareAcceleration(bool newValue) => setAndNotify(enableVideoHardwareAccelerationKey, newValue);

  bool get enableVideoAutoPlay => getBoolOrDefault(enableVideoAutoPlayKey, SettingsDefaults.enableVideoAutoPlay);

  set enableVideoAutoPlay(bool newValue) => setAndNotify(enableVideoAutoPlayKey, newValue);

  VideoLoopMode get videoLoopMode => getEnumOrDefault(videoLoopModeKey, SettingsDefaults.videoLoopMode, VideoLoopMode.values);

  set videoLoopMode(VideoLoopMode newValue) => setAndNotify(videoLoopModeKey, newValue.toString());

  bool get videoShowRawTimedText => getBoolOrDefault(videoShowRawTimedTextKey, SettingsDefaults.videoShowRawTimedText);

  set videoShowRawTimedText(bool newValue) => setAndNotify(videoShowRawTimedTextKey, newValue);

  VideoControls get videoControls => getEnumOrDefault(videoControlsKey, SettingsDefaults.videoControls, VideoControls.values);

  set videoControls(VideoControls newValue) => setAndNotify(videoControlsKey, newValue.toString());

  bool get videoGestureDoubleTapTogglePlay => getBoolOrDefault(videoGestureDoubleTapTogglePlayKey, SettingsDefaults.videoGestureDoubleTapTogglePlay);

  set videoGestureDoubleTapTogglePlay(bool newValue) => setAndNotify(videoGestureDoubleTapTogglePlayKey, newValue);

  bool get videoGestureSideDoubleTapSeek => getBoolOrDefault(videoGestureSideDoubleTapSeekKey, SettingsDefaults.videoGestureSideDoubleTapSeek);

  set videoGestureSideDoubleTapSeek(bool newValue) => setAndNotify(videoGestureSideDoubleTapSeekKey, newValue);

  // subtitles

  double get subtitleFontSize => getDouble(subtitleFontSizeKey) ?? SettingsDefaults.subtitleFontSize;

  set subtitleFontSize(double newValue) => setAndNotify(subtitleFontSizeKey, newValue);

  TextAlign get subtitleTextAlignment => getEnumOrDefault(subtitleTextAlignmentKey, SettingsDefaults.subtitleTextAlignment, TextAlign.values);

  set subtitleTextAlignment(TextAlign newValue) => setAndNotify(subtitleTextAlignmentKey, newValue.toString());

  bool get subtitleShowOutline => getBoolOrDefault(subtitleShowOutlineKey, SettingsDefaults.subtitleShowOutline);

  set subtitleShowOutline(bool newValue) => setAndNotify(subtitleShowOutlineKey, newValue);

  Color get subtitleTextColor => Color(getInt(subtitleTextColorKey) ?? SettingsDefaults.subtitleTextColor.value);

  set subtitleTextColor(Color newValue) => setAndNotify(subtitleTextColorKey, newValue.value);

  Color get subtitleBackgroundColor => Color(getInt(subtitleBackgroundColorKey) ?? SettingsDefaults.subtitleBackgroundColor.value);

  set subtitleBackgroundColor(Color newValue) => setAndNotify(subtitleBackgroundColorKey, newValue.value);

  // info

  EntryMapStyle get infoMapStyle {
    final preferred = getEnumOrDefault(infoMapStyleKey, SettingsDefaults.infoMapStyle, EntryMapStyle.values);
    final available = availability.mapStyles;
    return available.contains(preferred) ? preferred : available.first;
  }

  set infoMapStyle(EntryMapStyle newValue) => setAndNotify(infoMapStyleKey, newValue.toString());

  double get infoMapZoom => getDouble(infoMapZoomKey) ?? SettingsDefaults.infoMapZoom;

  set infoMapZoom(double newValue) => setAndNotify(infoMapZoomKey, newValue);

  CoordinateFormat get coordinateFormat => getEnumOrDefault(coordinateFormatKey, SettingsDefaults.coordinateFormat, CoordinateFormat.values);

  set coordinateFormat(CoordinateFormat newValue) => setAndNotify(coordinateFormatKey, newValue.toString());

  UnitSystem get unitSystem => getEnumOrDefault(unitSystemKey, SettingsDefaults.unitSystem, UnitSystem.values);

  set unitSystem(UnitSystem newValue) => setAndNotify(unitSystemKey, newValue.toString());

  // search

  bool get saveSearchHistory => getBoolOrDefault(saveSearchHistoryKey, SettingsDefaults.saveSearchHistory);

  set saveSearchHistory(bool newValue) => setAndNotify(saveSearchHistoryKey, newValue);

  List<CollectionFilter> get searchHistory => (getStringList(searchHistoryKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toList();

  set searchHistory(List<CollectionFilter> newValue) => setAndNotify(searchHistoryKey, newValue.map((filter) => filter.toJson()).toList());

  // bin

  bool get enableBin => getBoolOrDefault(enableBinKey, SettingsDefaults.enableBin);

  set enableBin(bool newValue) => setAndNotify(enableBinKey, newValue);

  // accessibility

  AccessibilityAnimations get accessibilityAnimations => getEnumOrDefault(accessibilityAnimationsKey, SettingsDefaults.accessibilityAnimations, AccessibilityAnimations.values);

  set accessibilityAnimations(AccessibilityAnimations newValue) => setAndNotify(accessibilityAnimationsKey, newValue.toString());

  AccessibilityTimeout get timeToTakeAction => getEnumOrDefault(timeToTakeActionKey, SettingsDefaults.timeToTakeAction, AccessibilityTimeout.values);

  set timeToTakeAction(AccessibilityTimeout newValue) => setAndNotify(timeToTakeActionKey, newValue.toString());

  // file picker

  bool get filePickerShowHiddenFiles => getBoolOrDefault(filePickerShowHiddenFilesKey, SettingsDefaults.filePickerShowHiddenFiles);

  set filePickerShowHiddenFiles(bool newValue) => setAndNotify(filePickerShowHiddenFilesKey, newValue);

  // screen saver

  bool get screenSaverFillScreen => getBoolOrDefault(screenSaverFillScreenKey, SettingsDefaults.slideshowFillScreen);

  set screenSaverFillScreen(bool newValue) => setAndNotify(screenSaverFillScreenKey, newValue);

  ViewerTransition get screenSaverTransition => getEnumOrDefault(screenSaverTransitionKey, SettingsDefaults.slideshowTransition, ViewerTransition.values);

  set screenSaverTransition(ViewerTransition newValue) => setAndNotify(screenSaverTransitionKey, newValue.toString());

  SlideshowVideoPlayback get screenSaverVideoPlayback => getEnumOrDefault(screenSaverVideoPlaybackKey, SettingsDefaults.slideshowVideoPlayback, SlideshowVideoPlayback.values);

  set screenSaverVideoPlayback(SlideshowVideoPlayback newValue) => setAndNotify(screenSaverVideoPlaybackKey, newValue.toString());

  SlideshowInterval get screenSaverInterval => getEnumOrDefault(screenSaverIntervalKey, SettingsDefaults.slideshowInterval, SlideshowInterval.values);

  set screenSaverInterval(SlideshowInterval newValue) => setAndNotify(screenSaverIntervalKey, newValue.toString());

  Set<CollectionFilter> get screenSaverCollectionFilters => (getStringList(screenSaverCollectionFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set screenSaverCollectionFilters(Set<CollectionFilter> newValue) => setAndNotify(screenSaverCollectionFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  // slideshow

  bool get slideshowRepeat => getBoolOrDefault(slideshowRepeatKey, SettingsDefaults.slideshowRepeat);

  set slideshowRepeat(bool newValue) => setAndNotify(slideshowRepeatKey, newValue);

  bool get slideshowShuffle => getBoolOrDefault(slideshowShuffleKey, SettingsDefaults.slideshowShuffle);

  set slideshowShuffle(bool newValue) => setAndNotify(slideshowShuffleKey, newValue);

  bool get slideshowFillScreen => getBoolOrDefault(slideshowFillScreenKey, SettingsDefaults.slideshowFillScreen);

  set slideshowFillScreen(bool newValue) => setAndNotify(slideshowFillScreenKey, newValue);

  ViewerTransition get slideshowTransition => getEnumOrDefault(slideshowTransitionKey, SettingsDefaults.slideshowTransition, ViewerTransition.values);

  set slideshowTransition(ViewerTransition newValue) => setAndNotify(slideshowTransitionKey, newValue.toString());

  SlideshowVideoPlayback get slideshowVideoPlayback => getEnumOrDefault(slideshowVideoPlaybackKey, SettingsDefaults.slideshowVideoPlayback, SlideshowVideoPlayback.values);

  set slideshowVideoPlayback(SlideshowVideoPlayback newValue) => setAndNotify(slideshowVideoPlaybackKey, newValue.toString());

  SlideshowInterval get slideshowInterval => getEnumOrDefault(slideshowIntervalKey, SettingsDefaults.slideshowInterval, SlideshowInterval.values);

  set slideshowInterval(SlideshowInterval newValue) => setAndNotify(slideshowIntervalKey, newValue.toString());

  // widget

  Color? getWidgetOutline(int widgetId) {
    final value = getInt('$widgetOutlinePrefixKey$widgetId');
    return value != null ? Color(value) : null;
  }

  void setWidgetOutline(int widgetId, Color? newValue) => setAndNotify('$widgetOutlinePrefixKey$widgetId', newValue?.value);

  WidgetShape getWidgetShape(int widgetId) => getEnumOrDefault('$widgetShapePrefixKey$widgetId', SettingsDefaults.widgetShape, WidgetShape.values);

  void setWidgetShape(int widgetId, WidgetShape newValue) => setAndNotify('$widgetShapePrefixKey$widgetId', newValue.toString());

  Set<CollectionFilter> getWidgetCollectionFilters(int widgetId) => (getStringList('$widgetCollectionFiltersPrefixKey$widgetId') ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  void setWidgetCollectionFilters(int widgetId, Set<CollectionFilter> newValue) => setAndNotify('$widgetCollectionFiltersPrefixKey$widgetId', newValue.map((filter) => filter.toJson()).toList());

  String? getWidgetUri(int widgetId) => getString('$widgetUriPrefixKey$widgetId');

  void setWidgetUri(int widgetId, String? newValue) => setAndNotify('$widgetUriPrefixKey$widgetId', newValue);

  // convenience methods

  int? getInt(String key) => settingsStore.getInt(key);

  double? getDouble(String key) => settingsStore.getDouble(key);

  String? getString(String key) => settingsStore.getString(key);

  List<String>? getStringList(String key) => settingsStore.getStringList(key);

  // ignore: avoid_positional_boolean_parameters
  bool getBoolOrDefault(String key, bool defaultValue) => settingsStore.getBool(key) ?? defaultValue;

  T getEnumOrDefault<T>(String key, T defaultValue, Iterable<T> values) {
    final valueString = settingsStore.getString(key);
    for (final v in values) {
      if (v.toString() == valueString) {
        return v;
      }
    }
    return defaultValue;
  }

  List<T> getEnumListOrDefault<T extends Object>(String key, List<T> defaultValue, Iterable<T> values) {
    return settingsStore.getStringList(key)?.map((s) => values.firstWhereOrNull((v) => v.toString() == s)).whereNotNull().toList() ?? defaultValue;
  }

  void setAndNotify(String key, dynamic newValue) {
    var oldValue = settingsStore.get(key);
    if (newValue == null) {
      settingsStore.remove(key);
    } else if (newValue is String) {
      oldValue = settingsStore.getString(key);
      settingsStore.setString(key, newValue);
    } else if (newValue is List<String>) {
      oldValue = settingsStore.getStringList(key);
      settingsStore.setStringList(key, newValue);
    } else if (newValue is int) {
      oldValue = settingsStore.getInt(key);
      settingsStore.setInt(key, newValue);
    } else if (newValue is double) {
      oldValue = settingsStore.getDouble(key);
      settingsStore.setDouble(key, newValue);
    } else if (newValue is bool) {
      oldValue = settingsStore.getBool(key);
      settingsStore.setBool(key, newValue);
    }
    if (oldValue != newValue) {
      _updateStreamController.add(SettingsChangedEvent(key, oldValue, newValue));
      notifyListeners();
    }
  }

  // platform settings

  void _onPlatformSettingsChange(Map? fields) {
    fields?.forEach((key, value) {
      switch (key) {
        case platformAccelerometerRotationKey:
          if (value is num) {
            isRotationLocked = value == 0;
          }
          break;
        case platformTransitionAnimationScaleKey:
          if (value is num) {
            areAnimationsRemoved = value == 0;
          }
      }
    });
  }

  bool get isRotationLocked => getBoolOrDefault(platformAccelerometerRotationKey, SettingsDefaults.isRotationLocked);

  set isRotationLocked(bool newValue) => setAndNotify(platformAccelerometerRotationKey, newValue);

  bool get areAnimationsRemoved => getBoolOrDefault(platformTransitionAnimationScaleKey, SettingsDefaults.areAnimationsRemoved);

  set areAnimationsRemoved(bool newValue) => setAndNotify(platformTransitionAnimationScaleKey, newValue);

  // import/export

  Map<String, dynamic> export() => Map.fromEntries(
        settingsStore.getKeys().whereNot(isInternalKey).map((k) => MapEntry(k, settingsStore.get(k))),
      );

  Future<void> import(dynamic jsonMap) async {
    if (jsonMap is Map<String, dynamic>) {
      // clear to restore defaults
      await reset(includeInternalKeys: false);

      // apply user modifications
      jsonMap.forEach((key, newValue) {
        final oldValue = settingsStore.get(key);

        if (newValue == null) {
          settingsStore.remove(key);
        } else if (key.startsWith(tileExtentPrefixKey)) {
          if (newValue is double) {
            settingsStore.setDouble(key, newValue);
          } else {
            debugPrint('failed to import key=$key, value=$newValue is not a double');
          }
        } else if (key.startsWith(tileLayoutPrefixKey)) {
          if (newValue is String) {
            settingsStore.setString(key, newValue);
          } else {
            debugPrint('failed to import key=$key, value=$newValue is not a string');
          }
        } else {
          switch (key) {
            case subtitleTextColorKey:
            case subtitleBackgroundColorKey:
              if (newValue is int) {
                settingsStore.setInt(key, newValue);
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not an int');
              }
              break;
            case subtitleFontSizeKey:
            case infoMapZoomKey:
              if (newValue is double) {
                settingsStore.setDouble(key, newValue);
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not a double');
              }
              break;
            case isInstalledAppAccessAllowedKey:
            case isErrorReportingAllowedKey:
            case enableDynamicColorKey:
            case enableBlurEffectKey:
            case enableBottomNavigationBarKey:
            case mustBackTwiceToExitKey:
            case confirmDeleteForeverKey:
            case confirmMoveToBinKey:
            case confirmMoveUndatedItemsKey:
            case setMetadataDateBeforeFileOpKey:
            case showThumbnailFavouriteKey:
            case showThumbnailTagKey:
            case showThumbnailLocationKey:
            case showThumbnailMotionPhotoKey:
            case showThumbnailRatingKey:
            case showThumbnailRawKey:
            case showThumbnailVideoDurationKey:
            case showOverlayOnOpeningKey:
            case showOverlayMinimapKey:
            case showOverlayInfoKey:
            case showOverlayShootingDetailsKey:
            case showOverlayThumbnailPreviewKey:
            case viewerGestureSideTapNextKey:
            case viewerUseCutoutKey:
            case viewerMaxBrightnessKey:
            case enableMotionPhotoAutoPlayKey:
            case enableVideoHardwareAccelerationKey:
            case enableVideoAutoPlayKey:
            case videoGestureDoubleTapTogglePlayKey:
            case videoGestureSideDoubleTapSeekKey:
            case subtitleShowOutlineKey:
            case saveSearchHistoryKey:
            case filePickerShowHiddenFilesKey:
            case screenSaverFillScreenKey:
            case slideshowRepeatKey:
            case slideshowShuffleKey:
            case slideshowFillScreenKey:
              if (newValue is bool) {
                settingsStore.setBool(key, newValue);
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not a bool');
              }
              break;
            case localeKey:
            case displayRefreshRateModeKey:
            case themeBrightnessKey:
            case themeColorModeKey:
            case keepScreenOnKey:
            case homePageKey:
            case collectionGroupFactorKey:
            case collectionSortFactorKey:
            case albumGroupFactorKey:
            case albumSortFactorKey:
            case countrySortFactorKey:
            case tagSortFactorKey:
            case imageBackgroundKey:
            case videoLoopModeKey:
            case videoControlsKey:
            case subtitleTextAlignmentKey:
            case infoMapStyleKey:
            case coordinateFormatKey:
            case unitSystemKey:
            case accessibilityAnimationsKey:
            case timeToTakeActionKey:
            case screenSaverTransitionKey:
            case screenSaverVideoPlaybackKey:
            case screenSaverIntervalKey:
            case slideshowTransitionKey:
            case slideshowVideoPlaybackKey:
            case slideshowIntervalKey:
              if (newValue is String) {
                settingsStore.setString(key, newValue);
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not a string');
              }
              break;
            case drawerTypeBookmarksKey:
            case drawerAlbumBookmarksKey:
            case drawerPageBookmarksKey:
            case pinnedFiltersKey:
            case hiddenFiltersKey:
            case collectionBrowsingQuickActionsKey:
            case collectionSelectionQuickActionsKey:
            case viewerQuickActionsKey:
            case screenSaverCollectionFiltersKey:
              if (newValue is List) {
                settingsStore.setStringList(key, newValue.cast<String>());
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not a list');
              }
              break;
          }
        }
        if (oldValue != newValue) {
          _updateStreamController.add(SettingsChangedEvent(key, oldValue, newValue));
        }
      });
      notifyListeners();
    }
  }
}

@immutable
class SettingsChangedEvent {
  final String key;
  final dynamic oldValue;
  final dynamic newValue;

  // old and new values as stored, e.g. `List<String>` for collections
  const SettingsChangedEvent(this.key, this.oldValue, this.newValue);
}
