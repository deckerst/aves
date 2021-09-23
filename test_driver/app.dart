import 'dart:ui';

import 'package:aves/main.dart' as app;
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/media_store_service.dart';
import 'package:aves/services/report_service.dart';
import 'package:aves/services/window_service.dart';
import 'package:flutter/foundation.dart';
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
  // TODO TLAD [test] decouple services from settings setters, so there is no need for fake services here
  // set up fake services called during settings initialization
  getIt
    ..registerSingleton<WindowService>(DriverInitWindowService())
    ..registerSingleton<ReportService>(DriverInitReportService());

  await settings.init();
  settings
    ..keepScreenOn = KeepScreenOn.always
    ..hasAcceptedTerms = false
    ..isCrashlyticsEnabled = false
    ..locale = const Locale('en')
    ..homePage = HomePageSetting.collection
    ..imageBackground = EntryBackground.checkered;

  // tear down fake services
  await Future.delayed(const Duration(seconds: 1));
  await getIt.reset();

  app.main();
}

class DriverInitWindowService extends Fake implements WindowService {
  @override
  Future<void> keepScreenOn(bool on) => SynchronousFuture(null);

  @override
  Future<bool> isRotationLocked() => SynchronousFuture(false);
}

class DriverInitReportService extends Fake implements ReportService {
  @override
  bool get isCollectionEnabled => false;

  @override
  Future<void> setCollectionEnabled(bool enabled) => SynchronousFuture(null);

  @override
  Future<void> log(String message) => SynchronousFuture(null);

  @override
  Future<void> setCustomKey(String key, Object value) => SynchronousFuture(null);

  @override
  Future<void> setCustomKeys(Map<String, Object> map) => SynchronousFuture(null);

  @override
  Future<void> recordError(exception, StackTrace? stack) => SynchronousFuture(null);

  @override
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) => SynchronousFuture(null);
}
