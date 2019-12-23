import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/sections.dart';
import 'package:aves/widgets/album/thumbnail.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/fullscreen_page.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';

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
    return Selector<MediaQueryData, double>(
      selector: (c, mq) => mq.size.width,
      builder: (c, mqWidth, child) => ThumbnailCollectionContent(
        collection: collection,
        appBar: appBar,
        screenWidth: mqWidth,
      ),
    );
  }
}

class ThumbnailCollectionContent extends StatelessWidget {
  final ImageCollection collection;
  final Widget appBar;
  final double screenWidth;

  final Map<dynamic, List<ImageEntry>> _sections;
  final ScrollController _scrollController = ScrollController();

  ThumbnailCollectionContent({
    Key key,
    @required this.collection,
    @required this.appBar,
    @required this.screenWidth,
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
                  screenWidth: screenWidth,
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
          controller: _scrollController,
          padding: EdgeInsets.only(
            // top padding to adjust scroll thumb
            top: topPadding,
            bottom: mqViewInsetsBottom,
          ),
        ),
      ),
    );
  }
}

class SectionSliver extends StatelessWidget {
  final ImageCollection collection;
  final Map<dynamic, List<ImageEntry>> sections;
  final dynamic sectionKey;
  final double screenWidth;

  const SectionSliver({
    Key key,
    @required this.collection,
    @required this.sections,
    @required this.sectionKey,
    @required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columnCount = 4;
    return SliverStickyHeader(
      header: SectionHeader(
        collection: collection,
        sections: sections,
        sectionKey: sectionKey,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          // TODO TLAD find out why thumbnails are rebuilt when config change (show/hide status bar)
          (sliverContext, index) {
            final sectionEntries = sections[sectionKey];
            if (index >= sectionEntries.length) return null;
            final entry = sectionEntries[index];
            return GestureDetector(
              onTap: () => _showFullscreen(sliverContext, entry),
              child: Thumbnail(
                entry: entry,
                extent: screenWidth / columnCount,
              ),
            );
          },
          childCount: sections[sectionKey].length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
        ),
      ),
      overlapsContent: false,
    );
  }

  _showFullscreen(BuildContext context, ImageEntry entry) {
    Navigator.push(
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

class SectionHeader extends StatelessWidget {
  final ImageCollection collection;
  final Map<dynamic, List<ImageEntry>> sections;
  final dynamic sectionKey;

  const SectionHeader({
    Key key,
    @required this.collection,
    @required this.sections,
    @required this.sectionKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          header = TitleSectionHeader(
            leading: albumIcon,
            title: collection.getUniqueAlbumName(sectionKey, sections.keys.cast<String>()),
          );
          break;
        case GroupFactor.month:
          header = MonthSectionHeader(date: sectionKey);
          break;
        case GroupFactor.day:
          header = DaySectionHeader(date: sectionKey);
          break;
      }
    }
    return IgnorePointer(
      child: header,
    );
  }
}
