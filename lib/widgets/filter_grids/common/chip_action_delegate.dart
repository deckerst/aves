import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/rename_album_dialog.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

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
      case ChipAction.goToAlbumPage:
        _goTo(context, filter, AlbumListPage.routeName, (context) => AlbumListPage());
        break;
      case ChipAction.goToCountryPage:
        _goTo(context, filter, CountryListPage.routeName, (context) => CountryListPage());
        break;
      case ChipAction.goToTagPage:
        _goTo(context, filter, TagListPage.routeName, (context) => TagListPage());
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
    final source = context.read<CollectionSource>();
    final selection = source.visibleEntries.where(filter.test).toSet();
    final count = selection.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          context: context,
          content: Text(context.l10n.deleteAlbumConfirmationDialogMessage(count)),
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

    if (!await checkStoragePermission(context, selection)) return;

    final selectionCount = selection.length;
    source.pauseMonitoring();
    showOpReport<ImageOpEvent>(
      context: context,
      opStream: ImageFileService.delete(selection),
      itemCount: selectionCount,
      onDone: (processed) {
        final deletedUris = processed.where((event) => event.success).map((event) => event.uri).toSet();
        final deletedCount = deletedUris.length;
        if (deletedCount < selectionCount) {
          final count = selectionCount - deletedCount;
          showFeedback(context, context.l10n.collectionDeleteFailureFeedback(count));
        }
        source.removeEntries(deletedUris);
        source.resumeMonitoring();
      },
    );
  }

  Future<void> _showRenameDialog(BuildContext context, AlbumFilter filter) async {
    final source = context.read<CollectionSource>();
    final album = filter.album;
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameAlbumDialog(album),
    );
    if (newName == null || newName.isEmpty) return;

    if (!await checkStoragePermissionForAlbums(context, {album})) return;

    final todoEntries = source.visibleEntries.where(filter.test).toSet();
    final destinationAlbum = path.join(path.dirname(album), newName);

    if (!await checkFreeSpaceForMove(context, todoEntries, destinationAlbum, MoveType.move)) return;

    final todoCount = todoEntries.length;
    // while the move is ongoing, source monitoring may remove entries from itself and the favourites repo
    // so we save favourites beforehand, and will mark the moved entries as such after the move
    final favouriteEntries = todoEntries.where((entry) => entry.isFavourite).toSet();
    source.pauseMonitoring();
    showOpReport<MoveOpEvent>(
      context: context,
      opStream: ImageFileService.move(todoEntries, copy: false, destinationAlbum: destinationAlbum),
      itemCount: todoCount,
      onDone: (processed) async {
        final movedOps = processed.where((e) => e.success).toSet();
        final movedCount = movedOps.length;
        if (movedCount < todoCount) {
          final count = todoCount - movedCount;
          showFeedback(context, context.l10n.collectionMoveFailureFeedback(count));
        } else {
          showFeedback(context, context.l10n.genericSuccessFeedback);
        }
        final pinned = settings.pinnedFilters.contains(filter);
        await source.updateAfterMove(
          todoEntries: todoEntries,
          favouriteEntries: favouriteEntries,
          copy: false,
          destinationAlbum: destinationAlbum,
          movedOps: movedOps,
        );
        // repin new album after obsolete album got removed and unpinned
        if (pinned) {
          final newFilter = AlbumFilter(destinationAlbum, source.getUniqueAlbumName(context, destinationAlbum));
          settings.pinnedFilters = settings.pinnedFilters..add(newFilter);
        }
        source.resumeMonitoring();
      },
    );
  }
}
