import 'package:path/path.dart';

final AndroidFileUtils androidFileUtils = AndroidFileUtils._private();

typedef void AndroidFileUtilsCallback(String key, dynamic oldValue, dynamic newValue);

class AndroidFileUtils {
  String dcimPath;
  String picturesPath;

  AndroidFileUtils._private();

  init() async {
    // TODO TLAD find storage root
    // getExternalStorageDirectory() gives '/storage/emulated/0/Android/data/deckers.thibault.aves/files'
    final ext = '/storage/emulated/0';
    dcimPath = join(ext, 'DCIM');
    picturesPath = join(ext, 'Pictures');
  }

  bool isCameraPath(String path) => path != null && path.startsWith(dcimPath) && (path.endsWith('Camera') || path.endsWith('100ANDRO'));

  bool isScreenshotsPath(String path) => path != null && path.startsWith(dcimPath) && path.endsWith('Screenshots');

  bool isKakaoTalkPath(String path) => path != null && path.startsWith(picturesPath) && path.endsWith('KakaoTalk');

  bool isTelegramPath(String path) => path != null && path.startsWith(picturesPath) && path.endsWith('Telegram');
}
