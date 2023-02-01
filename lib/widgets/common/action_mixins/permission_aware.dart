import 'package:aves/model/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

mixin PermissionAwareMixin {
  Future<bool> checkStoragePermission(BuildContext context, Set<AvesEntry> entries) {
    final storageDirs = entries.map((e) => e.storageDirectory).whereNotNull().toSet();
    return checkStoragePermissionForAlbums(context, storageDirs, entries: entries);
  }

  Future<bool> checkStoragePermissionForAlbums(BuildContext context, Set<String> storageDirs, {Set<AvesEntry>? entries}) async {
    final restrictedDirs = await storageService.getRestrictedDirectories();
    while (true) {
      final dirs = await storageService.getInaccessibleDirectories(storageDirs);

      final restrictedInaccessibleDirs = dirs.where(restrictedDirs.contains).toSet();
      if (restrictedInaccessibleDirs.isNotEmpty) {
        if (entries != null && await storageService.canRequestMediaFileAccess()) {
          // request media file access for items in restricted directories
          final uris = <String>[], mimeTypes = <String>[];
          entries.where((entry) {
            final dir = entry.directory;
            return dir != null && restrictedInaccessibleDirs.contains(VolumeRelativeDirectory.fromPath(dir));
          }).forEach((entry) {
            uris.add(entry.uri);
            mimeTypes.add(entry.mimeType);
          });
          final granted = await storageService.requestMediaFileAccess(uris, mimeTypes);
          if (!granted) return false;
        } else if (entries == null && await storageService.canInsertMedia(restrictedInaccessibleDirs)) {
          // insertion in restricted directories
        } else {
          // cannot proceed further
          await showRestrictedDirectoryDialog(context, restrictedInaccessibleDirs.first);
          return false;
        }
        // clear restricted directories
        dirs.removeAll(restrictedInaccessibleDirs);
      }

      if (dirs.isEmpty) return true;

      final dir = dirs.first;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final l10n = context.l10n;
          final directory = dir.relativeDir.isEmpty ? l10n.rootDirectoryDescription : l10n.otherDirectoryDescription(dir.relativeDir);
          final volume = dir.getVolumeDescription(context);
          return AvesDialog(
            content: Text(l10n.storageAccessDialogMessage(directory, volume)),
            actions: [
              const CancelButton(),
              TextButton(
                onPressed: () => Navigator.maybeOf(context)?.pop(true),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          );
        },
        routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
      );
      // abort if the user cancels in Flutter
      if (confirmed == null || !confirmed) return false;

      if (!await deviceService.isSystemFilePickerEnabled()) {
        await showDialog(
          context: context,
          builder: (context) => AvesDialog(
            content: Text(context.l10n.missingSystemFilePickerDialogMessage),
            actions: const [OkButton()],
          ),
          routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
        );
        return false;
      }

      final granted = await storageService.requestDirectoryAccess(dir.dirPath);
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
          content: Text(context.l10n.restrictedAccessDialogMessage(directory, volume)),
          actions: const [OkButton()],
        );
      },
      routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
    );
  }
}
