import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoGesturesTile extends StatelessWidget {
  const VideoGesturesTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsGesturesTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: VideoGesturesPage.routeName),
            builder: (context) => const VideoGesturesPage(),
          ),
        );
      },
    );
  }
}

class VideoGesturesPage extends StatelessWidget {
  static const routeName = '/settings/video/gestures';

  const VideoGesturesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsGesturesTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
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
