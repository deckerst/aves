import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/collection_section.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailCollection extends AnimatedWidget {
  final ImageCollection collection;
  final Widget appBar;

  const ThumbnailCollection({
    Key key,
    this.collection,
    this.appBar,
  }) : super(key: key, listenable: collection);

  @override
  Widget build(BuildContext context) {
    return ThumbnailCollectionContent(
      collection: collection,
      appBar: appBar,
    );
  }
}

class ThumbnailCollectionContent extends StatelessWidget {
  final ImageCollection collection;
  final Widget appBar;

  final Map<dynamic, List<ImageEntry>> _sections;
  final ScrollController _scrollController = ScrollController();

  ThumbnailCollectionContent({
    Key key,
    @required this.collection,
    @required this.appBar,
  })  : _sections = collection.sections,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final sectionKeys = _sections.keys.toList();
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
        builder: (c, mqViewInsetsBottom, child) => DraggableScrollbar.arrows(
          controller: _scrollController,
          padding: EdgeInsets.only(
            // top padding to adjust scroll thumb
            top: topPadding,
            bottom: mqViewInsetsBottom,
          ),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              if (appBar != null) appBar,
              ...sectionKeys.map((sectionKey) {
                Widget sliver = SectionSliver(
                  // need key to prevent section header mismatch
                  // but it should not be unique key, otherwise sections are rebuilt when changing page
                  key: ValueKey(sectionKey),
                  collection: collection,
                  sections: _sections,
                  sectionKey: sectionKey,
                );
                if (sectionKey == sectionKeys.last) {
                  sliver = SliverPadding(
                    padding: EdgeInsets.only(bottom: mqViewInsetsBottom),
                    sliver: sliver,
                  );
                }
                return sliver;
              }),
            ],
          ),
        ),
      ),
    );
  }
}
