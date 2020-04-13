import 'package:aves/utils/android_app_service.dart';
import 'package:aves/utils/android_file_service.dart';
import 'package:path/path.dart';

final AndroidFileUtils androidFileUtils = AndroidFileUtils._private();

class AndroidFileUtils {
  String externalStorage, dcimPath, downloadPath, moviesPath, picturesPath;

  static List<StorageVolume> storageVolumes = [];
  static Map appNameMap = {};

  AndroidFileUtils._private();

  Future<void> init() async {
    storageVolumes = (await AndroidFileService.getStorageVolumes()).map((map) => StorageVolume.fromMap(map)).toList();
    // path_provider getExternalStorageDirectory() gives '/storage/emulated/0/Android/data/deckers.thibault.aves/files'
    externalStorage = '/storage/emulated/0';
    dcimPath = join(externalStorage, 'DCIM');
    downloadPath = join(externalStorage, 'Download');
    moviesPath = join(externalStorage, 'Movies');
    picturesPath = join(externalStorage, 'Pictures');
    appNameMap = await AndroidAppService.getAppNames()
      ..addAll({'KakaoTalkDownload': 'com.kakao.talk'});
  }

  bool isCameraPath(String path) => path != null && path.startsWith(dcimPath) && (path.endsWith('Camera') || path.endsWith('100ANDRO'));

  bool isScreenshotsPath(String path) => path != null && (path.startsWith(dcimPath) || path.startsWith(picturesPath)) && path.endsWith('Screenshots');

  bool isScreenRecordingsPath(String path) => path != null && (path.startsWith(dcimPath) || path.startsWith(moviesPath)) && (path.endsWith('Screen recordings') || path.endsWith('ScreenRecords'));

  bool isDownloadPath(String path) => path == downloadPath;

  StorageVolume getStorageVolume(String path) => storageVolumes.firstWhere((v) => path.startsWith(v.path), orElse: () => null);

  bool isOnSD(String path) => getStorageVolume(path).isRemovable;

  AlbumType getAlbumType(String albumDirectory) {
    if (albumDirectory != null) {
      if (androidFileUtils.isCameraPath(albumDirectory)) return AlbumType.Camera;
      if (androidFileUtils.isDownloadPath(albumDirectory)) return AlbumType.Download;
      if (androidFileUtils.isScreenRecordingsPath(albumDirectory)) return AlbumType.ScreenRecordings;
      if (androidFileUtils.isScreenshotsPath(albumDirectory)) return AlbumType.Screenshots;

      final parts = albumDirectory.split(separator);
      if (albumDirectory.startsWith(androidFileUtils.externalStorage) && appNameMap.keys.contains(parts.last)) return AlbumType.App;
    }
    return AlbumType.Default;
  }

  String getAlbumAppPackageName(String albumDirectory) {
    final parts = albumDirectory.split(separator);
    return AndroidFileUtils.appNameMap[parts.last];
  }
}

enum AlbumType {
  Default,
  App,
  Camera,
  Download,
  ScreenRecordings,
  Screenshots,
}

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
      state: map['string'] ?? '',
    );
  }
}
