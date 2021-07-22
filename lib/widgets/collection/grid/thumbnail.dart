import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/viewer_service.dart';
import 'package:aves/widgets/collection/thumbnail/decorated.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/scaling.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InteractiveThumbnail extends StatelessWidget {
  final CollectionLens collection;
  final AvesEntry entry;
  final double tileExtent;
  final ValueNotifier<bool>? isScrollingNotifier;

  const InteractiveThumbnail({
    Key? key,
    required this.collection,
    required this.entry,
    required this.tileExtent,
    this.isScrollingNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(entry.uri),
      onTap: () {
        final appMode = context.read<ValueNotifier<AppMode>>().value;
        switch (appMode) {
          case AppMode.main:
            final selection = context.read<Selection<AvesEntry>>();
            if (selection.isSelecting) {
              selection.toggleSelection(entry);
            } else {
              _goToViewer(context);
            }
            break;
          case AppMode.pickExternal:
            ViewerService.pick(entry.uri);
            break;
          case AppMode.pickInternal:
            Navigator.pop(context, entry);
            break;
          case AppMode.view:
            break;
        }
      },
      child: MetaData(
        metaData: ScalerMetadata(entry),
        child: DecoratedThumbnail(
          entry: entry,
          tileExtent: tileExtent,
          collection: collection,
          // when the user is scrolling faster than we can retrieve the thumbnails,
          // the retrieval task queue can pile up for thumbnails that got disposed
          // in this case we pause the image retrieval task to get it out of the queue
          cancellableNotifier: isScrollingNotifier,
        ),
      ),
    );
  }

  void _goToViewer(BuildContext context) {
    Navigator.push(
      context,
      TransparentMaterialPageRoute(
        settings: const RouteSettings(name: EntryViewerPage.routeName),
        pageBuilder: (c, a, sa) {
          final viewerCollection = CollectionLens(
            source: collection.source,
            filters: collection.filters,
            id: collection.id,
            listenToSource: false,
          );
          assert(viewerCollection.sortedEntries.map((e) => e.contentId).contains(entry.contentId));
          return EntryViewerPage(
            collection: viewerCollection,
            initialEntry: entry,
          );
        },
      ),
    );
  }
}
