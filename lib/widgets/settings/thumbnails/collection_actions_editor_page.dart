import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/quick_actions/editor_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

class CollectionActionEditorPage extends StatefulWidget {
  static const routeName = '/settings/collection_actions';

  const CollectionActionEditorPage({super.key});

  @override
  State<CollectionActionEditorPage> createState() => _CollectionActionEditorPageState();
}

class _CollectionActionEditorPageState extends State<CollectionActionEditorPage> {
  late final QuickActionEditorController<EntrySetAction> _browsingController;
  late final QuickActionEditorController<EntrySetAction> _selectingController;

  @override
  void initState() {
    super.initState();
    _browsingController = QuickActionEditorController(
      load: () => settings.collectionBrowsingQuickActions,
      save: (actions) => settings.collectionBrowsingQuickActions = actions,
    );
    _selectingController = QuickActionEditorController(
      load: () => settings.collectionSelectionQuickActions,
      save: (actions) => settings.collectionSelectionQuickActions = actions,
    );
  }

  @override
  void dispose() {
    _browsingController.dispose();
    _selectingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = <(Tab, Widget)>[
      (
        Tab(text: l10n.settingsCollectionQuickActionTabBrowsing),
        QuickActionEditorBody<EntrySetAction>(
          bannerText: context.l10n.settingsCollectionBrowsingQuickActionEditorBanner,
          allAvailableActions: const [
            EntrySetActions.collectionEditorBrowsing,
          ],
          actionIcon: (context, action) => action.getIcon(),
          actionText: (context, action) => action.getText(context),
          controller: _browsingController,
        ),
      ),
      (
        Tab(text: l10n.settingsCollectionQuickActionTabSelecting),
        QuickActionEditorBody<EntrySetAction>(
          bannerText: context.l10n.settingsCollectionSelectionQuickActionEditorBanner,
          allAvailableActions: const [
            EntrySetActions.collectionEditorSelectionRegular,
            EntrySetActions.collectionEditorSelectionEdit,
          ],
          actionIcon: (context, action) => action.getIcon(),
          actionText: (context, action) => action.getText(context),
          controller: _selectingController,
        ),
      ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: AvesScaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsCollectionQuickActionEditorPageTitle),
          bottom: TabBar(
            tabs: tabs.map((t) => t.$1).toList(),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: tabs.map((t) => t.$2).toList(),
          ),
        ),
      ),
    );
  }
}
