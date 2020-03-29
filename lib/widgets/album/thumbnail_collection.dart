import 'package:aves/model/collection_lens.dart';
import 'package:aves/widgets/album/collection_scaling.dart';
import 'package:aves/widgets/album/collection_section.dart';
import 'package:aves/widgets/common/scroll_thumb.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailCollection extends StatelessWidget {
  final Widget appBar;
  final WidgetBuilder emptyBuilder;

  final ValueNotifier<int> _columnCountNotifier = ValueNotifier(4);
  final GlobalKey _scrollableKey = GlobalKey();

  ThumbnailCollection({
    Key key,
    this.appBar,
    this.emptyBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('$runtimeType build');
    final collection = Provider.of<CollectionLens>(context);
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
              builder: (context, columnCount, child) {
                debugPrint('$runtimeType builder columnCount=$columnCount');
                final scrollView = CustomScrollView(
                  key: _scrollableKey,
                  primary: true,
                  slivers: [
                    if (appBar != null) appBar,
                    if (collection.isEmpty && emptyBuilder != null)
                      SliverFillViewport(
                        delegate: SliverChildListDelegate.fixed(
                          [emptyBuilder(context)],
                        ),
                      ),
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
                );

                return DraggableScrollbar(
                  heightScrollThumb: avesScrollThumbHeight,
                  backgroundColor: Colors.white,
                  scrollThumbBuilder: avesScrollThumbBuilder(),
                  controller: PrimaryScrollController.of(context),
                  padding: EdgeInsets.only(
                    // padding to get scroll thumb below app bar, above nav bar
                    top: topPadding,
                    bottom: mqViewInsetsBottom,
                  ),
                  child: scrollView,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
