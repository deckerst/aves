// @dart=2.9
import 'dart:ui';

import 'package:aves/main.dart' as app;
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/storage_service.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:path/path.dart' as p;

import 'constants.dart';

void main() {
  enableFlutterDriverExtension();

  // scan files copied from test assets
  // we do it via the app instead of broadcasting via ADB
  // because `MEDIA_SCANNER_SCAN_FILE` intent got deprecated in API 29
  final storageService = PlatformStorageService();
  storageService.scanFile(p.join(targetPicturesDir, 'aves_logo.svg'), 'image/svg+xml');
  storageService.scanFile(p.join(targetPicturesDir, 'ipse.jpg'), 'image/jpeg');

  configureAndLaunch();
}

Future<void> configureAndLaunch() async {
  await settings.init();
  settings.keepScreenOn = KeepScreenOn.always;
  settings.hasAcceptedTerms = false;
  settings.locale = Locale('en');
  settings.homePage = HomePageSetting.collection;

  app.main();
}
