import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ViewerOverlayTile extends StatelessWidget {
  const ViewerOverlayTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsViewerOverlayTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: ViewerOverlayPage.routeName),
            builder: (context) => const ViewerOverlayPage(),
          ),
        );
      },
    );
  }
}

class ViewerOverlayPage extends StatelessWidget {
  static const routeName = '/settings/viewer_overlay';

  const ViewerOverlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsViewerOverlayTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Selector<Settings, bool>(
              selector: (context, s) => s.showOverlayOnOpening,
              builder: (context, current, child) => SwitchListTile(
                value: current,
                onChanged: (v) => settings.showOverlayOnOpening = v,
                title: Text(context.l10n.settingsViewerShowOverlayOnOpening),
              ),
            ),
            Selector<Settings, bool>(
              selector: (context, s) => s.showOverlayInfo,
              builder: (context, current, child) => SwitchListTile(
                value: current,
                onChanged: (v) => settings.showOverlayInfo = v,
                title: Text(context.l10n.settingsViewerShowInformation),
                subtitle: Text(context.l10n.settingsViewerShowInformationSubtitle),
              ),
            ),
            Selector<Settings, Tuple2<bool, bool>>(
              selector: (context, s) => Tuple2(s.showOverlayInfo, s.showOverlayShootingDetails),
              builder: (context, s, child) {
                final showInfo = s.item1;
                final current = s.item2;
                return SwitchListTile(
                  value: current,
                  onChanged: showInfo ? (v) => settings.showOverlayShootingDetails = v : null,
                  title: Text(context.l10n.settingsViewerShowShootingDetails),
                );
              },
            ),
            Selector<Settings, bool>(
              selector: (context, s) => s.showOverlayMinimap,
              builder: (context, current, child) => SwitchListTile(
                value: current,
                onChanged: (v) => settings.showOverlayMinimap = v,
                title: Text(context.l10n.settingsViewerShowMinimap),
              ),
            ),
            Selector<Settings, bool>(
              selector: (context, s) => s.showOverlayThumbnailPreview,
              builder: (context, current, child) => SwitchListTile(
                value: current,
                onChanged: (v) => settings.showOverlayThumbnailPreview = v,
                title: Text(context.l10n.settingsViewerShowOverlayThumbnails),
              ),
            ),
            Selector<Settings, bool>(
              selector: (context, s) => s.enableOverlayBlurEffect,
              builder: (context, current, child) => SwitchListTile(
                value: current,
                onChanged: (v) => settings.enableOverlayBlurEffect = v,
                title: Text(context.l10n.settingsViewerEnableOverlayBlurEffect),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
