import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/app_bar/app_bar_title.dart';
import 'package:aves/widgets/common/app_bar/sliver_app_bar_title.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/viewer/action/entry_info_action_delegate.dart';
import 'package:aves/widgets/viewer/info/info_search.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

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
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    bool isVisible(EntryAction action) => actionDelegate.isVisible(
          appMode: appMode,
          targetEntry: entry,
          action: action,
        );
    final commonActions = EntryActions.commonMetadataActions.where(isVisible);
    final formatSpecificActions = EntryActions.formatSpecificMetadataActions.where(isVisible);
    final useTvLayout = settings.useTvLayout;
    final animations = context.select<Settings, AccessibilityAnimations>((s) => s.accessibilityAnimations);
    return SliverAppBar(
      leading: useTvLayout
          ? null
          : FontSizeIconTheme(
              child: IconButton(
                // key is expected by test driver
                key: const Key('back-button'),
                icon: const Icon(AIcons.goUp),
                onPressed: onBackPressed,
                tooltip: context.l10n.viewerInfoBackToViewerTooltip,
              ),
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
                PopupMenuButton<EntryAction>(
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
                    await Future.delayed(animations.popUpAnimationDelay * timeDilation);
                    actionDelegate.onActionSelected(context, entry, collection, action);
                  },
                  popUpAnimationStyle: animations.popUpAnimationStyle,
                ),
            ].map((v) => FontSizeIconTheme(child: v)).toList(),
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
    final isSelecting = context.read<Selection<AvesEntry>?>()?.isSelecting ?? false;
    Navigator.maybeOf(context)?.push(
      SearchPageRoute(
        delegate: InfoSearchDelegate(
          searchFieldLabel: context.l10n.viewerInfoSearchFieldLabel,
          searchFieldStyle: Themes.searchFieldStyle(context),
          entry: entry,
          metadataNotifier: metadataNotifier,
          isSelecting: isSelecting,
        ),
      ),
    );
  }
}
