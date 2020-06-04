import 'dart:io';
import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/common/action_delegates/entry_action_delegate.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';
import 'package:aves/widgets/fullscreen/image_page.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:aves/widgets/fullscreen/overlay/bottom.dart';
import 'package:aves/widgets/fullscreen/overlay/top.dart';
import 'package:aves/widgets/fullscreen/overlay/video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

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

class FullscreenBodyState extends State<FullscreenBody> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  ImageEntry _entry;
  int _currentHorizontalPage;
  ValueNotifier<int> _currentVerticalPage;
  PageController _horizontalPager, _verticalPager;
  final AChangeNotifier _verticalScrollNotifier = AChangeNotifier();
  final ValueNotifier<bool> _overlayVisible = ValueNotifier(true);
  AnimationController _overlayAnimationController;
  Animation<double> _topOverlayScale, _bottomOverlayScale;
  Animation<Offset> _bottomOverlayOffset;
  EdgeInsets _frozenViewInsets, _frozenViewPadding;
  EntryActionDelegate _actionDelegate;
  final List<Tuple2<String, IjkMediaController>> _videoControllers = [];

  CollectionLens get collection => widget.collection;

  bool get hasCollection => collection != null;

  List<ImageEntry> get entries => hasCollection ? collection.sortedEntries : [widget.initialEntry];

  List<String> get pages => ['transition', 'image', 'info'];

  int get transitionPage => pages.indexOf('transition');

  int get imagePage => pages.indexOf('image');

  int get infoPage => pages.indexOf('info');

  @override
  void initState() {
    super.initState();
    _entry = widget.initialEntry;
    _currentHorizontalPage = max(0, entries.indexOf(_entry));
    _currentVerticalPage = ValueNotifier(imagePage);
    _horizontalPager = PageController(initialPage: _currentHorizontalPage);
    _verticalPager = PageController(initialPage: _currentVerticalPage.value)..addListener(_onVerticalPageControllerChange);
    _overlayAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _actionDelegate = EntryActionDelegate(
      collection: collection,
      showInfo: () => _goToVerticalPage(infoPage),
    );
    WidgetsBinding.instance.addObserver(this);
    _initVideoController();
    _initOverlay();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(FullscreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    _overlayVisible.removeListener(_onOverlayVisibleChange);
    _videoControllers.forEach((kv) => kv.item2.dispose());
    _videoControllers.clear();
    _verticalPager.removeListener(_onVerticalPageControllerChange);
    WidgetsBinding.instance.removeObserver(this);
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(FullscreenBody widget) {
    widget.collection?.addListener(_onCollectionChange);
  }

  void _unregisterWidget(FullscreenBody widget) {
    widget.collection?.removeListener(_onCollectionChange);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseVideoControllers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topOverlay = ValueListenableBuilder<int>(
      valueListenable: _currentVerticalPage,
      builder: (context, page, child) {
        final showOverlay = _entry != null && page == imagePage;
        return showOverlay
            ? FullscreenTopOverlay(
                entries: entries,
                index: _currentHorizontalPage,
                scale: _topOverlayScale,
                canToggleFavourite: hasCollection,
                viewInsets: _frozenViewInsets,
                viewPadding: _frozenViewPadding,
                onActionSelected: (action) => _actionDelegate.onActionSelected(context, _entry, action),
              )
            : const SizedBox.shrink();
      },
    );

    final videoController = _entry != null && _entry.isVideo ? _videoControllers.firstWhere((kv) => kv.item1 == _entry.uri, orElse: () => null)?.item2 : null;
    Widget bottomOverlay = Column(
      children: [
        if (videoController != null)
          VideoControlOverlay(
            entry: _entry,
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
    );
    bottomOverlay = ValueListenableBuilder<double>(
      valueListenable: _overlayAnimationController,
      builder: (context, animation, child) {
        return Visibility(
          visible: _entry != null && _overlayAnimationController.status != AnimationStatus.dismissed,
          child: child,
        );
      },
      child: bottomOverlay,
    );

    bottomOverlay = Selector<MediaQueryData, double>(
      selector: (c, mq) => mq.size.height,
      builder: (c, mqHeight, child) {
        // when orientation change, the `PageController` offset is not updated right away
        // and it does not trigger its listeners when it does, so we force a refresh in the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) => _onVerticalPageControllerChange());
        return AnimatedBuilder(
          animation: _verticalScrollNotifier,
          builder: (context, child) => Positioned(
            bottom: (_verticalPager.offset ?? 0) - mqHeight,
            child: child,
          ),
          child: child,
        );
      },
      child: bottomOverlay,
    );

    return WillPopScope(
      onWillPop: () {
        if (_currentVerticalPage.value == infoPage) {
          // back from info to image
          _goToVerticalPage(imagePage);
          return SynchronousFuture(false);
        }
        _onLeave();
        return SynchronousFuture(true);
      },
      child: NotificationListener(
        onNotification: (notification) {
          if (notification is FilterNotification) _goToCollection(notification.filter);
          return false;
        },
        child: Stack(
          children: [
            FullscreenVerticalPageView(
              collection: collection,
              entry: _entry,
              videoControllers: _videoControllers,
              verticalPager: _verticalPager,
              horizontalPager: _horizontalPager,
              onVerticalPageChanged: _onVerticalPageChanged,
              onHorizontalPageChanged: _onHorizontalPageChanged,
              onImageTap: () => _overlayVisible.value = !_overlayVisible.value,
              onImagePageRequested: () => _goToVerticalPage(imagePage),
            ),
            topOverlay,
            bottomOverlay,
          ],
        ),
      ),
    );
  }

  void _onVerticalPageControllerChange() {
    _verticalScrollNotifier.notifyListeners();
  }

  void _goToCollection(CollectionFilter filter) {
    _showSystemUI();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionPage(collection.derive(filter)),
      ),
      (route) => false,
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

  void _onHorizontalPageChanged(int page) {
    _currentHorizontalPage = page;
    _updateEntry();
  }

  void _onCollectionChange() {
    _updateEntry();
  }

  void _updateEntry() {
    final newEntry = _currentHorizontalPage != null && _currentHorizontalPage < entries.length ? entries[_currentHorizontalPage] : null;
    if (_entry == newEntry) return;
    _entry = newEntry;
    _pauseVideoControllers();
    _initVideoController();
    setState(() {});
  }

  void _onLeave() {
    if (!ModalRoute.of(context).canPop) {
      // exit app when trying to pop a fullscreen page that is a viewer for a single entry
      exit(0);
    }
    _showSystemUI();
  }

  // system UI

  static void _showSystemUI() => SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

  static void _hideSystemUI() => SystemChrome.setEnabledSystemUIOverlays([]);

  // overlay

  Future<void> _initOverlay() async {
    // wait for MaterialPageRoute.transitionDuration
    // to show overlay after hero animation is complete
    await Future.delayed(Duration(milliseconds: (300 * timeDilation).toInt()));
    await _onOverlayVisibleChange();
  }

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
      setState(() {
        _frozenViewInsets = null;
        _frozenViewPadding = null;
      });
    }
  }

  // video controller

  void _pauseVideoControllers() => _videoControllers.forEach((e) => e.item2.pause());

  Future<void> _initVideoController() async {
    if (_entry == null || !_entry.isVideo) return;

    final uri = _entry.uri;
    var controllerEntry = _videoControllers.firstWhere((kv) => kv.item1 == uri, orElse: () => null);
    if (controllerEntry != null) {
      _videoControllers.remove(controllerEntry);
    } else {
      // do not set data source of IjkMediaController here
      controllerEntry = Tuple2(uri, IjkMediaController());
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
  final List<Tuple2<String, IjkMediaController>> videoControllers;
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
  final ValueNotifier<Color> _backgroundColorNotifier = ValueNotifier(Colors.black);
  final ValueNotifier<bool> _infoPageVisibleNotifier = ValueNotifier(false);

  CollectionLens get collection => widget.collection;

  bool get hasCollection => collection != null;

  ImageEntry get entry => widget.entry;

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
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(FullscreenVerticalPageView widget) {
    widget.verticalPager.addListener(_onVerticalPageControllerChanged);
    widget.entry?.imageChangeNotifier?.addListener(_onImageChanged);
  }

  void _unregisterWidget(FullscreenVerticalPageView widget) {
    widget.verticalPager.removeListener(_onVerticalPageControllerChanged);
    widget.entry?.imageChangeNotifier?.removeListener(_onImageChanged);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // fake page for opacity transition between collection and fullscreen views
      const SizedBox(),
      hasCollection
          ? MultiImagePage(
              collection: collection,
              pageController: widget.horizontalPager,
              onTap: widget.onImageTap,
              onPageChanged: widget.onHorizontalPageChanged,
              videoControllers: widget.videoControllers,
            )
          : SingleImagePage(
              entry: entry,
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
          entry: entry,
          visibleNotifier: _infoPageVisibleNotifier,
        ),
      ),
    ];
    return ValueListenableBuilder<Color>(
      valueListenable: _backgroundColorNotifier,
      builder: (context, backgroundColor, child) => Container(
        color: backgroundColor,
        child: child,
      ),
      child: PageView(
        scrollDirection: Axis.vertical,
        controller: widget.verticalPager,
        physics: const PhotoViewPageViewScrollPhysics(parent: PageScrollPhysics()),
        onPageChanged: (page) {
          widget.onVerticalPageChanged(page);
          _infoPageVisibleNotifier.value = page == pages.length - 1;
        },
        children: pages,
      ),
    );
  }

  void _onVerticalPageControllerChanged() {
    final opacity = min(1.0, widget.verticalPager.page);
    _backgroundColorNotifier.value = _backgroundColorNotifier.value.withOpacity(opacity * opacity);
  }

  void _onImageChanged() async {
    await UriImage(uri: entry.uri, mimeType: entry.mimeType).evict();
    // TODO TLAD also evict `ThumbnailProvider` with specified extents
    await ThumbnailProvider(entry: entry).evict();
    if (entry.path != null) await FileImage(File(entry.path)).evict();
    // rebuild to refresh the Image inside ImagePage
    setState(() {});
  }
}
