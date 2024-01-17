import 'package:aves/model/device.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';

class DebugDeviceSection extends StatefulWidget {
  const DebugDeviceSection({super.key});

  @override
  State<DebugDeviceSection> createState() => _DebugDeviceSectionState();
}

class _DebugDeviceSectionState extends State<DebugDeviceSection> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AvesExpansionTile(
      title: 'Device',
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: InfoRowGroup(
            info: {
              'packageName': device.packageName,
              'packageVersion': device.packageVersion,
              'userAgent': device.userAgent,
              'canAuthenticateUser': '${device.canAuthenticateUser}',
              'canGrantDirectoryAccess': '${device.canGrantDirectoryAccess}',
              'canPinShortcut': '${device.canPinShortcut}',
              'canRenderFlagEmojis': '${device.canRenderFlagEmojis}',
              'canRenderSubdivisionFlagEmojis': '${device.canRenderSubdivisionFlagEmojis}',
              'canRequestManageMedia': '${device.canRequestManageMedia}',
              'canSetLockScreenWallpaper': '${device.canSetLockScreenWallpaper}',
              'canUseCrypto': '${device.canUseCrypto}',
              'canUseVaults': '${device.canUseVaults}',
              'hasGeocoder': '${device.hasGeocoder}',
              'isDynamicColorAvailable': '${device.isDynamicColorAvailable}',
              'isTelevision': '${device.isTelevision}',
              'showPinShortcutFeedback': '${device.showPinShortcutFeedback}',
              'supportEdgeToEdgeUIMode': '${device.supportEdgeToEdgeUIMode}',
              'supportPictureInPicture': '${device.supportPictureInPicture}',
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
