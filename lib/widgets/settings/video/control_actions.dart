import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/settings/common/quick_actions/action_panel.dart';
import 'package:aves/widgets/viewer/overlay/video/controls.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoControlButtonsPage extends StatelessWidget {
  static const routeName = '/settings/video/control_buttons';
  static const _availableActions = [...EntryActions.videoPlayback, EntryAction.openVideoPlayer];

  const VideoControlButtonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !settings.useTvLayout,
        title: Text(context.l10n.settingsVideoButtonsTile),
      ),
      body: SafeArea(
        child: Selector<Settings, List<EntryAction>>(
          selector: (context, s) => s.videoControlActions,
          builder: (context, selectedActionList, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ActionPanel(
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    height: OverlayButton.getSize(context) + 48,
                    child: selectedActionList.isNotEmpty
                        ? VideoControlRow(onActionSelected: (_) {})
                        : Text(
                            context.l10n.settingsViewerQuickActionEmpty,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: _availableActions.map((action) {
                      return SwitchListTile(
                        value: selectedActionList.contains(action),
                        onChanged: (v) {
                          final selectedActionSet = settings.videoControlActions.toSet();
                          if (v) {
                            selectedActionSet.add(action);
                          } else {
                            selectedActionSet.remove(action);
                          }
                          settings.videoControlActions = _availableActions.where(selectedActionSet.contains).toList();
                        },
                        title: Text(action.getText(context)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
