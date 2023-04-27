import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:aves/app_flavor.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/enums/map_style.dart';
import 'package:aves/ref/bursts.dart';
import 'package:aves/services/accessibility_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/places_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

final Settings settings = Settings._private();

class Settings extends ChangeNotifier {
  final List<StreamSubscription> _subscriptions = [];
  final EventChannel _platformSettingsChangeChannel = const OptionalEventChannel('deckers.thibault/aves/settings_change');
  final StreamController<SettingsChangedEvent> _updateStreamController = StreamController.broadcast();

  Stream<SettingsChangedEvent> get updateStream => _updateStreamController.stream;

  Settings._private();

  static const int _recentFilterHistoryMax = 10;
  static const Set<String> _internalKeys = {
    hasAcceptedTermsKey,
    catalogTimeZoneRawOffsetMillisKey,
    searchHistoryKey,
    platformAccelerometerRotationKey,
    platformTransitionAnimationScaleKey,
    topEntryIdsKey,
    recentDestinationAlbumsKey,
    recentTagsKey,
  };
  static const _widgetKeyPrefix = 'widget_';

  // app
  static const hasAcceptedTermsKey = 'has_accepted_terms';
  static const canUseAnalysisServiceKey = 'can_use_analysis_service';
  static const isInstalledAppAccessAllowedKey = 'is_installed_app_access_allowed';
  static const isErrorReportingAllowedKey = 'is_crashlytics_enabled';
  static const localeKey = 'locale';
  static const catalogTimeZoneRawOffsetMillisKey = 'catalog_time_zone_raw_offset_millis';
  static const tileExtentPrefixKey = 'tile_extent_';
  static const tileLayoutPrefixKey = 'tile_layout_';
  static const entryRenamingPatternKey = 'entry_renaming_pattern';
  static const topEntryIdsKey = 'top_entry_ids';
  static const recentDestinationAlbumsKey = 'recent_destination_albums';
  static const recentTagsKey = 'recent_tags';

  // display
  static const displayRefreshRateModeKey = 'display_refresh_rate_mode';
  static const themeBrightnessKey = 'theme_brightness';
  static const themeColorModeKey = 'theme_color_mode';
  static const enableDynamicColorKey = 'dynamic_color';
  static const enableBlurEffectKey = 'enable_overlay_blur_effect';
  static const maxBrightnessKey = 'max_brightness';
  static const forceTvLayoutKey = 'force_tv_layout';

  // navigation
  static const mustBackTwiceToExitKey = 'must_back_twice_to_exit';
  static const keepScreenOnKey = 'keep_screen_on';
  static const homePageKey = 'home_page';
  static const enableBottomNavigationBarKey = 'show_bottom_navigation_bar';
  static const confirmCreateVaultKey = 'confirm_create_vault';
  static const confirmDeleteForeverKey = 'confirm_delete_forever';
  static const confirmMoveToBinKey = 'confirm_move_to_bin';
  static const confirmMoveUndatedItemsKey = 'confirm_move_undated_items';
  static const confirmAfterMoveToBinKey = 'confirm_after_move_to_bin';
  static const setMetadataDateBeforeFileOpKey = 'set_metadata_date_before_file_op';
  static const drawerTypeBookmarksKey = 'drawer_type_bookmarks';
  static const drawerAlbumBookmarksKey = 'drawer_album_bookmarks';
  static const drawerPageBookmarksKey = 'drawer_page_bookmarks';

  // collection
  static const collectionBurstPatternsKey = 'collection_burst_patterns';
  static const collectionGroupFactorKey = 'collection_group_factor';
  static const collectionSortFactorKey = 'collection_sort_factor';
  static const collectionSortReverseKey = 'collection_sort_reverse';
  static const collectionBrowsingQuickActionsKey = 'collection_browsing_quick_actions';
  static const collectionSelectionQuickActionsKey = 'collection_selection_quick_actions';
  static const showThumbnailFavouriteKey = 'show_thumbnail_favourite';
  static const thumbnailLocationIconKey = 'thumbnail_location_icon';
  static const thumbnailTagIconKey = 'thumbnail_tag_icon';
  static const showThumbnailMotionPhotoKey = 'show_thumbnail_motion_photo';
  static const showThumbnailRatingKey = 'show_thumbnail_rating';
  static const showThumbnailRawKey = 'show_thumbnail_raw';
  static const showThumbnailVideoDurationKey = 'show_thumbnail_video_duration';

  // filter grids
  static const albumGroupFactorKey = 'album_group_factor';
  static const albumSortFactorKey = 'album_sort_factor';
  static const countrySortFactorKey = 'country_sort_factor';
  static const stateSortFactorKey = 'state_sort_factor';
  static const placeSortFactorKey = 'place_sort_factor';
  static const tagSortFactorKey = 'tag_sort_factor';
  static const albumSortReverseKey = 'album_sort_reverse';
  static const countrySortReverseKey = 'country_sort_reverse';
  static const stateSortReverseKey = 'state_sort_reverse';
  static const placeSortReverseKey = 'place_sort_reverse';
  static const tagSortReverseKey = 'tag_sort_reverse';
  static const pinnedFiltersKey = 'pinned_filters';
  static const hiddenFiltersKey = 'hidden_filters';

  // viewer
  static const viewerQuickActionsKey = 'viewer_quick_actions';
  static const showOverlayOnOpeningKey = 'show_overlay_on_opening';
  static const showOverlayMinimapKey = 'show_overlay_minimap';
  static const showOverlayInfoKey = 'show_overlay_info';
  static const showOverlayDescriptionKey = 'show_overlay_description';
  static const showOverlayRatingTagsKey = 'show_overlay_rating_tags';
  static const showOverlayShootingDetailsKey = 'show_overlay_shooting_details';
  static const showOverlayThumbnailPreviewKey = 'show_overlay_thumbnail_preview';
  static const viewerGestureSideTapNextKey = 'viewer_gesture_side_tap_next';
  static const viewerUseCutoutKey = 'viewer_use_cutout';
  static const enableMotionPhotoAutoPlayKey = 'motion_photo_auto_play';
  static const imageBackgroundKey = 'image_background';

  // video
  static const enableVideoHardwareAccelerationKey = 'video_hwaccel_mediacodec';
  static const videoBackgroundModeKey = 'video_background_mode';
  static const videoAutoPlayModeKey = 'video_auto_play_mode';
  static const videoLoopModeKey = 'video_loop';
  static const videoControlsKey = 'video_controls';
  static const videoGestureDoubleTapTogglePlayKey = 'video_gesture_double_tap_toggle_play';
  static const videoGestureSideDoubleTapSeekKey = 'video_gesture_side_double_tap_skip';
  static const videoGestureVerticalDragBrightnessVolumeKey = 'video_gesture_vertical_drag_brightness_volume';

  // subtitles
  static const subtitleFontSizeKey = 'subtitle_font_size';
  static const subtitleTextAlignmentKey = 'subtitle_text_alignment';
  static const subtitleTextPositionKey = 'subtitle_text_position';
  static const subtitleShowOutlineKey = 'subtitle_show_outline';
  static const subtitleTextColorKey = 'subtitle_text_color';
  static const subtitleBackgroundColorKey = 'subtitle_background_color';

  // info
  static const infoMapZoomKey = 'info_map_zoom';
  static const coordinateFormatKey = 'coordinates_format';
  static const unitSystemKey = 'unit_system';

  // tag editor

  static const tagEditorCurrentFilterSectionExpandedKey = 'tag_editor_current_filter_section_expanded';
  static const tagEditorExpandedSectionKey = 'tag_editor_expanded_section';

  // converter

  static const convertMimeTypeKey = 'convert_mime_type';
  static const convertWriteMetadataKey = 'convert_write_metadata';

  // map
  static const mapStyleKey = 'info_map_style';
  static const mapDefaultCenterKey = 'map_default_center';

  // search
  static const saveSearchHistoryKey = 'save_search_history';
  static const searchHistoryKey = 'search_history';

  // bin
  static const enableBinKey = 'enable_bin';

  // accessibility
  static const showPinchGestureAlternativesKey = 'show_pinch_gesture_alternatives';
  static const accessibilityAnimationsKey = 'accessibility_animations';
  static const timeToTakeActionKey = 'time_to_take_action';

  // file picker
  static const filePickerShowHiddenFilesKey = 'file_picker_show_hidden_files';

  // screen saver
  static const screenSaverFillScreenKey = 'screen_saver_fill_screen';
  static const screenSaverAnimatedZoomEffectKey = 'screen_saver_animated_zoom_effect';
  static const screenSaverTransitionKey = 'screen_saver_transition';
  static const screenSaverVideoPlaybackKey = 'screen_saver_video_playback';
  static const screenSaverIntervalKey = 'screen_saver_interval';
  static const screenSaverCollectionFiltersKey = 'screen_saver_collection_filters';

  // slideshow
  static const slideshowRepeatKey = 'slideshow_loop';
  static const slideshowShuffleKey = 'slideshow_shuffle';
  static const slideshowFillScreenKey = 'slideshow_fill_screen';
  static const slideshowAnimatedZoomEffectKey = 'slideshow_animated_zoom_effect';
  static const slideshowTransitionKey = 'slideshow_transition';
  static const slideshowVideoPlaybackKey = 'slideshow_video_playback';
  static const slideshowIntervalKey = 'slideshow_interval';

  // widget
  static const widgetOutlinePrefixKey = '${_widgetKeyPrefix}outline_';
  static const widgetShapePrefixKey = '${_widgetKeyPrefix}shape_';
  static const widgetCollectionFiltersPrefixKey = '${_widgetKeyPrefix}collection_filters_';
  static const widgetOpenPagePrefixKey = '${_widgetKeyPrefix}open_page_';
  static const widgetDisplayedItemPrefixKey = '${_widgetKeyPrefix}displayed_item_';
  static const widgetUriPrefixKey = '${_widgetKeyPrefix}uri_';

  // platform settings
  // cf Android `Settings.System.ACCELEROMETER_ROTATION`
  static const platformAccelerometerRotationKey = 'accelerometer_rotation';

  // cf Android `Settings.Global.TRANSITION_ANIMATION_SCALE`
  static const platformTransitionAnimationScaleKey = 'transition_animation_scale';

  bool get initialized => settingsStore.initialized;

  Future<void> init({required bool monitorPlatformSettings}) async {
    await settingsStore.init();
    _appliedLocale = null;
    if (monitorPlatformSettings) {
      _subscriptions
        ..forEach((sub) => sub.cancel())
        ..clear();
      _subscriptions.add(_platformSettingsChangeChannel.receiveBroadcastStream().listen((event) => _onPlatformSettingsChanged(event as Map?)));
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

  Future<void> setContextualDefaults(AppFlavor flavor) async {
    // performance
    final performanceClass = await deviceService.getPerformanceClass();
    enableBlurEffect = performanceClass >= 29;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final pattern = BurstPatterns.byManufacturer[androidInfo.manufacturer];
    collectionBurstPatterns = pattern != null ? [pattern] : [];

    // availability
    if (flavor.hasMapStyleDefault) {
      final defaultMapStyle = mobileServices.defaultMapStyle;
      if (mobileServices.mapStyles.contains(defaultMapStyle)) {
        mapStyle = defaultMapStyle;
      } else {
        final styles = EntryMapStyle.values.whereNot((v) => v.needMobileService).toList();
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
    videoControls = VideoControls.none;
    videoGestureDoubleTapTogglePlay = false;
    videoGestureSideDoubleTapSeek = false;
    enableBin = false;
    showPinchGestureAlternatives = true;
  }

  Future<void> sanitize() async {
    if (timeToTakeAction == AccessibilityTimeout.system && !await AccessibilityService.hasRecommendedTimeouts()) {
      _set(timeToTakeActionKey, null);
    }
    if (viewerUseCutout != SettingsDefaults.viewerUseCutout && !await windowService.isCutoutAware()) {
      _set(viewerUseCutoutKey, null);
    }
    if (videoBackgroundMode == VideoBackgroundMode.pip && !device.supportPictureInPicture) {
      _set(videoBackgroundModeKey, null);
    }
    collectionBurstPatterns = collectionBurstPatterns.where(BurstPatterns.options.contains).toList();
  }

  // app

  bool get hasAcceptedTerms => getBool(hasAcceptedTermsKey) ?? SettingsDefaults.hasAcceptedTerms;

  set hasAcceptedTerms(bool newValue) => _set(hasAcceptedTermsKey, newValue);

  bool get canUseAnalysisService => getBool(canUseAnalysisServiceKey) ?? SettingsDefaults.canUseAnalysisService;

  set canUseAnalysisService(bool newValue) => _set(canUseAnalysisServiceKey, newValue);

  bool get isInstalledAppAccessAllowed => getBool(isInstalledAppAccessAllowedKey) ?? SettingsDefaults.isInstalledAppAccessAllowed;

  set isInstalledAppAccessAllowed(bool newValue) => _set(isInstalledAppAccessAllowedKey, newValue);

  bool get isErrorReportingAllowed => getBool(isErrorReportingAllowedKey) ?? SettingsDefaults.isErrorReportingAllowed;

  set isErrorReportingAllowed(bool newValue) => _set(isErrorReportingAllowedKey, newValue);

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
    _set(localeKey, tag);
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
      _appliedLocale = basicLocaleListResolution(preferredLocales, AvesApp.supportedLocales);
    }
    return _appliedLocale!;
  }

  int get catalogTimeZoneRawOffsetMillis => getInt(catalogTimeZoneRawOffsetMillisKey) ?? 0;

  set catalogTimeZoneRawOffsetMillis(int newValue) => _set(catalogTimeZoneRawOffsetMillisKey, newValue);

  double getTileExtent(String routeName) => getDouble(tileExtentPrefixKey + routeName) ?? 0;

  void setTileExtent(String routeName, double newValue) => _set(tileExtentPrefixKey + routeName, newValue);

  TileLayout getTileLayout(String routeName) => getEnumOrDefault(tileLayoutPrefixKey + routeName, SettingsDefaults.tileLayout, TileLayout.values);

  void setTileLayout(String routeName, TileLayout newValue) => _set(tileLayoutPrefixKey + routeName, newValue.toString());

  String get entryRenamingPattern => getString(entryRenamingPatternKey) ?? SettingsDefaults.entryRenamingPattern;

  set entryRenamingPattern(String newValue) => _set(entryRenamingPatternKey, newValue);

  List<int>? get topEntryIds => getStringList(topEntryIdsKey)?.map(int.tryParse).whereNotNull().toList();

  set topEntryIds(List<int>? newValue) => _set(topEntryIdsKey, newValue?.map((id) => id.toString()).whereNotNull().toList());

  List<String> get recentDestinationAlbums => getStringList(recentDestinationAlbumsKey) ?? [];

  set recentDestinationAlbums(List<String> newValue) => _set(recentDestinationAlbumsKey, newValue.take(_recentFilterHistoryMax).toList());

  List<CollectionFilter> get recentTags => (getStringList(recentTagsKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toList();

  set recentTags(List<CollectionFilter> newValue) => _set(recentTagsKey, newValue.take(_recentFilterHistoryMax).map((filter) => filter.toJson()).toList());

  // display

  DisplayRefreshRateMode get displayRefreshRateMode => getEnumOrDefault(displayRefreshRateModeKey, SettingsDefaults.displayRefreshRateMode, DisplayRefreshRateMode.values);

  set displayRefreshRateMode(DisplayRefreshRateMode newValue) => _set(displayRefreshRateModeKey, newValue.toString());

  AvesThemeBrightness get themeBrightness => getEnumOrDefault(themeBrightnessKey, SettingsDefaults.themeBrightness, AvesThemeBrightness.values);

  set themeBrightness(AvesThemeBrightness newValue) => _set(themeBrightnessKey, newValue.toString());

  AvesThemeColorMode get themeColorMode => getEnumOrDefault(themeColorModeKey, SettingsDefaults.themeColorMode, AvesThemeColorMode.values);

  set themeColorMode(AvesThemeColorMode newValue) => _set(themeColorModeKey, newValue.toString());

  bool get enableDynamicColor => getBool(enableDynamicColorKey) ?? SettingsDefaults.enableDynamicColor;

  set enableDynamicColor(bool newValue) => _set(enableDynamicColorKey, newValue);

  bool get enableBlurEffect => getBool(enableBlurEffectKey) ?? SettingsDefaults.enableBlurEffect;

  set enableBlurEffect(bool newValue) => _set(enableBlurEffectKey, newValue);

  MaxBrightness get maxBrightness => getEnumOrDefault(maxBrightnessKey, SettingsDefaults.maxBrightness, MaxBrightness.values);

  set maxBrightness(MaxBrightness newValue) => _set(maxBrightnessKey, newValue.toString());

  bool get forceTvLayout => getBool(forceTvLayoutKey) ?? SettingsDefaults.forceTvLayout;

  set forceTvLayout(bool newValue) => _set(forceTvLayoutKey, newValue);

  bool get useTvLayout => device.isTelevision || forceTvLayout;

  bool get isReadOnly => useTvLayout;

  // navigation

  bool get mustBackTwiceToExit => getBool(mustBackTwiceToExitKey) ?? SettingsDefaults.mustBackTwiceToExit;

  set mustBackTwiceToExit(bool newValue) => _set(mustBackTwiceToExitKey, newValue);

  KeepScreenOn get keepScreenOn => getEnumOrDefault(keepScreenOnKey, SettingsDefaults.keepScreenOn, KeepScreenOn.values);

  set keepScreenOn(KeepScreenOn newValue) => _set(keepScreenOnKey, newValue.toString());

  HomePageSetting get homePage => getEnumOrDefault(homePageKey, SettingsDefaults.homePage, HomePageSetting.values);

  set homePage(HomePageSetting newValue) => _set(homePageKey, newValue.toString());

  bool get enableBottomNavigationBar => getBool(enableBottomNavigationBarKey) ?? SettingsDefaults.enableBottomNavigationBar;

  set enableBottomNavigationBar(bool newValue) => _set(enableBottomNavigationBarKey, newValue);

  bool get confirmCreateVault => getBool(confirmCreateVaultKey) ?? SettingsDefaults.confirm;

  set confirmCreateVault(bool newValue) => _set(confirmCreateVaultKey, newValue);

  bool get confirmDeleteForever => getBool(confirmDeleteForeverKey) ?? SettingsDefaults.confirm;

  set confirmDeleteForever(bool newValue) => _set(confirmDeleteForeverKey, newValue);

  bool get confirmMoveToBin => getBool(confirmMoveToBinKey) ?? SettingsDefaults.confirm;

  set confirmMoveToBin(bool newValue) => _set(confirmMoveToBinKey, newValue);

  bool get confirmMoveUndatedItems => getBool(confirmMoveUndatedItemsKey) ?? SettingsDefaults.confirm;

  set confirmMoveUndatedItems(bool newValue) => _set(confirmMoveUndatedItemsKey, newValue);

  bool get confirmAfterMoveToBin => getBool(confirmAfterMoveToBinKey) ?? SettingsDefaults.confirm;

  set confirmAfterMoveToBin(bool newValue) => _set(confirmAfterMoveToBinKey, newValue);

  bool get setMetadataDateBeforeFileOp => getBool(setMetadataDateBeforeFileOpKey) ?? SettingsDefaults.setMetadataDateBeforeFileOp;

  set setMetadataDateBeforeFileOp(bool newValue) => _set(setMetadataDateBeforeFileOpKey, newValue);

  List<CollectionFilter?> get drawerTypeBookmarks =>
      (getStringList(drawerTypeBookmarksKey))?.map((v) {
        if (v.isEmpty) return null;
        return CollectionFilter.fromJson(v);
      }).toList() ??
      SettingsDefaults.drawerTypeBookmarks;

  set drawerTypeBookmarks(List<CollectionFilter?> newValue) => _set(drawerTypeBookmarksKey, newValue.map((filter) => filter?.toJson() ?? '').toList());

  List<String>? get drawerAlbumBookmarks => getStringList(drawerAlbumBookmarksKey);

  set drawerAlbumBookmarks(List<String>? newValue) => _set(drawerAlbumBookmarksKey, newValue);

  List<String> get drawerPageBookmarks => getStringList(drawerPageBookmarksKey) ?? SettingsDefaults.drawerPageBookmarks;

  set drawerPageBookmarks(List<String> newValue) => _set(drawerPageBookmarksKey, newValue);

  // collection

  List<String> get collectionBurstPatterns => getStringList(collectionBurstPatternsKey) ?? [];

  set collectionBurstPatterns(List<String> newValue) => _set(collectionBurstPatternsKey, newValue);

  EntryGroupFactor get collectionSectionFactor => getEnumOrDefault(collectionGroupFactorKey, SettingsDefaults.collectionSectionFactor, EntryGroupFactor.values);

  set collectionSectionFactor(EntryGroupFactor newValue) => _set(collectionGroupFactorKey, newValue.toString());

  EntrySortFactor get collectionSortFactor => getEnumOrDefault(collectionSortFactorKey, SettingsDefaults.collectionSortFactor, EntrySortFactor.values);

  set collectionSortFactor(EntrySortFactor newValue) => _set(collectionSortFactorKey, newValue.toString());

  bool get collectionSortReverse => getBool(collectionSortReverseKey) ?? false;

  set collectionSortReverse(bool newValue) => _set(collectionSortReverseKey, newValue);

  List<EntrySetAction> get collectionBrowsingQuickActions => getEnumListOrDefault(collectionBrowsingQuickActionsKey, SettingsDefaults.collectionBrowsingQuickActions, EntrySetAction.values);

  set collectionBrowsingQuickActions(List<EntrySetAction> newValue) => _set(collectionBrowsingQuickActionsKey, newValue.map((v) => v.toString()).toList());

  List<EntrySetAction> get collectionSelectionQuickActions => getEnumListOrDefault(collectionSelectionQuickActionsKey, SettingsDefaults.collectionSelectionQuickActions, EntrySetAction.values);

  set collectionSelectionQuickActions(List<EntrySetAction> newValue) => _set(collectionSelectionQuickActionsKey, newValue.map((v) => v.toString()).toList());

  bool get showThumbnailFavourite => getBool(showThumbnailFavouriteKey) ?? SettingsDefaults.showThumbnailFavourite;

  set showThumbnailFavourite(bool newValue) => _set(showThumbnailFavouriteKey, newValue);

  ThumbnailOverlayLocationIcon get thumbnailLocationIcon => getEnumOrDefault(thumbnailLocationIconKey, SettingsDefaults.thumbnailLocationIcon, ThumbnailOverlayLocationIcon.values);

  set thumbnailLocationIcon(ThumbnailOverlayLocationIcon newValue) => _set(thumbnailLocationIconKey, newValue.toString());

  ThumbnailOverlayTagIcon get thumbnailTagIcon => getEnumOrDefault(thumbnailTagIconKey, SettingsDefaults.thumbnailTagIcon, ThumbnailOverlayTagIcon.values);

  set thumbnailTagIcon(ThumbnailOverlayTagIcon newValue) => _set(thumbnailTagIconKey, newValue.toString());

  bool get showThumbnailMotionPhoto => getBool(showThumbnailMotionPhotoKey) ?? SettingsDefaults.showThumbnailMotionPhoto;

  set showThumbnailMotionPhoto(bool newValue) => _set(showThumbnailMotionPhotoKey, newValue);

  bool get showThumbnailRating => getBool(showThumbnailRatingKey) ?? SettingsDefaults.showThumbnailRating;

  set showThumbnailRating(bool newValue) => _set(showThumbnailRatingKey, newValue);

  bool get showThumbnailRaw => getBool(showThumbnailRawKey) ?? SettingsDefaults.showThumbnailRaw;

  set showThumbnailRaw(bool newValue) => _set(showThumbnailRawKey, newValue);

  bool get showThumbnailVideoDuration => getBool(showThumbnailVideoDurationKey) ?? SettingsDefaults.showThumbnailVideoDuration;

  set showThumbnailVideoDuration(bool newValue) => _set(showThumbnailVideoDurationKey, newValue);

  // filter grids

  AlbumChipGroupFactor get albumGroupFactor => getEnumOrDefault(albumGroupFactorKey, SettingsDefaults.albumGroupFactor, AlbumChipGroupFactor.values);

  set albumGroupFactor(AlbumChipGroupFactor newValue) => _set(albumGroupFactorKey, newValue.toString());

  ChipSortFactor get albumSortFactor => getEnumOrDefault(albumSortFactorKey, SettingsDefaults.chipListSortFactor, ChipSortFactor.values);

  set albumSortFactor(ChipSortFactor newValue) => _set(albumSortFactorKey, newValue.toString());

  ChipSortFactor get countrySortFactor => getEnumOrDefault(countrySortFactorKey, SettingsDefaults.chipListSortFactor, ChipSortFactor.values);

  set countrySortFactor(ChipSortFactor newValue) => _set(countrySortFactorKey, newValue.toString());

  ChipSortFactor get stateSortFactor => getEnumOrDefault(stateSortFactorKey, SettingsDefaults.chipListSortFactor, ChipSortFactor.values);

  set stateSortFactor(ChipSortFactor newValue) => _set(stateSortFactorKey, newValue.toString());

  ChipSortFactor get placeSortFactor => getEnumOrDefault(placeSortFactorKey, SettingsDefaults.chipListSortFactor, ChipSortFactor.values);

  set placeSortFactor(ChipSortFactor newValue) => _set(placeSortFactorKey, newValue.toString());

  ChipSortFactor get tagSortFactor => getEnumOrDefault(tagSortFactorKey, SettingsDefaults.chipListSortFactor, ChipSortFactor.values);

  set tagSortFactor(ChipSortFactor newValue) => _set(tagSortFactorKey, newValue.toString());

  bool get albumSortReverse => getBool(albumSortReverseKey) ?? false;

  set albumSortReverse(bool newValue) => _set(albumSortReverseKey, newValue);

  bool get countrySortReverse => getBool(countrySortReverseKey) ?? false;

  set countrySortReverse(bool newValue) => _set(countrySortReverseKey, newValue);

  bool get stateSortReverse => getBool(stateSortReverseKey) ?? false;

  set stateSortReverse(bool newValue) => _set(stateSortReverseKey, newValue);

  bool get placeSortReverse => getBool(placeSortReverseKey) ?? false;

  set placeSortReverse(bool newValue) => _set(placeSortReverseKey, newValue);

  bool get tagSortReverse => getBool(tagSortReverseKey) ?? false;

  set tagSortReverse(bool newValue) => _set(tagSortReverseKey, newValue);

  Set<CollectionFilter> get pinnedFilters => (getStringList(pinnedFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set pinnedFilters(Set<CollectionFilter> newValue) => _set(pinnedFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  Set<CollectionFilter> get hiddenFilters => (getStringList(hiddenFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set hiddenFilters(Set<CollectionFilter> newValue) => _set(hiddenFiltersKey, newValue.map((filter) => filter.toJson()).toList());

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

  set viewerQuickActions(List<EntryAction> newValue) => _set(viewerQuickActionsKey, newValue.map((v) => v.toString()).toList());

  bool get showOverlayOnOpening => getBool(showOverlayOnOpeningKey) ?? SettingsDefaults.showOverlayOnOpening;

  set showOverlayOnOpening(bool newValue) => _set(showOverlayOnOpeningKey, newValue);

  bool get showOverlayMinimap => getBool(showOverlayMinimapKey) ?? SettingsDefaults.showOverlayMinimap;

  set showOverlayMinimap(bool newValue) => _set(showOverlayMinimapKey, newValue);

  bool get showOverlayInfo => getBool(showOverlayInfoKey) ?? SettingsDefaults.showOverlayInfo;

  set showOverlayInfo(bool newValue) => _set(showOverlayInfoKey, newValue);

  bool get showOverlayDescription => getBool(showOverlayDescriptionKey) ?? SettingsDefaults.showOverlayDescription;

  set showOverlayDescription(bool newValue) => _set(showOverlayDescriptionKey, newValue);

  bool get showOverlayRatingTags => getBool(showOverlayRatingTagsKey) ?? SettingsDefaults.showOverlayRatingTags;

  set showOverlayRatingTags(bool newValue) => _set(showOverlayRatingTagsKey, newValue);

  bool get showOverlayShootingDetails => getBool(showOverlayShootingDetailsKey) ?? SettingsDefaults.showOverlayShootingDetails;

  set showOverlayShootingDetails(bool newValue) => _set(showOverlayShootingDetailsKey, newValue);

  bool get showOverlayThumbnailPreview => getBool(showOverlayThumbnailPreviewKey) ?? SettingsDefaults.showOverlayThumbnailPreview;

  set showOverlayThumbnailPreview(bool newValue) => _set(showOverlayThumbnailPreviewKey, newValue);

  bool get viewerGestureSideTapNext => getBool(viewerGestureSideTapNextKey) ?? SettingsDefaults.viewerGestureSideTapNext;

  set viewerGestureSideTapNext(bool newValue) => _set(viewerGestureSideTapNextKey, newValue);

  bool get viewerUseCutout => getBool(viewerUseCutoutKey) ?? SettingsDefaults.viewerUseCutout;

  set viewerUseCutout(bool newValue) => _set(viewerUseCutoutKey, newValue);

  bool get enableMotionPhotoAutoPlay => getBool(enableMotionPhotoAutoPlayKey) ?? SettingsDefaults.enableMotionPhotoAutoPlay;

  set enableMotionPhotoAutoPlay(bool newValue) => _set(enableMotionPhotoAutoPlayKey, newValue);

  EntryBackground get imageBackground => getEnumOrDefault(imageBackgroundKey, SettingsDefaults.imageBackground, EntryBackground.values);

  set imageBackground(EntryBackground newValue) => _set(imageBackgroundKey, newValue.toString());

  // video

  bool get enableVideoHardwareAcceleration => getBool(enableVideoHardwareAccelerationKey) ?? SettingsDefaults.enableVideoHardwareAcceleration;

  set enableVideoHardwareAcceleration(bool newValue) => _set(enableVideoHardwareAccelerationKey, newValue);

  VideoAutoPlayMode get videoAutoPlayMode => getEnumOrDefault(videoAutoPlayModeKey, SettingsDefaults.videoAutoPlayMode, VideoAutoPlayMode.values);

  set videoAutoPlayMode(VideoAutoPlayMode newValue) => _set(videoAutoPlayModeKey, newValue.toString());

  VideoBackgroundMode get videoBackgroundMode => getEnumOrDefault(videoBackgroundModeKey, SettingsDefaults.videoBackgroundMode, VideoBackgroundMode.values);

  set videoBackgroundMode(VideoBackgroundMode newValue) => _set(videoBackgroundModeKey, newValue.toString());

  VideoLoopMode get videoLoopMode => getEnumOrDefault(videoLoopModeKey, SettingsDefaults.videoLoopMode, VideoLoopMode.values);

  set videoLoopMode(VideoLoopMode newValue) => _set(videoLoopModeKey, newValue.toString());

  VideoControls get videoControls => getEnumOrDefault(videoControlsKey, SettingsDefaults.videoControls, VideoControls.values);

  set videoControls(VideoControls newValue) => _set(videoControlsKey, newValue.toString());

  bool get videoGestureDoubleTapTogglePlay => getBool(videoGestureDoubleTapTogglePlayKey) ?? SettingsDefaults.videoGestureDoubleTapTogglePlay;

  set videoGestureDoubleTapTogglePlay(bool newValue) => _set(videoGestureDoubleTapTogglePlayKey, newValue);

  bool get videoGestureSideDoubleTapSeek => getBool(videoGestureSideDoubleTapSeekKey) ?? SettingsDefaults.videoGestureSideDoubleTapSeek;

  set videoGestureSideDoubleTapSeek(bool newValue) => _set(videoGestureSideDoubleTapSeekKey, newValue);

  bool get videoGestureVerticalDragBrightnessVolume => getBool(videoGestureVerticalDragBrightnessVolumeKey) ?? SettingsDefaults.videoGestureVerticalDragBrightnessVolume;

  set videoGestureVerticalDragBrightnessVolume(bool newValue) => _set(videoGestureVerticalDragBrightnessVolumeKey, newValue);

  // subtitles

  double get subtitleFontSize => getDouble(subtitleFontSizeKey) ?? SettingsDefaults.subtitleFontSize;

  set subtitleFontSize(double newValue) => _set(subtitleFontSizeKey, newValue);

  TextAlign get subtitleTextAlignment => getEnumOrDefault(subtitleTextAlignmentKey, SettingsDefaults.subtitleTextAlignment, TextAlign.values);

  set subtitleTextAlignment(TextAlign newValue) => _set(subtitleTextAlignmentKey, newValue.toString());

  SubtitlePosition get subtitleTextPosition => getEnumOrDefault(subtitleTextPositionKey, SettingsDefaults.subtitleTextPosition, SubtitlePosition.values);

  set subtitleTextPosition(SubtitlePosition newValue) => _set(subtitleTextPositionKey, newValue.toString());

  bool get subtitleShowOutline => getBool(subtitleShowOutlineKey) ?? SettingsDefaults.subtitleShowOutline;

  set subtitleShowOutline(bool newValue) => _set(subtitleShowOutlineKey, newValue);

  Color get subtitleTextColor => Color(getInt(subtitleTextColorKey) ?? SettingsDefaults.subtitleTextColor.value);

  set subtitleTextColor(Color newValue) => _set(subtitleTextColorKey, newValue.value);

  Color get subtitleBackgroundColor => Color(getInt(subtitleBackgroundColorKey) ?? SettingsDefaults.subtitleBackgroundColor.value);

  set subtitleBackgroundColor(Color newValue) => _set(subtitleBackgroundColorKey, newValue.value);

  // info

  double get infoMapZoom => getDouble(infoMapZoomKey) ?? SettingsDefaults.infoMapZoom;

  set infoMapZoom(double newValue) => _set(infoMapZoomKey, newValue);

  CoordinateFormat get coordinateFormat => getEnumOrDefault(coordinateFormatKey, SettingsDefaults.coordinateFormat, CoordinateFormat.values);

  set coordinateFormat(CoordinateFormat newValue) => _set(coordinateFormatKey, newValue.toString());

  UnitSystem get unitSystem => getEnumOrDefault(unitSystemKey, SettingsDefaults.unitSystem, UnitSystem.values);

  set unitSystem(UnitSystem newValue) => _set(unitSystemKey, newValue.toString());

  // tag editor

  bool get tagEditorCurrentFilterSectionExpanded => getBool(tagEditorCurrentFilterSectionExpandedKey) ?? SettingsDefaults.tagEditorCurrentFilterSectionExpanded;

  set tagEditorCurrentFilterSectionExpanded(bool newValue) => _set(tagEditorCurrentFilterSectionExpandedKey, newValue);

  String? get tagEditorExpandedSection => getString(tagEditorExpandedSectionKey);

  set tagEditorExpandedSection(String? newValue) => _set(tagEditorExpandedSectionKey, newValue);

  // converter

  String get convertMimeType => getString(convertMimeTypeKey) ?? SettingsDefaults.convertMimeType;

  set convertMimeType(String newValue) => _set(convertMimeTypeKey, newValue);

  bool get convertWriteMetadata => getBool(convertWriteMetadataKey) ?? SettingsDefaults.convertWriteMetadata;

  set convertWriteMetadata(bool newValue) => _set(convertWriteMetadataKey, newValue);

  // map

  EntryMapStyle? get mapStyle {
    final preferred = getEnumOrDefault(mapStyleKey, null, EntryMapStyle.values);
    if (preferred == null) return null;

    final available = availability.mapStyles;
    return available.contains(preferred) ? preferred : available.first;
  }

  set mapStyle(EntryMapStyle? newValue) => _set(mapStyleKey, newValue?.toString());

  LatLng? get mapDefaultCenter {
    final json = getString(mapDefaultCenterKey);
    return json != null ? LatLng.fromJson(jsonDecode(json)) : null;
  }

  set mapDefaultCenter(LatLng? newValue) => _set(mapDefaultCenterKey, newValue != null ? jsonEncode(newValue.toJson()) : null);

  // search

  bool get saveSearchHistory => getBool(saveSearchHistoryKey) ?? SettingsDefaults.saveSearchHistory;

  set saveSearchHistory(bool newValue) => _set(saveSearchHistoryKey, newValue);

  List<CollectionFilter> get searchHistory => (getStringList(searchHistoryKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toList();

  set searchHistory(List<CollectionFilter> newValue) => _set(searchHistoryKey, newValue.map((filter) => filter.toJson()).toList());

  // bin

  bool get enableBin => getBool(enableBinKey) ?? SettingsDefaults.enableBin;

  set enableBin(bool newValue) => _set(enableBinKey, newValue);

  // accessibility

  bool get showPinchGestureAlternatives => getBool(showPinchGestureAlternativesKey) ?? SettingsDefaults.showPinchGestureAlternatives;

  set showPinchGestureAlternatives(bool newValue) => _set(showPinchGestureAlternativesKey, newValue);

  AccessibilityAnimations get accessibilityAnimations => getEnumOrDefault(accessibilityAnimationsKey, SettingsDefaults.accessibilityAnimations, AccessibilityAnimations.values);

  set accessibilityAnimations(AccessibilityAnimations newValue) => _set(accessibilityAnimationsKey, newValue.toString());

  AccessibilityTimeout get timeToTakeAction => getEnumOrDefault(timeToTakeActionKey, SettingsDefaults.timeToTakeAction, AccessibilityTimeout.values);

  set timeToTakeAction(AccessibilityTimeout newValue) => _set(timeToTakeActionKey, newValue.toString());

  // file picker

  bool get filePickerShowHiddenFiles => getBool(filePickerShowHiddenFilesKey) ?? SettingsDefaults.filePickerShowHiddenFiles;

  set filePickerShowHiddenFiles(bool newValue) => _set(filePickerShowHiddenFilesKey, newValue);

  // screen saver

  bool get screenSaverFillScreen => getBool(screenSaverFillScreenKey) ?? SettingsDefaults.slideshowFillScreen;

  set screenSaverFillScreen(bool newValue) => _set(screenSaverFillScreenKey, newValue);

  bool get screenSaverAnimatedZoomEffect => getBool(screenSaverAnimatedZoomEffectKey) ?? SettingsDefaults.slideshowAnimatedZoomEffect;

  set screenSaverAnimatedZoomEffect(bool newValue) => _set(screenSaverAnimatedZoomEffectKey, newValue);

  ViewerTransition get screenSaverTransition => getEnumOrDefault(screenSaverTransitionKey, SettingsDefaults.slideshowTransition, ViewerTransition.values);

  set screenSaverTransition(ViewerTransition newValue) => _set(screenSaverTransitionKey, newValue.toString());

  SlideshowVideoPlayback get screenSaverVideoPlayback => getEnumOrDefault(screenSaverVideoPlaybackKey, SettingsDefaults.slideshowVideoPlayback, SlideshowVideoPlayback.values);

  set screenSaverVideoPlayback(SlideshowVideoPlayback newValue) => _set(screenSaverVideoPlaybackKey, newValue.toString());

  int get screenSaverInterval => getInt(screenSaverIntervalKey) ?? SettingsDefaults.slideshowInterval;

  set screenSaverInterval(int newValue) => _set(screenSaverIntervalKey, newValue);

  Set<CollectionFilter> get screenSaverCollectionFilters => (getStringList(screenSaverCollectionFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set screenSaverCollectionFilters(Set<CollectionFilter> newValue) => _set(screenSaverCollectionFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  // slideshow

  bool get slideshowRepeat => getBool(slideshowRepeatKey) ?? SettingsDefaults.slideshowRepeat;

  set slideshowRepeat(bool newValue) => _set(slideshowRepeatKey, newValue);

  bool get slideshowShuffle => getBool(slideshowShuffleKey) ?? SettingsDefaults.slideshowShuffle;

  set slideshowShuffle(bool newValue) => _set(slideshowShuffleKey, newValue);

  bool get slideshowFillScreen => getBool(slideshowFillScreenKey) ?? SettingsDefaults.slideshowFillScreen;

  set slideshowFillScreen(bool newValue) => _set(slideshowFillScreenKey, newValue);

  bool get slideshowAnimatedZoomEffect => getBool(slideshowAnimatedZoomEffectKey) ?? SettingsDefaults.slideshowAnimatedZoomEffect;

  set slideshowAnimatedZoomEffect(bool newValue) => _set(slideshowAnimatedZoomEffectKey, newValue);

  ViewerTransition get slideshowTransition => getEnumOrDefault(slideshowTransitionKey, SettingsDefaults.slideshowTransition, ViewerTransition.values);

  set slideshowTransition(ViewerTransition newValue) => _set(slideshowTransitionKey, newValue.toString());

  SlideshowVideoPlayback get slideshowVideoPlayback => getEnumOrDefault(slideshowVideoPlaybackKey, SettingsDefaults.slideshowVideoPlayback, SlideshowVideoPlayback.values);

  set slideshowVideoPlayback(SlideshowVideoPlayback newValue) => _set(slideshowVideoPlaybackKey, newValue.toString());

  int get slideshowInterval => getInt(slideshowIntervalKey) ?? SettingsDefaults.slideshowInterval;

  set slideshowInterval(int newValue) => _set(slideshowIntervalKey, newValue);

  // widget

  Color? getWidgetOutline(int widgetId) {
    final value = getInt('$widgetOutlinePrefixKey$widgetId');
    return value != null ? Color(value) : null;
  }

  void setWidgetOutline(int widgetId, Color? newValue) => _set('$widgetOutlinePrefixKey$widgetId', newValue?.value);

  WidgetShape getWidgetShape(int widgetId) => getEnumOrDefault('$widgetShapePrefixKey$widgetId', SettingsDefaults.widgetShape, WidgetShape.values);

  void setWidgetShape(int widgetId, WidgetShape newValue) => _set('$widgetShapePrefixKey$widgetId', newValue.toString());

  Set<CollectionFilter> getWidgetCollectionFilters(int widgetId) => (getStringList('$widgetCollectionFiltersPrefixKey$widgetId') ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  void setWidgetCollectionFilters(int widgetId, Set<CollectionFilter> newValue) => _set('$widgetCollectionFiltersPrefixKey$widgetId', newValue.map((filter) => filter.toJson()).toList());

  WidgetOpenPage getWidgetOpenPage(int widgetId) => getEnumOrDefault('$widgetOpenPagePrefixKey$widgetId', SettingsDefaults.widgetOpenPage, WidgetOpenPage.values);

  void setWidgetOpenPage(int widgetId, WidgetOpenPage newValue) => _set('$widgetOpenPagePrefixKey$widgetId', newValue.toString());

  WidgetDisplayedItem getWidgetDisplayedItem(int widgetId) => getEnumOrDefault('$widgetDisplayedItemPrefixKey$widgetId', SettingsDefaults.widgetDisplayedItem, WidgetDisplayedItem.values);

  void setWidgetDisplayedItem(int widgetId, WidgetDisplayedItem newValue) => _set('$widgetDisplayedItemPrefixKey$widgetId', newValue.toString());

  String? getWidgetUri(int widgetId) => getString('$widgetUriPrefixKey$widgetId');

  void setWidgetUri(int widgetId, String? newValue) => _set('$widgetUriPrefixKey$widgetId', newValue);

  // convenience methods

  bool? getBool(String key) {
    try {
      return settingsStore.getBool(key);
    } catch (error) {
      // ignore, could be obsolete value of different type
      return null;
    }
  }

  int? getInt(String key) {
    try {
      return settingsStore.getInt(key);
    } catch (error) {
      // ignore, could be obsolete value of different type
      return null;
    }
  }

  double? getDouble(String key) {
    try {
      return settingsStore.getDouble(key);
    } catch (error) {
      // ignore, could be obsolete value of different type
      return null;
    }
  }

  String? getString(String key) {
    try {
      return settingsStore.getString(key);
    } catch (error) {
      // ignore, could be obsolete value of different type
      return null;
    }
  }

  List<String>? getStringList(String key) {
    try {
      return settingsStore.getStringList(key);
    } catch (error) {
      // ignore, could be obsolete value of different type
      return null;
    }
  }

  T getEnumOrDefault<T>(String key, T defaultValue, Iterable<T> values) {
    try {
      final valueString = settingsStore.getString(key);
      for (final v in values) {
        if (v.toString() == valueString) {
          return v;
        }
      }
    } catch (error) {
      // ignore, could be obsolete value of different type
    }
    return defaultValue;
  }

  List<T> getEnumListOrDefault<T extends Object>(String key, List<T> defaultValue, Iterable<T> values) {
    return settingsStore.getStringList(key)?.map((s) => values.firstWhereOrNull((v) => v.toString() == s)).whereNotNull().toList() ?? defaultValue;
  }

  void _set(String key, dynamic newValue) {
    var oldValue = settingsStore.get(key);
    if (newValue == null) {
      settingsStore.remove(key);
    } else if (newValue is String) {
      oldValue = getString(key);
      settingsStore.setString(key, newValue);
    } else if (newValue is List<String>) {
      oldValue = getStringList(key);
      settingsStore.setStringList(key, newValue);
    } else if (newValue is int) {
      oldValue = getInt(key);
      settingsStore.setInt(key, newValue);
    } else if (newValue is double) {
      oldValue = getDouble(key);
      settingsStore.setDouble(key, newValue);
    } else if (newValue is bool) {
      oldValue = getBool(key);
      settingsStore.setBool(key, newValue);
    }
    if (oldValue != newValue) {
      _updateStreamController.add(SettingsChangedEvent(key, oldValue, newValue));
      notifyListeners();
    }
  }

  // platform settings

  void _onPlatformSettingsChanged(Map? fields) {
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

  bool get isRotationLocked => getBool(platformAccelerometerRotationKey) ?? SettingsDefaults.isRotationLocked;

  set isRotationLocked(bool newValue) => _set(platformAccelerometerRotationKey, newValue);

  bool get areAnimationsRemoved => getBool(platformTransitionAnimationScaleKey) ?? SettingsDefaults.areAnimationsRemoved;

  set areAnimationsRemoved(bool newValue) => _set(platformTransitionAnimationScaleKey, newValue);

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
            case screenSaverIntervalKey:
            case slideshowIntervalKey:
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
            case confirmCreateVaultKey:
            case confirmDeleteForeverKey:
            case confirmMoveToBinKey:
            case confirmMoveUndatedItemsKey:
            case confirmAfterMoveToBinKey:
            case setMetadataDateBeforeFileOpKey:
            case collectionSortReverseKey:
            case showThumbnailFavouriteKey:
            case showThumbnailMotionPhotoKey:
            case showThumbnailRatingKey:
            case showThumbnailRawKey:
            case showThumbnailVideoDurationKey:
            case albumSortReverseKey:
            case countrySortReverseKey:
            case stateSortReverseKey:
            case placeSortReverseKey:
            case tagSortReverseKey:
            case showOverlayOnOpeningKey:
            case showOverlayMinimapKey:
            case showOverlayInfoKey:
            case showOverlayDescriptionKey:
            case showOverlayRatingTagsKey:
            case showOverlayShootingDetailsKey:
            case showOverlayThumbnailPreviewKey:
            case viewerGestureSideTapNextKey:
            case viewerUseCutoutKey:
            case enableMotionPhotoAutoPlayKey:
            case enableVideoHardwareAccelerationKey:
            case videoGestureDoubleTapTogglePlayKey:
            case videoGestureSideDoubleTapSeekKey:
            case videoGestureVerticalDragBrightnessVolumeKey:
            case subtitleShowOutlineKey:
            case tagEditorCurrentFilterSectionExpandedKey:
            case convertWriteMetadataKey:
            case saveSearchHistoryKey:
            case showPinchGestureAlternativesKey:
            case filePickerShowHiddenFilesKey:
            case screenSaverFillScreenKey:
            case screenSaverAnimatedZoomEffectKey:
            case slideshowRepeatKey:
            case slideshowShuffleKey:
            case slideshowFillScreenKey:
            case slideshowAnimatedZoomEffectKey:
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
            case maxBrightnessKey:
            case keepScreenOnKey:
            case homePageKey:
            case collectionGroupFactorKey:
            case collectionSortFactorKey:
            case thumbnailLocationIconKey:
            case thumbnailTagIconKey:
            case albumGroupFactorKey:
            case albumSortFactorKey:
            case countrySortFactorKey:
            case stateSortFactorKey:
            case placeSortFactorKey:
            case tagSortFactorKey:
            case imageBackgroundKey:
            case videoAutoPlayModeKey:
            case videoBackgroundModeKey:
            case videoLoopModeKey:
            case videoControlsKey:
            case subtitleTextAlignmentKey:
            case subtitleTextPositionKey:
            case tagEditorExpandedSectionKey:
            case convertMimeTypeKey:
            case mapStyleKey:
            case mapDefaultCenterKey:
            case coordinateFormatKey:
            case unitSystemKey:
            case accessibilityAnimationsKey:
            case timeToTakeActionKey:
            case screenSaverTransitionKey:
            case screenSaverVideoPlaybackKey:
            case slideshowTransitionKey:
            case slideshowVideoPlaybackKey:
              if (newValue is String) {
                settingsStore.setString(key, newValue);
              } else {
                debugPrint('failed to import key=$key, value=$newValue is not a string');
              }
              break;
            case drawerTypeBookmarksKey:
            case drawerAlbumBookmarksKey:
            case drawerPageBookmarksKey:
            case collectionBurstPatternsKey:
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
      await sanitize();
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
