import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ViewerOverlayPage extends StatelessWidget {
  static const routeName = '/settings/viewer/overlay';

  const ViewerOverlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final useTvLayout = settings.useTvLayout;
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !useTvLayout,
        title: Text(context.l10n.settingsViewerOverlayPageTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            if (!useTvLayout)
              SettingsSwitchListTile(
                selector: (context, s) => s.showOverlayOnOpening,
                onChanged: (v) => settings.showOverlayOnOpening = v,
                title: context.l10n.settingsViewerShowOverlayOnOpening,
              ),
            SettingsSwitchListTile(
              selector: (context, s) => s.showOverlayInfo,
              onChanged: (v) => settings.showOverlayInfo = v,
              title: context.l10n.settingsViewerShowInformation,
              subtitle: context.l10n.settingsViewerShowInformationSubtitle,
            ),
            Selector<Settings, Tuple2<bool, bool>>(
              selector: (context, s) => Tuple2(s.showOverlayInfo, s.showOverlayRatingTags),
              builder: (context, s, child) {
                final showInfo = s.item1;
                final current = s.item2;
                return SwitchListTile(
                  value: current,
                  onChanged: showInfo ? (v) => settings.showOverlayRatingTags = v : null,
                  title: Text(context.l10n.settingsViewerShowRatingTags),
                );
              },
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
            Selector<Settings, Tuple2<bool, bool>>(
              selector: (context, s) => Tuple2(s.showOverlayInfo, s.showOverlayDescription),
              builder: (context, s, child) {
                final showInfo = s.item1;
                final current = s.item2;
                return SwitchListTile(
                  value: current,
                  onChanged: showInfo ? (v) => settings.showOverlayDescription = v : null,
                  title: Text(context.l10n.settingsViewerShowDescription),
                );
              },
            ),
            if (!useTvLayout)
              SettingsSwitchListTile(
                selector: (context, s) => s.showOverlayMinimap,
                onChanged: (v) => settings.showOverlayMinimap = v,
                title: context.l10n.settingsViewerShowMinimap,
              ),
            if (!useTvLayout)
              SettingsSwitchListTile(
                selector: (context, s) => s.showOverlayThumbnailPreview,
                onChanged: (v) => settings.showOverlayThumbnailPreview = v,
                title: context.l10n.settingsViewerShowOverlayThumbnails,
              ),
            if (!useTvLayout)
              SettingsSelectionListTile<OverlayHistogramStyle>(
                values: OverlayHistogramStyle.values,
                getName: (context, v) => v.getName(context),
                selector: (context, s) => s.overlayHistogramStyle,
                onSelection: (v) => settings.overlayHistogramStyle = v,
                tileTitle: context.l10n.settingsViewerShowHistogram,
              ),
          ],
        ),
      ),
    );
  }
}
