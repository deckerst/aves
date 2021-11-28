import 'package:aves/services/common/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

final Device device = Device._private();

class Device {
  late final String _userAgent;
  late final bool _canGrantDirectoryAccess, _canPinShortcut, _canPrint, _canRenderEmojis, _canRenderGoogleMaps;
  late final bool _hasFilePicker, _showPinShortcutFeedback;

  String get userAgent => _userAgent;

  bool get canGrantDirectoryAccess => _canGrantDirectoryAccess;

  bool get canPinShortcut => _canPinShortcut;

  bool get canPrint => _canPrint;

  bool get canRenderEmojis => _canRenderEmojis;

  bool get canRenderGoogleMaps => _canRenderGoogleMaps;

  // TODO TLAD toggle settings > import/export, about > bug report > save
  bool get hasFilePicker => _hasFilePicker;

  bool get showPinShortcutFeedback => _showPinShortcutFeedback;

  Device._private();

  Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _userAgent = '${packageInfo.packageName}/${packageInfo.version}';

    final capabilities = await deviceService.getCapabilities();
    _canGrantDirectoryAccess = capabilities['canGrantDirectoryAccess'] ?? false;
    _canPinShortcut = capabilities['canPinShortcut'] ?? false;
    _canPrint = capabilities['canPrint'] ?? false;
    _canRenderEmojis = capabilities['canRenderEmojis'] ?? false;
    _canRenderGoogleMaps = capabilities['canRenderGoogleMaps'] ?? false;
    _hasFilePicker = capabilities['hasFilePicker'] ?? false;
    _showPinShortcutFeedback = capabilities['showPinShortcutFeedback'] ?? false;
  }
}
