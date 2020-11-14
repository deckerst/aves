import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/home_page.dart';
import 'package:aves/model/settings/screen_on.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/aves_expansion_tile.dart';
import 'package:aves/widgets/common/aves_selection_dialog.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/highlight_title.dart';
import 'package:aves/widgets/settings/access_grants.dart';
import 'package:aves/widgets/settings/svg_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ValueNotifier<String> _expandedNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: SafeArea(
          child: Consumer<Settings>(
            builder: (context, settings, child) => AnimationLimiter(
              child: ListView(
                padding: EdgeInsets.all(8),
                children: AnimationConfiguration.toStaggeredList(
                  duration: Durations.staggeredAnimation,
                  delay: Durations.staggeredAnimationDelay,
                  childAnimationBuilder: (child) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: child,
                    ),
                  ),
                  children: [
                    _buildNavigationSection(context),
                    _buildDisplaySection(context),
                    _buildThumbnailsSection(context),
                    _buildViewerSection(context),
                    _buildSearchSection(context),
                    _buildPrivacySection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return AvesExpansionTile(
      title: 'Navigation',
      expandedNotifier: _expandedNotifier,
      children: [
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
      ],
    );
  }

  Widget _buildDisplaySection(BuildContext context) {
    return AvesExpansionTile(
      title: 'Display',
      expandedNotifier: _expandedNotifier,
      children: [
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
      ],
    );
  }

  Widget _buildThumbnailsSection(BuildContext context) {
    return AvesExpansionTile(
      title: 'Thumbnails',
      expandedNotifier: _expandedNotifier,
      children: [
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
      ],
    );
  }

  Widget _buildViewerSection(BuildContext context) {
    return AvesExpansionTile(
      title: 'Viewer',
      expandedNotifier: _expandedNotifier,
      children: [
        SwitchListTile(
          value: settings.showOverlayMinimap,
          onChanged: (v) => settings.showOverlayMinimap = v,
          title: Text('Show minimap'),
        ),
        SwitchListTile(
          value: settings.showOverlayShootingDetails,
          onChanged: (v) => settings.showOverlayShootingDetails = v,
          title: Text('Show shooting details'),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return AvesExpansionTile(
      title: 'Search',
      expandedNotifier: _expandedNotifier,
      children: [
        SwitchListTile(
          value: settings.saveSearchHistory,
          onChanged: (v) {
            settings.saveSearchHistory = v;
            if (!v) {
              settings.searchHistory = [];
            }
          },
          title: Text('Save search history'),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return AvesExpansionTile(
      title: 'Privacy',
      expandedNotifier: _expandedNotifier,
      children: [
        SwitchListTile(
          value: settings.isCrashlyticsEnabled,
          onChanged: (v) => settings.isCrashlyticsEnabled = v,
          title: Text('Allow anonymous analytics and crash reporting'),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 16),
          child: GrantedDirectories(),
        ),
      ],
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
