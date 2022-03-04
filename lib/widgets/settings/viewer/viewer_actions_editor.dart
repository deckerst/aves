import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/quick_actions/editor_page.dart';
import 'package:flutter/material.dart';

class ViewerActionsTile extends StatelessWidget {
  const ViewerActionsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsViewerQuickActionsTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: ViewerActionEditorPage.routeName),
            builder: (context) => const ViewerActionEditorPage(),
          ),
        );
      },
    );
  }
}

class ViewerActionEditorPage extends StatelessWidget {
  static const routeName = '/settings/viewer_actions';

  const ViewerActionEditorPage({Key? key}) : super(key: key);

  static const allAvailableActions = [
    EntryAction.share,
    EntryAction.edit,
    EntryAction.rename,
    EntryAction.delete,
    EntryAction.copy,
    EntryAction.move,
    EntryAction.toggleFavourite,
    EntryAction.rotateScreen,
    EntryAction.videoCaptureFrame,
    EntryAction.videoSetSpeed,
    EntryAction.videoSelectStreams,
    EntryAction.viewSource,
    EntryAction.rotateCCW,
    EntryAction.rotateCW,
    EntryAction.flip,
  ];

  @override
  Widget build(BuildContext context) {
    return QuickActionEditorPage<EntryAction>(
      title: context.l10n.settingsViewerQuickActionEditorTitle,
      bannerText: context.l10n.settingsViewerQuickActionEditorBanner,
      allAvailableActions: allAvailableActions,
      actionIcon: (action) => action.getIcon(),
      actionText: (context, action) => action.getText(context),
      load: () => settings.viewerQuickActions,
      save: (actions) => settings.viewerQuickActions = actions,
    );
  }
}
