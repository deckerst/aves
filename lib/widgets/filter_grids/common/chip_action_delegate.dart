import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/action_delegates/feedback.dart';
import 'package:aves/widgets/common/action_delegates/permission_aware.dart';
import 'package:aves/widgets/common/action_delegates/rename_album_dialog.dart';
import 'package:aves/widgets/filter_grids/common/chip_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pedantic/pedantic.dart';

class ChipActionDelegate {
  Future<void> onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) async {
    // wait for the popup menu to hide before proceeding with the action
    await Future.delayed(Durations.popupMenuAnimation * timeDilation);

    switch (action) {
      case ChipAction.pin:
        final pinnedFilters = settings.pinnedFilters..add(filter);
        settings.pinnedFilters = pinnedFilters;
        break;
      case ChipAction.unpin:
        final pinnedFilters = settings.pinnedFilters..remove(filter);
        settings.pinnedFilters = pinnedFilters;
        break;
      default:
        break;
    }
  }
}

class AlbumChipActionDelegate extends ChipActionDelegate with FeedbackMixin, PermissionAwareMixin {
  @override
  Future<void> onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) async {
    await super.onActionSelected(context, filter, action);
    final album = (filter as AlbumFilter).album;
    switch (action) {
      case ChipAction.rename:
        unawaited(_showRenameDialog(context, album));
        break;
      default:
        break;
    }
  }

  Future<void> _showRenameDialog(BuildContext context, String album) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameAlbumDialog(album),
    );
    if (newName == null || newName.isEmpty) return;

    if (!await checkStoragePermissionForAlbums(context, {album})) return;

    // TODO TLAD rename album
    final result = await ImageFileService.renameDirectory(album, newName);
    showFeedback(context, result != null ? 'Done!' : 'Failed');
  }
}
