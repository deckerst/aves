import 'package:aves/services/common/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

final Device device = Device._private();

class Device {
  late final String _packageName, _packageVersion, _userAgent;
  late final bool _canAuthenticateUser, _canPinShortcut;
  late final bool _canRenderFlagEmojis, _canRenderSubdivisionFlagEmojis, _canRequestManageMedia, _canSetLockScreenWallpaper;
  late final bool _hasGeocoder, _isDynamicColorAvailable, _isTelevision, _showPinShortcutFeedback, _supportEdgeToEdgeUIMode, _supportPictureInPicture;

  String get packageName => _packageName;

  String get packageVersion => _packageVersion;

  String get userAgent => _userAgent;

  bool get canAuthenticateUser => _canAuthenticateUser;

  bool get canPinShortcut => _canPinShortcut;

  bool get canRenderFlagEmojis => _canRenderFlagEmojis;

  bool get canRenderSubdivisionFlagEmojis => _canRenderSubdivisionFlagEmojis;

  bool get canRequestManageMedia => _canRequestManageMedia;

  bool get canSetLockScreenWallpaper => _canSetLockScreenWallpaper;

  bool get hasGeocoder => _hasGeocoder;

  bool get isDynamicColorAvailable => _isDynamicColorAvailable;

  bool get isTelevision => _isTelevision;

  bool get showPinShortcutFeedback => _showPinShortcutFeedback;

  bool get supportEdgeToEdgeUIMode => _supportEdgeToEdgeUIMode;

  bool get supportPictureInPicture => _supportPictureInPicture;

  Device._private();

  Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _packageName = packageInfo.packageName;
    _packageVersion = packageInfo.version;
    _userAgent = '$_packageName/$_packageVersion';

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    _isTelevision = androidInfo.systemFeatures.contains('android.software.leanback');

    final auth = LocalAuthentication();
    _canAuthenticateUser = await auth.canCheckBiometrics || await auth.isDeviceSupported();

    final capabilities = await deviceService.getCapabilities();
    _canPinShortcut = capabilities['canPinShortcut'] ?? false;
    _canRenderFlagEmojis = capabilities['canRenderFlagEmojis'] ?? false;
    _canRenderSubdivisionFlagEmojis = capabilities['canRenderSubdivisionFlagEmojis'] ?? false;
    _canRequestManageMedia = capabilities['canRequestManageMedia'] ?? false;
    _canSetLockScreenWallpaper = capabilities['canSetLockScreenWallpaper'] ?? false;
    _hasGeocoder = capabilities['hasGeocoder'] ?? false;
    _isDynamicColorAvailable = capabilities['isDynamicColorAvailable'] ?? false;
    _showPinShortcutFeedback = capabilities['showPinShortcutFeedback'] ?? false;
    _supportEdgeToEdgeUIMode = capabilities['supportEdgeToEdgeUIMode'] ?? false;
    _supportPictureInPicture = capabilities['supportPictureInPicture'] ?? false;
  }
}
