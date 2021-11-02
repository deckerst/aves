import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/common/quick_actions/editor_page.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class CollectionActionsTile extends StatelessWidget {
  const CollectionActionsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsCollectionQuickActionsTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: CollectionActionEditorPage.routeName),
            builder: (context) => const CollectionActionEditorPage(),
          ),
        );
      },
    );
  }
}

class CollectionActionEditorPage extends StatelessWidget {
  static const routeName = '/settings/collection_actions';

  const CollectionActionEditorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = <Tuple2<Tab, Widget>>[
      Tuple2(
        Tab(text: l10n.settingsCollectionQuickActionTabBrowsing),
        QuickActionEditorBody<EntrySetAction>(
          bannerText: context.l10n.settingsCollectionBrowsingQuickActionEditorBanner,
          allAvailableActions: EntrySetActions.browsing,
          actionIcon: (action) => action.getIcon(),
          actionText: (context, action) => action.getText(context),
          load: () => settings.collectionBrowsingQuickActions.toList(),
          save: (actions) => settings.collectionBrowsingQuickActions = actions,
        ),
      ),
      Tuple2(
        Tab(text: l10n.settingsCollectionQuickActionTabSelecting),
        QuickActionEditorBody<EntrySetAction>(
          bannerText: context.l10n.settingsCollectionSelectionQuickActionEditorBanner,
          allAvailableActions: EntrySetActions.selection,
          actionIcon: (action) => action.getIcon(),
          actionText: (context, action) => action.getText(context),
          load: () => settings.collectionSelectionQuickActions.toList(),
          save: (actions) => settings.collectionSelectionQuickActions = actions,
        ),
      ),
    ];

    return MediaQueryDataProvider(
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.settingsCollectionQuickActionEditorTitle),
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
      ),
    );
  }
}
