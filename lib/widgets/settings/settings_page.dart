import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/home_page.dart';
import 'package:aves/model/settings/screen_on.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/settings/access_grants.dart';
import 'package:aves/widgets/settings/entry_background.dart';
import 'package:aves/widgets/settings/hidden_filters.dart';
import 'package:aves/widgets/settings/language.dart';
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
    final theme = Theme.of(context);
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsPageTitle),
        ),
        body: Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              // dense style font for tile subtitles, without modifying title font
              bodyText2: TextStyle(fontSize: 12),
            ),
          ),
          child: SafeArea(
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
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return AvesExpansionTile(
      title: context.l10n.settingsSectionNavigation,
      expandedNotifier: _expandedNotifier,
      children: [
        ListTile(
          title: Text(context.l10n.settingsHome),
          subtitle: Text(settings.homePage.getName(context)),
          onTap: () async {
            final value = await showDialog<HomePageSetting>(
              context: context,
              builder: (context) => AvesSelectionDialog<HomePageSetting>(
                initialValue: settings.homePage,
                options: Map.fromEntries(HomePageSetting.values.map((v) => MapEntry(v, v.getName(context)))),
                title: context.l10n.settingsHome,
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
          title: Text(context.l10n.settingsDoubleBackExit),
        ),
      ],
    );
  }

  Widget _buildDisplaySection(BuildContext context) {
    return AvesExpansionTile(
      title: context.l10n.settingsSectionDisplay,
      expandedNotifier: _expandedNotifier,
      children: [
        LanguageTile(),
        ListTile(
          title: Text(context.l10n.settingsKeepScreenOnTile),
          subtitle: Text(settings.keepScreenOn.getName(context)),
          onTap: () async {
            final value = await showDialog<KeepScreenOn>(
              context: context,
              builder: (context) => AvesSelectionDialog<KeepScreenOn>(
                initialValue: settings.keepScreenOn,
                options: Map.fromEntries(KeepScreenOn.values.map((v) => MapEntry(v, v.getName(context)))),
                title: context.l10n.settingsKeepScreenOnTitle,
              ),
            );
            if (value != null) {
              settings.keepScreenOn = value;
            }
          },
        ),
        ListTile(
          title: Text(context.l10n.settingsRasterImageBackground),
          trailing: EntryBackgroundSelector(
            getter: () => settings.rasterBackground,
            setter: (value) => settings.rasterBackground = value,
          ),
        ),
        ListTile(
          title: Text(context.l10n.settingsVectorImageBackground),
          trailing: EntryBackgroundSelector(
            getter: () => settings.vectorBackground,
            setter: (value) => settings.vectorBackground = value,
          ),
        ),
        ListTile(
          title: Text(context.l10n.settingsCoordinateFormatTile),
          subtitle: Text(settings.coordinateFormat.getName(context)),
          onTap: () async {
            final value = await showDialog<CoordinateFormat>(
              context: context,
              builder: (context) => AvesSelectionDialog<CoordinateFormat>(
                initialValue: settings.coordinateFormat,
                options: Map.fromEntries(CoordinateFormat.values.map((v) => MapEntry(v, v.getName(context)))),
                optionSubtitleBuilder: (value) => value.format(Constants.pointNemo),
                title: context.l10n.settingsCoordinateFormatTitle,
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
      title: context.l10n.settingsSectionThumbnails,
      expandedNotifier: _expandedNotifier,
      children: [
        SwitchListTile(
          value: settings.showThumbnailLocation,
          onChanged: (v) => settings.showThumbnailLocation = v,
          title: Text(context.l10n.settingsThumbnailShowLocationIcon),
        ),
        SwitchListTile(
          value: settings.showThumbnailRaw,
          onChanged: (v) => settings.showThumbnailRaw = v,
          title: Text(context.l10n.settingsThumbnailShowRawIcon),
        ),
        SwitchListTile(
          value: settings.showThumbnailVideoDuration,
          onChanged: (v) => settings.showThumbnailVideoDuration = v,
          title: Text(context.l10n.settingsThumbnailShowVideoDuration),
        ),
      ],
    );
  }

  Widget _buildViewerSection(BuildContext context) {
    return AvesExpansionTile(
      title: context.l10n.settingsSectionViewer,
      expandedNotifier: _expandedNotifier,
      children: [
        SwitchListTile(
          value: settings.showOverlayMinimap,
          onChanged: (v) => settings.showOverlayMinimap = v,
          title: Text(context.l10n.settingsViewerShowMinimap),
        ),
        SwitchListTile(
          value: settings.showOverlayInfo,
          onChanged: (v) => settings.showOverlayInfo = v,
          title: Text(context.l10n.settingsViewerShowInformation),
          subtitle: Text(context.l10n.settingsViewerShowInformationSubtitle),
        ),
        SwitchListTile(
          value: settings.showOverlayShootingDetails,
          onChanged: settings.showOverlayInfo ? (v) => settings.showOverlayShootingDetails = v : null,
          title: Text(context.l10n.settingsViewerShowShootingDetails),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return AvesExpansionTile(
      title: context.l10n.settingsSectionSearch,
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
          title: Text(context.l10n.settingsSaveSearchHistory),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return AvesExpansionTile(
      title: context.l10n.settingsSectionPrivacy,
      expandedNotifier: _expandedNotifier,
      children: [
        SwitchListTile(
          value: settings.isCrashlyticsEnabled,
          onChanged: (v) => settings.isCrashlyticsEnabled = v,
          title: Text(context.l10n.settingsEnableAnalytics),
        ),
        HiddenFilterTile(),
        StorageAccessTile(),
      ],
    );
  }
}
