import 'package:aves/services/common/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

final Device device = Device._private();

class Device {
  late final String _userAgent;
  late final bool _canGrantDirectoryAccess, _canPinShortcut, _canPrint, _canRenderFlagEmojis, _canRequestManageMedia, _canSetLockScreenWallpaper;
  late final bool _hasGeocoder, _isDynamicColorAvailable, _isTelevision, _showPinShortcutFeedback, _supportEdgeToEdgeUIMode;

  String get userAgent => _userAgent;

  bool get canGrantDirectoryAccess => _canGrantDirectoryAccess;

  bool get canPinShortcut => _canPinShortcut;

  bool get canPrint => _canPrint;

  bool get canRenderFlagEmojis => _canRenderFlagEmojis;

  bool get canRequestManageMedia => _canRequestManageMedia;

  bool get canSetLockScreenWallpaper => _canSetLockScreenWallpaper;

  bool get hasGeocoder => _hasGeocoder;

  bool get isDynamicColorAvailable => _isDynamicColorAvailable;

  bool get isReadOnly => _isTelevision;

  bool get isTelevision => _isTelevision;

  bool get showPinShortcutFeedback => _showPinShortcutFeedback;

  bool get supportEdgeToEdgeUIMode => _supportEdgeToEdgeUIMode;

  Device._private();

  Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _userAgent = '${packageInfo.packageName}/${packageInfo.version}';

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    _isTelevision = androidInfo.systemFeatures.contains('android.software.leanback');

    final capabilities = await deviceService.getCapabilities();
    _canGrantDirectoryAccess = capabilities['canGrantDirectoryAccess'] ?? false;
    _canPinShortcut = capabilities['canPinShortcut'] ?? false;
    _canPrint = capabilities['canPrint'] ?? false;
    _canRenderFlagEmojis = capabilities['canRenderFlagEmojis'] ?? false;
    _canRequestManageMedia = capabilities['canRequestManageMedia'] ?? false;
    _canSetLockScreenWallpaper = capabilities['canSetLockScreenWallpaper'] ?? false;
    _hasGeocoder = capabilities['hasGeocoder'] ?? false;
    _isDynamicColorAvailable = capabilities['isDynamicColorAvailable'] ?? false;
    _showPinShortcutFeedback = capabilities['showPinShortcutFeedback'] ?? false;
    _supportEdgeToEdgeUIMode = capabilities['supportEdgeToEdgeUIMode'] ?? false;
  }
}
