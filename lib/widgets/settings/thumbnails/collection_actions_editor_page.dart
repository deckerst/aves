import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/quick_actions/editor_page.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class CollectionActionEditorPage extends StatelessWidget {
  static const routeName = '/settings/collection_actions';

  const CollectionActionEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = <Tuple2<Tab, Widget>>[
      Tuple2(
        Tab(text: l10n.settingsCollectionQuickActionTabBrowsing),
        QuickActionEditorBody<EntrySetAction>(
          bannerText: context.l10n.settingsCollectionBrowsingQuickActionEditorBanner,
          allAvailableActions: const [EntrySetActions.collectionEditorBrowsing],
          actionIcon: (action) => action.getIcon(),
          actionText: (context, action) => action.getText(context),
          load: () => settings.collectionBrowsingQuickActions,
          save: (actions) => settings.collectionBrowsingQuickActions = actions,
        ),
      ),
      Tuple2(
        Tab(text: l10n.settingsCollectionQuickActionTabSelecting),
        QuickActionEditorBody<EntrySetAction>(
          bannerText: context.l10n.settingsCollectionSelectionQuickActionEditorBanner,
          allAvailableActions: const [
            EntrySetActions.collectionEditorSelectionRegular,
            EntrySetActions.collectionEditorSelectionEdit,
          ],
          actionIcon: (action) => action.getIcon(),
          actionText: (context, action) => action.getText(context),
          load: () => settings.collectionSelectionQuickActions,
          save: (actions) => settings.collectionSelectionQuickActions = actions,
        ),
      ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsCollectionQuickActionEditorPageTitle),
          bottom: TabBar(
            tabs: tabs.map((t) => t.item1).toList(),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: tabs.map((t) => t.item2).toList(),
          ),
        ),
      ),
    );
  }
}
