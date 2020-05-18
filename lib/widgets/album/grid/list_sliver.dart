import 'package:aves/main.dart';
import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/services/viewer_service.dart';
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
  const CollectionListSliver();

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
  final ImageEntry entry;
  final double tileExtent;
  final ValueNotifier<bool> isScrollingNotifier;

  const GridThumbnail({
    Key key,
    this.collection,
    @required this.entry,
    @required this.tileExtent,
    this.isScrollingNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(entry.uri),
      onTap: () {
        if (AvesApp.mode == AppMode.main) {
          if (collection.isBrowsing) {
            _goToFullscreen(context);
          } else if (collection.isSelecting) {
            collection.toggleSelection(entry);
          }
        } else if (AvesApp.mode == AppMode.pick) {
          ViewerService.pick(entry.uri);
        }
      },
      onLongPress: () {
        if (AvesApp.mode == AppMode.main && collection.isBrowsing) {
          collection.toggleSelection(entry);
        }
      },
      child: MetaData(
        metaData: ThumbnailMetadata(entry),
        child: DecoratedThumbnail(
          entry: entry,
          extent: tileExtent,
          collection: collection,
          isScrollingNotifier: isScrollingNotifier,
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
  final ImageEntry entry;

  const ThumbnailMetadata(this.entry);
}
