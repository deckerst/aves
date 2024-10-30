import 'dart:io';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/vaults/details.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_mixins/entry_storage.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/create_album_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/edit_vault_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/rename_album_dialog.dart';
import 'package:aves/widgets/dialogs/tile_view_dialog.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

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
  bool get sortReverse => settings.albumSortReverse;

  @override
  set sortReverse(bool value) => settings.albumSortReverse = value;

  @override
  TileLayout get tileLayout => settings.getTileLayout(AlbumListPage.routeName);

  @override
  set tileLayout(TileLayout tileLayout) => settings.setTileLayout(AlbumListPage.routeName, tileLayout);

  static const _groupOptions = [
    AlbumChipGroupFactor.importance,
    AlbumChipGroupFactor.mimeType,
    AlbumChipGroupFactor.volume,
    AlbumChipGroupFactor.none,
  ];

  @override
  bool isVisible(
    ChipSetAction action, {
    required AppMode appMode,
    required bool isSelecting,
    required int itemCount,
    required Set<AlbumFilter> selectedFilters,
  }) {
    final selectedSingleItem = selectedFilters.length == 1;
    final isMain = appMode == AppMode.main;

    switch (action) {
      case ChipSetAction.createAlbum:
      case ChipSetAction.createVault:
        return !settings.isReadOnly && appMode.canCreateFilter && !isSelecting;
      case ChipSetAction.delete:
      case ChipSetAction.rename:
        return isMain && isSelecting && !settings.isReadOnly;
      case ChipSetAction.hide:
        return isMain && selectedFilters.none((v) => vaults.isVault(v.album));
      case ChipSetAction.configureVault:
        return isMain && selectedSingleItem && vaults.isVault(selectedFilters.first.album);
      case ChipSetAction.lockVault:
        return isMain && selectedFilters.any((v) => vaults.isVault(v.album));
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
    final selectedItemCount = selectedFilters.length;
    final hasSelection = selectedItemCount > 0;

    switch (action) {
      case ChipSetAction.rename:
        if (selectedFilters.length != 1) return false;

        final dirPath = selectedFilters.first.album;
        if (vaults.isVault(dirPath)) return true;

        // do not allow renaming volume root
        final dir = androidFileUtils.relativeDirectoryFromPath(dirPath);
        return dir != null && dir.relativeDir.isNotEmpty;
      case ChipSetAction.hide:
        return hasSelection;
      case ChipSetAction.lockVault:
        return selectedFilters.map((v) => v.album).any((v) => vaults.isVault(v) && !vaults.isLocked(v));
      case ChipSetAction.configureVault:
        return true;
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
  void onActionSelected(BuildContext context, ChipSetAction action) {
    reportService.log('$runtimeType handles $action');
    switch (action) {
      // general
      case ChipSetAction.createAlbum:
        _createAlbum(context, locked: false);
      case ChipSetAction.createVault:
        _createAlbum(context, locked: true);
      // single/multiple filters
      case ChipSetAction.delete:
        _delete(context);
      case ChipSetAction.lockVault:
        lockFilters(getSelectedFilters(context));
        browse(context);
      // single filter
      case ChipSetAction.rename:
        _rename(context);
      case ChipSetAction.configureVault:
        _configureVault(context);
      default:
        break;
    }
    super.onActionSelected(context, action);
  }

  @override
  Future<void> configureView(BuildContext context) async {
    final initialValue = (
      sortFactor,
      settings.albumGroupFactor,
      tileLayout,
      sortReverse,
    );
    final extentController = context.read<TileExtentController>();
    final value = await showDialog<(ChipSortFactor?, AlbumChipGroupFactor?, TileLayout?, bool)>(
      context: context,
      builder: (context) {
        return TileViewDialog<ChipSortFactor, AlbumChipGroupFactor, TileLayout>(
          initialValue: initialValue,
          sortOptions: ChipSetActionDelegate.sortOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          groupOptions: _groupOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          layoutOptions: ChipSetActionDelegate.layoutOptions.map((v) => TileViewDialogOption(value: v, title: v.getName(context), icon: v.icon)).toList(),
          sortOrder: (factor, reverse) => factor.getOrderName(context, reverse),
          tileExtentController: extentController,
        );
      },
      routeSettings: const RouteSettings(name: TileViewDialog.routeName),
    );
    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);
    if (value != null && initialValue != value) {
      sortFactor = value.$1!;
      settings.albumGroupFactor = value.$2!;
      tileLayout = value.$3!;
      sortReverse = value.$4;
    }
  }

  void _createAlbum(BuildContext context, {required bool locked}) async {
    final l10n = context.l10n;
    final source = context.read<CollectionSource>();
    late final String? directory;
    if (locked) {
      if (!await showSkippableConfirmationDialog(
        context: context,
        type: ConfirmationDialog.createVault,
        message: l10n.newVaultWarningDialogMessage,
        confirmationButtonLabel: l10n.continueButtonLabel,
      )) {
        return;
      }

      final details = await showDialog<VaultDetails>(
        context: context,
        builder: (context) => const EditVaultDialog(),
        routeSettings: const RouteSettings(name: CreateAlbumDialog.routeName),
      );
      if (details == null) return;

      await vaults.create(details);
      directory = details.path;
    } else {
      directory = await showDialog<String>(
        context: context,
        builder: (context) => const CreateAlbumDialog(),
        routeSettings: const RouteSettings(name: CreateAlbumDialog.routeName),
      );
      if (directory == null) return;
    }
    source.createAlbum(directory);

    final filter = AlbumFilter(directory, source.getAlbumDisplayName(context, directory));
    // get navigator beforehand because
    // local context may be deactivated when action is triggered after navigation
    final navigator = Navigator.maybeOf(context);
    final showAction = SnackBarAction(
      label: l10n.showButtonLabel,
      onPressed: () async {
        // local context may be deactivated when action is triggered after navigation
        if (navigator != null) {
          final context = navigator.context;
          final highlightInfo = context.read<HighlightInfo>();
          if (context.currentRouteName == AlbumListPage.routeName) {
            highlightInfo.trackItem(FilterGridItem(filter, null), highlightItem: filter);
          } else {
            highlightInfo.set(filter);
            await navigator.pushAndRemoveUntil(
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
    showFeedback(context, FeedbackType.info, l10n.genericSuccessFeedback, showAction);
  }

  Future<void> _delete(BuildContext context) async {
    final filters = getSelectedFilters(context);
    final byBinUsage = groupBy<AlbumFilter, bool>(filters, (filter) {
      final details = vaults.getVault(filter.album);
      return details?.useBin ?? settings.enableBin;
    });
    await Future.forEach(
        byBinUsage.entries,
        (kv) => _doDelete(
              context: context,
              filters: kv.value.toSet(),
              enableBin: kv.key,
            ));
    browse(context);
  }

  Future<void> _doDelete({
    required BuildContext context,
    required Set<AlbumFilter> filters,
    required bool enableBin,
  }) async {
    if (!await unlockFilters(context, filters)) return;

    final source = context.read<CollectionSource>();
    final todoEntries = source.visibleEntries.where((entry) => filters.any((f) => f.test(entry))).toSet();
    final todoAlbums = filters.map((v) => v.album).toSet();
    final filledAlbums = todoEntries.map((e) => e.directory).nonNulls.toSet();
    final emptyAlbums = todoAlbums.whereNot(filledAlbums.contains).toSet();

    if (enableBin && filledAlbums.isNotEmpty) {
      await doMove(
        context,
        moveType: MoveType.toBin,
        entries: todoEntries,
        onSuccess: () {
          source.forgetNewAlbums(todoAlbums);
          source.cleanEmptyAlbums(emptyAlbums);
          browse(context);
        },
      );
      return;
    }

    final l10n = context.l10n;
    final todoCount = todoEntries.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AvesDialog(
        content: Text(filters.length == 1 ? l10n.deleteSingleAlbumConfirmationDialogMessage(todoCount) : l10n.deleteMultiAlbumConfirmationDialogMessage(todoCount)),
        actions: [
          const CancelButton(),
          TextButton(
            onPressed: () => Navigator.maybeOf(context)?.pop(true),
            child: Text(l10n.deleteButtonLabel),
          ),
        ],
      ),
      routeSettings: const RouteSettings(name: AvesDialog.confirmationRouteName),
    );
    if (confirmed == null || !confirmed) return;

    settings.pinnedFilters = settings.pinnedFilters..removeAll(filters);
    source.forgetNewAlbums(todoAlbums);
    source.cleanEmptyAlbums(emptyAlbums);

    if (!await checkStoragePermissionForAlbums(context, filledAlbums)) return;

    await _deleteEntriesForever(context, todoEntries);

    final vaultAlbumFilters = filters.where((v) => vaults.isVault(v.album)).toSet();
    if (vaultAlbumFilters.isNotEmpty) {
      final allEntries = source.allEntries;
      final emptyVaultAlbums = vaultAlbumFilters.whereNot((v) => allEntries.any(v.test)).map((v) => v.album).toSet();
      await vaults.remove(emptyVaultAlbums);
    }
  }

  Future<void> _deleteEntriesForever(BuildContext context, Set<AvesEntry> todoEntries) async {
    if (todoEntries.isEmpty) return;

    final source = context.read<CollectionSource>();
    final filledAlbums = todoEntries.map((e) => e.directory).nonNulls.toSet();

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final todoCount = todoEntries.length;

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
        browse(context);
        source.resumeMonitoring();

        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedbackWithMessenger(context, messenger, FeedbackType.warn, l10n.collectionDeleteFailureFeedback(count));
        }

        // cleanup
        await storageService.deleteEmptyRegularDirectories(filledAlbums);
      },
    );
  }

  Future<void> _rename(BuildContext context) async {
    final filters = getSelectedFilters(context);
    if (filters.isEmpty) return;

    final filter = filters.first;
    if (!await unlockFilter(context, filter)) return;

    final album = filter.album;
    if (!vaults.isVault(album)) {
      final dir = androidFileUtils.relativeDirectoryFromPath(album);
      // do not allow renaming volume root
      if (dir == null || dir.relativeDir.isEmpty) return;

      // check whether renaming is possible given OS restrictions,
      // before asking to input a new name
      final restrictedDirsLowerCase = await storageService.getRestrictedDirectoriesLowerCase();
      if (restrictedDirsLowerCase.contains(dir.copyWith(relativeDir: dir.relativeDir.toLowerCase()))) {
        await showRestrictedDirectoryDialog(context, dir);
        return;
      }
    }

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameAlbumDialog(album: album),
      routeSettings: const RouteSettings(name: RenameAlbumDialog.routeName),
    );
    if (newName == null || newName.isEmpty) return;

    await _doRename(context, filter, newName);
  }

  Future<void> _doRename(BuildContext context, AlbumFilter filter, String newName) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final source = context.read<CollectionSource>();
    final album = filter.album;
    final todoEntries = source.visibleEntries.where(filter.test).toSet();
    final todoCount = todoEntries.length;

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
        browse(context);
        source.resumeMonitoring();

        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedbackWithMessenger(context, messenger, FeedbackType.warn, l10n.collectionMoveFailureFeedback(count));
        } else {
          showFeedbackWithMessenger(context, messenger, FeedbackType.info, l10n.genericSuccessFeedback);
        }

        // cleanup
        await storageService.deleteEmptyRegularDirectories({album});
      },
    );
  }

  Future<void> _configureVault(BuildContext context) async {
    final filters = getSelectedFilters(context);
    if (filters.isEmpty) return;

    final filter = filters.first;
    if (!await unlockFilter(context, filter)) return;

    final oldDetails = vaults.getVault(filter.album);
    if (oldDetails == null) return;

    final newDetails = await showDialog<VaultDetails>(
      context: context,
      builder: (context) => EditVaultDialog(initialDetails: oldDetails),
      routeSettings: const RouteSettings(name: EditVaultDialog.routeName),
    );
    if (newDetails == null || oldDetails == newDetails) return;

    if (oldDetails.useBin && !newDetails.useBin) {
      final filter = AlbumFilter(oldDetails.path, null);
      final source = context.read<CollectionSource>();
      await _deleteEntriesForever(context, source.trashedEntries.where(filter.test).toSet());
    }

    final oldName = oldDetails.name;
    final newName = newDetails.name;
    if (oldName != newName) {
      await vaults.update(newDetails.copyWith(name: oldName));
      // wipe the old pass, if any, so that it does not overwrite the new pass
      // when renaming the vault afterwards
      await securityService.writeValue(oldDetails.passKey, null);
      await _doRename(context, filter, newName);
    } else {
      await vaults.update(newDetails);
      browse(context);
    }
  }
}
