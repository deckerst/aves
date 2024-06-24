import 'package:aves/model/filters/recent.dart';
import 'package:aves/model/naming_pattern.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/widgets/explorer/explorer_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves_model/aves_model.dart';

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
  static const maxBrightness = MaxBrightness.never;
  static const forceTvLayout = false;

  // navigation
  static const mustBackTwiceToExit = true;
  static const keepScreenOn = KeepScreenOn.viewerOnly;
  static const homePage = HomePageSetting.collection;
  static const enableBottomNavigationBar = true;
  static const confirm = true;
  static const setMetadataDateBeforeFileOp = false;
  static final drawerTypeBookmarks = [
    null,
    RecentlyAddedFilter.instance,
  ];
  static const drawerPageBookmarks = [
    AlbumListPage.routeName,
    CountryListPage.routeName,
    TagListPage.routeName,
    ExplorerPage.routeName,
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
  static const showThumbnailHdr = true;
  static const thumbnailLocationIcon = ThumbnailOverlayLocationIcon.none;
  static const thumbnailTagIcon = ThumbnailOverlayTagIcon.none;
  static const showThumbnailMotionPhoto = true;
  static const showThumbnailRating = true;
  static const showThumbnailRaw = true;
  static const showThumbnailVideoDuration = true;

  // filter grids
  static const albumGroupFactor = AlbumChipGroupFactor.importance;
  static const chipListSortFactor = ChipSortFactor.name;

  // viewer
  static const viewerQuickActions = [
    EntryAction.rotateScreen,
    EntryAction.toggleFavourite,
    EntryAction.share,
    EntryAction.delete,
  ];
  static const showOverlayOnOpening = true;
  static const showOverlayMinimap = false;
  static const overlayHistogramStyle = OverlayHistogramStyle.none;
  static const showOverlayInfo = true;
  static const showOverlayDescription = false;
  static const showOverlayRatingTags = false;
  static const showOverlayShootingDetails = false;
  static const showOverlayThumbnailPreview = false;
  static const viewerGestureSideTapNext = false;
  static const viewerUseCutout = true;
  static const enableMotionPhotoAutoPlay = false;

  // info
  static const infoMapZoom = 12.0;
  static const coordinateFormat = CoordinateFormat.dms;
  static const unitSystem = UnitSystem.metric;

  // tag editor

  static const tagEditorCurrentFilterSectionExpanded = true;

  // converter

  static const convertMimeType = MimeTypes.jpeg;
  static const convertQuality = 95;
  static const convertWriteMetadata = true;

  // rendering
  static const imageBackground = EntryBackground.white;

  // search
  static const saveSearchHistory = true;

  // bin
  static const enableBin = true;

  // accessibility
  static const showPinchGestureAlternatives = false;
  static const accessibilityAnimations = AccessibilityAnimations.system;
  static const timeToTakeAction = AccessibilityTimeout.s3;

  // file picker
  static const filePickerShowHiddenFiles = false;

  // slideshow
  static const slideshowRepeat = false;
  static const slideshowShuffle = false;
  static const slideshowFillScreen = false;
  static const slideshowAnimatedZoomEffect = true;
  static const slideshowTransition = ViewerTransition.fade;
  static const slideshowVideoPlayback = SlideshowVideoPlayback.playMuted;
  static const slideshowInterval = 5;

  // widget
  static const widgetOutline = false;
  static const widgetShape = WidgetShape.rrect;
  static const widgetOpenPage = WidgetOpenPage.viewer;
  static const widgetDisplayedItem = WidgetDisplayedItem.random;

  // platform settings
  static const isRotationLocked = false;
  static const areAnimationsRemoved = false;
}
