import 'dart:io';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/chip_set_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/action_mixins/entry_storage.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/create_album_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/rename_album_dialog.dart';
import 'package:aves/widgets/dialogs/tile_view_dialog.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AlbumChipSetActionDelegate extends ChipSetActionDelegate<AlbumFilter> with EntryStorageMixin {
  final Iterable<FilterGridItem<AlbumFilter>> _items;

  AlbumChipSetActionDelegate(Iterable<FilterGridItem<AlbumFilter>> items) : _items = items;

  @override
  Iterable<FilterGridItem<AlbumFilter>> get allItems => _items;

  @override
  ChipSortFactor get sortFactor => settings.albumSortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.albumSortFactor = factor;

  @override
  TileLayout get tileLayout => settings.getTileLayout(AlbumListPage.routeName);

  @override
  set tileLayout(TileLayout tileLayout) => settings.setTileLayout(AlbumListPage.routeName, tileLayout);

  @override
  bool isVisible(
    ChipSetAction action, {
    required AppMode appMode,
    required bool isSelecting,
    required int itemCount,
    required Set<AlbumFilter> selectedFilters,
  }) {
    switch (action) {
      case ChipSetAction.createAlbum:
        return appMode == AppMode.main && !isSelecting;
      case ChipSetAction.delete:
      case ChipSetAction.rename:
        return appMode == AppMode.main && isSelecting;
      default:
        return super.isVisible(
          action,
          appMode: appMode,
          isSelecting: isSelecting,
          itemCount: itemCount,
          selectedFilters: selectedFilters,
        );
    }
  }

  @override
  bool canApply(
    ChipSetAction action, {
    required bool isSelecting,
    required int itemCount,
    required Set<AlbumFilter> selectedFilters,
  }) {
    switch (action) {
      case ChipSetAction.rename:
        {
          if (selectedFilters.length != 1) return false;
          // do not allow renaming volume root
          final dir = VolumeRelativeDirectory.fromPath(selectedFilters.first.album);
          return dir != null && dir.relativeDir.isNotEmpty;
        }
      default:
        return super.canApply(
          action,
          isSelecting: isSelecting,
          itemCount: itemCount,
          selectedFilters: selectedFilters,
        );
    }
  }

  @override
  void onActionSelected(BuildContext context, Set<AlbumFilter> filters, ChipSetAction action) {
    switch (action) {
      // general
      case ChipSetAction.createAlbum:
        _createAlbum(context);
        break;
      // single/multiple filters
      case ChipSetAction.delete:
        _delete(context, filters);
        break;
      // single filter
      case ChipSetAction.rename:
        _rename(context, filters.first);
        break;
      default:
        break;
    }
    super.onActionSelected(context, filters, action);
  }

  void _browse(BuildContext context) => context.read<Selection<FilterGridItem<AlbumFilter>>>().browse();

  @override
  Future<void> configureView(BuildContext context) async {
    final initialValue = Tuple3(
      sortFactor,
      settings.albumGroupFactor,
      tileLayout,
    );
    final value = await showDialog<Tuple3<ChipSortFactor?, AlbumChipGroupFactor?, TileLayout?>>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return TileViewDialog<ChipSortFactor, AlbumChipGroupFactor, TileLayout>(
          initialValue: initialValue,
          sortOptions: {
            ChipSortFactor.date: l10n.sortByDate,
            ChipSortFactor.name: l10n.sortByName,
            ChipSortFactor.count: l10n.sortByItemCount,
            ChipSortFactor.size: l10n.sortBySize,
          },
          groupOptions: {
            AlbumChipGroupFactor.importance: l10n.albumGroupTier,
            AlbumChipGroupFactor.volume: l10n.albumGroupVolume,
            AlbumChipGroupFactor.none: l10n.albumGroupNone,
          },
          layoutOptions: {
            TileLayout.grid: l10n.tileLayoutGrid,
            TileLayout.list: l10n.tileLayoutList,
          },
        );
      },
    );
    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
    if (value != null && initialValue != value) {
      sortFactor = value.item1!;
      settings.albumGroupFactor = value.item2!;
      tileLayout = value.item3!;
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
          // local context may be deactivated when action is triggered after navigation
          final context = AvesApp.navigatorKey.currentContext;
          if (context != null) {
            final highlightInfo = context.read<HighlightInfo>();
            final filter = AlbumFilter(newAlbum, source.getAlbumDisplayName(context, newAlbum));
            if (context.currentRouteName == AlbumListPage.routeName) {
              highlightInfo.trackItem(FilterGridItem(filter, null), highlightItem: filter);
            } else {
              highlightInfo.set(filter);
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: AlbumListPage.routeName),
                  builder: (_) => const AlbumListPage(),
                ),
                (route) => false,
              );
            }
          }
        },
      );
      showFeedback(context, context.l10n.genericSuccessFeedback, showAction);
    }
  }

  Future<void> _delete(BuildContext context, Set<AlbumFilter> filters) async {
    final source = context.read<CollectionSource>();
    final todoEntries = source.visibleEntries.where((entry) => filters.any((f) => f.test(entry))).toSet();
    final todoAlbums = filters.map((v) => v.album).toSet();
    final filledAlbums = todoEntries.map((e) => e.directory).whereNotNull().toSet();
    final emptyAlbums = todoAlbums.whereNot(filledAlbums.contains).toSet();

    if (settings.enableBin && filledAlbums.isNotEmpty) {
      await move(
        context,
        moveType: MoveType.toBin,
        entries: todoEntries,
        onSuccess: () {
          source.forgetNewAlbums(todoAlbums);
          source.cleanEmptyAlbums(emptyAlbums);
          _browse(context);
        },
      );
      return;
    }

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final todoCount = todoEntries.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
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
    final opId = mediaEditService.newOpId;
    await showOpReport<ImageOpEvent>(
      context: context,
      opStream: mediaEditService.delete(opId: opId, entries: todoEntries),
      itemCount: todoCount,
      onCancel: () => mediaEditService.cancelFileOp(opId),
      onDone: (processed) async {
        final successOps = processed.where((event) => event.success);
        final deletedOps = successOps.where((e) => !e.skipped).toSet();
        final deletedUris = deletedOps.map((event) => event.uri).toSet();
        await source.removeEntries(deletedUris, includeTrash: true);
        _browse(context);
        source.resumeMonitoring();

        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedbackWithMessenger(context, messenger, l10n.collectionDeleteFailureFeedback(count));
        }

        // cleanup
        await storageService.deleteEmptyDirectories(filledAlbums);
      },
    );
  }

  Future<void> _rename(BuildContext context, AlbumFilter filter) async {
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

    final destinationAlbumParent = pContext.dirname(album);
    final destinationAlbum = pContext.join(destinationAlbumParent, newName);
    if (!await checkFreeSpaceForMove(context, todoEntries, destinationAlbum, MoveType.move)) return;

    if (!await checkStoragePermissionForAlbums(context, {album})) return;

    if (!await File(destinationAlbum).exists()) {
      // access to the destination parent is required to create the underlying destination folder
      if (!await checkStoragePermissionForAlbums(context, {destinationAlbumParent})) return;
    }

    source.pauseMonitoring();
    final opId = mediaEditService.newOpId;
    await showOpReport<MoveOpEvent>(
      context: context,
      opStream: mediaEditService.move(
        opId: opId,
        entriesByDestination: {destinationAlbum: todoEntries},
        copy: false,
        // there should be no file conflict, as the target directory itself does not exist
        nameConflictStrategy: NameConflictStrategy.rename,
      ),
      itemCount: todoCount,
      onCancel: () => mediaEditService.cancelFileOp(opId),
      onDone: (processed) async {
        final successOps = processed.where((e) => e.success).toSet();
        final movedOps = successOps.where((e) => !e.skipped).toSet();
        await source.renameAlbum(album, destinationAlbum, todoEntries, movedOps);
        _browse(context);
        source.resumeMonitoring();

        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedbackWithMessenger(context, messenger, l10n.collectionMoveFailureFeedback(count));
        } else {
          showFeedbackWithMessenger(context, messenger, l10n.genericSuccessFeedback);
        }

        // cleanup
        await storageService.deleteEmptyDirectories({album});
      },
    );
  }
}
