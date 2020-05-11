import 'package:aves/model/image_entry.dart';
import 'package:aves/services/android_file_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

mixin PermissionAwareMixin {
  Future<bool> checkStoragePermission(BuildContext context, Iterable<ImageEntry> entries) async {
    final byVolume = groupBy(entries.where((e) => e.path != null), (e) => androidFileUtils.getStorageVolume(e.path));
    final removableVolumes = byVolume.keys.where((v) => v.isRemovable);
    final volumePermissions = await Future.wait<Tuple2<StorageVolume, bool>>(
      removableVolumes.map(
        (volume) => AndroidFileService.hasGrantedPermissionToVolumeRoot(volume.path).then(
          (granted) => Tuple2(volume, granted),
        ),
      ),
    );
    final ungrantedVolumes = volumePermissions.where((t) => !t.item2).map((t) => t.item1).toList();
    while (ungrantedVolumes.isNotEmpty) {
      final volume = ungrantedVolumes.first;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Storage Volume Access'),
            content: Text('Please select the root directory of “${volume.description}” in the next screen, so that this app can access it and complete your request.'),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'.toUpperCase()),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('OK'.toUpperCase()),
              ),
            ],
          );
        },
      );
      // abort if the user cancels in Flutter
      if (confirmed == null || !confirmed) return false;

      final granted = await AndroidFileService.requestVolumeAccess(volume.path);
      debugPrint('$runtimeType _checkStoragePermission with volume=${volume.path} got granted=$granted');
      if (granted) {
        ungrantedVolumes.remove(volume);
      } else {
        // abort if the user denies access from the native dialog
        return false;
      }
    }
    return true;
  }
}
