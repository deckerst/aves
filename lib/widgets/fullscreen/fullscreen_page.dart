import 'dart:io';
import 'dart:math';

import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/media_query_data_provider.dart';
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

class FullscreenPage extends AnimatedWidget {
  final ImageCollection collection;
  final String initialUri;

  const FullscreenPage({
    Key key,
    this.collection,
    this.initialUri,
  }) : super(key: key, listenable: collection);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: FullscreenBody(
          collection: collection,
          initialUri: initialUri,
        ),
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

class FullscreenBody extends StatefulWidget {
  final ImageCollection collection;
  final String initialUri;

  const FullscreenBody({
    Key key,
    this.collection,
    this.initialUri,
  }) : super(key: key);

  @override
  FullscreenBodyState createState() => FullscreenBodyState();
}

class FullscreenBodyState extends State<FullscreenBody> with SingleTickerProviderStateMixin {
  bool _isInitialScale = true;
  int _currentHorizontalPage, _currentVerticalPage = imagePage;
  PageController _horizontalPager, _verticalPager;
  ValueNotifier<bool> _overlayVisible = ValueNotifier(true);
  AnimationController _overlayAnimationController;
  Animation<double> _topOverlayScale;
  Animation<Offset> _bottomOverlayOffset;
  EdgeInsets _frozenViewInsets, _frozenViewPadding;
  FullscreenActionDelegate _actionDelegate;
  List<Tuple2<String, VideoPlayerController>> _videoControllers = List();

  ImageCollection get collection => widget.collection;

  List<ImageEntry> get entries => widget.collection.sortedEntries;

  static const transitionPage = 0;
  static const imagePage = 1;
  static const infoPage = 2;

  @override
  void initState() {
    super.initState();
    final index = entries.indexWhere((entry) => entry.uri == widget.initialUri);
    _currentHorizontalPage = max(0, index);
    _horizontalPager = PageController(initialPage: _currentHorizontalPage);
    _verticalPager = PageController(initialPage: _currentVerticalPage);
    _overlayAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _topOverlayScale = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOutQuart,
    );
    _bottomOverlayOffset = Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOutQuart,
    ));
    _overlayVisible.addListener(_onOverlayVisibleChange);
    _actionDelegate = FullscreenActionDelegate(
      collection: collection,
      showInfo: () => _goToVerticalPage(infoPage),
    );
    _initVideoController();
    _initOverlay();
  }

  _initOverlay() async {
    // wait for MaterialPageRoute.transitionDuration
    // to show overlay after hero animation is complete
    await Future.delayed(Duration(milliseconds: (300 * timeDilation).toInt()));
    await _onOverlayVisibleChange();
  }

  @override
  void dispose() {
    _overlayVisible.removeListener(_onOverlayVisibleChange);
    _videoControllers.forEach((kv) => kv.item2.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = _currentHorizontalPage != null && _currentHorizontalPage < entries.length ? entries[_currentHorizontalPage] : null;
    return WillPopScope(
      onWillPop: () {
        if (_currentVerticalPage == infoPage) {
          _goToVerticalPage(imagePage);
          return Future.value(false);
        }
        _onLeave();
        return Future.value(true);
      },
      child: Stack(
        children: [
          PageView(
            scrollDirection: Axis.vertical,
            controller: _verticalPager,
            physics: _isInitialScale ? PageScrollPhysics() : NeverScrollableScrollPhysics(),
            onPageChanged: _onVerticalPageChanged,
            children: [
              SizedBox(),
              Container(
                color: Colors.black,
                child: ImagePage(
                  collection: collection,
                  pageController: _horizontalPager,
                  onTap: () => _overlayVisible.value = !_overlayVisible.value,
                  onPageChanged: _onHorizontalPageChanged,
                  onScaleChanged: (state) => setState(() => _isInitialScale = state == PhotoViewScaleState.initial),
                  videoControllers: _videoControllers,
                ),
              ),
              NotificationListener(
                onNotification: (notification) {
                  if (notification is BackUpNotification) _goToVerticalPage(imagePage);
                  return false;
                },
                child: InfoPage(collection: collection, entry: entry),
              ),
            ],
          ),
          ..._buildOverlay(entry)
        ],
      ),
    );
  }

  List<Widget> _buildOverlay(ImageEntry entry) {
    if (entry == null || _currentVerticalPage != imagePage) return [];
    final videoController = entry.isVideo ? _videoControllers.firstWhere((kv) => kv.item1 == entry.path, orElse: () => null)?.item2 : null;
    return [
      FullscreenTopOverlay(
        entries: entries,
        index: _currentHorizontalPage,
        scale: _topOverlayScale,
        viewInsets: _frozenViewInsets,
        viewPadding: _frozenViewPadding,
        onActionSelected: (action) => _actionDelegate.onActionSelected(context, entry, action),
      ),
      Positioned(
        bottom: 0,
        child: Column(
          children: [
            if (videoController != null)
              VideoControlOverlay(
                entry: entry,
                controller: videoController,
                scale: _topOverlayScale,
                viewInsets: _frozenViewInsets,
                viewPadding: _frozenViewPadding,
              ),
            SlideTransition(
              position: _bottomOverlayOffset,
              child: FullscreenBottomOverlay(
                entries: entries,
                index: _currentHorizontalPage,
                viewInsets: _frozenViewInsets,
                viewPadding: _frozenViewPadding,
              ),
            ),
          ],
        ),
      )
    ];
  }

  Future<void> _goToVerticalPage(int page) {
    return _verticalPager.animateToPage(
      page,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onVerticalPageChanged(page) {
    setState(() => _currentVerticalPage = page);
    if (_currentVerticalPage == transitionPage) {
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

    final path = entry.path;
    var controllerEntry = _videoControllers.firstWhere((kv) => kv.item1 == entry.path, orElse: () => null);
    if (controllerEntry != null) {
      _videoControllers.remove(controllerEntry);
    } else {
      final controller = VideoPlayerController.file(File(path))..initialize();
      controllerEntry = Tuple2(path, controller);
    }
    _videoControllers.insert(0, controllerEntry);
    while (_videoControllers.length > 3) {
      _videoControllers.removeLast().item2.dispose();
    }
  }
}
