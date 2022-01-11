import 'dart:ui';

import 'package:aves/main_play.dart' as app;
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
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
    // viewer
    ..imageBackground = EntryBackground.checkered
    // info
    ..infoMapStyle = EntryMapStyle.googleNormal;
  app.main();
}
