import 'dart:io';

import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:aves/services/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/cover_selection_dialog.dart';
import 'package:aves/widgets/dialogs/rename_album_dialog.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ChipActionDelegate {
  void onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) {
    switch (action) {
      case ChipAction.pin:
        settings.pinnedFilters = settings.pinnedFilters..add(filter);
        break;
      case ChipAction.unpin:
        settings.pinnedFilters = settings.pinnedFilters..remove(filter);
        break;
      case ChipAction.hide:
        _hide(context, filter);
        break;
      case ChipAction.setCover:
        _showCoverSelectionDialog(context, filter);
        break;
      case ChipAction.goToAlbumPage:
        _goTo(context, filter, AlbumListPage.routeName, (context) => const AlbumListPage());
        break;
      case ChipAction.goToCountryPage:
        _goTo(context, filter, CountryListPage.routeName, (context) => const CountryListPage());
        break;
      case ChipAction.goToTagPage:
        _goTo(context, filter, TagListPage.routeName, (context) => const TagListPage());
        break;
      default:
        break;
    }
  }

  Future<void> _hide(BuildContext context, CollectionFilter filter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          context: context,
          content: Text(context.l10n.hideFilterConfirmationDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.hideButtonLabel),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    final source = context.read<CollectionSource>();
    source.changeFilterVisibility(filter, false);
  }

  void _showCoverSelectionDialog(BuildContext context, CollectionFilter filter) async {
    final contentId = covers.coverContentId(filter);
    final customEntry = context.read<CollectionSource>().visibleEntries.firstWhereOrNull((entry) => entry.contentId == contentId);
    final coverSelection = await showDialog<Tuple2<bool, AvesEntry?>>(
      context: context,
      builder: (context) => CoverSelectionDialog(
        filter: filter,
        customEntry: customEntry,
      ),
    );
    if (coverSelection == null) return;

    final isCustom = coverSelection.item1;
    await covers.set(filter, isCustom ? coverSelection.item2?.contentId : null);
  }

  void _goTo(
    BuildContext context,
    CollectionFilter filter,
    String routeName,
    WidgetBuilder pageBuilder,
  ) {
    context.read<HighlightInfo>().set(filter);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: pageBuilder,
      ),
      (route) => false,
    );
  }
}

class AlbumChipActionDelegate extends ChipActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  @override
  void onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) {
    super.onActionSelected(context, filter, action);
    switch (action) {
      case ChipAction.delete:
        _showDeleteDialog(context, filter as AlbumFilter);
        break;
      case ChipAction.rename:
        _showRenameDialog(context, filter as AlbumFilter);
        break;
      default:
        break;
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, AlbumFilter filter) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final source = context.read<CollectionSource>();
    final album = filter.album;
    final todoEntries = source.visibleEntries.where(filter.test).toSet();
    final todoCount = todoEntries.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          context: context,
          content: Text(l10n.deleteAlbumConfirmationDialogMessage(todoCount)),
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

    if (!await checkStoragePermissionForAlbums(context, {album})) return;

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
        await storageService.deleteEmptyDirectories({album});
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
