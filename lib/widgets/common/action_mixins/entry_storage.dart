import 'dart:async';
import 'dart:io';

import 'package:aves/app_mode.dart';
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
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin EntryStorageMixin on FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  Future<void> move(
    BuildContext context, {
    required MoveType moveType,
    required Set<AvesEntry> selectedItems,
    VoidCallback? onSuccess,
  }) async {
    final source = context.read<CollectionSource>();
    if (!source.initialized) {
      // source may be uninitialized in viewer mode
      await source.init();
      unawaited(source.refresh());
    }

    final l10n = context.l10n;
    final selectionDirs = selectedItems.map((e) => e.directory).whereNotNull().toSet();

    final destinationAlbum = await pickAlbum(context: context, moveType: moveType);
    if (destinationAlbum == null) return;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    if (moveType == MoveType.move && !await checkStoragePermissionForAlbums(context, selectionDirs, entries: selectedItems)) return;

    if (!await checkFreeSpaceForMove(context, selectedItems, destinationAlbum, moveType)) return;

    // do not directly use selection when moving and post-processing items
    // as source monitoring may remove obsolete items from the original selection
    final todoItems = selectedItems.toSet();

    final copy = moveType == MoveType.copy;
    final todoCount = todoItems.length;
    assert(todoCount > 0);

    final destinationDirectory = Directory(destinationAlbum);
    final names = [
      ...todoItems.map((v) => '${v.filenameWithoutExtension}${v.extension}'),
      // do not guard up front based on directory existence,
      // as conflicts could be within moved entries scattered across multiple albums
      if (await destinationDirectory.exists()) ...destinationDirectory.listSync().map((v) => pContext.basename(v.path)),
    ];
    final uniqueNames = names.toSet();
    var nameConflictStrategy = NameConflictStrategy.rename;
    if (uniqueNames.length < names.length) {
      final value = await showDialog<NameConflictStrategy>(
        context: context,
        builder: (context) {
          return AvesSelectionDialog<NameConflictStrategy>(
            initialValue: nameConflictStrategy,
            options: Map.fromEntries(NameConflictStrategy.values.map((v) => MapEntry(v, v.getName(context)))),
            message: selectionDirs.length == 1 ? l10n.nameConflictDialogSingleSourceMessage : l10n.nameConflictDialogMultipleSourceMessage,
            confirmationButtonLabel: l10n.continueButtonLabel,
          );
        },
      );
      if (value == null) return;
      nameConflictStrategy = value;
    }

    source.pauseMonitoring();
    final opId = mediaFileService.newOpId;
    await showOpReport<MoveOpEvent>(
      context: context,
      opStream: mediaFileService.move(
        opId: opId,
        entries: todoItems,
        copy: copy,
        destinationAlbum: destinationAlbum,
        nameConflictStrategy: nameConflictStrategy,
      ),
      itemCount: todoCount,
      onCancel: () => mediaFileService.cancelFileOp(opId),
      onDone: (processed) async {
        final successOps = processed.where((e) => e.success).toSet();
        final movedOps = successOps.where((e) => !e.skipped).toSet();
        await source.updateAfterMove(
          todoEntries: todoItems,
          copy: copy,
          destinationAlbum: destinationAlbum,
          movedOps: movedOps,
        );
        source.resumeMonitoring();

        // cleanup
        if (moveType == MoveType.move) {
          await storageService.deleteEmptyDirectories(selectionDirs);
        }

        final successCount = successOps.length;
        if (successCount < todoCount) {
          final count = todoCount - successCount;
          showFeedback(context, copy ? l10n.collectionCopyFailureFeedback(count) : l10n.collectionMoveFailureFeedback(count));
        } else {
          final count = movedOps.length;
          final appMode = context.read<ValueNotifier<AppMode>>().value;

          SnackBarAction? action;
          if (count > 0 && appMode == AppMode.main) {
            action = SnackBarAction(
              label: l10n.showButtonLabel,
              onPressed: () async {
                late CollectionLens targetCollection;

                final highlightInfo = context.read<HighlightInfo>();
                final collection = context.read<CollectionLens?>();
                if (collection != null) {
                  targetCollection = collection;
                }
                if (collection == null || collection.filters.any((f) => f is AlbumFilter)) {
                  final filter = AlbumFilter(destinationAlbum, source.getAlbumDisplayName(context, destinationAlbum));
                  // we could simply add the filter to the current collection
                  // but navigating makes the change less jarring
                  targetCollection = CollectionLens(
                    source: source,
                    filters: collection?.filters,
                  )..addFilter(filter);
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
                  await Future.delayed(delayDuration);
                }
                await Future.delayed(Durations.highlightScrollInitDelay);
                final newUris = movedOps.map((v) => v.newFields['uri'] as String?).toSet();
                final targetEntry = targetCollection.sortedEntries.firstWhereOrNull((entry) => newUris.contains(entry.uri));
                if (targetEntry != null) {
                  highlightInfo.trackItem(targetEntry, highlightItem: targetEntry);
                }
              },
            );
          }
          showFeedback(
            context,
            copy ? l10n.collectionCopySuccessFeedback(count) : l10n.collectionMoveSuccessFeedback(count),
            action,
          );
          onSuccess?.call();
        }
      },
    );
  }
}
