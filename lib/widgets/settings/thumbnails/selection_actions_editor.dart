import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/quick_actions/editor_page.dart';
import 'package:flutter/material.dart';

class SelectionActionsTile extends StatelessWidget {
  const SelectionActionsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsCollectionSelectionQuickActionsTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: SelectionActionEditorPage.routeName),
            builder: (context) => const SelectionActionEditorPage(),
          ),
        );
      },
    );
  }
}

class SelectionActionEditorPage extends StatelessWidget {
  static const routeName = '/settings/collection_selection_actions';

  const SelectionActionEditorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuickActionEditorPage<EntrySetAction>(
      title: context.l10n.settingsCollectionSelectionQuickActionEditorTitle,
      bannerText: context.l10n.settingsCollectionSelectionQuickActionEditorBanner,
      allAvailableActions: EntrySetActions.selection,
      actionIcon: (action) => action.getIcon(),
      actionText: (context, action) => action.getText(context),
      load: () => settings.collectionSelectionQuickActions.toList(),
      save: (actions) => settings.collectionSelectionQuickActions = actions,
    );
  }
}
