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

class SectionSliver extends StatelessWidget {
  final CollectionLens collection;
  final dynamic sectionKey;
  final double tileExtent;
  final bool showHeader;

  const SectionSliver({
    Key key,
    @required this.collection,
    @required this.sectionKey,
    @required this.tileExtent,
    @required this.showHeader,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sections = collection.sections;
    final sectionEntries = sections[sectionKey];
    final childCount = sectionEntries.length;

    final sliver = SliverGrid(
      delegate: SliverChildBuilderDelegate(
        // TODO TLAD thumbnails at the beginning of each sections are built even though they are offscreen
        // because of `RenderSliverMultiBoxAdaptor.addInitialChild`
        // called by `RenderSliverGrid.performLayout` (line 547)
        (context, index) => index < childCount
            ? GridThumbnail(
                collection: collection,
                index: index,
                entry: sectionEntries[index],
                tileExtent: tileExtent,
              )
            : null,
        childCount: childCount,
        addAutomaticKeepAlives: false,
      ),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: tileExtent,
      ),
    );

    return showHeader
        ? SliverStickyHeader(
            header: SectionHeader(
              collection: collection,
              sections: sections,
              sectionKey: sectionKey,
            ),
            sliver: sliver,
            overlapsContent: false,
          )
        : sliver;
  }
}

class GridThumbnail extends StatelessWidget {
  final CollectionLens collection;
  final int index;
  final ImageEntry entry;
  final double tileExtent;
  final GestureTapCallback onTap;

  const GridThumbnail({
    Key key,
    this.collection,
    this.index,
    this.entry,
    this.tileExtent,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(entry.uri),
      onTap: () => _goToFullscreen(context),
      child: MetaData(
        metaData: ThumbnailMetadata(index, entry),
        child: Thumbnail(
          entry: entry,
          extent: tileExtent,
          heroTag: collection.heroTag(entry),
        ),
      ),
    );
  }

  void _goToFullscreen(BuildContext context) {
    Navigator.push(
      context,
      TransparentMaterialPageRoute(
        pageBuilder: (c, a, sa) => MultiFullscreenPage(
          collection: collection,
          initialEntry: entry,
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
    Widget header;
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
    return header != null
        ? IgnorePointer(
            child: header,
          )
        : const SizedBox.shrink();
  }

  Widget _buildAlbumSectionHeader(BuildContext context) {
    var albumIcon = IconUtils.getAlbumIcon(context: context, album: sectionKey as String);
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
