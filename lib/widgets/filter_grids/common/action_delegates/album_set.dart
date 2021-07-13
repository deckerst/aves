import 'dart:io';

import 'package:aves/model/actions/chip_set_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:aves/services/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/dialogs/create_album_dialog.dart';
import 'package:aves/widgets/dialogs/rename_album_dialog.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class AlbumChipSetActionDelegate extends ChipSetActionDelegate<AlbumFilter> {
  final Iterable<FilterGridItem<AlbumFilter>> _items;

  AlbumChipSetActionDelegate(Iterable<FilterGridItem<AlbumFilter>> items) : _items = items;

  @override
  Iterable<FilterGridItem<AlbumFilter>> get allItems => _items;

  @override
  ChipSortFactor get sortFactor => settings.albumSortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.albumSortFactor = factor;

  @override
  bool isValid(Set<AlbumFilter> filters, ChipSetAction action) {
    switch (action) {
      case ChipSetAction.delete:
      case ChipSetAction.rename:
        return true;
      default:
        return super.isValid(filters, action);
    }
  }

  @override
  bool canApply(Set<AlbumFilter> filters, ChipSetAction action) {
    switch (action) {
      case ChipSetAction.rename:
        {
          if (filters.length != 1) return false;
          // do not allow renaming volume root
          final dir = VolumeRelativeDirectory.fromPath(filters.first.album);
          return dir != null && dir.relativeDir.isNotEmpty;
        }
      default:
        return super.canApply(filters, action);
    }
  }

  @override
  void onActionSelected(BuildContext context, Set<AlbumFilter> filters, ChipSetAction action) {
    switch (action) {
      // general
      case ChipSetAction.group:
        _showGroupDialog(context);
        break;
      case ChipSetAction.createAlbum:
        _createAlbum(context);
        break;
      // single/multiple filters
      case ChipSetAction.delete:
        _showDeleteDialog(context, filters);
        break;
      // single filter
      case ChipSetAction.rename:
        _showRenameDialog(context, filters.first);
        break;
      default:
        break;
    }
    super.onActionSelected(context, filters, action);
  }

  Future<void> _showGroupDialog(BuildContext context) async {
    final factor = await showDialog<AlbumChipGroupFactor>(
      context: context,
      builder: (context) => AvesSelectionDialog<AlbumChipGroupFactor>(
        initialValue: settings.albumGroupFactor,
        options: {
          AlbumChipGroupFactor.importance: context.l10n.albumGroupTier,
          AlbumChipGroupFactor.volume: context.l10n.albumGroupVolume,
          AlbumChipGroupFactor.none: context.l10n.albumGroupNone,
        },
        title: context.l10n.albumGroupTitle,
      ),
    );
    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
    if (factor != null) {
      settings.albumGroupFactor = factor;
    }
  }

  void _createAlbum(BuildContext context) async {
    final newAlbum = await showDialog<String>(
      context: context,
      builder: (context) => const CreateAlbumDialog(),
    );
    if (newAlbum != null && newAlbum.isNotEmpty) {
      final source = context.read<CollectionSource>();
      source.createAlbum(newAlbum);

      final showAction = SnackBarAction(
        label: context.l10n.showButtonLabel,
        onPressed: () async {
          final filter = AlbumFilter(newAlbum, source.getAlbumDisplayName(context, newAlbum));
          context.read<HighlightInfo>().trackItem(FilterGridItem(filter, null), highlightItem: filter);
        },
      );
      showFeedback(context, context.l10n.genericSuccessFeedback, showAction);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, Set<AlbumFilter> filters) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final source = context.read<CollectionSource>();
    final todoEntries = source.visibleEntries.where((entry) => filters.any((f) => f.test(entry))).toSet();
    final todoCount = todoEntries.length;
    final todoAlbums = filters.map((v) => v.album).toSet();
    final filledAlbums = todoEntries.map((e) => e.directory).whereNotNull().toSet();
    final emptyAlbums = todoAlbums.whereNot(filledAlbums.contains).toSet();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          context: context,
          content: Text(filters.length == 1 ? l10n.deleteSingleAlbumConfirmationDialogMessage(todoCount) : l10n.deleteMultiAlbumConfirmationDialogMessage(todoCount)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.deleteButtonLabel),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    source.forgetNewAlbums(todoAlbums);
    source.cleanEmptyAlbums(emptyAlbums);

    if (!await checkStoragePermissionForAlbums(context, filledAlbums)) return;

    source.pauseMonitoring();
    showOpReport<ImageOpEvent>(
      context: context,
      opStream: imageFileService.delete(todoEntries),
      itemCount: todoCount,
      onDone: (processed) async {
        final deletedUris = processed.where((event) => event.success).map((event) => event.uri).toSet();
        await source.removeEntries(deletedUris);
        source.resumeMonitoring();

        final deletedCount = deletedUris.length;
        if (deletedCount < todoCount) {
          final count = todoCount - deletedCount;
          showFeedbackWithMessenger(messenger, l10n.collectionDeleteFailureFeedback(count));
        }

        // cleanup
        await storageService.deleteEmptyDirectories(filledAlbums);
      },
    );
  }

  Future<void> _showRenameDialog(BuildContext context, AlbumFilter filter) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final source = context.read<CollectionSource>();
    final album = filter.album;
    final todoEntries = source.visibleEntries.where(filter.test).toSet();
    final todoCount = todoEntries.length;

    final dir = VolumeRelativeDirectory.fromPath(album);
    // do not allow renaming volume root
    if (dir == null || dir.relativeDir.isEmpty) return;

    // check whether renaming is possible given OS restrictions,
    // before asking to input a new name
    final restrictedDirs = await storageService.getRestrictedDirectories();
    if (restrictedDirs.contains(dir)) {
      await showRestrictedDirectoryDialog(context, dir);
      return;
    }

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameAlbumDialog(album: album),
    );
    if (newName == null || newName.isEmpty) return;

    if (!await checkStoragePermissionForAlbums(context, {album})) return;

    final destinationAlbumParent = pContext.dirname(album);
    final destinationAlbum = pContext.join(destinationAlbumParent, newName);
    if (!await checkFreeSpaceForMove(context, todoEntries, destinationAlbum, MoveType.move)) return;

    if (!(await File(destinationAlbum).exists())) {
      // access to the destination parent is required to create the underlying destination folder
      if (!await checkStoragePermissionForAlbums(context, {destinationAlbumParent})) return;
    }

    source.pauseMonitoring();
    showOpReport<MoveOpEvent>(
      context: context,
      opStream: imageFileService.move(todoEntries, copy: false, destinationAlbum: destinationAlbum),
      itemCount: todoCount,
      onDone: (processed) async {
        final movedOps = processed.where((e) => e.success).toSet();
        await source.renameAlbum(album, destinationAlbum, todoEntries, movedOps);
        source.resumeMonitoring();

        final movedCount = movedOps.length;
        if (movedCount < todoCount) {
          final count = todoCount - movedCount;
          showFeedbackWithMessenger(messenger, l10n.collectionMoveFailureFeedback(count));
        } else {
          showFeedbackWithMessenger(messenger, l10n.genericSuccessFeedback);
        }

        // cleanup
        await storageService.deleteEmptyDirectories({album});
      },
    );
  }
}
