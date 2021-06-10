// @dart=2.9
import 'dart:isolate';

import 'package:aves/widgets/aves_app.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

void main() {
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

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);

  runApp(AvesApp());
}
