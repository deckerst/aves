import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/grid/list_known_extent.dart';
import 'package:aves/widgets/album/grid/list_section_layout.dart';
import 'package:aves/widgets/album/thumbnail/decorated.dart';
import 'package:aves/widgets/common/transparent_material_page_route.dart';
import 'package:aves/widgets/fullscreen/fullscreen_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// use a `SliverList` instead of multiple `SliverGrid` because having one `SliverGrid` per section does not scale up
// with the multiple `SliverGrid` solution, thumbnails at the beginning of each sections are built even though they are offscreen
// because of `RenderSliverMultiBoxAdaptor.addInitialChild` called by `RenderSliverGrid.performLayout` (line 547), as of Flutter v1.17.0
class CollectionListSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sectionLayouts = Provider.of<SectionedListLayout>(context).sectionLayouts;
    final childCount = sectionLayouts.isEmpty ? 0 : sectionLayouts.last.lastIndex + 1;
    return SliverKnownExtentList(
      sectionLayouts: sectionLayouts,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= childCount) return null;
          final sectionLayout = sectionLayouts.firstWhere((section) => section.hasChild(index), orElse: () => null);
          return sectionLayout?.builder(context, index) ?? const SizedBox.shrink();
        },
        childCount: childCount,
        addAutomaticKeepAlives: false,
      ),
    );
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
      onTap: () {
        if (collection.isBrowsing) {
          _goToFullscreen(context);
        } else {
          collection.toggleSelection(entry);
        }
      },
      onLongPress: () {
        if (collection.isBrowsing) {
          collection.toggleSelection(entry);
        }
      },
      child: MetaData(
        metaData: ThumbnailMetadata(index, entry),
        child: DecoratedThumbnail(
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
