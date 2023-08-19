import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/quick_actions/editor_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ViewerActionEditorPage extends StatelessWidget {
  static const routeName = '/settings/viewer/actions';

  const ViewerActionEditorPage({super.key});

  static final allAvailableActions = [
    [
      EntryAction.share,
      EntryAction.edit,
      EntryAction.rename,
      EntryAction.delete,
      EntryAction.copy,
      EntryAction.move,
      EntryAction.toggleFavourite,
      EntryAction.rotateScreen,
      EntryAction.viewSource,
      EntryAction.rotateCCW,
      EntryAction.rotateCW,
      EntryAction.flip,
    ],
    [
      ...EntryActions.export,
      ...EntryActions.video.whereNot((v) => v == EntryAction.videoSettings),
    ],
    EntryActions.commonMetadataActions,
  ];

  @override
  Widget build(BuildContext context) {
    return QuickActionEditorPage<EntryAction>(
      title: context.l10n.settingsViewerQuickActionEditorPageTitle,
      bannerText: context.l10n.settingsViewerQuickActionEditorBanner,
      allAvailableActions: allAvailableActions,
      actionIcon: (action) => action.getIcon(),
      actionText: (context, action) => action.getText(context),
      load: () => settings.viewerQuickActions,
      save: (actions) => settings.viewerQuickActions = actions,
    );
  }
}
