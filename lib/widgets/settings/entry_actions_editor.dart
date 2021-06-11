import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/quick_actions/editor_page.dart';
import 'package:flutter/material.dart';

class QuickEntryActionsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsViewerQuickActionsTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: QuickEntryActionEditorPage.routeName),
            builder: (context) => const QuickEntryActionEditorPage(),
          ),
        );
      },
    );
  }
}

class QuickEntryActionEditorPage extends StatelessWidget {
  static const routeName = '/settings/quick_entry_actions';

  const QuickEntryActionEditorPage({Key? key}) : super(key: key);

  static const allAvailableActions = [
    EntryAction.info,
    EntryAction.toggleFavourite,
    EntryAction.share,
    EntryAction.delete,
    EntryAction.rename,
    EntryAction.export,
    EntryAction.print,
    EntryAction.viewSource,
    EntryAction.flip,
    EntryAction.rotateCCW,
    EntryAction.rotateCW,
  ];

  @override
  Widget build(BuildContext context) {
    return QuickActionEditorPage<EntryAction>(
      bannerText: context.l10n.settingsViewerQuickActionEditorBanner,
      allAvailableActions: allAvailableActions,
      actionIcon: (action) => action.getIcon(),
      actionText: (context, action) => action.getText(context),
      load: () => settings.viewerQuickActions.toList(),
      save: (actions) => settings.viewerQuickActions = actions,
    );
  }
}
