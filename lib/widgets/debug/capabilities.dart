import 'package:aves/model/device.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';

class DebugCapabilitiesSection extends StatefulWidget {
  const DebugCapabilitiesSection({super.key});

  @override
  State<DebugCapabilitiesSection> createState() => _DebugCapabilitiesSectionState();
}

class _DebugCapabilitiesSectionState extends State<DebugCapabilitiesSection> with AutomaticKeepAliveClientMixin {
  late final Future<List<dynamic>> _appFuture, _windowFuture;

  @override
  void initState() {
    super.initState();
    _appFuture = Future.wait([
      appProfileService.canInteractAcrossProfiles(),
      appProfileService.canRequestInteractAcrossProfiles(),
      appProfileService.getTargetUserProfiles(),
    ]);
    _windowFuture = Future.wait([
      windowService.isCutoutAware(),
      windowService.isRotationLocked(),
      windowService.supportsHdr(),
      windowService.supportsWideGamut(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AvesExpansionTile(
      title: 'Capabilities',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HighlightTitle(title: 'Device'),
              InfoRowGroup(
                info: {
                  'canAuthenticateUser': '${device.canAuthenticateUser}',
                  'canPinShortcut': '${device.canPinShortcut}',
                  'canRenderFlagEmojis': '${device.canRenderFlagEmojis}',
                  'canRenderSubdivisionFlagEmojis': '${device.canRenderSubdivisionFlagEmojis}',
                  'canRequestManageMedia': '${device.canRequestManageMedia}',
                  'canSetLockScreenWallpaper': '${device.canSetLockScreenWallpaper}',
                  'hasGeocoder': '${device.hasGeocoder}',
                  'isDynamicColorAvailable': '${device.isDynamicColorAvailable}',
                  'isTelevision': '${device.isTelevision}',
                  'showPinShortcutFeedback': '${device.showPinShortcutFeedback}',
                  'supportEdgeToEdgeUIMode': '${device.supportEdgeToEdgeUIMode}',
                  'supportPictureInPicture': '${device.supportPictureInPicture}',
                },
              ),
            ],
          ),
        ),
        FutureBuilder<List<dynamic>>(
          future: _windowFuture,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) {
              return const SizedBox();
            }
            final [
              bool isCutoutAware,
              bool isRotationLocked,
              bool supportsHdr,
              bool supportsWideGamut,
            ] = data;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HighlightTitle(title: 'Window'),
                  InfoRowGroup(
                    info: {
                      'isCutoutAware': '$isCutoutAware',
                      'isRotationLocked': '$isRotationLocked',
                      'supportsHdr': '$supportsHdr',
                      'supportsWideGamut': '$supportsWideGamut',
                    },
                  ),
                ],
              ),
            );
          },
        ),
        FutureBuilder<List<dynamic>>(
          future: _appFuture,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) {
              return const SizedBox();
            }
            final [
              bool canInteractAcrossProfiles,
              bool canRequestInteractAcrossProfiles,
              List<String> targetUserProfiles,
            ] = data;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HighlightTitle(title: 'App'),
                  InfoRowGroup(
                    info: {
                      'userAgent': device.userAgent,
                      'canInteractAcrossProfiles': '$canInteractAcrossProfiles',
                      'canRequestInteractAcrossProfiles': '$canRequestInteractAcrossProfiles',
                      'targetUserProfiles': '$targetUserProfiles',
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
