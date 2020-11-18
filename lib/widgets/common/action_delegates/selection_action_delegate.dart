import 'dart:async';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/widgets/collection/collection_actions.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/action_delegates/create_album_dialog.dart';
import 'package:aves/widgets/common/action_delegates/feedback.dart';
import 'package:aves/widgets/common/action_delegates/permission_aware.dart';
import 'package:aves/widgets/common/action_delegates/size_aware.dart';
import 'package:aves/widgets/common/aves_dialog.dart';
import 'package:aves/widgets/common/entry_actions.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/common/chip_actions.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelectionActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  final CollectionLens collection;

  SelectionActionDelegate({
    @required this.collection,
  });

  void onEntryActionSelected(BuildContext context, EntryAction action) {
    switch (action) {
      case EntryAction.delete:
        _showDeleteDialog(context);
        break;
      case EntryAction.share:
        AndroidAppService.share(collection.selection);
        break;
      default:
        break;
    }
  }

  void onCollectionActionSelected(BuildContext context, CollectionAction action) {
    switch (action) {
      case CollectionAction.copy:
        _moveSelection(context, copy: true);
        break;
      case CollectionAction.move:
        _moveSelection(context, copy: false);
        break;
      case CollectionAction.refreshMetadata:
        _refreshSelectionMetadata();
        break;
      default:
        break;
    }
  }

  Future<void> _moveSelection(BuildContext context, {@required bool copy}) async {
    final source = collection.source;
    final chipSetActionDelegate = AlbumChipSetActionDelegate(source: source);
    final destinationAlbum = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        builder: (context) {
          return Selector<Settings, ChipSortFactor>(
            selector: (context, s) => s.albumSortFactor,
            builder: (context, sortFactor, child) {
              return FilterGridPage(
                source: source,
                appBar: SliverAppBar(
                  leading: BackButton(),
                  title: Text(copy ? 'Copy to Album' : 'Move to Album'),
                  actions: [
                    IconButton(
                      icon: Icon(AIcons.createAlbum),
                      onPressed: () async {
                        final newAlbum = await showDialog<String>(
                          context: context,
                          builder: (context) => CreateAlbumDialog(),
                        );
                        if (newAlbum != null && newAlbum.isNotEmpty) {
                          Navigator.pop<String>(context, newAlbum);
                        }
                      },
                      tooltip: 'Create album',
                    ),
                    IconButton(
                      icon: Icon(AIcons.sort),
                      onPressed: () => chipSetActionDelegate.onActionSelected(context, ChipSetAction.sort),
                    ),
                  ],
                  floating: true,
                ),
                filterEntries: AlbumListPage.getAlbumEntries(source),
                filterBuilder: (s) => AlbumFilter(s, source.getUniqueAlbumName(s)),
                emptyBuilder: () => EmptyContent(
                  icon: AIcons.album,
                  text: 'No albums',
                ),
                onTap: (filter) => Navigator.pop<String>(context, (filter as AlbumFilter)?.album),
              );
            },
          );
        },
      ),
    );
    if (destinationAlbum == null || destinationAlbum.isEmpty) return;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    final selection = collection.selection.toList();
    if (!await checkStoragePermission(context, selection)) return;

    if (!await checkFreeSpaceForMove(context, selection, destinationAlbum, copy)) return;

    showOpReport<MoveOpEvent>(
      context: context,
      selection: selection,
      opStream: ImageFileService.move(selection, copy: copy, destinationAlbum: destinationAlbum),
      onDone: (processed) async {
        final movedOps = processed.where((e) => e.success);
        final movedCount = movedOps.length;
        final selectionCount = selection.length;
        if (movedCount < selectionCount) {
          final count = selectionCount - movedCount;
          showFeedback(context, 'Failed to ${copy ? 'copy' : 'move'} ${Intl.plural(count, one: '$count item', other: '$count items')}');
        } else {
          final count = movedCount;
          showFeedback(context, '${copy ? 'Copied' : 'Moved'} ${Intl.plural(count, one: '$count item', other: '$count items')}');
        }
        await source.updateAfterMove(
          selection: selection,
          copy: copy,
          destinationAlbum: destinationAlbum,
          movedOps: movedOps,
        );
        collection.clearSelection();
        collection.browse();
      },
    );
  }

  Future<void> _refreshSelectionMetadata() async {
    collection.selection.forEach((entry) => entry.clearMetadata());
    final source = collection.source;
    source.stateNotifier.value = SourceState.cataloguing;
    await source.catalogEntries();
    source.stateNotifier.value = SourceState.locating;
    await source.locateEntries();
    source.stateNotifier.value = SourceState.ready;
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final selection = collection.selection.toList();
    final count = selection.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          content: Text('Are you sure you want to delete ${Intl.plural(count, one: 'this item', other: 'these $count items')}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.toUpperCase()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'.toUpperCase()),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    if (!await checkStoragePermission(context, selection)) return;

    showOpReport<ImageOpEvent>(
      context: context,
      selection: selection,
      opStream: ImageFileService.delete(selection),
      onDone: (processed) {
        final deletedUris = processed.where((e) => e.success).map((e) => e.uri).toList();
        final deletedCount = deletedUris.length;
        final selectionCount = selection.length;
        if (deletedCount < selectionCount) {
          final count = selectionCount - deletedCount;
          showFeedback(context, 'Failed to delete ${Intl.plural(count, one: '$count item', other: '$count items')}');
        }
        if (deletedCount > 0) {
          collection.source.removeEntries(selection.where((e) => deletedUris.contains(e.uri)).toList());
        }
        collection.clearSelection();
        collection.browse();
      },
    );
  }
}
