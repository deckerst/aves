import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/viewer/entry_background.dart';
import 'package:aves/widgets/settings/viewer/viewer_actions_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

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
        color: stringToColor('Image'),
      ),
      title: context.l10n.settingsSectionViewer,
      expandedNotifier: expandedNotifier,
      showHighlight: false,
      children: [
        const ViewerActionsTile(),
        Selector<Settings, bool>(
          selector: (context, s) => s.showOverlayOnOpening,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.showOverlayOnOpening = v,
            title: Text(context.l10n.settingsViewerShowOverlayOnOpening),
          ),
        ),
        Selector<Settings, bool>(
          selector: (context, s) => s.showOverlayMinimap,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.showOverlayMinimap = v,
            title: Text(context.l10n.settingsViewerShowMinimap),
          ),
        ),
        Selector<Settings, bool>(
          selector: (context, s) => s.showOverlayInfo,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.showOverlayInfo = v,
            title: Text(context.l10n.settingsViewerShowInformation),
            subtitle: Text(context.l10n.settingsViewerShowInformationSubtitle),
          ),
        ),
        Selector<Settings, Tuple2<bool, bool>>(
          selector: (context, s) => Tuple2(s.showOverlayInfo, s.showOverlayShootingDetails),
          builder: (context, s, child) {
            final showInfo = s.item1;
            final current = s.item2;
            return SwitchListTile(
              value: current,
              onChanged: showInfo ? (v) => settings.showOverlayShootingDetails = v : null,
              title: Text(context.l10n.settingsViewerShowShootingDetails),
            );
          },
        ),
        Selector<Settings, bool>(
          selector: (context, s) => s.enableOverlayBlurEffect,
          builder: (context, current, child) => SwitchListTile(
            value: current,
            onChanged: (v) => settings.enableOverlayBlurEffect = v,
            title: Text(context.l10n.settingsViewerEnableOverlayBlurEffect),
          ),
        ),
        const _CutoutModeSwitch(),
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
  _CutoutModeSwitchState createState() => _CutoutModeSwitchState();
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
          return Selector<Settings, bool>(
            selector: (context, s) => s.viewerUseCutout,
            builder: (context, current, child) => SwitchListTile(
              value: current,
              onChanged: (v) => settings.viewerUseCutout = v,
              title: Text(context.l10n.settingsViewerUseCutout),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
