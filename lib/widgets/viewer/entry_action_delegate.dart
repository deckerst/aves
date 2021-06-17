import 'dart:convert';

import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:aves/services/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/rename_entry_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:aves/widgets/viewer/debug/debug_page.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:aves/widgets/viewer/printer.dart';
import 'package:aves/widgets/viewer/source_viewer_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

class EntryActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  final CollectionLens? collection;
  final VoidCallback showInfo;

  EntryActionDelegate({
    required this.collection,
    required this.showInfo,
  });

  void onActionSelected(BuildContext context, AvesEntry entry, EntryAction action) {
    switch (action) {
      case EntryAction.toggleFavourite:
        entry.toggleFavourite();
        break;
      case EntryAction.delete:
        _showDeleteDialog(context, entry);
        break;
      case EntryAction.export:
        _showExportDialog(context, entry);
        break;
      case EntryAction.info:
        showInfo();
        break;
      case EntryAction.rename:
        _showRenameDialog(context, entry);
        break;
      case EntryAction.print:
        EntryPrinter(entry).print(context);
        break;
      case EntryAction.rotateCCW:
        _rotate(context, entry, clockwise: false);
        break;
      case EntryAction.rotateCW:
        _rotate(context, entry, clockwise: true);
        break;
      case EntryAction.flip:
        _flip(context, entry);
        break;
      case EntryAction.edit:
        AndroidAppService.edit(entry.uri, entry.mimeType).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.open:
        AndroidAppService.open(entry.uri, entry.mimeTypeAnySubtype).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.openMap:
        AndroidAppService.openMap(entry.geoUri!).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.setAs:
        AndroidAppService.setAs(entry.uri, entry.mimeType).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.share:
        AndroidAppService.shareEntries({entry}).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.viewSource:
        _goToSourceViewer(context, entry);
        break;
      case EntryAction.debug:
        _goToDebug(context, entry);
        break;
    }
  }

  Future<void> _flip(BuildContext context, AvesEntry entry) async {
    if (!await checkStoragePermission(context, {entry})) return;

    final success = await entry.flip();
    if (!success) showFeedback(context, context.l10n.genericFailureFeedback);
  }

  Future<void> _rotate(BuildContext context, AvesEntry entry, {required bool clockwise}) async {
    if (!await checkStoragePermission(context, {entry})) return;

    final success = await entry.rotate(clockwise: clockwise);
    if (!success) showFeedback(context, context.l10n.genericFailureFeedback);
  }

  Future<void> _showDeleteDialog(BuildContext context, AvesEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          context: context,
          content: Text(context.l10n.deleteEntriesConfirmationDialogMessage(1)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.deleteButtonLabel),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    if (!await checkStoragePermission(context, {entry})) return;

    if (!await entry.delete()) {
      showFeedback(context, context.l10n.genericFailureFeedback);
    } else {
      if (collection != null) {
        await collection!.source.removeEntries({entry.uri});
      }
      EntryDeletedNotification(entry).dispatch(context);
    }
  }

  Future<void> _showExportDialog(BuildContext context, AvesEntry entry) async {
    final source = context.read<CollectionSource>();
    if (!source.initialized) {
      await source.init();
      unawaited(source.refresh());
    }
    final destinationAlbum = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        settings: const RouteSettings(name: AlbumPickPage.routeName),
        builder: (context) => AlbumPickPage(source: source, moveType: MoveType.export),
      ),
    );

    if (destinationAlbum == null || destinationAlbum.isEmpty) return;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    if (!await checkFreeSpaceForMove(context, {entry}, destinationAlbum, MoveType.export)) return;

    final selection = <AvesEntry>{};
    if (entry.isMultiPage) {
      final multiPageInfo = await metadataService.getMultiPageInfo(entry);
      if (multiPageInfo != null) {
        if (entry.isMotionPhoto) {
          await multiPageInfo.extractMotionPhotoVideo();
        }
        if (multiPageInfo.pageCount > 1) {
          selection.addAll(multiPageInfo.exportEntries);
        }
      }
    } else {
      selection.add(entry);
    }

    final selectionCount = selection.length;
    showOpReport<ExportOpEvent>(
      context: context,
      opStream: imageFileService.export(
        selection,
        mimeType: MimeTypes.jpeg,
        destinationAlbum: destinationAlbum,
      ),
      itemCount: selectionCount,
      onDone: (processed) {
        final movedOps = processed.where((e) => e.success);
        final movedCount = movedOps.length;
        final _collection = collection;
        final showAction = _collection != null && movedCount > 0
            ? SnackBarAction(
                label: context.l10n.showButtonLabel,
                onPressed: () async {
                  final highlightInfo = context.read<HighlightInfo>();
                  final targetCollection = CollectionLens(
                    source: source,
                    filters: {AlbumFilter(destinationAlbum, source.getAlbumDisplayName(context, destinationAlbum))},
                    groupFactor: _collection.groupFactor,
                    sortFactor: _collection.sortFactor,
                  );
                  unawaited(Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: CollectionPage.routeName),
                      builder: (context) {
                        return CollectionPage(
                          targetCollection,
                        );
                      },
                    ),
                    (route) => false,
                  ));
                  await Future.delayed(Durations.staggeredAnimationPageTarget + Durations.highlightScrollInitDelay);
                  final newUris = movedOps.map((v) => v.newFields['uri'] as String?).toSet();
                  final targetEntry = targetCollection.sortedEntries.firstWhereOrNull((entry) => newUris.contains(entry.uri));
                  if (targetEntry != null) {
                    highlightInfo.trackItem(targetEntry, highlightItem: targetEntry);
                  }
                },
              )
            : null;
        if (movedCount < selectionCount) {
          final count = selectionCount - movedCount;
          showFeedback(
            context,
            context.l10n.collectionExportFailureFeedback(count),
            showAction,
          );
        } else {
          showFeedback(
            context,
            context.l10n.genericSuccessFeedback,
            showAction,
          );
        }
      },
    );
  }

  Future<void> _showRenameDialog(BuildContext context, AvesEntry entry) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameEntryDialog(entry),
    );
    if (newName == null || newName.isEmpty) return;

    if (!await checkStoragePermission(context, {entry})) return;

    final success = await context.read<CollectionSource>().renameEntry(entry, newName);

    if (success) {
      showFeedback(context, context.l10n.genericSuccessFeedback);
    } else {
      showFeedback(context, context.l10n.genericFailureFeedback);
    }
  }

  void _goToSourceViewer(BuildContext context, AvesEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: SourceViewerPage.routeName),
        builder: (context) => SourceViewerPage(
          loader: () => imageFileService.getSvg(entry.uri, entry.mimeType).then(utf8.decode),
        ),
      ),
    );
  }

  void _goToDebug(BuildContext context, AvesEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: ViewerDebugPage.routeName),
        builder: (context) => ViewerDebugPage(entry: entry),
      ),
    );
  }
}
