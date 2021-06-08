import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/home_page.dart';
import 'package:aves/model/settings/screen_on.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/settings/video_loop_mode.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/settings/access_grants.dart';
import 'package:aves/widgets/settings/entry_background.dart';
import 'package:aves/widgets/settings/hidden_filters.dart';
import 'package:aves/widgets/settings/language.dart';
import 'package:aves/widgets/settings/quick_actions/editor.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ValueNotifier<String?> _expandedNotifier = ValueNotifier(null);

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
              bodyText2: const TextStyle(fontSize: 12),
            ),
          ),
          child: SafeArea(
            child: Consumer<Settings>(
              builder: (context, settings, child) => AnimationLimiter(
                child: ListView(
                  padding: const EdgeInsets.all(8),
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
                      _buildThumbnailsSection(context),
                      _buildViewerSection(context),
                      _buildVideoSection(context),
                      _buildPrivacySection(context),
                      _buildLanguageSection(context),
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
      leading: _buildLeading(AIcons.home, stringToColor('Navigation')),
      title: context.l10n.settingsSectionNavigation,
      expandedNotifier: _expandedNotifier,
      showHighlight: false,
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
        SwitchListTile(
          value: settings.mustBackTwiceToExit,
          onChanged: (v) => settings.mustBackTwiceToExit = v,
          title: Text(context.l10n.settingsDoubleBackExit),
        ),
      ],
    );
  }

  Widget _buildThumbnailsSection(BuildContext context) {
    final iconSize = IconTheme.of(context).size! * MediaQuery.of(context).textScaleFactor;
    double opacityFor(bool enabled) => enabled ? 1 : .2;
    return AvesExpansionTile(
      leading: _buildLeading(AIcons.grid, stringToColor('Thumbnails')),
      title: context.l10n.settingsSectionThumbnails,
      expandedNotifier: _expandedNotifier,
      showHighlight: false,
      children: [
        SwitchListTile(
          value: settings.showThumbnailLocation,
          onChanged: (v) => settings.showThumbnailLocation = v,
          title: Row(
            children: [
              Expanded(child: Text(context.l10n.settingsThumbnailShowLocationIcon)),
              AnimatedOpacity(
                opacity: opacityFor(settings.showThumbnailLocation),
                duration: Durations.toggleableTransitionAnimation,
                child: Icon(
                  AIcons.location,
                  size: iconSize,
                ),
              ),
            ],
          ),
        ),
        SwitchListTile(
          value: settings.showThumbnailRaw,
          onChanged: (v) => settings.showThumbnailRaw = v,
          title: Row(
            children: [
              Expanded(child: Text(context.l10n.settingsThumbnailShowRawIcon)),
              AnimatedOpacity(
                opacity: opacityFor(settings.showThumbnailRaw),
                duration: Durations.toggleableTransitionAnimation,
                child: Icon(
                  AIcons.raw,
                  size: iconSize,
                ),
              ),
            ],
          ),
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
      leading: _buildLeading(AIcons.image, stringToColor('Image')),
      title: context.l10n.settingsSectionViewer,
      expandedNotifier: _expandedNotifier,
      showHighlight: false,
      children: [
        QuickActionsTile(),
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
      ],
    );
  }

  Widget _buildVideoSection(BuildContext context) {
    final hiddenFilters = settings.hiddenFilters;
    final showVideos = !hiddenFilters.contains(MimeFilter.video);
    return AvesExpansionTile(
      leading: _buildLeading(AIcons.video, stringToColor('Video')),
      title: context.l10n.settingsSectionVideo,
      expandedNotifier: _expandedNotifier,
      showHighlight: false,
      children: [
        SwitchListTile(
          value: showVideos,
          onChanged: (v) => context.read<CollectionSource>().changeFilterVisibility(MimeFilter.video, v),
          title: Text(context.l10n.settingsVideoShowVideos),
        ),
        SwitchListTile(
          value: settings.enableVideoHardwareAcceleration,
          onChanged: (v) => settings.enableVideoHardwareAcceleration = v,
          title: Text(context.l10n.settingsVideoEnableHardwareAcceleration),
        ),
        SwitchListTile(
          value: settings.enableVideoAutoPlay,
          onChanged: (v) => settings.enableVideoAutoPlay = v,
          title: Text(context.l10n.settingsVideoEnableAutoPlay),
        ),
        ListTile(
          title: Text(context.l10n.settingsVideoLoopModeTile),
          subtitle: Text(settings.videoLoopMode.getName(context)),
          onTap: () async {
            final value = await showDialog<VideoLoopMode>(
              context: context,
              builder: (context) => AvesSelectionDialog<VideoLoopMode>(
                initialValue: settings.videoLoopMode,
                options: Map.fromEntries(VideoLoopMode.values.map((v) => MapEntry(v, v.getName(context)))),
                title: context.l10n.settingsVideoLoopModeTitle,
              ),
            );
            if (value != null) {
              settings.videoLoopMode = value;
            }
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return AvesExpansionTile(
      leading: _buildLeading(AIcons.privacy, stringToColor('Privacy')),
      title: context.l10n.settingsSectionPrivacy,
      expandedNotifier: _expandedNotifier,
      showHighlight: false,
      children: [
        SwitchListTile(
          value: settings.isCrashlyticsEnabled,
          onChanged: (v) => settings.isCrashlyticsEnabled = v,
          title: Text(context.l10n.settingsEnableAnalytics),
        ),
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
        HiddenFilterTile(),
        StorageAccessTile(),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    return AvesExpansionTile(
      // use a fixed value instead of the title to identify this expansion tile
      // so that the tile state is kept when the language is modified
      value: 'language',
      leading: _buildLeading(AIcons.language, stringToColor('Language')),
      title: context.l10n.settingsSectionLanguage,
      expandedNotifier: _expandedNotifier,
      showHighlight: false,
      children: [
        LanguageTile(),
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

  Widget _buildLeading(IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(
            color: color,
            width: AvesFilterChip.outlineWidth,
          )),
          shape: BoxShape.circle,
        ),
        child: DecoratedIcon(
          icon,
          shadows: Constants.embossShadows,
          size: 18,
        ),
      );
}
