import 'package:aves/model/entry.dart';
import 'package:aves/services/android_file_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

mixin PermissionAwareMixin {
  Future<bool> checkStoragePermission(BuildContext context, Set<AvesEntry> entries) {
    return checkStoragePermissionForAlbums(context, entries.where((e) => e.path != null).map((e) => e.directory).toSet());
  }

  Future<bool> checkStoragePermissionForAlbums(BuildContext context, Set<String> albumPaths) async {
    final restrictedDirs = await AndroidFileService.getRestrictedDirectories();
    while (true) {
      final dirs = await AndroidFileService.getInaccessibleDirectories(albumPaths);
      if (dirs == null) return false;
      if (dirs.isEmpty) return true;

      final restrictedInaccessibleDir = dirs.firstWhere(restrictedDirs.contains, orElse: () => null);
      if (restrictedInaccessibleDir != null) {
        await showRestrictedDirectoryDialog(context, restrictedInaccessibleDir);
        return false;
      }

      final dir = dirs.first;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final directory = dir.relativeDir.isEmpty ? context.l10n.rootDirectoryDescription : context.l10n.otherDirectoryDescription(dir.relativeDir);
          final volume = dir.getVolumeDescription(context);
          return AvesDialog(
            context: context,
            title: context.l10n.storageAccessDialogTitle,
            content: Text(context.l10n.storageAccessDialogMessage(directory, volume)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          );
        },
      );
      // abort if the user cancels in Flutter
      if (confirmed == null || !confirmed) return false;

      final granted = await AndroidFileService.requestVolumeAccess(dir.volumePath);
      if (!granted) {
        // abort if the user denies access from the native dialog
        return false;
      }
    }
  }

  Future<bool> showRestrictedDirectoryDialog(BuildContext context, VolumeRelativeDirectory dir) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final directory = dir.relativeDir.isEmpty ? context.l10n.rootDirectoryDescription : context.l10n.otherDirectoryDescription(dir.relativeDir);
        final volume = dir.getVolumeDescription(context);
        return AvesDialog(
          context: context,
          title: context.l10n.restrictedAccessDialogTitle,
          content: Text(context.l10n.restrictedAccessDialogMessage(directory, volume)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );
  }
}
