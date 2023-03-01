import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/app_bar/app_bar_title.dart';
import 'package:aves/widgets/common/app_bar/sliver_app_bar_title.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/action/entry_info_action_delegate.dart';
import 'package:aves/widgets/viewer/info/info_search.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class InfoAppBar extends StatelessWidget {
  final AvesEntry entry;
  final CollectionLens? collection;
  final EntryInfoActionDelegate actionDelegate;
  final ValueNotifier<Map<String, MetadataDirectory>> metadataNotifier;
  final VoidCallback onBackPressed;

  const InfoAppBar({
    super.key,
    required this.entry,
    required this.collection,
    required this.actionDelegate,
    required this.metadataNotifier,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final commonActions = EntryActions.commonMetadataActions.where((v) => actionDelegate.isVisible(entry, v));
    final formatSpecificActions = EntryActions.formatSpecificMetadataActions.where((v) => actionDelegate.isVisible(entry, v));
    final useTvLayout = settings.useTvLayout;
    return SliverAppBar(
      leading: useTvLayout
          ? null
          : IconButton(
              // key is expected by test driver
              key: const Key('back-button'),
              icon: const Icon(AIcons.goUp),
              onPressed: onBackPressed,
              tooltip: context.l10n.viewerInfoBackToViewerTooltip,
            ),
      automaticallyImplyLeading: false,
      title: SliverAppBarTitleWrapper(
        child: InteractiveAppBarTitle(
          onTap: () => _goToSearch(context),
          child: Text(context.l10n.viewerInfoPageTitle),
        ),
      ),
      actions: useTvLayout
          ? []
          : [
              IconButton(
                icon: const Icon(AIcons.search),
                onPressed: () => _goToSearch(context),
                tooltip: MaterialLocalizations.of(context).searchFieldLabel,
              ),
              if (entry.canEdit)
                MenuIconTheme(
                  child: PopupMenuButton<EntryAction>(
                    itemBuilder: (context) => [
                      ...commonActions.map((action) => _toMenuItem(context, action, enabled: actionDelegate.canApply(entry, action))),
                      if (formatSpecificActions.isNotEmpty) ...[
                        const PopupMenuDivider(),
                        ...formatSpecificActions.map((action) => _toMenuItem(context, action, enabled: actionDelegate.canApply(entry, action))),
                      ],
                      if (!kReleaseMode) ...[
                        const PopupMenuDivider(),
                        _toMenuItem(context, EntryAction.debug, enabled: true),
                      ]
                    ],
                    onSelected: (action) async {
                      // wait for the popup menu to hide before proceeding with the action
                      await Future.delayed(Durations.popupMenuAnimation * timeDilation);
                      actionDelegate.onActionSelected(context, entry, collection, action);
                    },
                  ),
                ),
            ],
      floating: true,
    );
  }

  PopupMenuItem<EntryAction> _toMenuItem(BuildContext context, EntryAction action, {required bool enabled}) {
    return PopupMenuItem(
      value: action,
      enabled: enabled,
      child: MenuRow(text: action.getText(context), icon: action.getIcon()),
    );
  }

  void _goToSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: InfoSearchDelegate(
        searchFieldLabel: context.l10n.viewerInfoSearchFieldLabel,
        entry: entry,
        metadataNotifier: metadataNotifier,
      ),
    );
  }
}
