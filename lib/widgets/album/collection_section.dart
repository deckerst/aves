import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
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
  final CollectionLens collection;
  final dynamic sectionKey;
  final int columnCount;

  const SectionSliver({
    Key key,
    @required this.collection,
    @required this.sectionKey,
    @required this.columnCount,
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
                return MetaData(
                  metaData: ThumbnailMetadata(index, entry),
                  child: Thumbnail(
                    entry: entry,
                    extent: mqWidth / columnCount,
                    heroTag: collection.heroTag(entry),
                  ),
                );
              },
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

// metadata to identify entry from RenderObject hit test during collection scaling
class ThumbnailMetadata {
  final int index;
  final ImageEntry entry;

  const ThumbnailMetadata(this.index, this.entry);
}

class SectionHeader extends StatelessWidget {
  final CollectionLens collection;
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
    switch (collection.sortFactor) {
      case SortFactor.date:
        if (collection.sortFactor == SortFactor.date) {
          switch (collection.groupFactor) {
            case GroupFactor.album:
              header = _buildAlbumSectionHeader(context);
              break;
            case GroupFactor.month:
              header = MonthSectionHeader(key: ValueKey(sectionKey), date: sectionKey as DateTime);
              break;
            case GroupFactor.day:
              header = DaySectionHeader(key: ValueKey(sectionKey), date: sectionKey as DateTime);
              break;
          }
        }
        break;
      case SortFactor.size:
        break;
      case SortFactor.name:
        header = _buildAlbumSectionHeader(context);
        break;
    }
    return IgnorePointer(
      child: header,
    );
  }

  Widget _buildAlbumSectionHeader(BuildContext context) {
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
    final title = CollectionSource.getUniqueAlbumName(sectionKey as String, sections.keys.cast<String>());
    return TitleSectionHeader(
      key: ValueKey(title),
      leading: albumIcon,
      title: title,
    );
  }
}
