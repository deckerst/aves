import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/naming_pattern.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';

class SettingsDefaults {
  // app
  static const hasAcceptedTerms = false;
  static const canUseAnalysisService = true;
  static const isInstalledAppAccessAllowed = false;
  static const isErrorReportingAllowed = false;
  static const tileLayout = TileLayout.grid;
  static const entryRenamingPattern = '<${DateNamingProcessor.key}, yyyyMMdd-HHmmss> <${NameNamingProcessor.key}>';

  // display
  static const displayRefreshRateMode = DisplayRefreshRateMode.auto;
  static const themeBrightness = AvesThemeBrightness.system;
  static const themeColorMode = AvesThemeColorMode.polychrome;
  static const enableDynamicColor = false;
  static const enableBlurEffect = true; // `enableBlurEffect` has a contextual default value

  // navigation
  static const mustBackTwiceToExit = true;
  static const keepScreenOn = KeepScreenOn.viewerOnly;
  static const homePage = HomePageSetting.collection;
  static const enableBottomNavigationBar = true;
  static const confirmDeleteForever = true;
  static const confirmMoveToBin = true;
  static const confirmMoveUndatedItems = true;
  static const setMetadataDateBeforeFileOp = false;
  static final drawerTypeBookmarks = [
    null,
    MimeFilter.video,
    FavouriteFilter.instance,
  ];
  static const drawerPageBookmarks = [
    AlbumListPage.routeName,
    CountryListPage.routeName,
    TagListPage.routeName,
  ];

  // collection
  static const collectionSectionFactor = EntryGroupFactor.month;
  static const collectionSortFactor = EntrySortFactor.date;
  static const collectionBrowsingQuickActions = [
    EntrySetAction.searchCollection,
  ];
  static const collectionSelectionQuickActions = [
    EntrySetAction.share,
    EntrySetAction.delete,
  ];
  static const showThumbnailFavourite = true;
  static const showThumbnailTag = false;
  static const showThumbnailLocation = true;
  static const showThumbnailMotionPhoto = true;
  static const showThumbnailRating = true;
  static const showThumbnailRaw = true;
  static const showThumbnailVideoDuration = true;

  // filter grids
  static const albumGroupFactor = AlbumChipGroupFactor.importance;
  static const albumSortFactor = ChipSortFactor.name;
  static const countrySortFactor = ChipSortFactor.name;
  static const tagSortFactor = ChipSortFactor.name;

  // viewer
  static const viewerQuickActions = [
    EntryAction.rotateScreen,
    EntryAction.toggleFavourite,
    EntryAction.share,
    EntryAction.delete,
  ];
  static const showOverlayOnOpening = true;
  static const showOverlayMinimap = false;
  static const showOverlayInfo = true;
  static const showOverlayShootingDetails = false;
  static const showOverlayThumbnailPreview = false;
  static const viewerGestureSideTapNext = false;
  static const viewerUseCutout = true;
  static const viewerMaxBrightness = false;
  static const enableMotionPhotoAutoPlay = false;

  // video
  static const enableVideoHardwareAcceleration = true;
  static const enableVideoAutoPlay = false;
  static const videoLoopMode = VideoLoopMode.shortOnly;
  static const videoShowRawTimedText = false;
  static const videoControls = VideoControls.play;
  static const videoGestureDoubleTapTogglePlay = false;
  static const videoGestureSideDoubleTapSeek = true;

  // subtitles
  static const subtitleFontSize = 20.0;
  static const subtitleTextAlignment = TextAlign.center;
  static const subtitleShowOutline = true;
  static const subtitleTextColor = Colors.white;
  static const subtitleBackgroundColor = Colors.transparent;

  // info
  static const infoMapStyle = EntryMapStyle.stamenWatercolor; // `infoMapStyle` has a contextual default value
  static const infoMapZoom = 12.0;
  static const coordinateFormat = CoordinateFormat.dms;
  static const unitSystem = UnitSystem.metric;

  // rendering
  static const imageBackground = EntryBackground.white;

  // search
  static const saveSearchHistory = true;

  // bin
  static const enableBin = true;

  // accessibility
  static const accessibilityAnimations = AccessibilityAnimations.system;
  static const timeToTakeAction = AccessibilityTimeout.appDefault; // `timeToTakeAction` has a contextual default value

  // file picker
  static const filePickerShowHiddenFiles = false;

  // slideshow
  static const slideshowRepeat = false;
  static const slideshowShuffle = false;
  static const slideshowFillScreen = false;
  static const slideshowTransition = ViewerTransition.fade;
  static const slideshowVideoPlayback = SlideshowVideoPlayback.playMuted;
  static const slideshowInterval = SlideshowInterval.s5;

  // widget
  static const widgetOutline = false;
  static const widgetShape = WidgetShape.rrect;

  // platform settings
  static const isRotationLocked = false;
  static const areAnimationsRemoved = false;
}
