import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/viewer/entry_background.dart';
import 'package:aves/widgets/settings/viewer/overlay.dart';
import 'package:aves/widgets/settings/viewer/viewer_actions_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerSection extends StatelessWidget {
  final ValueNotifier<String?> expandedNotifier;

  const ViewerSection({
    Key? key,
    required this.expandedNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvesExpansionTile(
      leading: SettingsTileLeading(
        icon: AIcons.image,
        color: context.select<AvesColorsData, Color>((v) => v.image),
      ),
      title: context.l10n.settingsSectionViewer,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        const ViewerActionsTile(),
        const ViewerOverlayTile(),
        const _CutoutModeSwitch(),
        SettingsSwitchListTile(
          selector: (context, s) => s.viewerMaxBrightness,
          onChanged: (v) => settings.viewerMaxBrightness = v,
          title: context.l10n.settingsViewerMaximumBrightness,
        ),
        SettingsSwitchListTile(
          selector: (context, s) => s.enableMotionPhotoAutoPlay,
          onChanged: (v) => settings.enableMotionPhotoAutoPlay = v,
          title: context.l10n.settingsMotionPhotoAutoPlay,
        ),
        Selector<Settings, EntryBackground>(
          selector: (context, s) => s.imageBackground,
          builder: (context, current, child) => ListTile(
            title: Text(context.l10n.settingsImageBackground),
            trailing: EntryBackgroundSelector(
              getter: () => current,
              setter: (value) => settings.imageBackground = value,
            ),
          ),
        ),
      ],
    );
  }
}

class _CutoutModeSwitch extends StatefulWidget {
  const _CutoutModeSwitch({Key? key}) : super(key: key);

  @override
  State<_CutoutModeSwitch> createState() => _CutoutModeSwitchState();
}

class _CutoutModeSwitchState extends State<_CutoutModeSwitch> {
  late Future<bool> _canSet;

  @override
  void initState() {
    super.initState();
    _canSet = windowService.canSetCutoutMode();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _canSet,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!) {
          return SettingsSwitchListTile(
            selector: (context, s) => s.viewerUseCutout,
            onChanged: (v) => settings.viewerUseCutout = v,
            title: context.l10n.settingsViewerUseCutout,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
