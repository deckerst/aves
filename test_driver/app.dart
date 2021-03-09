import 'package:aves/main.dart' as app;
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/android_file_service.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:path/path.dart' as path;

import 'constants.dart';

void main() {
  enableFlutterDriverExtension();

  // scan files copied from test assets
  // we do it via the app instead of broadcasting via ADB
  // because `MEDIA_SCANNER_SCAN_FILE` intent got deprecated in API 29
  AndroidFileService.scanFile(path.join(targetPicturesDir, 'ipse.jpg'), 'image/jpeg');

  configureAndLaunch();
}

Future<void> configureAndLaunch() async {
  await settings.init();
  settings.keepScreenOn = KeepScreenOn.always;
  settings.hasAcceptedTerms = false;

  app.main();
}
