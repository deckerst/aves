import 'dart:ui';

import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';

class SettingsDefaults {
  // video
  static const enableVideoHardwareAcceleration = true;
  static const videoAutoPlayMode = VideoAutoPlayMode.disabled;
  static const videoBackgroundMode = VideoBackgroundMode.disabled;
  static const videoLoopMode = VideoLoopMode.shortOnly;
  static const videoResumptionMode = VideoResumptionMode.ask;
  static const videoShowRawTimedText = false;
  static const videoControls = VideoControls.play;
  static const videoGestureDoubleTapTogglePlay = false;
  static const videoGestureSideDoubleTapSeek = true;
  static const videoGestureVerticalDragBrightnessVolume = false;

  // subtitles
  static const subtitleFontSize = 20.0;
  static const subtitleTextAlignment = TextAlign.center;
  static const subtitleTextPosition = SubtitlePosition.bottom;
  static const subtitleShowOutline = true;
  static const subtitleTextColor = Color(0xFFFFFFFF);
  static const subtitleBackgroundColor = ColorUtils.transparentBlack;
}
