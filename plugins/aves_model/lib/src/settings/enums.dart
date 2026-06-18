enum AccessibilityAnimations { system, disabled, enabled }

enum AccessibilityTimeout { system, s1, s3, s5, s10, s30 }

enum AvesThemeBrightness { system, light, dark, black }

enum AvesThemeColorMode { monochrome, polychrome }

enum ConfirmationDialog { createVault, deleteForever, moveToBin, moveUndatedItems }

enum CoordinateFormat { dms, ddm, decimal }

enum DisplayRefreshRateMode { auto, highest, lowest }

enum EntryBackground { black, white, checkered }

enum HomePageSetting { collection, albums, tags, explorer }

enum KeepScreenOn { never, videoPlayback, viewerOnly, always }

enum MaxBrightness { never, viewerOnly, always }

enum OverlayHistogramStyle { none, rgb, luminance }

enum SlideshowVideoPlayback { skip, playMuted, playWithSound }

enum SubtitlePosition { top, bottom }

enum ThumbnailOverlayLocationIcon { located, unlocated, none }

enum ThumbnailOverlayTagIcon { tagged, untagged, none }

enum UnitSystem { metric, imperial }

enum VideoAutoPlayMode { disabled, playMuted, playWithSound }

enum VideoBackgroundMode { disabled, pip }

enum VideoHardwareAcceleration { disabled, enabled, forced }

enum VideoLoopMode { never, shortOnly, always }

enum VideoResumptionMode { never, ask, always }

enum ViewerTransition { slide, parallax, fade, zoomIn, none, random }

enum WidgetDisplayedItem { random, mostRecent }

enum WidgetOpenPage { home, collection, viewer, updateWidget }

enum WidgetOutline {
  none,
  black,
  white,
  // system brightness dependent (low contrast):
  // - white on light theme
  // - black on dark theme
  systemBlackAndWhite,
  // system brightness dependent (high contrast):
  // - black on light theme
  // - white on dark theme
  systemBlackAndWhiteHighContrast,
  // system brightness dependent (low contrast):
  // light dynamic colour on light theme
  // dark dynamic colour on dark theme.
  systemDynamicLowContrast,
  // system brightness dependent (high contrast):
  // dark dynamic colour on light theme
  // light dynamic colour on dark theme.
  systemDynamic,
}

// ideas for more shapes:
// - Material 3: https://m3.material.io/styles/shape/overview-principles
enum WidgetShape {
  rrect,
  circle,
  heart,
  m3sunny,
  concaveSquare, // aka M3 `4-sided cookie`
  m3cookie9,
  wavyCircle16,
  tearRectLeft,
  tearRectRight,
  bumpyRows,
  bumpyColumns,
}
