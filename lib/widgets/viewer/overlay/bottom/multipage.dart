import 'dart:math';

import 'package:aves/model/multipage.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/thumbnail/decorated.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MultiPageOverlay extends StatefulWidget {
  final MultiPageController controller;
  final double availableWidth;

  const MultiPageOverlay({
    Key? key,
    required this.controller,
    required this.availableWidth,
  }) : super(key: key);

  @override
  _MultiPageOverlayState createState() => _MultiPageOverlayState();
}

class _MultiPageOverlayState extends State<MultiPageOverlay> {
  final _cancellableNotifier = ValueNotifier(true);
  late ScrollController _scrollController;
  bool _syncScroll = true;
  int? _initControllerPage;

  static const double extent = 48;
  static const double separatorWidth = 2;

  MultiPageController get controller => widget.controller;

  double get availableWidth => widget.availableWidth;

  @override
  void initState() {
    super.initState();
    _registerWidget();
  }

  @override
  void didUpdateWidget(covariant MultiPageOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != controller) {
      _unregisterWidget();
      _registerWidget();
    }
  }

  @override
  void dispose() {
    _unregisterWidget();
    super.dispose();
  }

  void _registerWidget() {
    _initControllerPage = controller.page;
    final scrollOffset = pageToScrollOffset(_initControllerPage ?? 0);
    _scrollController = ScrollController(initialScrollOffset: scrollOffset);
    _scrollController.addListener(_onScrollChange);

    if (_initControllerPage == null) {
      _correctDefaultPageScroll();
    }
  }

  // correct scroll offset to match default page
  // if default page was unknown when the scroll controller was created
  void _correctDefaultPageScroll() async {
    await controller.infoStream.first;
    if (_initControllerPage == null) {
      _initControllerPage = controller.page;
      if (_initControllerPage != null && _initControllerPage != 0) {
        WidgetsBinding.instance!.addPostFrameCallback((_) => _goToPage(_initControllerPage!));
      }
    }
  }

  void _unregisterWidget() {
    _scrollController.removeListener(_onScrollChange);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marginWidth = max(0.0, (availableWidth - extent) / 2 - separatorWidth);
    final horizontalMargin = SizedBox(width: marginWidth);
    const separator = SizedBox(width: separatorWidth);

    return GridTheme(
      extent: extent,
      showLocation: false,
      child: StreamBuilder<MultiPageInfo?>(
        stream: controller.infoStream,
        builder: (context, snapshot) {
          final multiPageInfo = controller.info;
          final pageCount = multiPageInfo?.pageCount ?? 0;
          return SizedBox(
            height: extent,
            child: ListView.separated(
              key: ValueKey(multiPageInfo),
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              // default padding in scroll direction matches `MediaQuery.viewPadding`,
              // but we already accommodate for it, so make sure horizontal padding is 0
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                if (index == 0 || index == pageCount + 1) return horizontalMargin;
                final page = index - 1;
                final pageEntry = multiPageInfo!.getPageEntryByIndex(page);

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _goToPage(page),
                      child: DecoratedThumbnail(
                        entry: pageEntry,
                        tileExtent: extent,
                        // the retrieval task queue can pile up for thumbnails of heavy pages
                        // (e.g. thumbnails of 15MP HEIF images inside 100MB+ HEIC containers)
                        // so we cancel these requests when possible
                        cancellableNotifier: _cancellableNotifier,
                        selectable: false,
                        highlightable: false,
                      ),
                    ),
                    IgnorePointer(
                      child: AnimatedContainer(
                        color: controller.page == page ? Colors.transparent : Colors.black45,
                        width: extent,
                        height: extent,
                        duration: Durations.viewerOverlayPageShadeAnimation,
                      ),
                    )
                  ],
                );
              },
              separatorBuilder: (context, index) => separator,
              itemCount: pageCount + 2,
            ),
          );
        },
      ),
    );
  }

  Future<void> _goToPage(int page) async {
    _syncScroll = false;
    controller.page = page;
    await _scrollController.animateTo(
      pageToScrollOffset(page),
      duration: Durations.viewerOverlayPageScrollAnimation,
      curve: Curves.easeOutCubic,
    );
    _syncScroll = true;
  }

  void _onScrollChange() {
    if (_syncScroll) {
      controller.page = scrollOffsetToPage(_scrollController.offset);
    }
  }

  double pageToScrollOffset(int page) => page * (extent + separatorWidth);

  int scrollOffsetToPage(double offset) => (offset / (extent + separatorWidth)).round();
}
