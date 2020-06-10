import 'dart:async';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/widgets/album/app_bar.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/common/action_delegates/create_album_dialog.dart';
import 'package:aves/widgets/common/action_delegates/permission_aware.dart';
import 'package:aves/widgets/common/entry_actions.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grid_page.dart';
import 'package:collection/collection.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SelectionActionDelegate with PermissionAwareMixin {
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
        _share();
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
              leading: const BackButton(),
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
            emptyBuilder: () => const EmptyContent(
              icon: AIcons.album,
              text: 'No albums!',
            ),
            onPressed: (filter) => Navigator.pop<String>(context, (filter as AlbumFilter)?.album),
          );
        },
      ),
    );
    if (destinationAlbum == null || destinationAlbum.isEmpty) return;

    final selection = collection.selection.toList();
    if (!await checkStoragePermission(context, selection)) return;

    _showOpReport(
      context: context,
      selection: selection,
      opStream: ImageFileService.move(selection, copy: copy, destinationAlbum: destinationAlbum),
      onDone: (Set<MoveOpEvent> processed) async {
        debugPrint('$runtimeType _moveSelection onDone');
        final movedOps = processed.where((e) => e.success);
        final movedCount = movedOps.length;
        final selectionCount = selection.length;
        if (movedCount < selectionCount) {
          final count = selectionCount - movedCount;
          _showFeedback(context, 'Failed to move ${Intl.plural(count, one: '${count} item', other: '${count} items')}');
        } else {
          final count = movedCount;
          _showFeedback(context, '${copy ? 'Copied' : 'Moved'} ${Intl.plural(count, one: '${count} item', other: '${count} items')}');
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
            await Future.forEach(movedOps, (movedOp) async {
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

  void _showDeleteDialog(BuildContext context) async {
    final selection = collection.selection.toList();
    final count = selection.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Are you sure you want to delete ${Intl.plural(count, one: 'this item', other: 'these ${count} items')}?'),
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

    _showOpReport(
      context: context,
      selection: selection,
      opStream: ImageFileService.delete(selection),
      onDone: (Set<ImageOpEvent> processed) {
        final deletedUris = processed.where((e) => e.success).map((e) => e.uri);
        final deletedCount = deletedUris.length;
        final selectionCount = selection.length;
        if (deletedCount < selectionCount) {
          final count = selectionCount - deletedCount;
          _showFeedback(context, 'Failed to delete ${Intl.plural(count, one: '${count} item', other: '${count} items')}');
        }
        if (deletedCount > 0) {
          collection.source.removeEntries(selection.where((e) => deletedUris.contains(e.uri)));
        }
        collection.clearSelection();
        collection.browse();
      },
    );
  }

  void _share() {
    final urisByMimeType = groupBy<ImageEntry, String>(collection.selection, (e) => e.mimeType).map((k, v) => MapEntry(k, v.map((e) => e.uri).toList()));
    AndroidAppService.share(urisByMimeType);
  }

  // selection action report overlay

  OverlayEntry _opReportOverlayEntry;

  static const _overlayAnimationDuration = Duration(milliseconds: 300);

  void _showOpReport<T extends ImageOpEvent>({
    @required BuildContext context,
    @required List<ImageEntry> selection,
    @required Stream<T> opStream,
    @required void Function(Set<T> processed) onDone,
  }) {
    final processed = <T>{};

    // do not handle completion inside `StreamBuilder`
    // as it could be called multiple times
    final onComplete = () => _hideOpReportOverlay().then((_) => onDone(processed));
    opStream.listen(
      (event) => processed.add(event),
      onError: (error) => onComplete(),
      onDone: onComplete,
    );

    _opReportOverlayEntry = OverlayEntry(
      builder: (context) {
        return StreamBuilder<T>(
            stream: opStream,
            builder: (context, snapshot) {
              Widget child = const SizedBox.shrink();
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
                duration: _overlayAnimationDuration,
                child: child,
              );
            });
      },
    );
    Overlay.of(context).insert(_opReportOverlayEntry);
  }

  Future<void> _hideOpReportOverlay() async {
    await Future.delayed(_overlayAnimationDuration);
    _opReportOverlayEntry.remove();
    _opReportOverlayEntry = null;
  }

  void _showFeedback(BuildContext context, String message) {
    Flushbar(
      message: message,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      borderColor: Colors.white30,
      borderWidth: 0.5,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 600),
    ).show(context);
  }
}
