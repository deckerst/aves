import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/quick_actions/editor_page.dart';
import 'package:flutter/material.dart';

class VideoActionsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsVideoQuickActionsTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: VideoActionEditorPage.routeName),
            builder: (context) => const VideoActionEditorPage(),
          ),
        );
      },
    );
  }
}

class VideoActionEditorPage extends StatelessWidget {
  static const routeName = '/settings/video_actions';

  const VideoActionEditorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuickActionEditorPage<VideoAction>(
      title: context.l10n.settingsVideoQuickActionEditorTitle,
      bannerText: context.l10n.settingsViewerQuickActionEditorBanner,
      allAvailableActions: VideoActions.all,
      actionIcon: (action) => action.getIcon(),
      actionText: (context, action) => action.getText(context),
      load: () => settings.videoQuickActions.toList(),
      save: (actions) => settings.videoQuickActions = actions,
    );
  }
}
