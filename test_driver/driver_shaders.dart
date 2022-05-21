import 'dart:ui';

import 'package:aves/main_play.dart' as app;
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
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
    ..keepScreenOn = KeepScreenOn.always
    ..homePage = HomePageSetting.collection
    // collection
    ..collectionBrowsingQuickActions = SettingsDefaults.collectionBrowsingQuickActions
    // viewer
    ..showOverlayOnOpening = true
    ..showOverlayMinimap = true
    ..showOverlayInfo = true
    ..showOverlayShootingDetails = true
    ..showOverlayThumbnailPreview = true
    ..enableOverlayBlurEffect = true
    ..imageBackground = EntryBackground.checkered
    // info
    ..infoMapStyle = EntryMapStyle.googleNormal;
  app.main();
}
