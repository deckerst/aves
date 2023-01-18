import 'dart:math';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/viewer/controller.dart';
import 'package:aves/widgets/viewer/entry_vertical_pager.dart';
import 'package:aves/widgets/viewer/hero.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/notifications.dart';
import 'package:aves/widgets/viewer/overlay/bottom.dart';
import 'package:aves/widgets/viewer/overlay/panorama.dart';
import 'package:aves/widgets/viewer/overlay/slideshow_buttons.dart';
import 'package:aves/widgets/viewer/overlay/top.dart';
import 'package:aves/widgets/viewer/overlay/video/video.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:aves/widgets/viewer/video_action_delegate.dart';
import 'package:aves/widgets/viewer/visual/conductor.dart';
import 'package:aves/widgets/viewer/visual/controller_mixin.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class EntryViewerStack extends StatefulWidget {
  final CollectionLens? collection;
  final AvesEntry initialEntry;
  final ViewerController viewerController;

  const EntryViewerStack({
    super.key,
    this.collection,
    required this.initialEntry,
    required this.viewerController,
  });

  @override
  State<EntryViewerStack> createState() => _EntryViewerStackState();
}

class _EntryViewerStackState extends State<EntryViewerStack> with EntryViewControllerMixin, FeedbackMixin, SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late int _currentEntryIndex;
  late ValueNotifier<int> _currentVerticalPage;
  late PageController _horizontalPager, _verticalPager;
  final AChangeNotifier _verticalScrollNotifier = AChangeNotifier();
  bool _overlayInitialized = false;
  final ValueNotifier<bool> _overlayVisible = ValueNotifier(true);
  late AnimationController _overlayAnimationController;
  late Animation<double> _overlayButtonScale, _overlayVideoControlScale, _overlayOpacity;
  late Animation<Offset> _overlayTopOffset;
  EdgeInsets? _frozenViewInsets, _frozenViewPadding;
  late VideoActionDelegate _videoActionDelegate;
  final ValueNotifier<HeroInfo?> _heroInfoNotifier = ValueNotifier(null);
  bool _isEntryTracked = true;

  @override
  bool get isViewingImage => _currentVerticalPage.value == imagePage;

  @override
  late final ValueNotifier<AvesEntry?> entryNotifier;

  ViewerController get viewerController => widget.viewerController;

  CollectionLens? get collection => widget.collection;

  bool get hasCollection => collection != null;

  List<AvesEntry> get entries => hasCollection ? collection!.sortedEntries : [widget.initialEntry];

  static const int transitionPage = 0;

  static const int imagePage = 1;

  static const int infoPage = 2;

  @override
  void initState() {
    super.initState();
    if (settings.viewerMaxBrightness) {
      ScreenBrightness().setScreenBrightness(1);
    }
    if (settings.keepScreenOn == KeepScreenOn.viewerOnly) {
      windowService.keepScreenOn(true);
    }

    // make sure initial entry is actually among the filtered collection entries
    // `initialEntry` may be a dynamic burst entry from another collection lens
    // so it is, strictly speaking, not contained in the lens used by the viewer,
    // but it can be found by content ID
    final initialEntry = widget.initialEntry;
    final entry = entries.firstWhereOrNull((entry) => entry.id == initialEntry.id) ?? entries.firstOrNull;
    // opening hero, with viewer as target
    _heroInfoNotifier.value = HeroInfo(collection?.id, entry);
    entryNotifier = viewerController.entryNotifier;
    entryNotifier.value = entry;
    _currentEntryIndex = max(0, entry != null ? entries.indexOf(entry) : -1);
    _currentVerticalPage = ValueNotifier(imagePage);
    _horizontalPager = PageController(initialPage: _currentEntryIndex);
    _verticalPager = PageController(initialPage: _currentVerticalPage.value)..addListener(_onVerticalPageControllerChanged);
    _overlayAnimationController = AnimationController(
      duration: context.read<DurationsData>().viewerOverlayAnimation,
      vsync: this,
    );
    _overlayButtonScale = CurvedAnimation(
      parent: _overlayAnimationController,
      // a little bounce at the top
      curve: Curves.easeOutBack,
    );
    _overlayVideoControlScale = CurvedAnimation(
      parent: _overlayAnimationController,
      // no bounce at the bottom, to avoid video controller displacement
      curve: Curves.easeOutQuad,
    );
    _overlayOpacity = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOutQuad,
    );
    _overlayTopOffset = Tween(begin: const Offset(0, -1), end: const Offset(0, 0)).animate(CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOutQuad,
    ));
    _overlayVisible.value = settings.showOverlayOnOpening && !viewerController.autopilot;
    _overlayVisible.addListener(_onOverlayVisibleChanged);
    _videoActionDelegate = VideoActionDelegate(
      collection: collection,
    );
    initEntryControllers(entry);
    _registerWidget(widget);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initOverlay());
  }

  @override
  void didUpdateWidget(covariant EntryViewerStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    cleanEntryControllers(entryNotifier.value);
    _videoActionDelegate.dispose();
    _overlayAnimationController.dispose();
    _overlayVisible.removeListener(_onOverlayVisibleChanged);
    _verticalPager.removeListener(_onVerticalPageControllerChanged);
    WidgetsBinding.instance.removeObserver(this);
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(EntryViewerStack widget) {
    widget.collection?.addListener(_onCollectionChanged);
  }

  void _unregisterWidget(EntryViewerStack widget) {
    widget.collection?.removeListener(_onCollectionChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        viewerController.autopilot = false;
        pauseVideoControllers();
        break;
      case AppLifecycleState.resumed:
        availability.onResume();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewStateConductor = context.read<ViewStateConductor>();
    return WillPopScope(
      onWillPop: () {
        _onWillPop();
        return SynchronousFuture(false);
      },
      child: ValueListenableProvider<HeroInfo?>.value(
        value: _heroInfoNotifier,
        child: NotificationListener(
          onNotification: _handleNotification,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableSize = Size(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                children: [
                  ViewerVerticalPageView(
                    collection: collection,
                    entryNotifier: entryNotifier,
                    viewerController: viewerController,
                    overlayOpacity: _overlayInitialized
                        ? _overlayOpacity
                        : settings.showOverlayOnOpening
                            ? kAlwaysCompleteAnimation
                            : kAlwaysDismissedAnimation,
                    verticalPager: _verticalPager,
                    horizontalPager: _horizontalPager,
                    onVerticalPageChanged: _onVerticalPageChanged,
                    onHorizontalPageChanged: _onHorizontalPageChanged,
                    onImagePageRequested: () => _goToVerticalPage(imagePage),
                    onViewDisposed: (mainEntry, pageEntry) => viewStateConductor.reset(pageEntry ?? mainEntry),
                  ),
                  ..._buildOverlays(availableSize).map(_decorateOverlay),
                  const TopGestureAreaProtector(),
                  const SideGestureAreaProtector(),
                  const BottomGestureAreaProtector(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _decorateOverlay(Widget overlay) {
    return ValueListenableBuilder<double>(
      valueListenable: _overlayAnimationController,
      builder: (context, animation, child) {
        return Visibility(
          visible: !_overlayAnimationController.isDismissed,
          child: child!,
        );
      },
      child: overlay,
    );
  }

  List<Widget> _buildOverlays(Size availableSize) {
    final appMode = context.read<ValueNotifier<AppMode>>().value;
    switch (appMode) {
      case AppMode.screenSaver:
        return [];
      case AppMode.slideshow:
        return [
          _buildSlideshowBottomOverlay(availableSize),
        ];
      default:
        return [
          _buildViewerTopOverlay(availableSize),
          _buildViewerBottomOverlay(availableSize),
        ];
    }
  }

  Widget _buildSlideshowBottomOverlay(Size availableSize) {
    return SizedBox.fromSize(
      size: availableSize,
      child: Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: TooltipTheme(
          data: TooltipTheme.of(context).copyWith(
            preferBelow: false,
          ),
          child: SlideshowButtons(
            animationController: _overlayAnimationController,
          ),
        ),
      ),
    );
  }

  Widget _buildViewerTopOverlay(Size availableSize) {
    Widget child = ValueListenableBuilder<AvesEntry?>(
      valueListenable: entryNotifier,
      builder: (context, mainEntry, child) {
        if (mainEntry == null) return const SizedBox();

        return SlideTransition(
          position: _overlayTopOffset,
          child: ViewerTopOverlay(
            entries: entries,
            index: _currentEntryIndex,
            hasCollection: hasCollection,
            mainEntry: mainEntry,
            scale: _overlayButtonScale,
            availableSize: availableSize,
            viewInsets: _frozenViewInsets,
            viewPadding: _frozenViewPadding,
          ),
        );
      },
    );

    child = ValueListenableBuilder<int>(
      valueListenable: _currentVerticalPage,
      builder: (context, page, child) {
        return Visibility(
          visible: page == imagePage,
          child: child!,
        );
      },
      child: child,
    );

    return child;
  }

  Widget _buildViewerBottomOverlay(Size availableSize) {
    Widget child = ValueListenableBuilder<AvesEntry?>(
      valueListenable: entryNotifier,
      builder: (context, mainEntry, child) {
        if (mainEntry == null) return const SizedBox();

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
                    _onVideoAction(context, videoController, action);
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
          } else if (targetEntry.is360) {
            child = PanoramaOverlay(
              entry: targetEntry,
              scale: _overlayButtonScale,
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

        return TooltipTheme(
          data: TooltipTheme.of(context).copyWith(
            preferBelow: false,
          ),
          child: Column(
            children: [
              if (extraBottomOverlay != null) extraBottomOverlay,
              ViewerBottomOverlay(
                entries: entries,
                index: _currentEntryIndex,
                collection: collection,
                animationController: _overlayAnimationController,
                availableSize: availableSize,
                viewInsets: _frozenViewInsets,
                viewPadding: _frozenViewPadding,
                multiPageController: multiPageController,
              ),
            ],
          ),
        );
      },
    );

    child = Selector<MediaQueryData, double>(
      selector: (context, mq) => mq.size.height,
      builder: (context, mqHeight, child) {
        // when orientation change, the `PageController` offset is not updated right away
        // and it does not trigger its listeners when it does, so we force a refresh in the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) => _onVerticalPageControllerChanged());
        return AnimatedBuilder(
          animation: _verticalScrollNotifier,
          builder: (context, child) => Positioned(
            bottom: (_verticalPager.hasClients && _verticalPager.position.hasPixels ? _verticalPager.offset : 0) - availableSize.height,
            child: child!,
          ),
          child: child,
        );
      },
      child: child,
    );

    return child;
  }

  bool _handleNotification(dynamic notification) {
    if (notification is FilterSelectedNotification) {
      _goToCollection(notification.filter);
    } else if (notification is EntryDeletedNotification) {
      _onEntryRemoved(context, notification.entries);
    } else if (notification is EntryMovedNotification) {
      // only add or remove entries following user actions,
      // instead of applying all collection source changes
      final isBin = collection?.filters.contains(TrashFilter.instance) ?? false;
      final entries = notification.entries;
      switch (notification.moveType) {
        case MoveType.move:
          _onEntryRemoved(context, entries);
          break;
        case MoveType.toBin:
          if (!isBin) {
            _onEntryRemoved(context, entries);
          }
          break;
        case MoveType.fromBin:
          if (isBin) {
            _onEntryRemoved(context, entries);
          } else {
            _onEntryRestored(entries);
          }
          break;
        case MoveType.copy:
        case MoveType.export:
          break;
      }
    } else if (notification is ToggleOverlayNotification) {
      _overlayVisible.value = notification.visible ?? !_overlayVisible.value;
    } else if (notification is TvShowLessInfoNotification) {
      if (_overlayVisible.value) {
        _overlayVisible.value = false;
      } else {
        _onWillPop();
      }
    } else if (notification is TvShowMoreInfoNotification) {
      if (!_overlayVisible.value) {
        _overlayVisible.value = true;
      }
    } else if (notification is ShowInfoPageNotification) {
      _goToVerticalPage(infoPage);
    } else if (notification is JumpToPreviousEntryNotification) {
      _jumpToHorizontalPageByDelta(-1);
    } else if (notification is JumpToNextEntryNotification) {
      _jumpToHorizontalPageByDelta(1);
    } else if (notification is JumpToEntryNotification) {
      _jumpToHorizontalPageByIndex(notification.index);
    } else if (notification is VideoActionNotification) {
      final controller = notification.controller;
      final action = notification.action;
      _onVideoAction(context, controller, action);
    } else {
      return false;
    }
    return true;
  }

  Future<void> _onVideoAction(BuildContext context, AvesVideoController controller, EntryAction action) async {
    await _videoActionDelegate.onActionSelected(context, controller, action);
    if (action == EntryAction.videoToggleMute) {
      final override = controller.isMuted;
      videoMutedOverride = override;
      await context.read<VideoConductor>().muteAll(override);
    }
  }

  void _onVerticalPageControllerChanged() {
    if (!_isEntryTracked && _verticalPager.hasClients && _verticalPager.page?.floor() == transitionPage) {
      _trackEntry();
    }
    _verticalScrollNotifier.notify();
  }

  void _goToCollection(CollectionFilter filter) {
    final isMainMode = context.read<ValueNotifier<AppMode>>().value == AppMode.main;
    if (!isMainMode) return;

    final baseCollection = collection;
    if (baseCollection == null) return;

    _onLeave();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          source: baseCollection.source,
          filters: {...baseCollection.filters, filter},
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _goToVerticalPage(int page) async {
    final animationDuration = context.read<DurationsData>().viewerVerticalPageScrollAnimation;
    if (animationDuration > Duration.zero) {
      // duration & curve should feel similar to changing page by vertical fling
      await _verticalPager.animateToPage(
        page,
        duration: animationDuration,
        curve: Curves.easeOutQuart,
      );
    } else {
      _verticalPager.jumpToPage(page);
    }
  }

  void _onVerticalPageChanged(int page) {
    _currentVerticalPage.value = page;
    if (page == transitionPage) {
      dismissFeedback(context);
      _popVisual();
    } else if (page == infoPage) {
      // prevent hero when viewer is offscreen
      _heroInfoNotifier.value = null;
    }
  }

  void _jumpToHorizontalPageByDelta(int delta) {
    if (_horizontalPager.positions.isEmpty) return;

    final page = _horizontalPager.page?.round();
    if (page != null) {
      _jumpToHorizontalPageByIndex(page + delta);
    }
  }

  void _jumpToHorizontalPageByIndex(int target) {
    final _collection = collection;
    if (_collection != null) {
      if (!widget.viewerController.repeat) {
        target = target.clamp(0, _collection.entryCount - 1);
      }
      if (_currentEntryIndex != target) {
        _horizontalPager.jumpToPage(target);
      }
    }
  }

  void _onHorizontalPageChanged(int page) {
    _currentEntryIndex = page;
    if (viewerController.repeat) {
      _currentEntryIndex %= entries.length;
    }
    _updateEntry();
  }

  void _onCollectionChanged() {
    _updateEntry();
  }

  void _onEntryRestored(Set<AvesEntry> restoredEntries) {
    if (restoredEntries.isEmpty) return;

    final _collection = collection;
    if (_collection != null) {
      _collection.refresh();
      final index = _collection.sortedEntries.indexOf(restoredEntries.first);
      if (index != -1) {
        _onHorizontalPageChanged(index);
      }
      _onCollectionChanged();
    }
  }

  // deleted or moved to another album
  void _onEntryRemoved(BuildContext context, Set<AvesEntry> removedEntries) {
    if (removedEntries.isEmpty) return;

    if (hasCollection) {
      final collectionEntries = collection!.sortedEntries;
      removedEntries.forEach(collectionEntries.remove);
      if (collectionEntries.isNotEmpty) {
        _onCollectionChanged();
        return;
      }
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _leaveViewer();
    }
  }

  Future<void> _updateEntry() async {
    if (entries.isNotEmpty && _currentEntryIndex >= entries.length) {
      // as of Flutter v1.22.2, `PageView` does not call `onPageChanged` when the last page is deleted
      // so we manually track the page change, and let the entry update follow
      _onHorizontalPageChanged(entries.length - 1);
      return;
    }

    final newEntry = _currentEntryIndex < entries.length ? entries[_currentEntryIndex] : null;
    if (entryNotifier.value == newEntry) return;
    cleanEntryControllers(entryNotifier.value);
    entryNotifier.value = newEntry;
    _isEntryTracked = false;
    await pauseVideoControllers();
    await initEntryControllers(newEntry);
  }

  void _onWillPop() {
    if (_currentVerticalPage.value == infoPage) {
      // back from info to image
      _goToVerticalPage(imagePage);
    } else {
      if (!_isEntryTracked) _trackEntry();
      _popVisual();
    }
  }

  void _popVisual() {
    if (Navigator.canPop(context)) {
      void pop() {
        _onLeave();
        Navigator.pop(context);
      }

      // closing hero, with viewer as source
      final heroInfo = HeroInfo(collection?.id, entryNotifier.value);
      if (_heroInfoNotifier.value != heroInfo) {
        _heroInfoNotifier.value = heroInfo;
        // we post closing the viewer page so that hero animation source is ready
        WidgetsBinding.instance.addPostFrameCallback((_) => pop());
      } else {
        // viewer already has correct hero info, no need to rebuild
        pop();
      }
    } else {
      // exit app when trying to pop a viewer page
      _leaveViewer();
    }
  }

  Future<void> _leaveViewer() async {
    // widgets do not get disposed normally when popping the `SystemNavigator`
    // so we manually clean video controllers and save playback state
    await context.read<VideoConductor>().dispose();
    await SystemNavigator.pop();
  }

  // track item when returning to collection,
  // if they are not fully visible already
  void _trackEntry() {
    _isEntryTracked = true;
    final entry = entryNotifier.value;
    if (entry != null && hasCollection) {
      context.read<HighlightInfo>().trackItem(
            entry,
            predicate: (v) => v < 1,
            animate: false,
          );
    }
  }

  Future<void> _onLeave() async {
    await ScreenBrightness().resetScreenBrightness();
    if (settings.keepScreenOn == KeepScreenOn.viewerOnly) {
      await windowService.keepScreenOn(false);
    }
    await mediaSessionService.release();
    await AvesApp.showSystemUI();
    AvesApp.setSystemUIStyle(context);
    if (!settings.useTvLayout) {
      await windowService.requestOrientation();
    }
  }

  // overlay

  Future<void> _initOverlay() async {
    // wait for MaterialPageRoute.transitionDuration
    // to show overlay after hero animation is complete
    await Future.delayed(ModalRoute.of(context)!.transitionDuration * timeDilation);
    await _onOverlayVisibleChanged();
    _overlayInitialized = true;
  }

  Future<void> _onOverlayVisibleChanged({bool animate = true}) async {
    if (_overlayVisible.value) {
      await AvesApp.showSystemUI();
      AvesApp.setSystemUIStyle(context);
      if (animate) {
        await _overlayAnimationController.forward();
      } else {
        _overlayAnimationController.value = _overlayAnimationController.upperBound;
      }
      viewerController.autopilot = false;
    } else {
      final mediaQuery = context.read<MediaQueryData>();
      setState(() {
        _frozenViewInsets = mediaQuery.viewInsets;
        _frozenViewPadding = mediaQuery.viewPadding;
      });
      await AvesApp.hideSystemUI();
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
