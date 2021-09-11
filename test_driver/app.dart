import 'dart:ui';

import 'package:aves/main.dart' as app;
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/media_store_service.dart';
import 'package:aves/services/window_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/media_query.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:path/path.dart' as p;

import 'constants.dart';

void main() {
  enableFlutterDriverExtension();

  // scan files copied from test assets
  // we do it via the app instead of broadcasting via ADB
  // because `MEDIA_SCANNER_SCAN_FILE` intent got deprecated in API 29
  final mediaStoreService = PlatformMediaStoreService();
  mediaStoreService.scanFile(p.join(targetPicturesDir, 'aves_logo.svg'), 'image/svg+xml');
  mediaStoreService.scanFile(p.join(targetPicturesDir, 'ipse.jpg'), 'image/jpeg');

  configureAndLaunch();
}

Future<void> configureAndLaunch() async {
  // set up fake services called during settings initialization
  final fakeWindowService = FakeWindowService();
  getIt.registerSingleton<WindowService>(fakeWindowService);

  await settings.init();
  settings.keepScreenOn = KeepScreenOn.always;
  settings.hasAcceptedTerms = false;
  settings.isCrashlyticsEnabled = false;
  settings.locale = const Locale('en');
  settings.homePage = HomePageSetting.collection;
  settings.imageBackground = EntryBackground.checkered;

  // tear down fake services
  getIt.unregister<WindowService>(instance: fakeWindowService);

  app.main();
}

class FakeWindowService implements WindowService {
  @override
  Future<void> keepScreenOn(bool on) => SynchronousFuture(null);

  @override
  Future<bool> isRotationLocked() => SynchronousFuture(false);

  @override
  Future<void> requestOrientation([Orientation? orientation]) => SynchronousFuture(null);

  @override
  Future<bool> canSetCutoutMode() => SynchronousFuture(false);

  @override
  Future<void> setCutoutMode(bool use) => SynchronousFuture(null);
}
