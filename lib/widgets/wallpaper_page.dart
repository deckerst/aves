import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/viewer/controller.dart';
import 'package:aves/widgets/viewer/entry_horizontal_pager.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/notifications.dart';
import 'package:aves/widgets/viewer/overlay/bottom.dart';
import 'package:aves/widgets/viewer/overlay/video/video.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:aves/widgets/viewer/video_action_delegate.dart';
import 'package:aves/widgets/viewer/visual/controller_mixin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class WallpaperPage extends StatelessWidget {
  static const routeName = '/set_wallpaper';

  final AvesEntry? entry;

  const WallpaperPage({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: entry != null
            ? ViewStateConductorProvider(
                child: VideoConductorProvider(
                  child: MultiPageConductorProvider(
                    child: EntryEditor(
                      entry: entry!,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

class EntryEditor extends StatefulWidget {
  final AvesEntry entry;

  const EntryEditor({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  State<EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<EntryEditor> with EntryViewControllerMixin, SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _overlayVisible = ValueNotifier(true);
  late AnimationController _overlayAnimationController;
  late Animation<double> _overlayVideoControlScale;
  EdgeInsets? _frozenViewInsets, _frozenViewPadding;
  late VideoActionDelegate _videoActionDelegate;
  late final ViewerController _viewerController;

  @override
  final ValueNotifier<AvesEntry?> entryNotifier = ValueNotifier(null);

  AvesEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    if (!settings.viewerUseCutout) {
      windowService.setCutoutMode(false);
    }
    if (settings.viewerMaxBrightness) {
      ScreenBrightness().setScreenBrightness(1);
    }
    if (settings.keepScreenOn == KeepScreenOn.viewerOnly) {
      windowService.keepScreenOn(true);
    }

    entryNotifier.value = entry;
    _overlayAnimationController = AnimationController(
      duration: context.read<DurationsData>().viewerOverlayAnimation,
      vsync: this,
    );
    _overlayVideoControlScale = CurvedAnimation(
      parent: _overlayAnimationController,
      // no bounce at the bottom, to avoid video controller displacement
      curve: Curves.easeOutQuad,
    );
    _overlayVisible.addListener(_onOverlayVisibleChange);
    _videoActionDelegate = VideoActionDelegate(
      collection: null,
    );

    _viewerController = ViewerController(
      initialScale: const ScaleLevel(ref: ScaleReference.covered),
    );
    initEntryControllers(entry);
    _onOverlayVisibleChange();
  }

  @override
  void dispose() {
    cleanEntryControllers(entry);
    _viewerController.dispose();
    _videoActionDelegate.dispose();
    _overlayAnimationController.dispose();
    _overlayVisible.removeListener(_onOverlayVisibleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (dynamic notification) {
        if (notification is ToggleOverlayNotification) {
          _overlayVisible.value = notification.visible ?? !_overlayVisible.value;
        }
        return true;
      },
      child: Stack(
        children: [
          SingleEntryScroller(
            entry: entry,
            viewerController: _viewerController,
          ),
          Positioned(
            bottom: 0,
            child: _buildBottomOverlay(),
          ),
          const TopGestureAreaProtector(),
          const SideGestureAreaProtector(),
          const BottomGestureAreaProtector(),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay() {
    final mainEntry = entry;
    final multiPageController = mainEntry.isMultiPage ? context.read<MultiPageConductor>().getController(mainEntry) : null;

    Widget? _buildExtraBottomOverlay({AvesEntry? pageEntry}) {
      final targetEntry = pageEntry ?? mainEntry;
      Widget? child;
      // a 360 video is both a video and a panorama but only the video controls are displayed
      if (targetEntry.isVideo) {
        child = Selector<VideoConductor, AvesVideoController?>(
          selector: (context, vc) => vc.getController(targetEntry),
          builder: (context, videoController, child) => VideoControlOverlay(
            entry: targetEntry,
            controller: videoController,
            scale: _overlayVideoControlScale,
            onActionSelected: (action) {
              if (videoController != null) {
                _videoActionDelegate.onActionSelected(context, videoController, action);
              }
            },
            onActionMenuOpened: () {
              // if the menu is opened while overlay is hiding,
              // the popup menu button is disposed and menu items are ineffective,
              // so we make sure overlay stays visible
              _videoActionDelegate.stopOverlayHidingTimer();
              const ToggleOverlayNotification(visible: true).dispatch(context);
            },
          ),
        );
      }
      return child != null
          ? ExtraBottomOverlay(
              viewInsets: _frozenViewInsets,
              viewPadding: _frozenViewPadding,
              child: child,
            )
          : null;
    }

    final extraBottomOverlay = mainEntry.isMultiPage
        ? PageEntryBuilder(
            multiPageController: multiPageController,
            builder: (pageEntry) => _buildExtraBottomOverlay(pageEntry: pageEntry) ?? const SizedBox(),
          )
        : _buildExtraBottomOverlay();

    final child = TooltipTheme(
      data: TooltipTheme.of(context).copyWith(
        preferBelow: false,
      ),
      child: Column(
        children: [
          if (extraBottomOverlay != null) extraBottomOverlay,
          ViewerBottomOverlay(
            entries: [widget.entry],
            index: 0,
            hasCollection: false,
            animationController: _overlayAnimationController,
            viewInsets: _frozenViewInsets,
            viewPadding: _frozenViewPadding,
            multiPageController: multiPageController,
          ),
        ],
      ),
    );

    return ValueListenableBuilder<double>(
      valueListenable: _overlayAnimationController,
      builder: (context, animation, child) {
        return Visibility(
          visible: !_overlayAnimationController.isDismissed,
          child: child!,
        );
      },
      child: child,
    );
  }

  // overlay

  Future<void> _onOverlayVisibleChange({bool animate = true}) async {
    if (_overlayVisible.value) {
      AvesApp.showSystemUI();
      if (animate) {
        await _overlayAnimationController.forward();
      } else {
        _overlayAnimationController.value = _overlayAnimationController.upperBound;
      }
    } else {
      final mediaQuery = context.read<MediaQueryData>();
      setState(() {
        _frozenViewInsets = mediaQuery.viewInsets;
        _frozenViewPadding = mediaQuery.viewPadding;
      });
      AvesApp.hideSystemUI();
      if (animate) {
        await _overlayAnimationController.reverse();
      } else {
        _overlayAnimationController.reset();
      }
      setState(() {
        _frozenViewInsets = null;
        _frozenViewPadding = null;
      });
    }
  }
}
