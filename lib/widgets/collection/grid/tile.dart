import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/intent_service.dart';
import 'package:aves/widgets/collection/grid/list_details.dart';
import 'package:aves/widgets/collection/grid/list_details_theme.dart';
import 'package:aves/widgets/common/grid/scaling.dart';
import 'package:aves/widgets/common/providers/viewer_entry_provider.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:aves/widgets/common/thumbnail/notifications.dart';
import 'package:aves/widgets/viewer/hero.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const InteractiveTile({
  super.key,
  required final CollectionLens collection,
  required final AvesEntry entry,
  required final double thumbnailExtent,
  required final TileLayout tileLayout,
  final ValueNotifier<bool>? isScrollingNotifier,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final appMode = context.read<ValueNotifier<AppMode>>().value;
        switch (appMode) {
          case .main:
            final selection = context.read<Selection<AvesEntry>>();
            if (selection.isSelecting) {
              selection.toggleSelection(entry);
            } else {
              OpenViewerNotification(entry).dispatch(context);
            }
          case .pickSingleMediaExternal:
            IntentService.submitPickedItems([entry.uri]);
          case .pickMultipleMediaExternal:
            final selection = context.read<Selection<AvesEntry>>();
            selection.toggleSelection(entry);
          case .pickFilteredMediaInternal:
          case .pickUnfilteredMediaInternal:
            Navigator.maybeOf(context)?.pop<AvesEntry>(entry);
          default:
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
          heroTagger: () => EntryHeroInfo(collection, entry).tag,
        ),
      ),
    );
  }
}

class const Tile({
  super.key,
  required final AvesEntry entry,
  required final double thumbnailExtent,
  required final TileLayout tileLayout,
  final bool selectable = false,
  final bool highlightable = false,
  final ValueNotifier<bool>? isScrollingNotifier,
  final Object? Function()? heroTagger,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    switch (tileLayout) {
      case .mosaic:
      case .grid:
      case .calendar:
        return _buildThumbnail();
      case .list:
        return Row(
          crossAxisAlignment: .stretch,
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
    isMosaic: tileLayout == .mosaic,
    // when the user is scrolling faster than we can retrieve the thumbnails,
    // the retrieval task queue can pile up for thumbnails that got disposed
    // in this case we pause the image retrieval task to get it out of the queue
    cancellableNotifier: isScrollingNotifier,
    selectable: selectable,
    highlightable: highlightable,
    heroTagger: heroTagger,
    // do not use a hero placeholder but hide the thumbnail matching the viewer entry,
    // so that it can hero out on an entry and come back with a hero to a different entry
    heroPlaceholderBuilder: (context, heroSize, child) => child,
    imageDecorator: (context, child) {
      return Selector<ViewerEntryNotifier, bool>(
        selector: (context, v) => v.value == entry,
        builder: (context, isViewerEntry, child) {
          return Visibility.maintain(
            visible: !isViewerEntry,
            child: child!,
          );
        },
        child: child,
      );
    },
  );
}
