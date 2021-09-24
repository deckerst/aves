import 'dart:ui';

import 'package:aves/main.dart' as app;
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/media/media_store_service.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'constants.dart';

void main() {
  enableFlutterDriverExtension();

  // scan files copied from test assets
  // we do it via the app instead of broadcasting via ADB
  // because `MEDIA_SCANNER_SCAN_FILE` intent got deprecated in API 29
  PlatformMediaStoreService()
    ..scanFile(p.join(targetPicturesDir, 'aves_logo.svg'), 'image/svg+xml')
    ..scanFile(p.join(targetPicturesDir, 'ipse.jpg'), 'image/jpeg');

  // something like `configure().then((_) => app.main());` does not behave as expected
  // and starts the app without waiting for `configure` to complete
  configureAndLaunch();
}

Future<void> configureAndLaunch() async {
  await settings.init();
  settings
    ..keepScreenOn = KeepScreenOn.always
    ..hasAcceptedTerms = false
    ..isErrorReportingEnabled = false
    ..locale = const Locale('en')
    ..homePage = HomePageSetting.collection
    ..imageBackground = EntryBackground.checkered;

  app.main();
}
