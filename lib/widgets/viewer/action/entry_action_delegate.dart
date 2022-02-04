import 'dart:async';
import 'dart:convert';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_metadata_edition.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/services/media/media_file_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/entry_storage.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/add_shortcut_dialog.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/rename_dialog.dart';
import 'package:aves/widgets/dialogs/export_entry_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:aves/widgets/viewer/action/printer.dart';
import 'package:aves/widgets/viewer/action/single_entry_editor.dart';
import 'package:aves/widgets/viewer/debug/debug_page.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:aves/widgets/viewer/source_viewer_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class EntryActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin, SingleEntryEditorMixin, EntryStorageMixin {
  @override
  final AvesEntry entry;

  EntryActionDelegate(this.entry);

  void onActionSelected(BuildContext context, EntryAction action) {
    switch (action) {
      case EntryAction.addShortcut:
        _addShortcut(context);
        break;
      case EntryAction.copyToClipboard:
        androidAppService.copyToClipboard(entry.uri, entry.bestTitle).then((success) {
          showFeedback(context, success ? context.l10n.genericSuccessFeedback : context.l10n.genericFailureFeedback);
        });
        break;
      case EntryAction.delete:
        _delete(context);
        break;
      case EntryAction.convert:
        _convert(context);
        break;
      case EntryAction.print:
        EntryPrinter(entry).print(context);
        break;
      case EntryAction.rename:
        _rename(context);
        break;
      case EntryAction.copy:
        _move(context, moveType: MoveType.copy);
        break;
      case EntryAction.move:
        _move(context, moveType: MoveType.move);
        break;
      case EntryAction.share:
        androidAppService.shareEntries({entry}).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.toggleFavourite:
        entry.toggleFavourite();
        break;
      // raster
      case EntryAction.rotateCCW:
        _rotate(context, clockwise: false);
        break;
      case EntryAction.rotateCW:
        _rotate(context, clockwise: true);
        break;
      case EntryAction.flip:
        _flip(context);
        break;
      // vector
      case EntryAction.viewSource:
        _goToSourceViewer(context);
        break;
      // external
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
      case EntryAction.setAs:
        androidAppService.setAs(entry.uri, entry.mimeType).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      // platform
      case EntryAction.rotateScreen:
        _rotateScreen(context);
        break;
      // debug
      case EntryAction.debug:
        _goToDebug(context);
        break;
    }
  }

  Future<void> _addShortcut(BuildContext context) async {
    final result = await showDialog<Tuple2<AvesEntry?, String>>(
      context: context,
      builder: (context) => AddShortcutDialog(
        defaultName: entry.bestTitle ?? '',
      ),
    );
    if (result == null) return;

    final name = result.item2;
    if (name.isEmpty) return;

    await androidAppService.pinToHomeScreen(name, entry, uri: entry.uri);
    if (!device.showPinShortcutFeedback) {
      showFeedback(context, context.l10n.genericSuccessFeedback);
    }
  }

  Future<void> _flip(BuildContext context) async {
    await edit(context, entry.flip);
  }

  Future<void> _rotate(BuildContext context, {required bool clockwise}) async {
    await edit(context, () => entry.rotate(clockwise: clockwise));
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

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
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
      EntryRemovedNotification(entry).dispatch(context);
    }
  }

  Future<void> _convert(BuildContext context) async {
    final options = await showDialog<EntryExportOptions>(
      context: context,
      builder: (context) => ExportEntryDialog(entry: entry),
    );
    if (options == null) return;

    final source = context.read<CollectionSource>();
    if (!source.initialized) {
      await source.init();
      unawaited(source.refresh());
    }
    final destinationAlbum = await pickAlbum(context: context, moveType: MoveType.export);
    if (destinationAlbum == null) return;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    if (!await checkFreeSpaceForMove(context, {entry}, destinationAlbum, MoveType.export)) return;

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
    await showOpReport<ExportOpEvent>(
      context: context,
      opStream: mediaFileService.export(
        selection,
        options: options,
        destinationAlbum: destinationAlbum,
        nameConflictStrategy: NameConflictStrategy.rename,
      ),
      itemCount: selectionCount,
      onDone: (processed) {
        final successOps = processed.where((e) => e.success).toSet();
        final exportedOps = successOps.where((e) => !e.skipped).toSet();
        final newUris = exportedOps.map((v) => v.newFields['uri'] as String?).whereNotNull().toSet();
        final isMainMode = context.read<ValueNotifier<AppMode>>().value == AppMode.main;

        source.resumeMonitoring();
        source.refreshUris(newUris);

        final showAction = isMainMode && newUris.isNotEmpty
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
                  final targetEntry = targetCollection.sortedEntries.firstWhereOrNull((entry) => newUris.contains(entry.uri));
                  if (targetEntry != null) {
                    highlightInfo.trackItem(targetEntry, highlightItem: targetEntry);
                  }
                },
              )
            : null;
        final successCount = successOps.length;
        if (successCount < selectionCount) {
          final count = selectionCount - successCount;
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

  Future<void> _move(BuildContext context, {required MoveType moveType}) async {
    await move(
      context,
      moveType: moveType,
      selectedItems: {entry},
      onSuccess: moveType == MoveType.move ? () => EntryRemovedNotification(entry).dispatch(context) : null,
    );
  }

  Future<void> _rename(BuildContext context) async {
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

  void _goToSourceViewer(BuildContext context) {
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

  void _goToDebug(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: ViewerDebugPage.routeName),
        builder: (context) => ViewerDebugPage(entry: entry),
      ),
    );
  }
}
