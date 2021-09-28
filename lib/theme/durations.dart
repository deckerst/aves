import 'package:aves/model/settings/accessibility_animations.dart';
import 'package:aves/model/settings/enums.dart';
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
  static const sweeperOpacityAnimation = Duration(milliseconds: 150);
  static const sweepingAnimation = Duration(milliseconds: 650);
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
  static const doubleBackTimerDelay = Duration(milliseconds: 1000);
  static const softKeyboardDisplayDelay = Duration(milliseconds: 300);
  static const searchDebounceDelay = Duration(milliseconds: 250);
  static const contentChangeDebounceDelay = Duration(milliseconds: 1000);
  static const mapInfoDebounceDelay = Duration(milliseconds: 150);
  static const mapIdleDebounceDelay = Duration(milliseconds: 100);

  // app life
  static const lastVersionCheckInterval = Duration(days: 7);
}

class DurationsProvider extends StatefulWidget {
  final Widget child;

  const DurationsProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _DurationsProviderState createState() => _DurationsProviderState();
}

class _DurationsProviderState extends State<DurationsProvider> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAccessibilityFeatures() {
    if (settings.accessibilityAnimations == AccessibilityAnimations.system) {
      // TODO TLAD update provider
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<Settings, DurationsData>(
      update: (context, settings, __) {
        final enabled = settings.accessibilityAnimations.animate;
        return enabled ? DurationsData() : DurationsData.noAnimation();
      },
      child: widget.child,
    );
  }
}

@immutable
class DurationsData {
  // common animations
  final Duration expansionTileAnimation;
  final Duration iconAnimation;
  final Duration staggeredAnimation;
  final Duration staggeredAnimationPageTarget;

  // viewer animations
  final Duration viewerVerticalPageScrollAnimation;
  final Duration viewerOverlayAnimation;
  final Duration viewerOverlayChangeAnimation;

  // delays & refresh intervals
  final Duration staggeredAnimationDelay;

  const DurationsData({
    this.expansionTileAnimation = const Duration(milliseconds: 200),
    this.iconAnimation = const Duration(milliseconds: 300),
    this.staggeredAnimation = const Duration(milliseconds: 375),
    this.staggeredAnimationPageTarget = const Duration(milliseconds: 800),
    this.viewerVerticalPageScrollAnimation = const Duration(milliseconds: 500),
    this.viewerOverlayAnimation = const Duration(milliseconds: 200),
    this.viewerOverlayChangeAnimation = const Duration(milliseconds: 150),
  }) : staggeredAnimationDelay = staggeredAnimation ~/ 6;

  factory DurationsData.noAnimation() {
    return DurationsData(
      // as of Flutter v2.5.1, `ExpansionPanelList` throws if animation duration is zero
      expansionTileAnimation: const Duration(microseconds: 1),
      iconAnimation: Duration.zero,
      staggeredAnimation: Duration.zero,
      staggeredAnimationPageTarget: Duration.zero,
      viewerVerticalPageScrollAnimation: Duration.zero,
      viewerOverlayAnimation: Duration.zero,
      viewerOverlayChangeAnimation: Duration.zero,
    );
  }
}
