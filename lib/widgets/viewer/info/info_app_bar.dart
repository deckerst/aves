import 'package:aves/model/actions/entry_info_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/app_bar_title.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/edit_entry_date_dialog.dart';
import 'package:aves/widgets/viewer/info/info_search.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class InfoAppBar extends StatelessWidget with FeedbackMixin, PermissionAwareMixin {
  final AvesEntry entry;
  final ValueNotifier<Map<String, MetadataDirectory>> metadataNotifier;
  final VoidCallback onBackPressed;

  const InfoAppBar({
    Key? key,
    required this.entry,
    required this.metadataNotifier,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        // key is expected by test driver
        key: const Key('back-button'),
        icon: const Icon(AIcons.goUp),
        onPressed: onBackPressed,
        tooltip: context.l10n.viewerInfoBackToViewerTooltip,
      ),
      title: InteractiveAppBarTitle(
        onTap: () => _goToSearch(context),
        child: Text(context.l10n.viewerInfoPageTitle),
      ),
      actions: [
        IconButton(
          icon: const Icon(AIcons.search),
          onPressed: () => _goToSearch(context),
          tooltip: MaterialLocalizations.of(context).searchFieldLabel,
        ),
        MenuIconTheme(
          child: PopupMenuButton<EntryInfoAction>(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: EntryInfoAction.editDate,
                  enabled: entry.canEditExif,
                  child: MenuRow(text: context.l10n.entryInfoActionEditDate, icon: const Icon(AIcons.date)),
                ),
              ];
            },
            onSelected: (action) {
              // wait for the popup menu to hide before proceeding with the action
              Future.delayed(Durations.popupMenuAnimation * timeDilation, () => _onActionSelected(context, action));
            },
          ),
        ),
      ],
      titleSpacing: 0,
      floating: true,
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

  void _onActionSelected(BuildContext context, EntryInfoAction action) async {
    switch (action) {
      case EntryInfoAction.editDate:
        await _showDateEditDialog(context);
        break;
    }
  }

  Future<void> _showDateEditDialog(BuildContext context) async {
    final modifier = await showDialog<DateModifier>(
      context: context,
      builder: (context) => EditEntryDateDialog(entry: entry),
    );
    if (modifier == null) return;

    if (!await checkStoragePermission(context, {entry})) return;

    // TODO TLAD [meta edit] handle viewer mode
    final success = await context.read<CollectionSource>().editEntryDate(entry, modifier);
    if (success) {
      showFeedback(context, context.l10n.genericSuccessFeedback);
    } else {
      showFeedback(context, context.l10n.genericFailureFeedback);
    }
  }
}
