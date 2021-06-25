import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/color_list_tile.dart';
import 'package:aves/widgets/common/basic/slider_list_tile.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/settings/video/subtitle_sample.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubtitleThemeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsSubtitleThemeTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: SubtitleThemePage.routeName),
            builder: (context) => SubtitleThemePage(),
          ),
        );
      },
    );
  }
}

class SubtitleThemePage extends StatelessWidget {
  static const routeName = '/settings/subtitle_theme';

  static const textAlignOptions = [TextAlign.left, TextAlign.center, TextAlign.right];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsSubtitleThemeTitle),
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
                      ListTile(
                        title: Text(context.l10n.settingsSubtitleThemeTextAlignmentTile),
                        subtitle: Text(_getTextAlignName(context, settings.subtitleTextAlignment)),
                        onTap: () async {
                          final value = await showDialog<TextAlign>(
                            context: context,
                            builder: (context) => AvesSelectionDialog<TextAlign>(
                              initialValue: settings.subtitleTextAlignment,
                              options: Map.fromEntries(textAlignOptions.map((v) => MapEntry(v, _getTextAlignName(context, v)))),
                              title: context.l10n.settingsSubtitleThemeTextAlignmentTitle,
                            ),
                          );
                          if (value != null) {
                            settings.subtitleTextAlignment = value;
                          }
                        },
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
                      SwitchListTile(
                        value: settings.subtitleShowOutline,
                        onChanged: (v) => settings.subtitleShowOutline = v,
                        title: Text(context.l10n.settingsSubtitleThemeShowOutline),
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
