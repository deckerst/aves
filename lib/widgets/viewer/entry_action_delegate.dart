import 'dart:async';
import 'dart:convert';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/export_entry_dialog.dart';
import 'package:aves/widgets/dialogs/rename_entry_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:aves/widgets/viewer/debug/debug_page.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:aves/widgets/viewer/printer.dart';
import 'package:aves/widgets/viewer/source_viewer_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  void onActionSelected(BuildContext context, AvesEntry entry, EntryAction action) {
    switch (action) {
      case EntryAction.toggleFavourite:
        entry.toggleFavourite();
        break;
      case EntryAction.copyToClipboard:
        androidAppService.copyToClipboard(entry.uri, entry.bestTitle).then((success) {
          showFeedback(context, success ? context.l10n.genericSuccessFeedback : context.l10n.genericFailureFeedback);
        });
        break;
      case EntryAction.delete:
        _showDeleteDialog(context, entry);
        break;
      case EntryAction.export:
        _showExportDialog(context, entry);
        break;
      case EntryAction.info:
        ShowInfoNotification().dispatch(context);
        break;
      case EntryAction.print:
        EntryPrinter(entry).print(context);
        break;
      case EntryAction.rename:
        _showRenameDialog(context, entry);
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
        androidAppService.edit(entry.uri, entry.mimeType).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.open:
        androidAppService.open(entry.uri, entry.mimeTypeAnySubtype).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.openMap:
        androidAppService.openMap(entry.latLng!).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.rotateScreen:
        _rotateScreen(context);
        break;
      case EntryAction.setAs:
        androidAppService.setAs(entry.uri, entry.mimeType).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.share:
        androidAppService.shareEntries({entry}).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.viewSource:
        _goToSourceViewer(context, entry);
        break;
      case EntryAction.viewMotionPhotoVideo:
        OpenEmbeddedDataNotification.motionPhotoVideo().dispatch(context);
        break;
      case EntryAction.debug:
        _goToDebug(context, entry);
        break;
    }
  }

  Future<void> _flip(BuildContext context, AvesEntry entry) async {
    if (!await checkStoragePermission(context, {entry})) return;

    final success = await entry.flip(persist: _isMainMode(context));
    if (!success) showFeedback(context, context.l10n.genericFailureFeedback);
  }

  Future<void> _rotate(BuildContext context, AvesEntry entry, {required bool clockwise}) async {
    if (!await checkStoragePermission(context, {entry})) return;

    final success = await entry.rotate(clockwise: clockwise, persist: _isMainMode(context));
    if (!success) showFeedback(context, context.l10n.genericFailureFeedback);
  }

  Future<void> _rotateScreen(BuildContext context) async {
    switch (context.read<MediaQueryData>().orientation) {
      case Orientation.landscape:
        await windowService.requestOrientation(Orientation.portrait);
        break;
      case Orientation.portrait:
        await windowService.requestOrientation(Orientation.landscape);
        break;
    }
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
      final source = context.read<CollectionSource>();
      if (source.initialized) {
        await source.removeEntries({entry.uri});
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

    final mimeType = await showDialog<String>(
      context: context,
      builder: (context) => ExportEntryDialog(entry: entry),
    );
    if (mimeType == null) return;

    final selection = <AvesEntry>{};
    if (entry.isMultiPage) {
      final multiPageInfo = await entry.getMultiPageInfo();
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
    source.pauseMonitoring();
    showOpReport<ExportOpEvent>(
      context: context,
      // TODO TLAD [SVG] export separately from raster images (sending bytes, like frame captures)
      opStream: mediaFileService.export(
        selection,
        mimeType: mimeType,
        destinationAlbum: destinationAlbum,
        nameConflictStrategy: NameConflictStrategy.rename,
      ),
      itemCount: selectionCount,
      onDone: (processed) {
        final exportOps = processed.where((e) => e.success);
        final exportCount = exportOps.length;
        final isMainMode = context.read<ValueNotifier<AppMode>>().value == AppMode.main;

        source.resumeMonitoring();
        source.refreshUris(exportOps.map((v) => v.newFields['uri'] as String?).whereNotNull().toSet());

        final showAction = isMainMode && exportCount > 0
            ? SnackBarAction(
                label: context.l10n.showButtonLabel,
                onPressed: () async {
                  final highlightInfo = context.read<HighlightInfo>();
                  final targetCollection = CollectionLens(
                    source: source,
                    filters: {AlbumFilter(destinationAlbum, source.getAlbumDisplayName(context, destinationAlbum))},
                  );
                  unawaited(Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: CollectionPage.routeName),
                      builder: (context) => CollectionPage(
                        collection: targetCollection,
                      ),
                    ),
                    (route) => false,
                  ));
                  final delayDuration = context.read<DurationsData>().staggeredAnimationPageTarget;
                  await Future.delayed(delayDuration + Durations.highlightScrollInitDelay);
                  final newUris = exportOps.map((v) => v.newFields['uri'] as String?).toSet();
                  final targetEntry = targetCollection.sortedEntries.firstWhereOrNull((entry) => newUris.contains(entry.uri));
                  if (targetEntry != null) {
                    highlightInfo.trackItem(targetEntry, highlightItem: targetEntry);
                  }
                },
              )
            : null;
        if (exportCount < selectionCount) {
          final count = selectionCount - exportCount;
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
      builder: (context) => RenameEntryDialog(entry: entry),
    );
    if (newName == null || newName.isEmpty) return;

    if (!await checkStoragePermission(context, {entry})) return;

    final success = await context.read<CollectionSource>().renameEntry(entry, newName, persist: _isMainMode(context));

    if (success) {
      showFeedback(context, context.l10n.genericSuccessFeedback);
    } else {
      showFeedback(context, context.l10n.genericFailureFeedback);
    }
  }

  bool _isMainMode(BuildContext context) => context.read<ValueNotifier<AppMode>>().value == AppMode.main;

  void _goToSourceViewer(BuildContext context, AvesEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: SourceViewerPage.routeName),
        builder: (context) => SourceViewerPage(
          loader: () => mediaFileService.getSvg(entry.uri, entry.mimeType).then(utf8.decode),
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
