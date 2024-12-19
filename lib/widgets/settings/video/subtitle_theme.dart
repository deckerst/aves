import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/list_tiles/color.dart';
import 'package:aves/widgets/common/basic/list_tiles/slider.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/video/subtitle_sample.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubtitleThemePage extends StatelessWidget {
  static const routeName = '/settings/video/subtitle_theme';

  const SubtitleThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !settings.useTvLayout,
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
                      SettingsSelectionListTile<SubtitlePosition>(
                        values: const [SubtitlePosition.top, SubtitlePosition.bottom],
                        getName: (context, v) => v.getName(context),
                        selector: (context, s) => s.subtitleTextPosition,
                        onSelection: (v) => settings.subtitleTextPosition = v,
                        tileTitle: context.l10n.settingsSubtitleThemeTextPositionTile,
                        dialogTitle: context.l10n.settingsSubtitleThemeTextPositionDialogTitle,
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
                        value: settings.subtitleTextColor.withValues(alpha: 1),
                        onChanged: (v) => settings.subtitleTextColor = v.withValues(alpha: settings.subtitleTextColor.a),
                      ),
                      SliderListTile(
                        title: context.l10n.settingsSubtitleThemeTextOpacity,
                        value: settings.subtitleTextColor.a,
                        onChanged: (v) => settings.subtitleTextColor = settings.subtitleTextColor.withValues(alpha: v),
                      ),
                      ColorListTile(
                        title: context.l10n.settingsSubtitleThemeBackgroundColor,
                        value: settings.subtitleBackgroundColor.withValues(alpha: 1),
                        onChanged: (v) => settings.subtitleBackgroundColor = v.withValues(alpha: settings.subtitleBackgroundColor.a),
                      ),
                      SliderListTile(
                        title: context.l10n.settingsSubtitleThemeBackgroundOpacity,
                        value: settings.subtitleBackgroundColor.a,
                        onChanged: (v) => settings.subtitleBackgroundColor = settings.subtitleBackgroundColor.withValues(alpha: v),
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
    final l10n = context.l10n;
    return switch (align) {
      TextAlign.left => l10n.settingsSubtitleThemeTextAlignmentLeft,
      TextAlign.center => l10n.settingsSubtitleThemeTextAlignmentCenter,
      TextAlign.right => l10n.settingsSubtitleThemeTextAlignmentRight,
      _ => '',
    };
  }
}
