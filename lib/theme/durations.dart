import 'package:flutter/foundation.dart';

class Durations {
  // Flutter animations (with margin)
  static const popupMenuAnimation = Duration(milliseconds: 300 + 20); // ref `_kMenuDuration` used in `_PopupMenuRoute`
  // page transition duration also available via `ModalRoute.of(context)!.transitionDuration * timeDilation`
  static const pageTransitionAnimation = Duration(milliseconds: 300 + 20); // ref `transitionDuration` used in `MaterialRouteTransitionMixin`
  static const dialogTransitionAnimation = Duration(milliseconds: 150 + 20); // ref `transitionDuration` used in `DialogRoute`
  static const drawerTransitionAnimation = Duration(milliseconds: 246 + 20); // ref `_kBaseSettleDuration` used in `DrawerControllerState`
  static const toggleableTransitionAnimation = Duration(milliseconds: 200 + 20); // ref `_kToggleDuration` used in `ToggleableStateMixin`

  // common animations
  static const sweeperOpacityAnimation = Duration(milliseconds: 150);
  static const sweepingAnimation = Duration(milliseconds: 650);
  static const dialogFieldReachAnimation = Duration(milliseconds: 300);

  static const appBarTitleAnimation = Duration(milliseconds: 300);
  static const appBarActionChangeAnimation = Duration(milliseconds: 200);

  // filter grids animations
  static const chipDecorationAnimation = Duration(milliseconds: 200);
  static const highlightScrollAnimationMinMillis = 400;
  static const highlightScrollAnimationMaxMillis = 2000;
  static const scalingGridBackgroundAnimation = Duration(milliseconds: 200);
  static const scalingGridPositionAnimation = Duration(milliseconds: 150);

  // collection animations
  static const filterBarRemovalAnimation = Duration(milliseconds: 400);
  static const collectionOpOverlayAnimation = Duration(milliseconds: 300);
  static const sectionHeaderAnimation = Duration(milliseconds: 200);
  static const thumbnailOverlayAnimation = Duration(milliseconds: 200);

  // search animations
  static const filterRowExpandAnimation = Duration(milliseconds: 300);

  // viewer animations
  static const thumbnailScrollerScrollAnimation = Duration(milliseconds: 200);
  static const thumbnailScrollerShadeAnimation = Duration(milliseconds: 150);
  static const viewerVideoPlayerTransition = Duration(milliseconds: 500);
  static const viewerActionFeedbackAnimation = Duration(milliseconds: 600);
  static const viewerHorizontalPageAnimation = Duration(seconds: 1);

  // info animations
  static const mapStyleSwitchAnimation = Duration(milliseconds: 300);
  static const xmpStructArrayCardTransition = Duration(milliseconds: 300);
  static const tagEditorTransition = Duration(milliseconds: 200);

  // settings animations
  static const themeColorModeAnimation = Duration(milliseconds: 400);
  static const quickActionListAnimation = Duration(milliseconds: 200);
  static const quickActionHighlightAnimation = Duration(milliseconds: 200);

  // delays & refresh intervals
  static const opToastTextDisplay = Duration(seconds: 3);
  static const opToastActionDisplay = Duration(seconds: 5);
  static const infoScrollMonitoringTimerDelay = Duration(milliseconds: 100);
  static const collectionScrollMonitoringTimerDelay = Duration(milliseconds: 100);
  static const highlightJumpDelay = Duration(milliseconds: 400);
  static const highlightScrollInitDelay = Duration(milliseconds: 800);
  static const motionPhotoAutoPlayDelay = Duration(milliseconds: 700);
  static const videoOverlayHideDelay = Duration(milliseconds: 500);
  static const videoProgressTimerInterval = Duration(milliseconds: 300);
  static const doubleBackTimerDelay = Duration(milliseconds: 1000);
  static const softKeyboardDisplayDelay = Duration(milliseconds: 300);
  static const searchDebounceDelay = Duration(milliseconds: 250);
  static const mediaContentChangeDebounceDelay = Duration(milliseconds: 1000);
  static const viewerThumbnailScrollDebounceDelay = Duration(milliseconds: 1000);
  static const mapInfoDebounceDelay = Duration(milliseconds: 150);
  static const mapIdleDebounceDelay = Duration(milliseconds: 100);
}

@immutable
class DurationsData {
  // common animations
  final Duration expansionTileAnimation;
  final Duration formTransition;
  final Duration formTextStyleTransition;
  final Duration textDiffAnimation;
  final Duration chartTransition;
  final Duration iconAnimation;
  final Duration staggeredAnimation;
  final Duration staggeredAnimationPageTarget;
  final Duration quickChooserAnimation;
  final Duration tvImageFocusAnimation;

  // viewer animations
  final Duration viewerVerticalPageScrollAnimation;
  final Duration viewerOverlayAnimation;
  final Duration viewerOverlayChangeAnimation;

  // delays & refresh intervals
  final Duration staggeredAnimationDelay;

  const DurationsData({
    this.expansionTileAnimation = const Duration(milliseconds: 200),
    this.formTransition = const Duration(milliseconds: 200),
    this.formTextStyleTransition = const Duration(milliseconds: 800),
    this.textDiffAnimation = const Duration(milliseconds: 150),
    this.chartTransition = const Duration(milliseconds: 400),
    this.iconAnimation = const Duration(milliseconds: 300),
    this.staggeredAnimation = const Duration(milliseconds: 375),
    this.staggeredAnimationPageTarget = const Duration(milliseconds: 800),
    this.quickChooserAnimation = const Duration(milliseconds: 100),
    this.tvImageFocusAnimation = const Duration(milliseconds: 150),
    this.viewerVerticalPageScrollAnimation = const Duration(milliseconds: 500),
    this.viewerOverlayAnimation = const Duration(milliseconds: 200),
    this.viewerOverlayChangeAnimation = const Duration(milliseconds: 150),
  }) : staggeredAnimationDelay = staggeredAnimation ~/ 6;

  factory DurationsData.noAnimation() {
    return DurationsData(
      // as of Flutter v2.5.1, `ExpansionPanelList` throws if animation duration is zero
      expansionTileAnimation: const Duration(microseconds: 1),
      formTransition: Duration.zero,
      formTextStyleTransition: Duration.zero,
      textDiffAnimation: Duration.zero,
      chartTransition: Duration.zero,
      iconAnimation: Duration.zero,
      staggeredAnimation: Duration.zero,
      staggeredAnimationPageTarget: Duration.zero,
      quickChooserAnimation: Duration.zero,
      tvImageFocusAnimation: Duration.zero,
      viewerVerticalPageScrollAnimation: Duration.zero,
      viewerOverlayAnimation: Duration.zero,
      viewerOverlayChangeAnimation: Duration.zero,
    );
  }
}
