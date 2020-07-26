import 'dart:async';

import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/album/app_bar.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/common/action_delegates/create_album_dialog.dart';
import 'package:aves/widgets/common/action_delegates/feedback.dart';
import 'package:aves/widgets/common/action_delegates/permission_aware.dart';
import 'package:aves/widgets/common/entry_actions.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grid_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SelectionActionDelegate with FeedbackMixin, PermissionAwareMixin {
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

  Future _moveSelection(BuildContext context, {@required bool copy}) async {
    final source = collection.source;
    final destinationAlbum = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        builder: (context) {
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
              ],
              floating: true,
            ),
            filterEntries: source.getAlbumEntries(),
            filterBuilder: (s) => AlbumFilter(s, source.getUniqueAlbumName(s)),
            emptyBuilder: () => EmptyContent(
              icon: AIcons.album,
              text: 'No albums',
            ),
            onPressed: (filter) => Navigator.pop<String>(context, (filter as AlbumFilter)?.album),
          );
        },
      ),
    );
    if (destinationAlbum == null || destinationAlbum.isEmpty) return;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    final selection = collection.selection.toList();
    if (!await checkStoragePermission(context, selection)) return;

    _showOpReport<MoveOpEvent>(
      context: context,
      selection: selection,
      opStream: ImageFileService.move(selection, copy: copy, destinationAlbum: destinationAlbum),
      onDone: (processed) async {
        debugPrint('$runtimeType _moveSelection onDone');
        final movedOps = processed.where((e) => e.success);
        final movedCount = movedOps.length;
        final selectionCount = selection.length;
        if (movedCount < selectionCount) {
          final count = selectionCount - movedCount;
          showFeedback(context, 'Failed to move ${Intl.plural(count, one: '$count item', other: '$count items')}');
        } else {
          final count = movedCount;
          showFeedback(context, '${copy ? 'Copied' : 'Moved'} ${Intl.plural(count, one: '$count item', other: '$count items')}');
        }
        if (movedCount > 0) {
          final fromAlbums = <String>{};
          final movedEntries = <ImageEntry>[];
          if (copy) {
            movedOps.forEach((movedOp) {
              final sourceUri = movedOp.uri;
              final newFields = movedOp.newFields;
              final sourceEntry = selection.firstWhere((entry) => entry.uri == sourceUri, orElse: () => null);
              fromAlbums.add(sourceEntry.directory);
              movedEntries.add(sourceEntry?.copyWith(
                uri: newFields['uri'] as String,
                path: newFields['path'] as String,
                contentId: newFields['contentId'] as int,
              ));
            });
            await metadataDb.saveMetadata(movedEntries.map((entry) => entry.catalogMetadata));
            await metadataDb.saveAddresses(movedEntries.map((entry) => entry.addressDetails));
          } else {
            await Future.forEach<MoveOpEvent>(movedOps, (movedOp) async {
              final sourceUri = movedOp.uri;
              final newFields = movedOp.newFields;
              final entry = selection.firstWhere((entry) => entry.uri == sourceUri, orElse: () => null);
              if (entry != null) {
                fromAlbums.add(entry.directory);
                final oldContentId = entry.contentId;
                final newContentId = newFields['contentId'] as int;
                entry.uri = newFields['uri'] as String;
                entry.path = newFields['path'] as String;
                entry.contentId = newContentId;
                movedEntries.add(entry);

                await metadataDb.updateMetadataId(oldContentId, entry.catalogMetadata);
                await metadataDb.updateAddressId(oldContentId, entry.addressDetails);
                await favourites.move(oldContentId, entry);
              }
            });
          }
          source.applyMove(
            entries: movedEntries,
            fromAlbums: fromAlbums,
            toAlbum: destinationAlbum,
            copy: copy,
          );
        }
        collection.clearSelection();
        collection.browse();
      },
    );
  }

  void _refreshSelectionMetadata() async {
    collection.selection.forEach((entry) => entry.clearMetadata());
    final source = collection.source;
    source.stateNotifier.value = SourceState.cataloguing;
    await source.catalogEntries();
    source.stateNotifier.value = SourceState.locating;
    await source.locateEntries();
    source.stateNotifier.value = SourceState.ready;
  }

  void _showDeleteDialog(BuildContext context) async {
    final selection = collection.selection.toList();
    final count = selection.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Are you sure you want to delete ${Intl.plural(count, one: 'this item', other: 'these $count items')}?'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.toUpperCase()),
            ),
            FlatButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'.toUpperCase()),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    if (!await checkStoragePermission(context, selection)) return;

    _showOpReport<ImageOpEvent>(
      context: context,
      selection: selection,
      opStream: ImageFileService.delete(selection),
      onDone: (processed) {
        final deletedUris = processed.where((e) => e.success).map((e) => e.uri);
        final deletedCount = deletedUris.length;
        final selectionCount = selection.length;
        if (deletedCount < selectionCount) {
          final count = selectionCount - deletedCount;
          showFeedback(context, 'Failed to delete ${Intl.plural(count, one: '$count item', other: '$count items')}');
        }
        if (deletedCount > 0) {
          collection.source.removeEntries(selection.where((e) => deletedUris.contains(e.uri)));
        }
        collection.clearSelection();
        collection.browse();
      },
    );
  }

  // selection action report overlay

  OverlayEntry _opReportOverlayEntry;

  void _showOpReport<T extends ImageOpEvent>({
    @required BuildContext context,
    @required List<ImageEntry> selection,
    @required Stream<T> opStream,
    @required void Function(Set<T> processed) onDone,
  }) {
    final processed = <T>{};

    // do not handle completion inside `StreamBuilder`
    // as it could be called multiple times
    Future<void> onComplete() => _hideOpReportOverlay().then((_) => onDone(processed));
    opStream.listen(
      processed.add,
      onError: (error) {
        debugPrint('_showOpReport error=$error');
        onComplete();
      },
      onDone: onComplete,
    );

    _opReportOverlayEntry = OverlayEntry(
      builder: (context) {
        return AbsorbPointer(
          child: StreamBuilder<T>(
              stream: opStream,
              builder: (context, snapshot) {
                Widget child = SizedBox.shrink();
                if (!snapshot.hasError && snapshot.connectionState == ConnectionState.active) {
                  final percent = processed.length.toDouble() / selection.length;
                  child = CircularPercentIndicator(
                    percent: percent,
                    lineWidth: 16,
                    radius: 160,
                    backgroundColor: Colors.white24,
                    progressColor: Theme.of(context).accentColor,
                    animation: true,
                    center: Text(NumberFormat.percentPattern().format(percent)),
                    animateFromLastPercent: true,
                  );
                }
                return AnimatedSwitcher(
                  duration: Durations.collectionOpOverlayAnimation,
                  child: child,
                );
              }),
        );
      },
    );
    Overlay.of(context).insert(_opReportOverlayEntry);
  }

  Future<void> _hideOpReportOverlay() async {
    await Future.delayed(Durations.collectionOpOverlayAnimation * timeDilation);
    _opReportOverlayEntry.remove();
    _opReportOverlayEntry = null;
  }
}
