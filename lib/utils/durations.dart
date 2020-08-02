import 'package:flutter/scheduler.dart';

class Durations {
  // common animations
  static const iconAnimation = Duration(milliseconds: 300);
  static const opToastAnimation = Duration(milliseconds: 600);
  static const sweeperOpacityAnimation = Duration(milliseconds: 150);
  static const sweepingAnimation = Duration(milliseconds: 650);
  static const popupMenuAnimation = Duration(milliseconds: 300); // ref _PopupMenuRoute._kMenuDuration
  static const staggeredAnimation = Duration(milliseconds: 375);

  // collection animations
  static const appBarTitleAnimation = Duration(milliseconds: 300);
  static const filterBarRemovalAnimation = Duration(milliseconds: 400);
  static const collectionOpOverlayAnimation = Duration(milliseconds: 300);
  static const collectionScalingBackgroundAnimation = Duration(milliseconds: 200);
  static const sectionHeaderAnimation = Duration(milliseconds: 200);
  static const thumbnailTransition = Duration(milliseconds: 200);
  static const thumbnailOverlayAnimation = Duration(milliseconds: 200);

  // search animations
  static const filterRowExpandAnimation = Duration(milliseconds: 300);

  // fullscreen animations
  static const fullscreenPageAnimation = Duration(milliseconds: 300);
  static const fullscreenOverlayAnimation = Duration(milliseconds: 200);

  // delays & refresh intervals
  static const opToastDisplay = Duration(seconds: 2);
  static const collectionScrollMonitoringTimerDelay = Duration(milliseconds: 100);
  static const collectionScalingCompleteNotificationDelay = Duration(milliseconds: 300);
  static const videoProgressTimerInterval = Duration(milliseconds: 300);
  static Duration staggeredAnimationDelay = Durations.staggeredAnimation ~/ 6 * timeDilation;
}
