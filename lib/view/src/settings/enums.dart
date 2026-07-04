import 'package:aves/utils/calendar/aves_locale.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraAccessibilityAnimationsView on AccessibilityAnimations {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .system => l10n.settingsSystemDefault,
      .disabled => l10n.accessibilityAnimationsRemove,
      .enabled => l10n.accessibilityAnimationsKeep,
    };
  }
}

extension ExtraAccessibilityTimeoutView on AccessibilityTimeout {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .system => l10n.settingsSystemDefault,
      .s1 => l10n.timeSeconds(1),
      .s3 => l10n.timeSeconds(3),
      .s5 => l10n.timeSeconds(5),
      .s10 => l10n.timeSeconds(10),
      .s30 => l10n.timeSeconds(30),
    };
  }
}

extension ExtraAvesThemeBrightnessView on AvesThemeBrightness {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .system => l10n.settingsSystemDefault,
      .light => l10n.themeBrightnessLight,
      .dark => l10n.themeBrightnessDark,
      .black => l10n.themeBrightnessBlack,
    };
  }
}

extension ExtraCalendarView on ACalendar {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .gregorian => l10n.calendarGregorian,
      .persian => l10n.calendarPersian,
      _ => name,
    };
  }
}

extension ExtraCoordinateFormatView on CoordinateFormat {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .dms => l10n.coordinateFormatDms,
      .ddm => l10n.coordinateFormatDdm,
      .decimal => l10n.coordinateFormatDecimal,
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
    if (this == EntryMapStyles.googleNormal) return l10n.mapStyleGoogleNormal;
    if (this == EntryMapStyles.googleHybrid) return l10n.mapStyleGoogleHybrid;
    if (this == EntryMapStyles.googleTerrain) return l10n.mapStyleGoogleTerrain;
    if (this == EntryMapStyles.osmLiberty) return l10n.mapStyleOsmLiberty;
    if (this == EntryMapStyles.openTopoMap) return l10n.mapStyleOpenTopoMap;
    if (this == EntryMapStyles.osmHot) return l10n.mapStyleOsmHot;
    if (this == EntryMapStyles.stamenWatercolor) return l10n.mapStyleStamenWatercolor;
    final _name = name;
    if (_name != null) return _name;
    throw Exception('Name is undefined for map style=$this');
  }
}

extension ExtraHomePageSettingView on HomePageSetting {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .collection => l10n.drawerCollectionAll,
      .albums => l10n.drawerAlbumPage,
      .tags => l10n.drawerTagPage,
      .explorer => l10n.explorerPageTitle,
    };
  }
}

extension ExtraKeepScreenOnView on KeepScreenOn {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .never => l10n.keepScreenOnNever,
      .videoPlayback => l10n.keepScreenOnVideoPlayback,
      .viewerOnly => l10n.keepScreenOnViewerOnly,
      .always => l10n.keepScreenOnAlways,
    };
  }
}

extension ExtraMaxBrightnessView on MaxBrightness {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .never => l10n.maxBrightnessNever,
      .viewerOnly => l10n.keepScreenOnViewerOnly,
      .always => l10n.maxBrightnessAlways,
    };
  }
}

extension ExtraSlideshowVideoPlaybackView on SlideshowVideoPlayback {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .skip => l10n.videoPlaybackSkip,
      .playMuted => l10n.videoPlaybackMuted,
      .playWithSound => l10n.videoPlaybackWithSound,
    };
  }
}

extension ExtraOverlayHistogramStyleView on OverlayHistogramStyle {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .none => l10n.overlayHistogramNone,
      .rgb => l10n.overlayHistogramRGB,
      .luminance => l10n.overlayHistogramLuminance,
    };
  }
}

extension ExtraSubtitlePositionView on SubtitlePosition {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .top => l10n.subtitlePositionTop,
      .bottom => l10n.subtitlePositionBottom,
    };
  }
}

extension ExtraUnitSystemView on UnitSystem {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .metric => l10n.unitSystemMetric,
      .imperial => l10n.unitSystemImperial,
    };
  }
}

extension ExtraVideoAutoPlayModeView on VideoAutoPlayMode {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .disabled => l10n.settingsDisabled,
      .playMuted => l10n.videoPlaybackMuted,
      .playWithSound => l10n.videoPlaybackWithSound,
    };
  }
}

extension ExtraVideoBackgroundModeView on VideoBackgroundMode {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .disabled => l10n.settingsDisabled,
      .pip => l10n.settingsVideoEnablePip,
    };
  }
}

extension ExtraVideoHardwareAccelerationView on VideoHardwareAcceleration {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .disabled => l10n.settingsDisabled,
      .enabled => l10n.settingsEnabled,
      .forced => l10n.settingsForced,
    };
  }
}

extension ExtraVideoLoopModeView on VideoLoopMode {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .never => l10n.videoLoopModeNever,
      .shortOnly => l10n.videoLoopModeShortOnly,
      .always => l10n.videoLoopModeAlways,
    };
  }
}

extension ExtraVideoResumptionModeView on VideoResumptionMode {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .never => l10n.videoResumptionModeNever,
      .ask => l10n.settingsAskEverytime,
      .always => l10n.videoResumptionModeAlways,
    };
  }
}

extension ExtraViewerTransitionView on ViewerTransition {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .slide => l10n.viewerTransitionSlide,
      .parallax => l10n.viewerTransitionParallax,
      .fade => l10n.viewerTransitionFade,
      .zoomIn => l10n.viewerTransitionZoomIn,
      .none => l10n.viewerTransitionNone,
      .random => l10n.widgetDisplayedItemRandom,
    };
  }
}

extension ExtraWidgetDisplayedItemView on WidgetDisplayedItem {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .random => l10n.widgetDisplayedItemRandom,
      .mostRecent => l10n.widgetDisplayedItemMostRecent,
    };
  }
}

extension ExtraWidgetOpenPageView on WidgetOpenPage {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .home => l10n.widgetOpenPageHome,
      .collection => l10n.widgetOpenPageCollection,
      .viewer => l10n.widgetOpenPageViewer,
      .updateWidget => l10n.widgetTapUpdateWidget,
    };
  }
}
