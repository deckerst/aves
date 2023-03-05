import 'package:aves/services/common/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:floating/floating.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

final Device device = Device._private();

class Device {
  late final String _userAgent;
  late final bool _canAuthenticateUser, _canGrantDirectoryAccess, _canPinShortcut, _canPrint;
  late final bool _canRenderFlagEmojis, _canRequestManageMedia, _canSetLockScreenWallpaper, _canUseCrypto;
  late final bool _hasGeocoder, _isDynamicColorAvailable, _isTelevision, _showPinShortcutFeedback, _supportEdgeToEdgeUIMode, _supportPictureInPicture;

  String get userAgent => _userAgent;

  bool get canAuthenticateUser => _canAuthenticateUser;

  bool get canGrantDirectoryAccess => _canGrantDirectoryAccess;

  bool get canPinShortcut => _canPinShortcut;

  bool get canPrint => _canPrint;

  bool get canRenderFlagEmojis => _canRenderFlagEmojis;

  bool get canRequestManageMedia => _canRequestManageMedia;

  bool get canSetLockScreenWallpaper => _canSetLockScreenWallpaper;

  bool get canUseCrypto => _canUseCrypto;

  bool get canUseVaults => canAuthenticateUser || canUseCrypto;

  bool get hasGeocoder => _hasGeocoder;

  bool get isDynamicColorAvailable => _isDynamicColorAvailable;

  bool get isTelevision => _isTelevision;

  bool get showPinShortcutFeedback => _showPinShortcutFeedback;

  bool get supportEdgeToEdgeUIMode => _supportEdgeToEdgeUIMode;

  bool get supportPictureInPicture => _supportPictureInPicture;

  Device._private();

  Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _userAgent = '${packageInfo.packageName}/${packageInfo.version}';

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    _isTelevision = androidInfo.systemFeatures.contains('android.software.leanback');

    final auth = LocalAuthentication();
    _canAuthenticateUser = await auth.canCheckBiometrics || await auth.isDeviceSupported();

    final floating = Floating();
    _supportPictureInPicture = await floating.isPipAvailable;
    floating.dispose();

    final capabilities = await deviceService.getCapabilities();
    _canGrantDirectoryAccess = capabilities['canGrantDirectoryAccess'] ?? false;
    _canPinShortcut = capabilities['canPinShortcut'] ?? false;
    _canPrint = capabilities['canPrint'] ?? false;
    _canRenderFlagEmojis = capabilities['canRenderFlagEmojis'] ?? false;
    _canRequestManageMedia = capabilities['canRequestManageMedia'] ?? false;
    _canSetLockScreenWallpaper = capabilities['canSetLockScreenWallpaper'] ?? false;
    _canUseCrypto = capabilities['canUseCrypto'] ?? false;
    _hasGeocoder = capabilities['hasGeocoder'] ?? false;
    _isDynamicColorAvailable = capabilities['isDynamicColorAvailable'] ?? false;
    _showPinShortcutFeedback = capabilities['showPinShortcutFeedback'] ?? false;
    _supportEdgeToEdgeUIMode = capabilities['supportEdgeToEdgeUIMode'] ?? false;
  }
}
