import 'dart:async';
import 'dart:io';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/metadata/enums.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/collection/entry_set_action_delegate.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:aves/widgets/viewer/notifications.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin EntryStorageMixin on FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  Future<void> move(
    BuildContext context, {
    required MoveType moveType,
    required Set<AvesEntry> entries,
    bool hideShowAction = false,
    VoidCallback? onSuccess,
  }) async {
    final todoCount = entries.length;
    assert(todoCount > 0);

    final toBin = moveType == MoveType.toBin;
    final copy = moveType == MoveType.copy;

    final l10n = context.l10n;
    if (toBin) {
      if (!await showConfirmationDialog(
        context: context,
        type: ConfirmationDialog.moveToBin,
        message: l10n.binEntriesConfirmationDialogMessage(todoCount),
        confirmationButtonLabel: l10n.deleteButtonLabel,
      )) return;
    }

    final entriesByDestination = <String, Set<AvesEntry>>{};
    switch (moveType) {
      case MoveType.copy:
      case MoveType.move:
      case MoveType.export:
        final destinationAlbum = await pickAlbum(context: context, moveType: moveType);
        if (destinationAlbum == null) return;
        entriesByDestination[destinationAlbum] = entries;
        break;
      case MoveType.toBin:
        entriesByDestination[AndroidFileUtils.trashDirPath] = entries;
        break;
      case MoveType.fromBin:
        groupBy<AvesEntry, String?>(entries, (e) => e.directory).forEach((originAlbum, dirEntries) {
          if (originAlbum != null) {
            entriesByDestination[originAlbum] = dirEntries.toSet();
          }
        });
        break;
    }

    // permission for modification at destinations
    final destinationAlbums = entriesByDestination.keys.toSet();
    if (!await checkStoragePermissionForAlbums(context, destinationAlbums)) return;

    // permission for modification at origins
    final originAlbums = entries.map((e) => e.directory).whereNotNull().toSet();
    if ({MoveType.move, MoveType.toBin}.contains(moveType) && !await checkStoragePermissionForAlbums(context, originAlbums, entries: entries)) return;

    await Future.forEach<String>(destinationAlbums, (destinationAlbum) async {
      if (!await checkFreeSpaceForMove(context, entries, destinationAlbum, moveType)) return;
    });

    var nameConflictStrategy = NameConflictStrategy.rename;
    if (!toBin && destinationAlbums.length == 1) {
      final destinationDirectory = Directory(destinationAlbums.single);
      final names = [
        ...entries.map((v) => '${v.filenameWithoutExtension}${v.extension}'),
        // do not guard up front based on directory existence,
        // as conflicts could be within moved entries scattered across multiple albums
        if (await destinationDirectory.exists()) ...destinationDirectory.listSync().map((v) => pContext.basename(v.path)),
      ];
      final uniqueNames = names.toSet();
      if (uniqueNames.length < names.length) {
        final value = await showDialog<NameConflictStrategy>(
          context: context,
          builder: (context) => AvesSelectionDialog<NameConflictStrategy>(
            initialValue: nameConflictStrategy,
            options: Map.fromEntries(NameConflictStrategy.values.map((v) => MapEntry(v, v.getName(context)))),
            message: originAlbums.length == 1 ? l10n.nameConflictDialogSingleSourceMessage : l10n.nameConflictDialogMultipleSourceMessage,
            confirmationButtonLabel: l10n.continueButtonLabel,
          ),
        );
        if (value == null) return;
        nameConflictStrategy = value;
      }
    }

    if ({MoveType.move, MoveType.copy}.contains(moveType) && !await _checkUndatedItems(context, entries)) return;

    final source = context.read<CollectionSource>();
    source.pauseMonitoring();
    final opId = mediaFileService.newOpId;
    await showOpReport<MoveOpEvent>(
      context: context,
      opStream: mediaFileService.move(
        opId: opId,
        entriesByDestination: entriesByDestination,
        copy: copy,
        nameConflictStrategy: nameConflictStrategy,
      ),
      itemCount: todoCount,
      onCancel: () => mediaFileService.cancelFileOp(opId),
      onDone: (processed) async {
        final successOps = processed.where((v) => v.success).toSet();
        final movedOps = successOps.where((v) => !v.skipped).toSet();
        final movedEntries = movedOps.map((v) => v.uri).map((uri) => entries.firstWhereOrNull((entry) => entry.uri == uri)).whereNotNull().toSet();
        await source.updateAfterMove(
          todoEntries: entries,
          moveType: moveType,
          destinationAlbums: destinationAlbums,
          movedOps: movedOps,
        );
        source.resumeMonitoring();

        // cleanup
        if ({MoveType.move, MoveType.toBin}.contains(moveType)) {
          await storageService.deleteEmptyDirectories(originAlbums);
        }

        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedback(context, copy ? l10n.collectionCopyFailureFeedback(count) : l10n.collectionMoveFailureFeedback(count));
        } else {
          final count = movedOps.length;
          final appMode = context.read<ValueNotifier<AppMode>?>()?.value;

          SnackBarAction? action;
          if (count > 0 && appMode == AppMode.main) {
            if (toBin) {
              if (movedEntries.isNotEmpty) {
                action = SnackBarAction(
                  // TODO TLAD [l10n] key for "RESTORE"
                  label: l10n.entryActionRestore.toUpperCase(),
                  onPressed: () {
                    // local context may be deactivated when action is triggered after navigation
                    final context = AvesApp.navigatorKey.currentContext;
                    if (context != null) {
                      move(
                        context,
                        moveType: MoveType.fromBin,
                        entries: movedEntries,
                        hideShowAction: true,
                      );
                    }
                  },
                );
              }
            } else if (!hideShowAction) {
              action = SnackBarAction(
                label: l10n.showButtonLabel,
                onPressed: () {
                  // local context may be deactivated when action is triggered after navigation
                  final context = AvesApp.navigatorKey.currentContext;
                  if (context != null) {
                    _showMovedItems(context, destinationAlbums, movedOps);
                  }
                },
              );
            }
          }
          showFeedback(
            context,
            copy ? l10n.collectionCopySuccessFeedback(count) : l10n.collectionMoveSuccessFeedback(count),
            action,
          );

          EntryMovedNotification(moveType, movedEntries).dispatch(context);
          onSuccess?.call();
        }
      },
    );
  }

  Future<void> rename(
    BuildContext context, {
    required Map<AvesEntry, String> entriesToNewName,
    required bool persist,
    VoidCallback? onSuccess,
  }) async {
    final entries = entriesToNewName.keys.toSet();
    final todoCount = entries.length;
    assert(todoCount > 0);

    if (!await checkStoragePermission(context, entries)) return;

    if (!await _checkUndatedItems(context, entries)) return;

    final source = context.read<CollectionSource>();
    source.pauseMonitoring();
    final opId = mediaFileService.newOpId;
    await showOpReport<MoveOpEvent>(
      context: context,
      opStream: mediaFileService.rename(
        opId: opId,
        entriesToNewName: entriesToNewName,
      ),
      itemCount: todoCount,
      onCancel: () => mediaFileService.cancelFileOp(opId),
      onDone: (processed) async {
        final successOps = processed.where((e) => e.success).toSet();
        final movedOps = successOps.where((e) => !e.skipped).toSet();
        await source.updateAfterRename(
          todoEntries: entries,
          movedOps: movedOps,
          persist: persist,
        );
        source.resumeMonitoring();

        final l10n = context.l10n;
        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedback(context, l10n.collectionRenameFailureFeedback(count));
        } else {
          final count = movedOps.length;
          showFeedback(context, l10n.collectionRenameSuccessFeedback(count));
          onSuccess?.call();
        }
      },
    );
  }

  Future<bool> _checkUndatedItems(BuildContext context, Set<AvesEntry> entries) async {
    final undatedItems = entries.where((entry) {
      if (!entry.isCatalogued) return false;
      final dateMillis = entry.catalogMetadata?.dateMillis;
      return dateMillis == null || dateMillis == 0;
    }).toSet();
    if (undatedItems.isNotEmpty) {
      if (!await showConfirmationDialog(
        context: context,
        type: ConfirmationDialog.moveUndatedItems,
        delegate: MoveUndatedConfirmationDialogDelegate(),
        confirmationButtonLabel: context.l10n.continueButtonLabel,
      )) return false;

      if (settings.setMetadataDateBeforeFileOp) {
        final entriesToDate = undatedItems.where((entry) => entry.canEditDate).toSet();
        if (entriesToDate.isNotEmpty) {
          await EntrySetActionDelegate().editDate(
            context,
            entries: entriesToDate,
            modifier: DateModifier.copyField(DateFieldSource.fileModifiedDate),
            showResult: false,
          );
        }
      }
    }
    return true;
  }

  Future<void> _showMovedItems(
    BuildContext context,
    Set<String> destinationAlbums,
    Set<MoveOpEvent> movedOps,
  ) async {
    final newUris = movedOps.map((v) => v.newFields['uri'] as String?).toSet();
    bool highlightTest(AvesEntry entry) => newUris.contains(entry.uri);

    final collection = context.read<CollectionLens?>();
    if (collection == null || collection.filters.any((f) => f is AlbumFilter || f is TrashFilter)) {
      final source = context.read<CollectionSource>();
      final targetFilters = collection?.filters.where((f) => f != TrashFilter.instance).toSet() ?? {};
      // we could simply add the filter to the current collection
      // but navigating makes the change less jarring
      if (destinationAlbums.length == 1) {
        final destinationAlbum = destinationAlbums.single;
        targetFilters.removeWhere((f) => f is AlbumFilter);
        targetFilters.add(AlbumFilter(destinationAlbum, source.getAlbumDisplayName(context, destinationAlbum)));
      }
      unawaited(Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: CollectionPage.routeName),
          builder: (context) => CollectionPage(
            source: source,
            filters: targetFilters,
            highlightTest: highlightTest,
          ),
        ),
        (route) => false,
      ));
    } else {
      // track in current page, without navigation
      await Future.delayed(Durations.highlightScrollInitDelay);
      final targetEntry = collection.sortedEntries.firstWhereOrNull(highlightTest);
      if (targetEntry != null) {
        context.read<HighlightInfo>().trackItem(targetEntry, highlightItem: targetEntry);
      }
    }
  }
}

class MoveUndatedConfirmationDialogDelegate extends ConfirmationDialogDelegate {
  final ValueNotifier<bool> _setMetadataDate = ValueNotifier(false);

  MoveUndatedConfirmationDialogDelegate() {
    _setMetadataDate.value = settings.setMetadataDateBeforeFileOp;
  }

  @override
  List<Widget> build(BuildContext context) => [
        Padding(
          padding: const EdgeInsets.all(16) + const EdgeInsets.only(top: 8),
          child: Text(context.l10n.moveUndatedConfirmationDialogMessage),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _setMetadataDate,
          builder: (context, flag, child) => SwitchListTile(
            value: flag,
            onChanged: (v) => _setMetadataDate.value = v,
            title: Text(context.l10n.moveUndatedConfirmationDialogSetDate),
          ),
        ),
      ];

  @override
  void apply() => settings.setMetadataDateBeforeFileOp = _setMetadataDate.value;
}
