import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/services/app_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

mixin PermissionAwareMixin {
  Future<bool> checkStoragePermission(BuildContext context, Set<AvesEntry> entries) {
    final storageDirs = entries.map((e) => e.storageDirectory).nonNulls.toSet();
    return checkStoragePermissionForAlbums(context, storageDirs, entries: entries);
  }

  Future<bool> checkStoragePermissionForAlbums(BuildContext context, Set<String> storageDirs, {Set<AvesEntry>? entries}) async {
    final restrictedVolumes = await storageService.getRestrictedVolumes();
    final restrictedDirsLowerCase = await storageService.getRestrictedDirectoriesLowerCase();
    while (true) {
      final inaccessibleDirs = await storageService.getInaccessibleDirectories(storageDirs);

      final restrictedInaccessibleDirsLowerCase = inaccessibleDirs
          .map(
            (dir) => dir.copyWith(
              relativeDir: dir.relativeDir.toLowerCase(),
            ),
          )
          .where(restrictedDirsLowerCase.contains)
          .toSet();
      if (restrictedVolumes.isNotEmpty || restrictedInaccessibleDirsLowerCase.isNotEmpty) {
        if (entries != null && await storageService.canRequestMediaFileBulkAccess()) {
          // request media file access for items in restricted directories
          final uris = <String>[], mimeTypes = <String>[];
          entries
              .where((entry) {
                final dirPath = entry.storageDirectory;
                if (dirPath == null) return false;

                final dir = androidFileUtils.relativeDirectoryFromPath(dirPath);
                if (dir == null) return false;

                final volumePath = dir.volumePath;
                if (restrictedVolumes.contains(volumePath)) {
                  // other user storage space (e.g. Dual Messenger) is not visible via the SAF directory picker
                  return true;
                }

                final relativeDirLower = dir.relativeDir.toLowerCase();
                if (restrictedInaccessibleDirsLowerCase.contains(dir.copyWith(relativeDir: relativeDirLower))) {
                  // some critical directories (e.g. volume roots) are not selectable via the SAF directory picker
                  return true;
                }

                return false;
              })
              .forEach((entry) {
                uris.add(entry.uri);
                mimeTypes.add(entry.mimeType);
              });
          if (uris.isNotEmpty) {
            var granted = false;
            try {
              granted = await storageService.requestMediaFileAccess(uris, mimeTypes);
            } on TooManyItemsException catch (_) {
              await showWarningDialog(
                context: context,
                message: context.l10n.tooManyItemsErrorDialogMessage,
              );
            }
            if (!granted) return false;
          }
        } else if (entries == null && await storageService.canInsertMedia(restrictedInaccessibleDirsLowerCase)) {
          // insertion in restricted directories
        } else {
          // cannot proceed further
          await showRestrictedDirectoryDialog(context, restrictedInaccessibleDirsLowerCase.first);
          return false;
        }
        // clear restricted directories
        inaccessibleDirs.removeWhere((dir) => restrictedVolumes.contains(dir.volumePath));
        inaccessibleDirs.removeWhere((dir) => restrictedInaccessibleDirsLowerCase.contains(dir.copyWith(relativeDir: dir.relativeDir.toLowerCase())));
      }

      if (inaccessibleDirs.isEmpty) return true;

      // abort if the user cancels in Flutter
      final l10n = context.l10n;
      final dir = inaccessibleDirs.first;
      final directoryName = dir.relativeDir.isEmpty ? l10n.rootDirectoryDescription : l10n.otherDirectoryDescription(dir.relativeDir);
      final volume = dir.getVolumeDescription(context);
      if (!await showConfirmationDialog(
        context: context,
        message: l10n.storageAccessDialogMessage(directoryName, volume),
      )) {
        return false;
      }

      if (!await checkSystemFilePickerEnabled(context)) return false;

      final granted = await storageService.requestDirectoryAccess(dir.dirPath);
      if (!granted) {
        // abort if the user denies access from the native dialog
        return false;
      }
    }
  }

  Future<void> showRestrictedDirectoryDialog(BuildContext context, VolumeRelativeDirectory dir) {
    final l10n = context.l10n;
    final directory = dir.relativeDir.isEmpty ? l10n.rootDirectoryDescription : l10n.otherDirectoryDescription(dir.relativeDir);
    final volume = dir.getVolumeDescription(context);
    return showWarningDialog(
      context: context,
      message: l10n.restrictedAccessDialogMessage(directory, volume),
    );
  }

  Future<bool> checkSystemFilePickerEnabled(BuildContext context) async {
    if (await deviceService.isSystemFilePickerEnabled()) return true;

    await showWarningDialog(
      context: context,
      message: context.l10n.missingSystemFilePickerDialogMessage,
    );
    return false;
  }
}
