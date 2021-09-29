import 'package:aves/services/storage_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeStorageService extends Fake implements StorageService {
  static const primaryRootAlbum = '/storage/emulated/0';
  static const primaryPath = '$primaryRootAlbum/';
  static const primaryDescription = 'Internal Storage';
  static const removablePath = '/storage/1234-5678/';
  static const removableDescription = 'SD Card';

  @override
  Future<Set<StorageVolume>> getStorageVolumes() => SynchronousFuture({
        const StorageVolume(
          path: primaryPath,
          description: primaryDescription,
          isPrimary: true,
          isRemovable: false,
          state: 'fake',
        ),
        const StorageVolume(
          path: removablePath,
          description: removableDescription,
          isPrimary: false,
          isRemovable: true,
          state: 'fake',
        ),
      });
}
