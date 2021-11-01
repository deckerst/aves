import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/quick_actions/editor_page.dart';
import 'package:flutter/material.dart';

class BrowsingActionsTile extends StatelessWidget {
  const BrowsingActionsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsCollectionBrowsingQuickActionsTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: BrowsingActionEditorPage.routeName),
            builder: (context) => const BrowsingActionEditorPage(),
          ),
        );
      },
    );
  }
}

class BrowsingActionEditorPage extends StatelessWidget {
  static const routeName = '/settings/collection_browsing_actions';

  const BrowsingActionEditorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuickActionEditorPage<EntrySetAction>(
      title: context.l10n.settingsCollectionBrowsingQuickActionEditorTitle,
      bannerText: context.l10n.settingsCollectionBrowsingQuickActionEditorBanner,
      allAvailableActions: EntrySetActions.browsing,
      actionIcon: (action) => action.getIcon(),
      actionText: (context, action) => action.getText(context),
      load: () => settings.collectionBrowsingQuickActions.toList(),
      save: (actions) => settings.collectionBrowsingQuickActions = actions,
    );
  }
}
