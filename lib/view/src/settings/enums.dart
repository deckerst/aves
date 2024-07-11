import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraAccessibilityAnimationsView on AccessibilityAnimations {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      AccessibilityAnimations.system => l10n.settingsSystemDefault,
      AccessibilityAnimations.disabled => l10n.accessibilityAnimationsRemove,
      AccessibilityAnimations.enabled => l10n.accessibilityAnimationsKeep,
    };
  }
}

extension ExtraAccessibilityTimeoutView on AccessibilityTimeout {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      AccessibilityTimeout.system => l10n.settingsSystemDefault,
      AccessibilityTimeout.s1 => l10n.timeSeconds(1),
      AccessibilityTimeout.s3 => l10n.timeSeconds(3),
      AccessibilityTimeout.s5 => l10n.timeSeconds(5),
      AccessibilityTimeout.s10 => l10n.timeSeconds(10),
      AccessibilityTimeout.s30 => l10n.timeSeconds(30),
    };
  }
}

extension ExtraAvesThemeBrightnessView on AvesThemeBrightness {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      AvesThemeBrightness.system => l10n.settingsSystemDefault,
      AvesThemeBrightness.light => l10n.themeBrightnessLight,
      AvesThemeBrightness.dark => l10n.themeBrightnessDark,
      AvesThemeBrightness.black => l10n.themeBrightnessBlack,
    };
  }
}

extension ExtraCoordinateFormatView on CoordinateFormat {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      CoordinateFormat.dms => l10n.coordinateFormatDms,
      CoordinateFormat.decimal => l10n.coordinateFormatDecimal,
    };
  }
}

extension ExtraDisplayRefreshRateModeView on DisplayRefreshRateMode {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      DisplayRefreshRateMode.auto => l10n.settingsSystemDefault,
      DisplayRefreshRateMode.highest => l10n.displayRefreshRatePreferHighest,
      DisplayRefreshRateMode.lowest => l10n.displayRefreshRatePreferLowest,
    };
  }
}

extension ExtraEntryMapStyleView on EntryMapStyle {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      EntryMapStyle.googleNormal => l10n.mapStyleGoogleNormal,
      EntryMapStyle.googleHybrid => l10n.mapStyleGoogleHybrid,
      EntryMapStyle.googleTerrain => l10n.mapStyleGoogleTerrain,
      EntryMapStyle.osmHot => l10n.mapStyleOsmHot,
      EntryMapStyle.stamenWatercolor => l10n.mapStyleStamenWatercolor,
    };
  }
}

extension ExtraHomePageSettingView on HomePageSetting {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      HomePageSetting.collection => l10n.drawerCollectionAll,
      HomePageSetting.albums => l10n.drawerAlbumPage,
      HomePageSetting.tags => l10n.drawerTagPage,
      HomePageSetting.explorer => l10n.explorerPageTitle,
    };
  }
}

extension ExtraKeepScreenOnView on KeepScreenOn {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      KeepScreenOn.never => l10n.keepScreenOnNever,
      KeepScreenOn.videoPlayback => l10n.keepScreenOnVideoPlayback,
      KeepScreenOn.viewerOnly => l10n.keepScreenOnViewerOnly,
      KeepScreenOn.always => l10n.keepScreenOnAlways,
    };
  }
}

extension ExtraMaxBrightnessView on MaxBrightness {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      MaxBrightness.never => l10n.maxBrightnessNever,
      MaxBrightness.viewerOnly => l10n.keepScreenOnViewerOnly,
      MaxBrightness.always => l10n.maxBrightnessAlways,
    };
  }
}

extension ExtraSlideshowVideoPlaybackView on SlideshowVideoPlayback {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      SlideshowVideoPlayback.skip => l10n.videoPlaybackSkip,
      SlideshowVideoPlayback.playMuted => l10n.videoPlaybackMuted,
      SlideshowVideoPlayback.playWithSound => l10n.videoPlaybackWithSound,
    };
  }
}

extension ExtraOverlayHistogramStyleView on OverlayHistogramStyle {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      OverlayHistogramStyle.none => l10n.overlayHistogramNone,
      OverlayHistogramStyle.rgb => l10n.overlayHistogramRGB,
      OverlayHistogramStyle.luminance => l10n.overlayHistogramLuminance,
    };
  }
}

extension ExtraSubtitlePositionView on SubtitlePosition {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      SubtitlePosition.top => l10n.subtitlePositionTop,
      SubtitlePosition.bottom => l10n.subtitlePositionBottom,
    };
  }
}

extension ExtraUnitSystemView on UnitSystem {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      UnitSystem.metric => l10n.unitSystemMetric,
      UnitSystem.imperial => l10n.unitSystemImperial,
    };
  }
}

extension ExtraVideoAutoPlayModeView on VideoAutoPlayMode {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      VideoAutoPlayMode.disabled => l10n.settingsDisabled,
      VideoAutoPlayMode.playMuted => l10n.videoPlaybackMuted,
      VideoAutoPlayMode.playWithSound => l10n.videoPlaybackWithSound,
    };
  }
}

extension ExtraVideoBackgroundModeView on VideoBackgroundMode {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      VideoBackgroundMode.disabled => l10n.settingsDisabled,
      VideoBackgroundMode.pip => l10n.settingsVideoEnablePip,
    };
  }
}

extension ExtraVideoControlsView on VideoControls {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      VideoControls.play => l10n.videoControlsPlay,
      VideoControls.playSeek => l10n.videoControlsPlaySeek,
      VideoControls.playOutside => l10n.videoControlsPlayOutside,
      VideoControls.none => l10n.videoControlsNone,
    };
  }
}

extension ExtraVideoLoopModeView on VideoLoopMode {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      VideoLoopMode.never => l10n.videoLoopModeNever,
      VideoLoopMode.shortOnly => l10n.videoLoopModeShortOnly,
      VideoLoopMode.always => l10n.videoLoopModeAlways,
    };
  }
}

extension ExtraVideoResumptionModeView on VideoResumptionMode {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      VideoResumptionMode.never => l10n.videoResumptionModeNever,
      VideoResumptionMode.ask => l10n.settingsAskEverytime,
      VideoResumptionMode.always => l10n.videoResumptionModeAlways,
    };
  }
}

extension ExtraViewerTransitionView on ViewerTransition {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ViewerTransition.slide => l10n.viewerTransitionSlide,
      ViewerTransition.parallax => l10n.viewerTransitionParallax,
      ViewerTransition.fade => l10n.viewerTransitionFade,
      ViewerTransition.zoomIn => l10n.viewerTransitionZoomIn,
      ViewerTransition.none => l10n.viewerTransitionNone,
      ViewerTransition.random => l10n.widgetDisplayedItemRandom,
    };
  }
}

extension ExtraWidgetDisplayedItemView on WidgetDisplayedItem {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      WidgetDisplayedItem.random => l10n.widgetDisplayedItemRandom,
      WidgetDisplayedItem.mostRecent => l10n.widgetDisplayedItemMostRecent,
    };
  }
}

extension ExtraWidgetOpenPageView on WidgetOpenPage {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      WidgetOpenPage.home => l10n.widgetOpenPageHome,
      WidgetOpenPage.collection => l10n.widgetOpenPageCollection,
      WidgetOpenPage.viewer => l10n.widgetOpenPageViewer,
      WidgetOpenPage.updateWidget => l10n.widgetTapUpdateWidget,
    };
  }
}
