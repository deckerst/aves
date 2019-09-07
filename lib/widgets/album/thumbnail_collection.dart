import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/sections.dart';
import 'package:aves/widgets/album/thumbnail.dart';
import 'package:aves/widgets/common/draggable_scrollbar.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class ThumbnailCollection extends AnimatedWidget {
  final ImageCollection collection;
  final Widget appBar;

  ThumbnailCollection({
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
    this.collection,
    this.appBar,
  })  : _sections = collection.sections,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    final sectionKeys = _sections.keys.toList();
    return SafeArea(
      child: DraggableScrollbar.arrows(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (appBar != null) appBar,
            ...sectionKeys.map((sectionKey) {
              Widget sliver = SectionSliver(
                collection: collection,
                sections: _sections,
                sectionKey: sectionKey,
              );
              if (sectionKey == sectionKeys.last) {
                sliver = SliverPadding(
                  padding: EdgeInsets.only(bottom: bottomInsets),
                  sliver: sliver,
                );
              }
              return sliver;
            }),
          ],
        ),
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: bottomInsets),
        labelTextBuilder: (double offset) => Text(
          "${offset ~/ 1}",
          style: TextStyle(color: Colors.blueGrey),
        ),
      ),
    );
  }
}

class SectionSliver extends StatelessWidget {
  final ImageCollection collection;
  final Map<dynamic, List<ImageEntry>> sections;
  final dynamic sectionKey;

  const SectionSliver({
    Key key,
    this.collection,
    this.sections,
    this.sectionKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columnCount = 4;
    Widget header = SizedBox.shrink();
    if (collection.sortFactor == SortFactor.date) {
      switch (collection.groupFactor) {
        case GroupFactor.album:
          Widget albumIcon = IconUtils.getAlbumIcon(context, sectionKey);
          if (albumIcon != null) {
            albumIcon = Material(
              type: MaterialType.circle,
              elevation: 3,
              color: Colors.transparent,
              shadowColor: Colors.black,
              child: albumIcon,
            );
          }
          header = SectionHeader(
            leading: albumIcon,
            title: collection.getUniqueAlbumName(sectionKey, sections.keys.toList()),
          );
          break;
        case GroupFactor.date:
          header = MonthSectionHeader(date: sectionKey);
          break;
      }
    }
    return SliverStickyHeader(
      header: header,
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (sliverContext, index) {
            final sectionEntries = sections[sectionKey];
            if (index >= sectionEntries.length) return null;
            final entry = sectionEntries[index];
            final mediaQuery = MediaQuery.of(sliverContext);
            return GestureDetector(
              onTap: () => _showFullscreen(sliverContext, entry),
              child: Thumbnail(
                entry: entry,
                extent: mediaQuery.size.width / columnCount,
                devicePixelRatio: mediaQuery.devicePixelRatio,
              ),
            );
          },
          childCount: sections[sectionKey].length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
        ),
      ),
    );
  }

  Future _showFullscreen(BuildContext context, ImageEntry entry) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenPage(
          collection: collection,
          initialUri: entry.uri,
        ),
      ),
    );
  }
}
