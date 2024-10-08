import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

mixin PermissionAwareMixin {
  Future<bool> checkStoragePermission(BuildContext context, Set<AvesEntry> entries) {
    final storageDirs = entries.map((e) => e.storageDirectory).whereNotNull().toSet();
    return checkStoragePermissionForAlbums(context, storageDirs, entries: entries);
  }

  Future<bool> checkStoragePermissionForAlbums(BuildContext context, Set<String> storageDirs, {Set<AvesEntry>? entries}) async {
    final restrictedDirsLowerCase = await storageService.getRestrictedDirectoriesLowerCase();
    while (true) {
      final dirs = await storageService.getInaccessibleDirectories(storageDirs);

      final restrictedInaccessibleDirs = dirs
          .map((dir) => dir.copyWith(
                relativeDir: dir.relativeDir.toLowerCase(),
              ))
          .where(restrictedDirsLowerCase.contains)
          .toSet();
      if (restrictedInaccessibleDirs.isNotEmpty) {
        if (entries != null && await storageService.canRequestMediaFileBulkAccess()) {
          // request media file access for items in restricted directories
          final uris = <String>[], mimeTypes = <String>[];
          entries.where((entry) {
            final dirPath = entry.directory;
            if (dirPath == null) return false;
            final dir = androidFileUtils.relativeDirectoryFromPath(dirPath);
            return restrictedInaccessibleDirs.contains(dir?.copyWith(relativeDir: dir.relativeDir.toLowerCase()));
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
                // MD2 button labels were upper case but they are lower case in MD3
                child: Text(Themes.asButtonLabel(MaterialLocalizations.of(context).okButtonLabel)),
              ),
            ],
          );
        },
        routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
      );
      // abort if the user cancels in Flutter
      if (confirmed == null || !confirmed) return false;

      if (!await _checkSystemFilePickerEnabled(context)) return false;

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

  Future<bool> _checkSystemFilePickerEnabled(BuildContext context) async {
    if (await deviceService.isSystemFilePickerEnabled()) return true;

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
}
