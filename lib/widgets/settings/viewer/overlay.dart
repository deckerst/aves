import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/switch_icon.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerOverlayPage extends StatelessWidget {
  static const routeName = '/settings/viewer/overlay';

  const ViewerOverlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final useTvLayout = settings.useTvLayout;

    Widget _trailingIcon(BuildContext context, IconData data) => Icon(
          data,
          size: SettingSwitchTrailingIcon.getIconSize(context),
          color: SettingSwitchTrailingIcon.getIconColor(context),
        );

    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !useTvLayout,
        title: Text(l10n.settingsViewerOverlayPageTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            if (!useTvLayout) ...[
              SettingsSwitchListTile(
                selector: (context, s) => s.showOverlayOnOpening,
                onChanged: (v) => settings.showOverlayOnOpening = v,
                title: l10n.settingsViewerShowOverlayOnOpening,
              ),
              const Divider(height: 32),
            ],
            SettingsSwitchListTile(
              selector: (context, s) => s.showOverlayInfo,
              onChanged: (v) => settings.showOverlayInfo = v,
              title: l10n.settingsViewerShowInformation,
              subtitle: l10n.settingsViewerShowInformationSubtitle,
            ),
            Selector<Settings, bool>(
              selector: (context, s) => s.showOverlayInfo,
              builder: (context, showInfo, child) {
                return SettingsSwitchListTile(
                  selector: (context, s) => s.showOverlayShootingDetails,
                  onChanged: showInfo ? (v) => settings.showOverlayShootingDetails = v : null,
                  title: l10n.settingsViewerShowShootingDetails,
                  trailing: _trailingIcon(context, AIcons.shooting),
                );
              },
            ),
            Selector<Settings, bool>(
              selector: (context, s) => s.showOverlayInfo,
              builder: (context, showInfo, child) {
                return SettingsSwitchListTile(
                  selector: (context, s) => s.showOverlayRatingTags,
                  onChanged: showInfo ? (v) => settings.showOverlayRatingTags = v : null,
                  title: l10n.settingsViewerShowRatingTags,
                  trailing: _trailingIcon(context, AIcons.tag),
                );
              },
            ),
            Selector<Settings, bool>(
              selector: (context, s) => s.showOverlayInfo,
              builder: (context, showInfo, child) {
                return SettingsSwitchListTile(
                  selector: (context, s) => s.showOverlayDescription,
                  onChanged: showInfo ? (v) => settings.showOverlayDescription = v : null,
                  title: l10n.settingsViewerShowDescription,
                  trailing: _trailingIcon(context, AIcons.description),
                );
              },
            ),
            if (!useTvLayout) ...[
              const Divider(height: 32),
              SettingsSwitchListTile(
                selector: (context, s) => s.showOverlayZoomLevel,
                onChanged: (v) => settings.showOverlayZoomLevel = v,
                title: l10n.settingsViewerShowZoomLevel,
                trailing: _trailingIcon(context, AIcons.zoomLevel),
              ),
              SettingsSwitchListTile(
                selector: (context, s) => s.showOverlayMinimap,
                onChanged: (v) => settings.showOverlayMinimap = v,
                title: l10n.settingsViewerShowMinimap,
                trailing: _trailingIcon(context, AIcons.minimap),
              ),
              SettingsSelectionListTile<OverlayHistogramStyle>(
                values: OverlayHistogramStyle.values,
                getName: (context, v) => v.getName(context),
                selector: (context, s) => s.overlayHistogramStyle,
                onSelection: (v) => settings.overlayHistogramStyle = v,
                tileTitle: l10n.settingsViewerShowHistogram,
                trailingBuilder: (context) {
                  final style = context.select<Settings, OverlayHistogramStyle>((v) => v.overlayHistogramStyle);
                  return SettingSwitchTrailingIcon(
                    key: ValueKey(style),
                    icon: AIcons.histogram,
                    disabled: style == OverlayHistogramStyle.none,
                  );
                },
              ),
              const Divider(height: 32),
              SettingsSwitchListTile(
                selector: (context, s) => s.showOverlayThumbnailPreview,
                onChanged: (v) => settings.showOverlayThumbnailPreview = v,
                title: l10n.settingsViewerShowOverlayThumbnails,
                trailing: _trailingIcon(context, AIcons.thumbnailBar),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
