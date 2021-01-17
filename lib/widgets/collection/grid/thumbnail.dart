import 'package:aves/main.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/viewer_service.dart';
import 'package:aves/widgets/collection/thumbnail/decorated.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/scaling.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:flutter/material.dart';

class InteractiveThumbnail extends StatelessWidget {
  final CollectionLens collection;
  final ImageEntry entry;
  final double tileExtent;
  final ValueNotifier<bool> isScrollingNotifier;

  const InteractiveThumbnail({
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
            _goToViewer(context);
          } else if (collection.isSelecting) {
            collection.toggleSelection(entry);
          }
        } else if (AvesApp.mode == AppMode.pick) {
          ViewerService.pick(entry.uri);
        }
      },
      child: MetaData(
        metaData: ScalerMetadata(entry),
        child: DecoratedThumbnail(
          entry: entry,
          extent: tileExtent,
          collection: collection,
          isScrollingNotifier: isScrollingNotifier,
        ),
      ),
    );
  }

  void _goToViewer(BuildContext context) {
    Navigator.push(
      context,
      TransparentMaterialPageRoute(
        settings: RouteSettings(name: MultiEntryViewerPage.routeName),
        pageBuilder: (c, a, sa) => MultiEntryViewerPage(
          collection: collection,
          initialEntry: entry,
        ),
      ),
    );
  }
}
