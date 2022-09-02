import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/color_list_tile.dart';
import 'package:aves/widgets/common/basic/slider_list_tile.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/video/subtitle_sample.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubtitleThemePage extends StatelessWidget {
  static const routeName = '/settings/video/subtitle_theme';

  const SubtitleThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsSubtitleThemePageTitle),
      ),
      body: SafeArea(
        child: Consumer<Settings>(
          builder: (context, settings, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SubtitleSample(),
                ),
                const Divider(height: 0),
                Expanded(
                  child: ListView(
                    children: [
                      SettingsSelectionListTile<TextAlign>(
                        values: const [TextAlign.left, TextAlign.center, TextAlign.right],
                        getName: _getTextAlignName,
                        selector: (context, s) => s.subtitleTextAlignment,
                        onSelection: (v) => settings.subtitleTextAlignment = v,
                        tileTitle: context.l10n.settingsSubtitleThemeTextAlignmentTile,
                        dialogTitle: context.l10n.settingsSubtitleThemeTextAlignmentDialogTitle,
                      ),
                      SliderListTile(
                        title: context.l10n.settingsSubtitleThemeTextSize,
                        value: settings.subtitleFontSize,
                        onChanged: (v) => settings.subtitleFontSize = v,
                        min: 10,
                        max: 40,
                        divisions: 6,
                      ),
                      ColorListTile(
                        title: context.l10n.settingsSubtitleThemeTextColor,
                        value: settings.subtitleTextColor.withOpacity(1),
                        onChanged: (v) => settings.subtitleTextColor = v.withOpacity(settings.subtitleTextColor.opacity),
                      ),
                      SliderListTile(
                        title: context.l10n.settingsSubtitleThemeTextOpacity,
                        value: settings.subtitleTextColor.opacity,
                        onChanged: (v) => settings.subtitleTextColor = settings.subtitleTextColor.withOpacity(v),
                      ),
                      ColorListTile(
                        title: context.l10n.settingsSubtitleThemeBackgroundColor,
                        value: settings.subtitleBackgroundColor.withOpacity(1),
                        onChanged: (v) => settings.subtitleBackgroundColor = v.withOpacity(settings.subtitleBackgroundColor.opacity),
                      ),
                      SliderListTile(
                        title: context.l10n.settingsSubtitleThemeBackgroundOpacity,
                        value: settings.subtitleBackgroundColor.opacity,
                        onChanged: (v) => settings.subtitleBackgroundColor = settings.subtitleBackgroundColor.withOpacity(v),
                      ),
                      SettingsSwitchListTile(
                        selector: (context, s) => s.subtitleShowOutline,
                        onChanged: (v) => settings.subtitleShowOutline = v,
                        title: context.l10n.settingsSubtitleThemeShowOutline,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getTextAlignName(BuildContext context, TextAlign align) {
    switch (align) {
      case TextAlign.left:
        return context.l10n.settingsSubtitleThemeTextAlignmentLeft;
      case TextAlign.center:
        return context.l10n.settingsSubtitleThemeTextAlignmentCenter;
      case TextAlign.right:
        return context.l10n.settingsSubtitleThemeTextAlignmentRight;
      default:
        return '';
    }
  }
}
