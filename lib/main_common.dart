import 'dart:isolate';

import 'package:aves/app_flavor.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:flutter/material.dart';

void mainCommon(AppFlavor flavor, {Map? debugIntentData}) {
//  HttpClient.enableTimelineLogging = true; // enable network traffic logging
//  debugPrintGestureArenaDiagnostics = true;

// Invert oversized images (debug mode only)
// cf https://flutter.dev/docs/development/tools/devtools/inspector
// but unaware of device pixel ratio as of Flutter 2.2.1: https://github.com/flutter/flutter/issues/76208
//
// MaterialApp.checkerboardOffscreenLayers
// cf https://flutter.dev/docs/perf/rendering/ui-performance#checking-for-offscreen-layers
//
// MaterialApp.checkerboardRasterCacheImages
// cf https://flutter.dev/docs/perf/rendering/ui-performance#checking-for-non-cached-images
//
// flutter run --profile --trace-skia

  initPlatformServices();

  Isolate.current.addErrorListener(RawReceivePort((pair) {
    final List<dynamic> errorAndStacktrace = pair;
    reportService.recordError(errorAndStacktrace.first, errorAndStacktrace.last);
  }).sendPort);

  // Errors during the widget build phase will show by default:
  // - in debug mode: error on red background
  // - in profile/release mode: plain grey background
  // This can be modified via `ErrorWidget.builder`
  // ErrorWidget.builder = (details) => ErrorWidget(details.exception);
  // cf https://docs.flutter.dev/testing/errors

  runApp(AvesApp(flavor: flavor, debugIntentData: debugIntentData));
}
