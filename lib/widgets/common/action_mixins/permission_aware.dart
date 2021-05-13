import 'package:aves/model/entry.dart';
import 'package:aves/services/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

mixin PermissionAwareMixin {
  Future<bool> checkStoragePermission(BuildContext context, Set<AvesEntry> entries) {
    return checkStoragePermissionForAlbums(context, entries.where((e) => e.path != null).map((e) => e.directory).cast<String >().toSet());
  }

  Future<bool> checkStoragePermissionForAlbums(BuildContext context, Set<String> albumPaths) async {
    final restrictedDirs = await storageService.getRestrictedDirectories();
    while (true) {
      final dirs = await storageService.getInaccessibleDirectories(albumPaths);
      if (dirs.isEmpty) return true;

      final restrictedInaccessibleDir = dirs.firstWhereOrNull(restrictedDirs.contains);
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

      final granted = await storageService.requestVolumeAccess(dir.volumePath);
      if (!granted) {
        // abort if the user denies access from the native dialog
        return false;
      }
    }
  }

  Future<bool?> showRestrictedDirectoryDialog(BuildContext context, VolumeRelativeDirectory dir) {
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
