import 'package:aves/model/settings/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Durations {
  // Flutter animations (with margin)
  static const popupMenuAnimation = Duration(milliseconds: 300 + 10); // ref `_kMenuDuration` used in `_PopupMenuRoute`
  // page transition duration also available via `ModalRoute.of(context)!.transitionDuration * timeDilation`
  static const pageTransitionAnimation = Duration(milliseconds: 300 + 10); // ref `transitionDuration` used in `MaterialRouteTransitionMixin`
  static const dialogTransitionAnimation = Duration(milliseconds: 150 + 10); // ref `transitionDuration` used in `DialogRoute`
  static const drawerTransitionAnimation = Duration(milliseconds: 246 + 10); // ref `_kBaseSettleDuration` used in `DrawerControllerState`
  static const toggleableTransitionAnimation = Duration(milliseconds: 200 + 10); // ref `_kToggleDuration` used in `ToggleableStateMixin`

  // common animations
  static const iconAnimation = Duration(milliseconds: 300);
  static const sweeperOpacityAnimation = Duration(milliseconds: 150);
  static const sweepingAnimation = Duration(milliseconds: 650);

  // static const staggeredAnimation = Duration(milliseconds: 375);
  // static const staggeredAnimationPageTarget = Duration(milliseconds: 800);
  static const dialogFieldReachAnimation = Duration(milliseconds: 300);

  static const appBarTitleAnimation = Duration(milliseconds: 300);
  static const appBarActionChangeAnimation = Duration(milliseconds: 200);

  // drawer
  static const newsBadgeAnimation = Duration(milliseconds: 200);

  // filter grids animations
  static const chipDecorationAnimation = Duration(milliseconds: 200);
  static const highlightScrollAnimationMinMillis = 400;
  static const highlightScrollAnimationMaxMillis = 2000;

  // collection animations
  static const filterBarRemovalAnimation = Duration(milliseconds: 400);
  static const collectionOpOverlayAnimation = Duration(milliseconds: 300);
  static const collectionScalingBackgroundAnimation = Duration(milliseconds: 200);
  static const sectionHeaderAnimation = Duration(milliseconds: 200);
  static const thumbnailOverlayAnimation = Duration(milliseconds: 200);

  // search animations
  static const filterRowExpandAnimation = Duration(milliseconds: 300);

  // viewer animations
  static const viewerVerticalPageScrollAnimation = Duration(milliseconds: 500);
  static const viewerOverlayAnimation = Duration(milliseconds: 200);
  static const viewerOverlayChangeAnimation = Duration(milliseconds: 150);
  static const thumbnailScrollerScrollAnimation = Duration(milliseconds: 200);
  static const thumbnailScrollerShadeAnimation = Duration(milliseconds: 150);
  static const viewerVideoPlayerTransition = Duration(milliseconds: 500);

  // info animations
  static const mapStyleSwitchAnimation = Duration(milliseconds: 300);
  static const xmpStructArrayCardTransition = Duration(milliseconds: 300);

  // settings animations
  static const quickActionListAnimation = Duration(milliseconds: 200);
  static const quickActionHighlightAnimation = Duration(milliseconds: 200);

  // delays & refresh intervals
  static const opToastTextDisplay = Duration(seconds: 3);
  static const opToastActionDisplay = Duration(seconds: 5);
  static const infoScrollMonitoringTimerDelay = Duration(milliseconds: 100);
  static const collectionScrollMonitoringTimerDelay = Duration(milliseconds: 100);
  static const highlightJumpDelay = Duration(milliseconds: 400);
  static const highlightScrollInitDelay = Duration(milliseconds: 800);
  static const videoOverlayHideDelay = Duration(milliseconds: 500);
  static const videoProgressTimerInterval = Duration(milliseconds: 300);

  // static Duration staggeredAnimationDelay = Durations.staggeredAnimation ~/ 6 * timeDilation;
  static const doubleBackTimerDelay = Duration(milliseconds: 1000);
  static const softKeyboardDisplayDelay = Duration(milliseconds: 300);
  static const searchDebounceDelay = Duration(milliseconds: 250);
  static const contentChangeDebounceDelay = Duration(milliseconds: 1000);
  static const mapInfoDebounceDelay = Duration(milliseconds: 150);
  static const mapIdleDebounceDelay = Duration(milliseconds: 100);

  // app life
  static const lastVersionCheckInterval = Duration(days: 7);
}

class DurationsProvider extends StatelessWidget {
  final Widget child;

  const DurationsProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<Settings, DurationsData>(
      update: (_, settings, __) {
        final enabled = settings.accessibilityAnimations.enabled;
        return enabled ? DurationsData() : DurationsData.noAnimation();
      },
      child: child,
    );
  }
}

@immutable
class DurationsData {
  // common animations
  final Duration expansionTileAnimation;
  final Duration staggeredAnimation;
  final Duration staggeredAnimationPageTarget;

  // delays & refresh intervals
  final Duration staggeredAnimationDelay;

  const DurationsData({
    this.expansionTileAnimation = const Duration(milliseconds: 200),
    this.staggeredAnimation = const Duration(milliseconds: 375),
    this.staggeredAnimationPageTarget = const Duration(milliseconds: 800),
  }) : staggeredAnimationDelay = staggeredAnimation ~/ 6;

  factory DurationsData.noAnimation() {
    return DurationsData(
      expansionTileAnimation: const Duration(microseconds: 1), // as of Flutter v2.5.1, `ExpansionPanelList` throws if animation duration is zero
      staggeredAnimation: Duration.zero,
      staggeredAnimationPageTarget: Duration.zero,
    );
  }
}
