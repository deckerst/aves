import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/quick_actions/editor_page.dart';
import 'package:aves/widgets/viewer/overlay/bottom.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ViewerActionEditorPage extends StatefulWidget {
  static const routeName = '/settings/viewer/actions';

  const ViewerActionEditorPage({super.key});

  @override
  State<ViewerActionEditorPage> createState() => _ViewerActionEditorPageState();
}

class _ViewerActionEditorPageState extends State<ViewerActionEditorPage> {
  late final QuickActionEditorController<EntryAction> _controller;

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
    ],
    [
      ...EntryActions.video.whereNot((v) => v == EntryAction.videoSettings),
    ],
    EntryActions.commonMetadataActions,
  ];

  @override
  void initState() {
    super.initState();
    _controller = QuickActionEditorController(
      load: () => settings.viewerQuickActions,
      save: (actions) => settings.viewerQuickActions = actions,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuickActionEditorPage<EntryAction>(
      title: context.l10n.settingsViewerQuickActionEditorPageTitle,
      bannerText: context.l10n.settingsViewerQuickActionEditorBanner,
      displayedButtonsDirection: ViewerBottomOverlay.actionsDirection,
      allAvailableActions: allAvailableActions,
      actionIcon: (context, action) => action.getIcon(),
      actionText: (context, action) => action.getText(context),
      controller: _controller,
    );
  }
}
