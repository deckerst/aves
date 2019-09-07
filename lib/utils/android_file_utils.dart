import 'package:path/path.dart';

final AndroidFileUtils androidFileUtils = AndroidFileUtils._private();

typedef void AndroidFileUtilsCallback(String key, dynamic oldValue, dynamic newValue);

class AndroidFileUtils {
  String dcimPath, downloadPath, picturesPath;

  AndroidFileUtils._private();

  init() async {
    // path_provider getExternalStorageDirectory() gives '/storage/emulated/0/Android/data/deckers.thibault.aves/files'
    final ext = '/storage/emulated/0';
    dcimPath = join(ext, 'DCIM');
    downloadPath = join(ext, 'Download');
    picturesPath = join(ext, 'Pictures');
  }

  bool isCameraPath(String path) => path != null && path.startsWith(dcimPath) && (path.endsWith('Camera') || path.endsWith('100ANDRO'));

  bool isScreenshotsPath(String path) => path != null && path.startsWith(dcimPath) && path.endsWith('Screenshots');

  bool isDownloadPath(String path) => path == downloadPath;
}
