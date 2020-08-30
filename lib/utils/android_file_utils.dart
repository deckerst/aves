import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/android_file_service.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:path/path.dart';

final AndroidFileUtils androidFileUtils = AndroidFileUtils._private();

class AndroidFileUtils {
  String primaryStorage, dcimPath, downloadPath, moviesPath, picturesPath;
  Set<StorageVolume> storageVolumes = {};
  Map appNameMap = {};

  AChangeNotifier appNameChangeNotifier = AChangeNotifier();

  AndroidFileUtils._private();

  Future<void> init() async {
    storageVolumes = (await AndroidFileService.getStorageVolumes()).map((map) => StorageVolume.fromMap(map)).toSet();
    // path_provider getExternalStorageDirectory() gives '/storage/emulated/0/Android/data/deckers.thibault.aves/files'
    primaryStorage = storageVolumes.firstWhere((volume) => volume.isPrimary).path;
    dcimPath = join(primaryStorage, 'DCIM');
    downloadPath = join(primaryStorage, 'Download');
    moviesPath = join(primaryStorage, 'Movies');
    picturesPath = join(primaryStorage, 'Pictures');
  }

  Future<void> initAppNames() async {
    appNameMap = await AndroidAppService.getAppNames()
      ..addAll({'KakaoTalkDownload': 'com.kakao.talk'});
    appNameChangeNotifier.notifyListeners();
  }

  bool isCameraPath(String path) => path != null && path.startsWith(dcimPath) && (path.endsWith('Camera') || path.endsWith('100ANDRO'));

  bool isScreenshotsPath(String path) => path != null && (path.startsWith(dcimPath) || path.startsWith(picturesPath)) && path.endsWith('Screenshots');

  bool isScreenRecordingsPath(String path) => path != null && (path.startsWith(dcimPath) || path.startsWith(moviesPath)) && (path.endsWith('Screen recordings') || path.endsWith('ScreenRecords'));

  bool isDownloadPath(String path) => path == downloadPath;

  StorageVolume getStorageVolume(String path) => storageVolumes.firstWhere((v) => path.startsWith(v.path), orElse: () => null);

  bool isOnRemovableStorage(String path) => getStorageVolume(path)?.isRemovable ?? false;

  AlbumType getAlbumType(String albumDirectory) {
    if (albumDirectory != null) {
      if (isCameraPath(albumDirectory)) return AlbumType.camera;
      if (isDownloadPath(albumDirectory)) return AlbumType.download;
      if (isScreenRecordingsPath(albumDirectory)) return AlbumType.screenRecordings;
      if (isScreenshotsPath(albumDirectory)) return AlbumType.screenshots;

      final parts = albumDirectory.split(separator);
      if (albumDirectory.startsWith(primaryStorage) && appNameMap.keys.contains(parts.last)) return AlbumType.app;
    }
    return AlbumType.regular;
  }

  String getAlbumAppPackageName(String albumDirectory) {
    final parts = albumDirectory.split(separator);
    return appNameMap[parts.last];
  }
}

enum AlbumType { regular, app, camera, download, screenRecordings, screenshots }

class StorageVolume {
  final String description, path, state;
  final bool isEmulated, isPrimary, isRemovable;

  const StorageVolume({
    this.description,
    this.isEmulated,
    this.isPrimary,
    this.isRemovable,
    this.path,
    this.state,
  });

  factory StorageVolume.fromMap(Map map) {
    return StorageVolume(
      description: map['description'] ?? '',
      isEmulated: map['isEmulated'] ?? false,
      isPrimary: map['isPrimary'] ?? false,
      isRemovable: map['isRemovable'] ?? false,
      path: map['path'] ?? '',
      state: map['state'] ?? '',
    );
  }
}
