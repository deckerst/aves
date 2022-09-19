import 'dart:ui';

import 'package:aves/main_play.dart' as app;
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/enums/enums.dart';
import 'package:aves_map/src/style.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => configureAndLaunch();

Future<void> configureAndLaunch() async {
  enableFlutterDriverExtension();
  await settings.init(monitorPlatformSettings: false);
  settings
    // app
    ..hasAcceptedTerms = false
    ..isInstalledAppAccessAllowed = true
    ..isErrorReportingAllowed = false
    ..locale = const Locale('en')
    // display
    ..themeBrightness = AvesThemeBrightness.dark
    ..themeColorMode = AvesThemeColorMode.polychrome
    ..enableDynamicColor = false
    ..enableBlurEffect = true
    // navigation
    ..keepScreenOn = KeepScreenOn.always
    ..homePage = HomePageSetting.collection
    ..enableBottomNavigationBar = true
    // collection
    ..collectionSectionFactor = EntryGroupFactor.album
    ..collectionSortFactor = EntrySortFactor.date
    ..collectionBrowsingQuickActions = SettingsDefaults.collectionBrowsingQuickActions
    // viewer
    ..showOverlayOnOpening = true
    ..showOverlayMinimap = true
    ..showOverlayInfo = true
    ..showOverlayShootingDetails = true
    ..showOverlayThumbnailPreview = true
    ..imageBackground = EntryBackground.checkered
    // info
    ..mapStyle = EntryMapStyle.googleNormal;
  app.main();
}
