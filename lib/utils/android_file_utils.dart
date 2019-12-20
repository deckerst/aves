import 'package:path/path.dart';

final AndroidFileUtils androidFileUtils = AndroidFileUtils._private();

class AndroidFileUtils {
  String externalStorage, dcimPath, downloadPath, picturesPath;

  AndroidFileUtils._private();

  void init() {
    // path_provider getExternalStorageDirectory() gives '/storage/emulated/0/Android/data/deckers.thibault.aves/files'
    externalStorage = '/storage/emulated/0';
    dcimPath = join(externalStorage, 'DCIM');
    downloadPath = join(externalStorage, 'Download');
    picturesPath = join(externalStorage, 'Pictures');
  }

  bool isCameraPath(String path) => path != null && path.startsWith(dcimPath) && (path.endsWith('Camera') || path.endsWith('100ANDRO'));

  bool isScreenshotsPath(String path) => path != null && path.startsWith(dcimPath) && path.endsWith('Screenshots');

  bool isDownloadPath(String path) => path == downloadPath;
}
