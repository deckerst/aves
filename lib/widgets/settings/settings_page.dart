import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/home_page.dart';
import 'package:aves/model/settings/screen_on.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/aves_selection_dialog.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/highlight_title.dart';
import 'package:aves/widgets/settings/access_grants.dart';
import 'package:aves/widgets/settings/svg_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
          ),
          body: SafeArea(
            child: Consumer<Settings>(
              builder: (context, settings, child) => ListView(
                padding: EdgeInsets.symmetric(vertical: 16),
                children: [
                  SectionTitle('Navigation'),
                  ListTile(
                    title: Text('Home'),
                    subtitle: Text(settings.homePage.name),
                    onTap: () async {
                      final value = await showDialog<HomePageSetting>(
                        context: context,
                        builder: (context) => AvesSelectionDialog<HomePageSetting>(
                          initialValue: settings.homePage,
                          options: Map.fromEntries(HomePageSetting.values.map((v) => MapEntry(v, v.name))),
                          title: 'Home',
                        ),
                      );
                      if (value != null) {
                        settings.homePage = value;
                      }
                    },
                  ),
                  SwitchListTile(
                    value: settings.mustBackTwiceToExit,
                    onChanged: (v) => settings.mustBackTwiceToExit = v,
                    title: Text('Tap “back” twice to exit'),
                  ),
                  SectionTitle('Display'),
                  ListTile(
                    title: Text('Keep screen on'),
                    subtitle: Text(settings.keepScreenOn.name),
                    onTap: () async {
                      final value = await showDialog<KeepScreenOn>(
                        context: context,
                        builder: (context) => AvesSelectionDialog<KeepScreenOn>(
                          initialValue: settings.keepScreenOn,
                          options: Map.fromEntries(KeepScreenOn.values.map((v) => MapEntry(v, v.name))),
                          title: 'Keep Screen On',
                        ),
                      );
                      if (value != null) {
                        settings.keepScreenOn = value;
                      }
                    },
                  ),
                  ListTile(
                    title: Text('SVG background'),
                    trailing: SvgBackgroundSelector(),
                  ),
                  ListTile(
                    title: Text('Coordinate format'),
                    subtitle: Text(settings.coordinateFormat.name),
                    onTap: () async {
                      final value = await showDialog<CoordinateFormat>(
                        context: context,
                        builder: (context) => AvesSelectionDialog<CoordinateFormat>(
                          initialValue: settings.coordinateFormat,
                          options: Map.fromEntries(CoordinateFormat.values.map((v) => MapEntry(v, v.name))),
                          optionSubtitleBuilder: (dynamic value) {
                            // dynamic declaration followed by cast, as workaround for generics limitation
                            final formatter = (value as CoordinateFormat);
                            return formatter.format(Constants.pointNemo);
                          },
                          title: 'Coordinate Format',
                        ),
                      );
                      if (value != null) {
                        settings.coordinateFormat = value;
                      }
                    },
                  ),
                  SectionTitle('Thumbnails'),
                  SwitchListTile(
                    value: settings.showThumbnailLocation,
                    onChanged: (v) => settings.showThumbnailLocation = v,
                    title: Text('Show location icon'),
                  ),
                  SwitchListTile(
                    value: settings.showThumbnailRaw,
                    onChanged: (v) => settings.showThumbnailRaw = v,
                    title: Text('Show raw icon'),
                  ),
                  SwitchListTile(
                    value: settings.showThumbnailVideoDuration,
                    onChanged: (v) => settings.showThumbnailVideoDuration = v,
                    title: Text('Show video duration'),
                  ),
                  SectionTitle('Privacy'),
                  SwitchListTile(
                    value: settings.isCrashlyticsEnabled,
                    onChanged: (v) => settings.isCrashlyticsEnabled = v,
                    title: Text('Allow anonymous analytics and crash reporting'),
                  ),
                  GrantedDirectories(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 6, right: 16, bottom: 12),
      child: HighlightTitle(text),
    );
  }
}
