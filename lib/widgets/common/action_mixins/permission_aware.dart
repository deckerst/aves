import 'package:aves/model/device.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/services/app_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/storage_permission_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/manage_media_dialog.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

mixin PermissionAwareMixin {
  Future<bool> checkStoragePermission(BuildContext context, Set<AvesEntry> entries) {
    final storageDirs = entries.map((entry) => entry.storageDirectory).nonNulls.toSet();
    return checkStoragePermissionForAlbums(context, storageDirs, entries: entries);
  }

  Future<bool> checkStoragePermissionForAlbums(BuildContext context, Set<String> storageDirs, {Set<AvesEntry>? entries}) async {
    // remove placeholders
    storageDirs.remove(AndroidFileUtils.trashDirPath);

    final insertion = entries == null;
    final apiByDir = await storagePermissionService.getEditionApis(storageDirs, insertion: insertion);
    final restrictedDirectories = apiByDir.entries.where((kv) => kv.value.isEmpty).map((kv) => kv.key).toSet();
    if (restrictedDirectories.isNotEmpty) {
      await showRestrictedDirectoryDialog(context, restrictedDirectories.first);
      return false;
    }

    final dirsByApi = groupBy(apiByDir.entries, (kv) => kv.value.first).map((k, v) => MapEntry(k, v.map((kv) => kv.key).toSet()));
    for (final api in dirsByApi.keys.sortedBy((v) => v.index)) {
      final dirs = dirsByApi[api];
      if (dirs != null && dirs.isNotEmpty) {
        final dirPaths = dirs.map((v) => v.dirPath).toSet();
        switch (api) {
          case StorageApi.file:
            // nothing to request
            break;
          case StorageApi.mediaStore:
            final success = await _requestMediaStorePermission(context, dirPaths, entries);
            if (!success) return false;
          case StorageApi.saf:
            final success = await _requestSafPermission(context, dirPaths);
            if (!success) return false;
        }
      }
    }

    return true;
  }

  Future<bool> _requestMediaStorePermission(BuildContext context, Set<String> dirPaths, Set<AvesEntry>? entries) async {
    if (device.canRequestMediaManagementPermission) {
      if (!await deviceService.isMediaManagementGranted()) {
        final granted = await showAvesDialog<bool>(
          context: context,
          builder: (context) => const ManageMediaDialog(),
          routeSettings: const RouteSettings(name: ManageMediaDialog.routeName),
        );
        if (granted == null || !granted) return false;
      }
    }

    // request media access, which will trigger an OS level dialog
    // if the Media Management permission is not granted
    final uris = <String>[], mimeTypes = <String>[];
    entries
        ?.where((entry) {
          final storageDirectory = androidFileUtils.ensureTrailingSeparator(entry.storageDirectory);
          return dirPaths.contains(storageDirectory);
        })
        .forEach((entry) {
          uris.add(entry.uri);
          mimeTypes.add(entry.mimeType);
        });
    if (uris.isNotEmpty) {
      var granted = false;
      try {
        granted = await storagePermissionService.requestMediaStoreFileAccess(uris, mimeTypes);
      } on TooManyItemsException catch (_) {
        await showWarningDialog(
          context: context,
          message: context.l10n.tooManyItemsErrorDialogMessage,
        );
      }
      if (!granted) return false;
    }
    return true;
  }

  Future<bool> _requestSafPermission(BuildContext context, Set<String> dirPaths) async {
    final todoDirectories = await Future.wait(dirPaths.map(storagePermissionService.getSafDirectoryToRequest));
    var needGrant = true;
    while (needGrant) {
      final grantedDirectories = await storagePermissionService.getSafGrantedDirectories();
      final directoryToRequest = todoDirectories.firstWhereOrNull((v) => !grantedDirectories.contains(v?.dirPath));
      if (directoryToRequest == null) {
        needGrant = false;
      } else {
        final volume = directoryToRequest.getVolumeDescription(context);
        final relativeDir = directoryToRequest.relativeDir;

        final l10n = context.l10n;
        final directoryName = relativeDir.isEmpty ? l10n.rootDirectoryDescription : l10n.otherDirectoryDescription(relativeDir);
        if (!await showConfirmationDialog(
          context: context,
          message: l10n.storageAccessDialogMessage(directoryName, volume),
        )) {
          // abort if the user cancels in Flutter
          return false;
        }

        if (!await checkSystemFilePickerEnabled(context)) return false;

        final granted = await storagePermissionService.requestSafMediaDirectoryAccess(directoryToRequest.dirPath);
        if (!granted) {
          // abort if the user denies access from the native dialog
          return false;
        }
      }
    }
    return true;
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
