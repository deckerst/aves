import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/thumbnail/decorated.dart';
import 'package:aves/widgets/viewer/multipage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MultiPageOverlay extends StatefulWidget {
  final AvesEntry mainEntry;
  final MultiPageController controller;
  final double availableWidth;

  MultiPageOverlay({
    Key key,
    @required this.mainEntry,
    @required this.controller,
    @required this.availableWidth,
  })  : assert(mainEntry.isMultipage),
        assert(controller != null),
        super(key: key);

  @override
  _MultiPageOverlayState createState() => _MultiPageOverlayState();
}

class _MultiPageOverlayState extends State<MultiPageOverlay> {
  ScrollController _scrollController;
  bool _syncScroll = true;

  static const double extent = 48;
  static const double separatorWidth = 2;

  AvesEntry get mainEntry => widget.mainEntry;

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
    final page = controller.page ?? 0;
    final scrollOffset = pageToScrollOffset(page);
    _scrollController = ScrollController(initialScrollOffset: scrollOffset);
    _scrollController.addListener(_onScrollChange);
  }

  void _unregisterWidget() {
    _scrollController.removeListener(_onScrollChange);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marginWidth = max(0, (availableWidth - extent) / 2 - separatorWidth);
    final horizontalMargin = SizedBox(width: marginWidth);
    final separator = SizedBox(width: separatorWidth);
    final shade = IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black38,
        ),
      ),
    );

    return FutureBuilder<MultiPageInfo>(
      future: controller.info,
      builder: (context, snapshot) {
        final multiPageInfo = snapshot.data;
        if ((multiPageInfo?.pageCount ?? 0) <= 1) return SizedBox.shrink();
        return Container(
          height: extent + separatorWidth * 2,
          child: Stack(
            children: [
              Positioned(
                top: separatorWidth,
                width: availableWidth,
                height: extent,
                child: ListView.separated(
                  key: ValueKey(mainEntry),
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  // default padding in scroll direction matches `MediaQuery.viewPadding`,
                  // but we already accommodate for it, so make sure horizontal padding is 0
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    if (index == 0 || index == multiPageInfo.pageCount + 1) return horizontalMargin;
                    final page = index - 1;
                    final pageEntry = mainEntry.getPageEntry(multiPageInfo.getByIndex(page));

                    return GestureDetector(
                      onTap: () async {
                        _syncScroll = false;
                        controller.page = page;
                        await _scrollController.animateTo(
                          pageToScrollOffset(page),
                          duration: Durations.viewerOverlayPageChooserAnimation,
                          curve: Curves.easeOutCubic,
                        );
                        _syncScroll = true;
                      },
                      child: DecoratedThumbnail(
                        entry: pageEntry,
                        extent: extent,
                        selectable: false,
                        highlightable: false,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => separator,
                  itemCount: multiPageInfo.pageCount + 2,
                ),
              ),
              Positioned(
                left: 0,
                top: separatorWidth,
                width: marginWidth + separatorWidth,
                height: extent,
                child: shade,
              ),
              Positioned(
                top: separatorWidth,
                right: 0,
                width: marginWidth + separatorWidth,
                height: extent,
                child: shade,
              ),
              Positioned(
                top: 0,
                width: availableWidth,
                height: separatorWidth,
                child: shade,
              ),
              Positioned(
                bottom: 0,
                width: availableWidth,
                height: separatorWidth,
                child: shade,
              ),
            ],
          ),
        );
      },
    );
  }

  void _onScrollChange() {
    if (_syncScroll) {
      controller.page = scrollOffsetToPage(_scrollController.offset);
    }
  }

  double pageToScrollOffset(int page) => page * (extent + separatorWidth);

  int scrollOffsetToPage(double offset) => (offset / (extent + separatorWidth)).round();
}
