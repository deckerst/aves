import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/video_controls.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoControlsTile extends StatelessWidget {
  const VideoControlsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsVideoControlsTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: VideoControlsPage.routeName),
            builder: (context) => const VideoControlsPage(),
          ),
        );
      },
    );
  }
}

class VideoControlsPage extends StatelessWidget {
  static const routeName = '/settings/video/controls';

  const VideoControlsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsVideoControlsTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Selector<Settings, VideoControls>(
              selector: (context, s) => s.videoControls,
              builder: (context, current, child) => ListTile(
                title: Text(context.l10n.settingsVideoButtonsTile),
                subtitle: Text(current.getName(context)),
                onTap: () => showSelectionDialog<VideoControls>(
                  context: context,
                  builder: (context) => AvesSelectionDialog<VideoControls>(
                    initialValue: current,
                    options: Map.fromEntries(VideoControls.values.map((v) => MapEntry(v, v.getName(context)))),
                    title: context.l10n.settingsVideoButtonsTitle,
                  ),
                  onSelection: (v) => settings.videoControls = v,
                ),
              ),
            ),
            Selector<Settings, bool>(
              selector: (context, s) => s.videoGestureDoubleTapTogglePlay,
              builder: (context, current, child) => SwitchListTile(
                value: current,
                onChanged: (v) => settings.videoGestureDoubleTapTogglePlay = v,
                title: Text(context.l10n.settingsVideoGestureDoubleTapTogglePlay),
              ),
            ),
            Selector<Settings, bool>(
              selector: (context, s) => s.videoGestureSideDoubleTapSeek,
              builder: (context, current, child) => SwitchListTile(
                value: current,
                onChanged: (v) => settings.videoGestureSideDoubleTapSeek = v,
                title: Text(context.l10n.settingsVideoGestureSideDoubleTapSeek),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
