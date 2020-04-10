import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/grid/header_album.dart';
import 'package:aves/widgets/album/thumbnail.dart';
import 'package:aves/widgets/album/transparent_material_page_route.dart';
import 'package:aves/widgets/fullscreen/fullscreen_page.dart';
import 'package:flutter/material.dart';

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
