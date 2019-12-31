import 'package:aves/model/image_collection.dart';
import 'package:aves/widgets/album/collection_section.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailCollection extends StatelessWidget {
  final Widget appBar;
  final ScrollController _scrollController = ScrollController();

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

    final scrollView = CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (appBar != null) appBar,
        ...sectionKeys.map((sectionKey) => SectionSliver(
              // need key to prevent section header mismatch
              // but it should not be unique key, otherwise sections are rebuilt when changing page
              key: ValueKey(sectionKey),
              collection: collection,
              sections: sections,
              sectionKey: sectionKey,
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

    return SafeArea(
      child: Selector<MediaQueryData, double>(
        selector: (c, mq) => mq.viewInsets.bottom,
        builder: (c, mqViewInsetsBottom, child) {
          return DraggableScrollbar.arrows(
            controller: _scrollController,
            padding: EdgeInsets.only(
              // top padding to adjust scroll thumb
              top: topPadding,
              bottom: mqViewInsetsBottom,
            ),
            child: scrollView,
          );
        },
      ),
    );
  }
}
