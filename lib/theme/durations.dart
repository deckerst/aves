import 'package:flutter/foundation.dart';

class ADurations {
  // Flutter animations (with margin)
  static const transitionMarginMillis = 20;

  // page transition duration also available via `ModalRoute.of(context)!.transitionDuration * timeDilation`
  static const pageTransitionExact = Duration(milliseconds: 300); // ref `transitionDuration` used in `MaterialRouteTransitionMixin`
  static const pageTransitionLoose = Duration(milliseconds: 300 + transitionMarginMillis); // ref `transitionDuration` used in `MaterialRouteTransitionMixin`
  static const dialogTransitionLoose = Duration(milliseconds: 150 + transitionMarginMillis); // ref `transitionDuration` used in `DialogRoute`
  static const drawerTransitionLoose = Duration(milliseconds: 246 + transitionMarginMillis); // ref `_kBaseSettleDuration` used in `DrawerControllerState`
  static const toggleableTransitionLoose = Duration(milliseconds: 200 + transitionMarginMillis); // ref `_kToggleDuration` used in `ToggleableStateMixin`

  // common animations
  static const sweeperOpacityAnimation = Duration(milliseconds: 150);
  static const sweepingAnimation = Duration(milliseconds: 650);
  static const rotatorAnimation = Duration(milliseconds: 650);
  static const dialogFieldReachAnimation = Duration(milliseconds: 300);

  static const appBarTitleAnimation = Duration(milliseconds: 300);
  static const appBarActionChangeAnimation = Duration(milliseconds: 200);
  static const popupMenuAnimation = Duration(milliseconds: 300);

  // filter grids animations
  static const chipDecorationAnimation = Duration(milliseconds: 200);
  static const highlightScrollAnimationMinMillis = 400;
  static const highlightScrollAnimationMaxMillis = 2000;
  static const scalingGridBackgroundAnimation = Duration(milliseconds: 200);
  static const scalingGridPositionAnimation = Duration(milliseconds: 150);

  // collection animations
  static const filterBarRemovalAnimation = Duration(milliseconds: 400);
  static const collectionOpOverlayAnimation = Duration(milliseconds: 300);

  // search animations
  static const filterRowExpandAnimation = Duration(milliseconds: 300);
  static const searchBodyTransition = Duration(milliseconds: 300);

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
  static const appInactiveReactionDelay = Duration(milliseconds: 300);
  static const videoProgressTimerInterval = Duration(milliseconds: 300);
  static const doubleBackTimerDelay = Duration(milliseconds: 1000);
  static const softKeyboardDisplayDelay = Duration(milliseconds: 300);
  static const searchDebounceDelay = Duration(milliseconds: 250);
  static const mediaContentChangeDebounceDelay = Duration(milliseconds: 1000);
  static const mapInfoDebounceDelay = Duration(milliseconds: 150);
  static const mapIdleDebounceDelay = Duration(milliseconds: 100);
}

@immutable
class const DurationsData({
  // common animations
  final Duration expansionTileAnimation = const Duration(milliseconds: 200),
  final Duration formTransition = const Duration(milliseconds: 200),
  final Duration formTextStyleTransition = const Duration(milliseconds: 800),
  final Duration textDiffAnimation = const Duration(milliseconds: 150),
  final Duration chartTransition = const Duration(milliseconds: 400),
  final Duration iconAnimation = const Duration(milliseconds: 300),
  final Duration staggeredAnimation = const Duration(milliseconds: 375),
  final Duration staggeredAnimationPageTarget = const Duration(milliseconds: 800),
  final Duration quickChooserAnimation = const Duration(milliseconds: 100),
  final Duration tvImageFocusAnimation = const Duration(milliseconds: 150),
  // viewer animations
  final Duration viewerRouteTransitionDuration = ADurations.pageTransitionExact,
  final Duration viewerHorizontalPageScrollAnimation = const Duration(milliseconds: 400),
  final Duration viewerOverlayAnimation = const Duration(milliseconds: 200),
  final Duration viewerOverlayChangeAnimation = const Duration(milliseconds: 150),
}) {
  // delays & refresh intervals
  final Duration staggeredAnimationDelay = staggeredAnimation ~/ 6;

  factory noAnimation() {
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
      viewerRouteTransitionDuration: Duration.zero,
      viewerHorizontalPageScrollAnimation: Duration.zero,
      viewerOverlayAnimation: Duration.zero,
      viewerOverlayChangeAnimation: Duration.zero,
    );
  }
}
