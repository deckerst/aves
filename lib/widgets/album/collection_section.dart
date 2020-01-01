import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/sections.dart';
import 'package:aves/widgets/album/thumbnail.dart';
import 'package:aves/widgets/album/transparent_material_page_route.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/fullscreen_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';

class SectionSliver extends StatelessWidget {
  final ImageCollection collection;
  final dynamic sectionKey;

  static const columnCount = 4;

  const SectionSliver({
    Key key,
    @required this.collection,
    @required this.sectionKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sections = collection.sections;

    final sliver = SliverGrid(
      delegate: SliverChildBuilderDelegate(
        // TODO TLAD find out why thumbnails are rebuilt (with `initState`)
        (context, index) {
          final sectionEntries = sections[sectionKey];
          if (index >= sectionEntries.length) return null;
          final entry = sectionEntries[index];
          return GestureDetector(
            key: ValueKey(entry.uri),
            onTap: () => _showFullscreen(context, entry),
            child: Selector<MediaQueryData, double>(
              selector: (c, mq) => mq.size.width,
              builder: (c, mqWidth, child) {
                return Thumbnail(
                  entry: entry,
                  extent: mqWidth / columnCount,
                );
              },
            ),
          );
        },
        childCount: sections[sectionKey].length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
      ),
      // TODO TLAD custom SliverGridDelegate / SliverGridLayout to lerp between columnCount
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
      ),
    );

    return SliverStickyHeader(
      header: SectionHeader(
        collection: collection,
        sections: sections,
        sectionKey: sectionKey,
      ),
      sliver: sliver,
      overlapsContent: false,
    );
  }

  void _showFullscreen(BuildContext context, ImageEntry entry) {
    Navigator.push(
      context,
      TransparentMaterialPageRoute(
        pageBuilder: (context, _, __) => FullscreenPage(
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
    Widget header = const SizedBox.shrink();
    if (collection.sortFactor == SortFactor.date) {
      switch (collection.groupFactor) {
        case GroupFactor.album:
          Widget albumIcon = IconUtils.getAlbumIcon(context, sectionKey as String);
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
            title: collection.getUniqueAlbumName(sectionKey as String, sections.keys.cast<String>()),
          );
          break;
        case GroupFactor.month:
          header = MonthSectionHeader(date: sectionKey as DateTime);
          break;
        case GroupFactor.day:
          header = DaySectionHeader(date: sectionKey as DateTime);
          break;
      }
    }
    return IgnorePointer(
      child: header,
    );
  }
}
