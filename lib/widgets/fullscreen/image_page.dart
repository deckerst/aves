import 'dart:io';
import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/fullscreen/info_page.dart';
import 'package:aves/widgets/fullscreen/overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullscreenPage extends StatefulWidget {
  final List<ImageEntry> entries;
  final String initialUri;

  const FullscreenPage({
    Key key,
    this.entries,
    this.initialUri,
  }) : super(key: key);

  @override
  FullscreenPageState createState() => FullscreenPageState();
}

class FullscreenPageState extends State<FullscreenPage> with SingleTickerProviderStateMixin {
  bool _isInitialScale = true;
  int _currentHorizontalPage, _currentVerticalPage = 0;
  PageController _horizontalPager, _verticalPager;
  ValueNotifier<bool> _overlayVisible = ValueNotifier(false);
  AnimationController _overlayAnimationController;
  Animation<Offset> _topOverlayOffset, _bottomOverlayOffset;

  List<ImageEntry> get entries => widget.entries;

  @override
  void initState() {
    super.initState();
    final index = entries.indexWhere((entry) => entry.uri == widget.initialUri);
    _currentHorizontalPage = max(0, index);
    _horizontalPager = PageController(initialPage: _currentHorizontalPage);
    _verticalPager = PageController(initialPage: _currentVerticalPage);
    _overlayAnimationController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    );
    _topOverlayOffset = Tween(begin: Offset(0, 0), end: Offset(0, -1)).animate(CurvedAnimation(parent: _overlayAnimationController, curve: Curves.easeOutQuart, reverseCurve: Curves.easeInQuart));
    _bottomOverlayOffset = Tween(begin: Offset(0, 0), end: Offset(0, 1)).animate(CurvedAnimation(parent: _overlayAnimationController, curve: Curves.easeOutQuart, reverseCurve: Curves.easeInQuart));
    _overlayVisible.addListener(onOverlayVisibleChange);
  }

  @override
  void dispose() {
    _overlayVisible.removeListener(onOverlayVisibleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            scrollDirection: Axis.vertical,
            controller: _verticalPager,
            physics: _isInitialScale ? PageScrollPhysics() : NeverScrollableScrollPhysics(),
            onPageChanged: (page) => setState(() => _currentVerticalPage = page),
            children: [
              ImagePage(
                entries: entries,
                pageController: _horizontalPager,
                onTap: () {
                  final visible = !_overlayVisible.value;
                  _overlayVisible.value = visible;
                  SystemChrome.setEnabledSystemUIOverlays(visible ? []: SystemUiOverlay.values);
                },
                onPageChanged: (page) => setState(() => _currentHorizontalPage = page),
                onScaleChanged: (state) => setState(() => _isInitialScale = state == PhotoViewScaleState.initial),
              ),
              NotificationListener(
                onNotification: (notification) {
                  if (notification is BackUpNotification) {
                    _verticalPager.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                  return false;
                },
                child: InfoPage(
                  entry: entries[_currentHorizontalPage],
                ),
              ),
            ],
          ),
          if (_currentHorizontalPage != null && _currentVerticalPage == 0) ...[
            SlideTransition(
              position: _topOverlayOffset,
              child: FullscreenTopOverlay(
                entries: entries,
                index: _currentHorizontalPage,
              ),
            ),
            Positioned(
              bottom: 0,
              child: SlideTransition(
                position: _bottomOverlayOffset,
                child: FullscreenBottomOverlay(
                  entries: entries,
                  index: _currentHorizontalPage,
                ),
              ),
            )
          ]
        ],
      ),
      resizeToAvoidBottomInset: false,
//        Hero(
//          tag: uri,
//          child: Stack(
//            children: [
//              Center(
//                child: widget.thumbnail == null
//                    ? CircularProgressIndicator()
//                    : Image.memory(
//                        widget.thumbnail,
//                        width: requestWidth,
//                        height: requestHeight,
//                        fit: BoxFit.contain,
//                      ),
//              ),
//              Center(
//                child: FadeInImage(
//                  placeholder: MemoryImage(kTransparentImage),
//                  image: FileImage(File(path)),
//                  fadeOutDuration: Duration(milliseconds: 1),
//                  fadeInDuration: Duration(milliseconds: 200),
//                  width: requestWidth,
//                  height: requestHeight,
//                  fit: BoxFit.contain,
//                ),
//              ),
//            ],
//          ),
//        ),
    );
  }

  onOverlayVisibleChange() {
    if (_overlayVisible.value)
      _overlayAnimationController.forward();
    else
      _overlayAnimationController.reverse();
  }
}

class ImagePage extends StatefulWidget {
  final List<ImageEntry> entries;
  final PageController pageController;
  final VoidCallback onTap;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<PhotoViewScaleState> onScaleChanged;

  const ImagePage({
    this.entries,
    this.pageController,
    this.onTap,
    this.onPageChanged,
    this.onScaleChanged,
  });

  @override
  State<StatefulWidget> createState() => ImagePageState();
}

class ImagePageState extends State<ImagePage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PhotoViewGallery.builder(
      itemCount: widget.entries.length,
      builder: (context, index) {
        final entry = widget.entries[index];
        return PhotoViewGalleryPageOptions(
          imageProvider: FileImage(File(entry.path)),
          heroTag: entry.uri,
          minScale: PhotoViewComputedScale.contained,
          initialScale: PhotoViewComputedScale.contained,
          onTapUp: (tapContext, details, value) => widget.onTap?.call(),
        );
      },
      loadingChild: Center(
        child: CircularProgressIndicator(),
      ),
      pageController: widget.pageController,
      onPageChanged: widget.onPageChanged,
      scaleStateChangedCallback: widget.onScaleChanged,
      transitionOnUserGestures: true,
      scrollPhysics: BouncingScrollPhysics(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
