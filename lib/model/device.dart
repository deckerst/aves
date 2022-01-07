import 'package:aves/services/common/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

final Device device = Device._private();

class Device {
  late final String _userAgent;
  late final bool _canGrantDirectoryAccess, _canPinShortcut, _canPrint, _canRenderFlagEmojis, _canRenderGoogleMaps;
  late final bool _showPinShortcutFeedback, _supportEdgeToEdgeUIMode;

  String get userAgent => _userAgent;

  bool get canGrantDirectoryAccess => _canGrantDirectoryAccess;

  bool get canPinShortcut => _canPinShortcut;

  bool get canPrint => _canPrint;

  bool get canRenderFlagEmojis => _canRenderFlagEmojis;

  bool get canRenderGoogleMaps => _canRenderGoogleMaps;

  bool get showPinShortcutFeedback => _showPinShortcutFeedback;

  bool get supportEdgeToEdgeUIMode => _supportEdgeToEdgeUIMode;

  Device._private();

  Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _userAgent = '${packageInfo.packageName}/${packageInfo.version}';

    final capabilities = await deviceService.getCapabilities();
    _canGrantDirectoryAccess = capabilities['canGrantDirectoryAccess'] ?? false;
    _canPinShortcut = capabilities['canPinShortcut'] ?? false;
    _canPrint = capabilities['canPrint'] ?? false;
    _canRenderFlagEmojis = capabilities['canRenderFlagEmojis'] ?? false;
    _canRenderGoogleMaps = capabilities['canRenderGoogleMaps'] ?? false;
    _showPinShortcutFeedback = capabilities['showPinShortcutFeedback'] ?? false;
    _supportEdgeToEdgeUIMode = capabilities['supportEdgeToEdgeUIMode'] ?? false;
  }
}
