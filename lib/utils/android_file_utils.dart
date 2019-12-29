import 'package:aves/utils/android_app_service.dart';
import 'package:path/path.dart';

final AndroidFileUtils androidFileUtils = AndroidFileUtils._private();

class AndroidFileUtils {
  String externalStorage, dcimPath, downloadPath, picturesPath;

  static Map appNameMap = {};

  AndroidFileUtils._private();

  Future<void> init() async {
    // path_provider getExternalStorageDirectory() gives '/storage/emulated/0/Android/data/deckers.thibault.aves/files'
    externalStorage = '/storage/emulated/0';
    dcimPath = join(externalStorage, 'DCIM');
    downloadPath = join(externalStorage, 'Download');
    picturesPath = join(externalStorage, 'Pictures');
    appNameMap = await AndroidAppService.getAppNames();
  }

  bool isCameraPath(String path) => path != null && path.startsWith(dcimPath) && (path.endsWith('Camera') || path.endsWith('100ANDRO'));

  bool isScreenshotsPath(String path) => path != null && path.startsWith(dcimPath) && path.endsWith('Screenshots');

  bool isScreenRecordingsPath(String path) => path != null && path.startsWith(dcimPath) && path.endsWith('Screen recordings');

  bool isDownloadPath(String path) => path == downloadPath;

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
