import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/viewer_service.dart';
import 'package:aves/widgets/collection/grid/list_details.dart';
import 'package:aves/widgets/collection/grid/list_details_theme.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/grid/scaling.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InteractiveTile extends StatelessWidget {
  final CollectionLens collection;
  final AvesEntry entry;
  final double thumbnailExtent;
  final TileLayout tileLayout;
  final ValueNotifier<bool>? isScrollingNotifier;

  const InteractiveTile({
    super.key,
    required this.collection,
    required this.entry,
    required this.thumbnailExtent,
    required this.tileLayout,
    this.isScrollingNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
          case AppMode.pickSingleMediaExternal:
            ViewerService.pick([entry.uri]);
            break;
          case AppMode.pickMultipleMediaExternal:
            final selection = context.read<Selection<AvesEntry>>();
            selection.toggleSelection(entry);
            break;
          case AppMode.pickMediaInternal:
            Navigator.pop(context, entry);
            break;
          case AppMode.pickFilterInternal:
          case AppMode.view:
            break;
        }
      },
      child: MetaData(
        metaData: ScalerMetadata(entry),
        child: Tile(
          entry: entry,
          thumbnailExtent: thumbnailExtent,
          tileLayout: tileLayout,
          selectable: true,
          highlightable: true,
          isScrollingNotifier: isScrollingNotifier,
          // hero tag should include a collection identifier, so that it animates
          // between different views of the entry in the same collection (e.g. thumbnails <-> viewer)
          // but not between different collection instances, even with the same attributes (e.g. reloading collection page via drawer)
          heroTagger: () => Object.hashAll([collection.id, entry.id]),
        ),
      ),
    );
  }

  void _goToViewer(BuildContext context) {
    Navigator.push(
      context,
      TransparentMaterialPageRoute(
        settings: const RouteSettings(name: EntryViewerPage.routeName),
        pageBuilder: (context, a, sa) {
          final viewerCollection = collection.copyWith(
            listenToSource: false,
          );
          assert(viewerCollection.sortedEntries.map((entry) => entry.id).contains(entry.id));
          return EntryViewerPage(
            collection: viewerCollection,
            initialEntry: entry,
          );
        },
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final AvesEntry entry;
  final double thumbnailExtent;
  final TileLayout tileLayout;
  final bool selectable, highlightable;
  final ValueNotifier<bool>? isScrollingNotifier;
  final Object? Function()? heroTagger;

  const Tile({
    super.key,
    required this.entry,
    required this.thumbnailExtent,
    required this.tileLayout,
    this.selectable = false,
    this.highlightable = false,
    this.isScrollingNotifier,
    this.heroTagger,
  });

  @override
  Widget build(BuildContext context) {
    switch (tileLayout) {
      case TileLayout.grid:
        return _buildThumbnail();
      case TileLayout.list:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox.square(
              dimension: context.select<EntryListDetailsThemeData, double>((v) => v.extent),
              child: _buildThumbnail(),
            ),
            Expanded(
              child: EntryListDetails(
                entry: entry,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildThumbnail() => DecoratedThumbnail(
        entry: entry,
        tileExtent: thumbnailExtent,
        // when the user is scrolling faster than we can retrieve the thumbnails,
        // the retrieval task queue can pile up for thumbnails that got disposed
        // in this case we pause the image retrieval task to get it out of the queue
        cancellableNotifier: isScrollingNotifier,
        selectable: selectable,
        highlightable: highlightable,
        heroTagger: heroTagger,
      );
}
