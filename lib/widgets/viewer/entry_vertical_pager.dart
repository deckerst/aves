import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/catalog.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/viewer/action/entry_action_delegate.dart';
import 'package:aves/widgets/viewer/controls/controller.dart';
import 'package:aves/widgets/viewer/controls/intents.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves/widgets/viewer/controls/shortcuts.dart';
import 'package:aves/widgets/viewer/entry_horizontal_pager.dart';
import 'package:aves/widgets/viewer/info/info_page.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class ViewerVerticalPageView extends StatefulWidget {
  final CollectionLens? collection;
  final ValueNotifier<AvesEntry?> entryNotifier;
  final ViewerController viewerController;
  final Animation<double> overlayOpacity;
  final PageController horizontalPager, verticalPager;
  final void Function(int page) onVerticalPageChanged, onHorizontalPageChanged;
  final VoidCallback onImagePageRequested;
  final void Function(AvesEntry mainEntry, AvesEntry? pageEntry) onViewDisposed;

  const ViewerVerticalPageView({
    super.key,
    required this.collection,
    required this.entryNotifier,
    required this.viewerController,
    required this.overlayOpacity,
    required this.verticalPager,
    required this.horizontalPager,
    required this.onVerticalPageChanged,
    required this.onHorizontalPageChanged,
    required this.onImagePageRequested,
    required this.onViewDisposed,
  });

  @override
  State<ViewerVerticalPageView> createState() => _ViewerVerticalPageViewState();
}

class _ViewerVerticalPageViewState extends State<ViewerVerticalPageView> {
  final List<StreamSubscription> _subscriptions = [];
  final ValueNotifier<double> _backgroundOpacityNotifier = ValueNotifier(1);
  final ValueNotifier<bool> _isVerticallyScrollingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isImageFocusedNotifier = ValueNotifier(true);
  Timer? _verticalScrollMonitoringTimer;
  AvesEntry? _oldEntry;
  Future<double>? _systemBrightness;

  CollectionLens? get collection => widget.collection;

  bool get hasCollection => collection != null;

  AvesEntry? get entry => widget.entryNotifier.value;

  static const double maximumBrightness = 1.0;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);

    if (settings.maxBrightness == MaxBrightness.viewerOnly) {
      _systemBrightness = ScreenBrightness().system;
    }
  }

  @override
  void didUpdateWidget(covariant ViewerVerticalPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _stopScrollMonitoringTimer();
    _backgroundOpacityNotifier.dispose();
    _isVerticallyScrollingNotifier.dispose();
    _isImageFocusedNotifier.dispose();
    super.dispose();
  }

  void _registerWidget(ViewerVerticalPageView widget) {
    _subscriptions.add(widget.viewerController.showNextCommands.listen((event) {
      _goToHorizontalPage(1, animate: true);
    }));
    _subscriptions.add(widget.viewerController.overlayCommands.listen((event) {
      ToggleOverlayNotification(visible: event.visible).dispatch(context);
    }));
    widget.verticalPager.addListener(_onVerticalPageControllerChanged);
    widget.entryNotifier.addListener(_onEntryChanged);
    if (_oldEntry != entry) _onEntryChanged();
  }

  void _unregisterWidget(ViewerVerticalPageView widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    widget.verticalPager.removeListener(_onVerticalPageControllerChanged);
    widget.entryNotifier.removeListener(_onEntryChanged);
    _oldEntry?.visualChangeNotifier.removeListener(_onVisualChanged);
  }

  @override
  Widget build(BuildContext context) {
    // fake page for opacity transition between collection and viewer
    const transitionPage = SizedBox();

    final pages = [
      transitionPage,
      _buildImagePage(),
    ];

    final appMode = context.read<ValueNotifier<AppMode>>().value;
    if (!{AppMode.screenSaver, AppMode.slideshow}.contains(appMode)) {
      final infoPage = NotificationListener<ShowImageNotification>(
        onNotification: (notification) {
          widget.onImagePageRequested();
          return true;
        },
        child: AnimatedBuilder(
          animation: widget.verticalPager,
          builder: (context, child) {
            return Visibility(
              visible: widget.verticalPager.page! > 1,
              child: child!,
            );
          },
          child: FocusScope(
            child: InfoPage(
              collection: collection,
              entryNotifier: widget.entryNotifier,
              isScrollingNotifier: _isVerticallyScrollingNotifier,
            ),
          ),
        ),
      );

      pages.add(infoPage);
    }

    return ValueListenableBuilder<double>(
      valueListenable: _backgroundOpacityNotifier,
      builder: (context, backgroundOpacity, child) {
        return ValueListenableBuilder<double>(
          valueListenable: widget.overlayOpacity,
          builder: (context, overlayOpacity, child) {
            final background = Theme.of(context).brightness == Brightness.dark ? Colors.black : Color.lerp(Colors.black, Colors.white, overlayOpacity)!;
            return Container(
              color: background.withOpacity(backgroundOpacity),
              child: child,
            );
          },
          child: child,
        );
      },
      child: PageView(
        // key is expected by test driver
        key: const Key('vertical-pageview'),
        scrollDirection: Axis.vertical,
        controller: widget.verticalPager,
        physics: MagnifierScrollerPhysics(
          gestureSettings: context.select<MediaQueryData, DeviceGestureSettings>((mq) => mq.gestureSettings),
          parent: const PageScrollPhysics(),
        ),
        onPageChanged: widget.onVerticalPageChanged,
        children: pages,
      ),
    );
  }

  Widget _buildImagePage() {
    final useTvLayout = settings.useTvLayout;

    Map<ShortcutActivator, Intent>? shortcuts = {
      ...ViewerShortcuts.entryActions,
      ...ViewerShortcuts.media,
      const SingleActivator(LogicalKeyboardKey.arrowUp): useTvLayout ? const TvShowLessInfoIntent() : const LeaveIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowDown): useTvLayout ? const TvShowMoreInfoIntent() : const ShowInfoIntent(),
    };

    Widget? child;
    if (hasCollection) {
      shortcuts.addAll(const {
        SingleActivator(LogicalKeyboardKey.arrowLeft): ShowPreviousIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): ShowNextIntent(),
      });
      child = MultiEntryScroller(
        collection: collection!,
        viewerController: widget.viewerController,
        pageController: widget.horizontalPager,
        onPageChanged: widget.onHorizontalPageChanged,
        onViewDisposed: widget.onViewDisposed,
      );
    } else if (entry != null) {
      child = SingleEntryScroller(
        viewerController: widget.viewerController,
        entry: entry!,
      );
    }
    if (child != null) {
      if (settings.useTvLayout) {
        child = ValueListenableBuilder<bool>(
          valueListenable: _isImageFocusedNotifier,
          builder: (context, isImageFocused, child) {
            return AnimatedScale(
              scale: isImageFocused ? 1 : .6,
              curve: Curves.fastOutSlowIn,
              duration: context.select<DurationsData, Duration>((v) => v.tvImageFocusAnimation),
              child: child!,
            );
          },
          child: child,
        );
      }

      return FocusableActionDetector(
        autofocus: true,
        shortcuts: shortcuts,
        actions: {
          ShowPreviousIntent: CallbackAction<Intent>(onInvoke: (intent) => _goToHorizontalPage(-1, animate: false)),
          ShowNextIntent: CallbackAction<Intent>(onInvoke: (intent) => _goToHorizontalPage(1, animate: false)),
          LeaveIntent: CallbackAction<Intent>(onInvoke: (intent) => Navigator.maybeOf(context)?.pop()),
          ShowInfoIntent: CallbackAction<Intent>(onInvoke: (intent) => ShowInfoPageNotification().dispatch(context)),
          TvShowLessInfoIntent: CallbackAction<Intent>(onInvoke: (intent) => TvShowLessInfoNotification().dispatch(context)),
          TvShowMoreInfoIntent: CallbackAction<Intent>(onInvoke: (intent) => TvShowMoreInfoNotification().dispatch(context)),
          PlayPauseIntent: CallbackAction<PlayPauseIntent>(onInvoke: _onPlayPauseIntent),
          EntryActionIntent: CallbackAction<EntryActionIntent>(onInvoke: (intent) => _onEntryActionIntent(intent.action)),
          ActivateIntent: CallbackAction<Intent>(onInvoke: (intent) {
            if (useTvLayout) {
              final _entry = entry;
              if (_entry != null && _entry.isVideo) {
                // address `TV-PC` requirement from https://developer.android.com/docs/quality-guidelines/tv-app-quality
                final controller = context.read<VideoConductor>().getController(_entry);
                if (controller != null) {
                  VideoActionNotification(
                    controller: controller,
                    entry: _entry,
                    action: EntryAction.videoTogglePlay,
                  ).dispatch(context);
                }
              } else {
                const ToggleOverlayNotification().dispatch(context);
              }
            }
            return null;
          }),
        },
        onFocusChange: (focused) => _isImageFocusedNotifier.value = focused,
        child: child,
      );
    }
    return const SizedBox();
  }

  void _onEntryActionIntent(EntryAction action) {
    final mainEntry = entry;
    if (mainEntry != null) {
      AvesEntry? pageEntry;
      final multiPageController = context.read<MultiPageConductor>().getController(mainEntry);
      if (multiPageController != null) {
        pageEntry = multiPageController.info?.getPageEntryByIndex(multiPageController.page);
      }
      final appMode = context.read<ValueNotifier<AppMode>>().value;
      final actionDelegate = EntryActionDelegate(mainEntry, pageEntry ?? mainEntry, collection);
      if (actionDelegate.isVisible(appMode: appMode, action: action) && actionDelegate.canApply(action)) {
        actionDelegate.onActionSelected(context, action);
      }
    }
  }

  void _goToHorizontalPage(int delta, {required bool animate}) {
    final pageController = widget.horizontalPager;
    final page = pageController.page?.round();
    final _collection = collection;
    if (page != null && _collection != null) {
      var target = page + delta;
      if (!widget.viewerController.repeat) {
        target = target.clamp(0, _collection.entryCount - 1);
      }
      if (animate) {
        pageController.animateToPage(
          target,
          duration: Durations.viewerHorizontalPageAnimation,
          curve: Curves.easeInOutCubic,
        );
      } else {
        pageController.jumpToPage(target);
      }
    }
  }

  void _onVerticalPageControllerChanged() {
    final page = widget.verticalPager.page!;

    final opacity = min(1.0, page);
    _backgroundOpacityNotifier.value = opacity * opacity;

    if (settings.maxBrightness == MaxBrightness.viewerOnly) {
      _systemBrightness?.then((system) {
        final value = lerpDouble(maximumBrightness, system, ((1 - page).abs() * 2).clamp(0, 1))!;
        ScreenBrightness().setScreenBrightness(value);
      });
    }

    _isVerticallyScrollingNotifier.value = true;
    _stopScrollMonitoringTimer();
    _verticalScrollMonitoringTimer = Timer(Durations.infoScrollMonitoringTimerDelay, () {
      _isVerticallyScrollingNotifier.value = false;
    });
  }

  void _stopScrollMonitoringTimer() {
    _verticalScrollMonitoringTimer?.cancel();
  }

  // when the entry changed (e.g. by scrolling through the PageView, or if the entry got deleted)
  Future<void> _onEntryChanged() async {
    _oldEntry?.visualChangeNotifier.removeListener(_onVisualChanged);
    _oldEntry = entry;

    final _entry = entry;
    if (_entry != null) {
      _entry.visualChangeNotifier.addListener(_onVisualChanged);
      // make sure to locate the entry,
      // so that we can display the address instead of coordinates
      // even when initial collection locating has not reached this entry yet
      await _entry.catalog(background: false, force: false, persist: true);
      await _entry.locate(background: false, force: false, geocoderLocale: settings.appliedLocale);
    } else {
      Navigator.maybeOf(context)?.pop();
    }

    // needed to refresh when entry changes but the page does not (e.g. on page deletion)
    if (mounted) {
      setState(() {});
    }
  }

  // when the entry image itself changed (e.g. after rotation)
  void _onVisualChanged() async {
    // rebuild to refresh the Image inside ImagePage
    if (mounted) {
      setState(() {});
    }
  }

  void _onPlayPauseIntent(PlayPauseIntent intent) {
    // address `TV-PP` requirement from https://developer.android.com/docs/quality-guidelines/tv-app-quality
    final _entry = entry;
    if (_entry != null && _entry.isVideo) {
      final controller = context.read<VideoConductor>().getController(_entry);
      if (controller != null) {
        bool toggle;
        switch (intent.type) {
          case TvPlayPauseType.play:
            toggle = !controller.isPlaying;
            break;
          case TvPlayPauseType.pause:
            toggle = controller.isPlaying;
            break;
          case TvPlayPauseType.toggle:
            toggle = true;
            break;
        }
        if (toggle) {
          VideoActionNotification(
            controller: controller,
            entry: _entry,
            action: EntryAction.videoTogglePlay,
          ).dispatch(context);
        }
      }
    }
  }
}
