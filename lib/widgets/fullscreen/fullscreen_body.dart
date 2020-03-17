import 'dart:io';
import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/fullscreen/fullscreen_action_delegate.dart';
import 'package:aves/widgets/fullscreen/image_page.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:aves/widgets/fullscreen/overlay/bottom.dart';
import 'package:aves/widgets/fullscreen/overlay/top.dart';
import 'package:aves/widgets/fullscreen/overlay/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:video_player/video_player.dart';

class FullscreenBody extends StatefulWidget {
  final CollectionLens collection;
  final ImageEntry initialEntry;

  const FullscreenBody({
    Key key,
    this.collection,
    this.initialEntry,
  }) : super(key: key);

  @override
  FullscreenBodyState createState() => FullscreenBodyState();
}

class FullscreenBodyState extends State<FullscreenBody> with SingleTickerProviderStateMixin {
  int _currentHorizontalPage;
  ValueNotifier<int> _currentVerticalPage;
  PageController _horizontalPager, _verticalPager;
  final ValueNotifier<bool> _overlayVisible = ValueNotifier(true);
  AnimationController _overlayAnimationController;
  Animation<double> _topOverlayScale, _bottomOverlayScale;
  Animation<Offset> _bottomOverlayOffset;
  EdgeInsets _frozenViewInsets, _frozenViewPadding;
  FullscreenActionDelegate _actionDelegate;
  final List<Tuple2<String, VideoPlayerController>> _videoControllers = [];

  CollectionLens get collection => widget.collection;

  bool get hasCollection => collection != null;

  List<ImageEntry> get entries => hasCollection ? collection.sortedEntries : [widget.initialEntry];

  List<String> get pages => hasCollection ? ['transition', 'image', 'info'] : ['image', 'info'];

  int get transitionPage => pages.indexOf('transition');

  int get imagePage => pages.indexOf('image');

  int get infoPage => pages.indexOf('info');

  @override
  void initState() {
    super.initState();
    _currentHorizontalPage = max(0, entries.indexOf(widget.initialEntry));
    _currentVerticalPage = ValueNotifier(imagePage);
    _horizontalPager = PageController(initialPage: _currentHorizontalPage);
    _verticalPager = PageController(initialPage: _currentVerticalPage.value);
    _overlayAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _topOverlayScale = CurvedAnimation(
      parent: _overlayAnimationController,
      // a little bounce at the top
      curve: Curves.easeOutBack,
    );
    _bottomOverlayScale = CurvedAnimation(
      parent: _overlayAnimationController,
      // no bounce at the bottom, to avoid video controller displacement
      curve: Curves.easeOutQuad,
    );
    _bottomOverlayOffset = Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOutQuad,
    ));
    _overlayVisible.addListener(_onOverlayVisibleChange);
    _actionDelegate = FullscreenActionDelegate(
      collection: collection,
      showInfo: () => _goToVerticalPage(infoPage),
    );
    _initVideoController();
    _initOverlay();
  }

  Future<void> _initOverlay() async {
    // wait for MaterialPageRoute.transitionDuration
    // to show overlay after hero animation is complete
    await Future.delayed(Duration(milliseconds: (300 * timeDilation).toInt()));
    await _onOverlayVisibleChange();
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    _overlayVisible.removeListener(_onOverlayVisibleChange);
    _videoControllers.forEach((kv) => kv.item2.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = _currentHorizontalPage != null && _currentHorizontalPage < entries.length ? entries[_currentHorizontalPage] : null;
    return WillPopScope(
      onWillPop: () {
        if (_currentVerticalPage.value == infoPage) {
          // back from info to image
          _goToVerticalPage(imagePage);
          return Future.value(false);
        }
        if (!ModalRoute.of(context).canPop) {
          // exit app when trying to pop a fullscreen page that is a viewer for a single entry
          exit(0);
        }
        _onLeave();
        return Future.value(true);
      },
      child: Stack(
        children: [
          FullscreenVerticalPageView(
            collection: collection,
            entry: entry,
            videoControllers: _videoControllers,
            verticalPager: _verticalPager,
            horizontalPager: _horizontalPager,
            onVerticalPageChanged: _onVerticalPageChanged,
            onHorizontalPageChanged: _onHorizontalPageChanged,
            onImageTap: () => _overlayVisible.value = !_overlayVisible.value,
            onImagePageRequested: () => _goToVerticalPage(imagePage),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _currentVerticalPage,
            builder: (context, page, child) {
              final showOverlay = entry != null && page == imagePage;
              return showOverlay
                  ? FullscreenTopOverlay(
                      entries: entries,
                      index: _currentHorizontalPage,
                      scale: _topOverlayScale,
                      viewInsets: _frozenViewInsets,
                      viewPadding: _frozenViewPadding,
                      onActionSelected: (action) => _actionDelegate.onActionSelected(context, entry, action),
                    )
                  : const SizedBox.shrink();
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: _currentVerticalPage,
            builder: (context, page, child) {
              final showOverlay = entry != null && page == imagePage;
              final videoController = showOverlay && entry.isVideo ? _videoControllers.firstWhere((kv) => kv.item1 == entry.uri, orElse: () => null)?.item2 : null;
              return showOverlay
                  ? Positioned(
                      bottom: 0,
                      child: Column(
                        children: [
                          if (videoController != null)
                            VideoControlOverlay(
                              entry: entry,
                              controller: videoController,
                              scale: _bottomOverlayScale,
                              viewInsets: _frozenViewInsets,
                              viewPadding: _frozenViewPadding,
                            ),
                          SlideTransition(
                            position: _bottomOverlayOffset,
                            child: FullscreenBottomOverlay(
                              entries: entries,
                              index: _currentHorizontalPage,
                              showPosition: hasCollection,
                              viewInsets: _frozenViewInsets,
                              viewPadding: _frozenViewPadding,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _goToVerticalPage(int page) {
    return _verticalPager.animateToPage(
      page,
      duration: Duration(milliseconds: (300 * timeDilation).toInt()),
      curve: Curves.easeInOut,
    );
  }

  void _onVerticalPageChanged(int page) {
    _currentVerticalPage.value = page;
    if (page == transitionPage) {
      _onLeave();
      Navigator.pop(context);
    }
  }

  void _onLeave() => _showSystemUI();

  void _showSystemUI() => SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

  void _hideSystemUI() => SystemChrome.setEnabledSystemUIOverlays([]);

  Future<void> _onOverlayVisibleChange() async {
    if (_overlayVisible.value) {
      _showSystemUI();
      _overlayAnimationController.forward();
    } else {
      final mediaQuery = Provider.of<MediaQueryData>(context, listen: false);
      setState(() {
        _frozenViewInsets = mediaQuery.viewInsets;
        _frozenViewPadding = mediaQuery.viewPadding;
      });
      _hideSystemUI();
      await _overlayAnimationController.reverse();
      _frozenViewInsets = null;
      _frozenViewPadding = null;
    }
  }

  void _onHorizontalPageChanged(int page) {
    _currentHorizontalPage = page;
    _pauseVideoControllers();
    _initVideoController();
    setState(() {});
  }

  void _pauseVideoControllers() => _videoControllers.forEach((e) => e.item2.pause());

  void _initVideoController() {
    final entry = _currentHorizontalPage != null && _currentHorizontalPage < entries.length ? entries[_currentHorizontalPage] : null;
    if (entry == null || !entry.isVideo) return;

    final uri = entry.uri;
    var controllerEntry = _videoControllers.firstWhere((kv) => kv.item1 == uri, orElse: () => null);
    if (controllerEntry != null) {
      _videoControllers.remove(controllerEntry);
    } else {
      final controller = VideoPlayerController.uri(uri)..initialize();
      controllerEntry = Tuple2(uri, controller);
    }
    _videoControllers.insert(0, controllerEntry);
    while (_videoControllers.length > 3) {
      _videoControllers.removeLast().item2.dispose();
    }
  }
}

class FullscreenVerticalPageView extends StatefulWidget {
  final CollectionLens collection;
  final ImageEntry entry;
  final List<Tuple2<String, VideoPlayerController>> videoControllers;
  final PageController horizontalPager, verticalPager;
  final void Function(int page) onVerticalPageChanged, onHorizontalPageChanged;
  final VoidCallback onImageTap, onImagePageRequested;

  const FullscreenVerticalPageView({
    @required this.collection,
    @required this.entry,
    @required this.videoControllers,
    @required this.verticalPager,
    @required this.horizontalPager,
    @required this.onVerticalPageChanged,
    @required this.onHorizontalPageChanged,
    @required this.onImageTap,
    @required this.onImagePageRequested,
  });

  @override
  _FullscreenVerticalPageViewState createState() => _FullscreenVerticalPageViewState();
}

class _FullscreenVerticalPageViewState extends State<FullscreenVerticalPageView> {
  bool _isInitialScale = true;
  ValueNotifier<Color> _backgroundColorNotifier = ValueNotifier(Colors.black);
  ValueNotifier<bool> _infoPageVisibleNotifier = ValueNotifier(false);

  CollectionLens get collection => widget.collection;

  bool get hasCollection => collection != null;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(FullscreenVerticalPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    super.dispose();
    _unregisterWidget(widget);
  }

  void _registerWidget(FullscreenVerticalPageView widget) {
    widget.verticalPager.addListener(_onVerticalPageControllerChange);
    widget.entry.imageChangeNotifier.addListener(_onImageChange);
  }

  void _unregisterWidget(FullscreenVerticalPageView widget) {
    widget.verticalPager.removeListener(_onVerticalPageControllerChange);
    widget.entry.imageChangeNotifier.removeListener(_onImageChange);
  }

  void _onVerticalPageControllerChange() {
    _backgroundColorNotifier.value = _backgroundColorNotifier.value.withOpacity(min(1.0, widget.verticalPager.page));
  }

  void _onImageChange() async {
    await FileImage(File(widget.entry.path)).evict();
    // rebuild to refresh the Image inside ImagePage
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final onScaleChanged = (state) => setState(() => _isInitialScale = state == PhotoViewScaleState.initial);
    final pages = [
      // fake page for opacity transition between collection and fullscreen views
      if (hasCollection)
        const SizedBox(),
      hasCollection
          ? MultiImagePage(
              collection: collection,
              pageController: widget.horizontalPager,
              onTap: widget.onImageTap,
              onPageChanged: widget.onHorizontalPageChanged,
              onScaleChanged: onScaleChanged,
              videoControllers: widget.videoControllers,
            )
          : SingleImagePage(
              entry: widget.entry,
              onScaleChanged: onScaleChanged,
              onTap: widget.onImageTap,
              videoControllers: widget.videoControllers,
            ),
      NotificationListener(
        onNotification: (notification) {
          if (notification is BackUpNotification) widget.onImagePageRequested();
          return false;
        },
        child: InfoPage(
          collection: collection,
          entry: widget.entry,
          visibleNotifier: _infoPageVisibleNotifier,
        ),
      ),
    ];
    return ValueListenableBuilder(
      valueListenable: _backgroundColorNotifier,
      builder: (context, backgroundColor, child) => Container(
        color: backgroundColor,
        child: child,
      ),
      child: PageView(
        scrollDirection: Axis.vertical,
        controller: widget.verticalPager,
        physics: _isInitialScale ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          widget.onVerticalPageChanged(page);
          _infoPageVisibleNotifier.value = page == pages.length - 1;
        },
        children: pages,
      ),
    );
  }
}
