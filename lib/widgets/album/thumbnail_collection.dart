import 'package:aves/model/image_collection.dart';
import 'package:aves/widgets/album/collection_scaling.dart';
import 'package:aves/widgets/album/collection_section.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailCollection extends StatelessWidget {
  final Widget appBar;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _columnCountNotifier = ValueNotifier(4);
  final GlobalKey _scrollableKey = GlobalKey();

  ThumbnailCollection({
    Key key,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collection = Provider.of<ImageCollection>(context);
    final sections = collection.sections;
    final sectionKeys = sections.keys.toList();

    double topPadding = 0;
    if (appBar != null) {
      final topWidget = appBar;
      if (topWidget is PreferredSizeWidget) {
        topPadding = topWidget.preferredSize.height;
      } else if (topWidget is SliverAppBar) {
        topPadding = kToolbarHeight + (topWidget.bottom?.preferredSize?.height ?? 0.0);
      }
    }

    return SafeArea(
      child: Selector<MediaQueryData, double>(
        selector: (c, mq) => mq.viewInsets.bottom,
        builder: (c, mqViewInsetsBottom, child) {
          return GridScaleGestureDetector(
            scrollableKey: _scrollableKey,
            columnCountNotifier: _columnCountNotifier,
            child: ValueListenableBuilder(
              valueListenable: _columnCountNotifier,
              builder: (context, columnCount, child) => DraggableScrollbar(
                heightScrollThumb: 48,
                backgroundColor: Colors.white,
                scrollThumbBuilder: _thumbArrowBuilder(false),
                controller: _scrollController,
                padding: EdgeInsets.only(
                  // padding to get scroll thumb below app bar, above nav bar
                  top: topPadding,
                  bottom: mqViewInsetsBottom,
                ),
                child: CustomScrollView(
                  key: _scrollableKey,
                  controller: _scrollController,
                  slivers: [
                    if (appBar != null) appBar,
                    ...sectionKeys.map((sectionKey) => SectionSliver(
                          collection: collection,
                          sectionKey: sectionKey,
                          columnCount: columnCount,
                        )),
                    SliverToBoxAdapter(
                      child: Selector<MediaQueryData, double>(
                        selector: (c, mq) => mq.viewInsets.bottom,
                        builder: (c, mqViewInsetsBottom, child) {
                          return SizedBox(height: mqViewInsetsBottom);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static ScrollThumbBuilder _thumbArrowBuilder(bool alwaysVisibleScrollThumb) {
    return (
      Color backgroundColor,
      Animation<double> thumbAnimation,
      Animation<double> labelAnimation,
      double height, {
      Widget labelText,
    }) {
      final scrollThumb = Container(
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: const BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        margin: const EdgeInsets.only(right: .5),
        padding: const EdgeInsets.all(2),
        child: ClipPath(
          child: Container(
            height: height,
            width: 20.0,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(12.0),
              ),
            ),
          ),
          clipper: ArrowClipper(),
        ),
      );

      return DraggableScrollbar.buildScrollThumbAndLabel(
        scrollThumb: scrollThumb,
        backgroundColor: backgroundColor,
        thumbAnimation: thumbAnimation,
        labelAnimation: labelAnimation,
        labelText: labelText,
        alwaysVisibleScrollThumb: alwaysVisibleScrollThumb,
      );
    };
  }
}
