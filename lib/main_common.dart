import 'dart:isolate';

import 'package:aves/app_flavor.dart';
import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leak_tracker/leak_tracker.dart';

void mainCommon(AppFlavor flavor, {Map<String, Object?>? debugIntentData}) {
  AvesMethodChannel.kDebug = kDebugMode;
  debugProfilePlatformChannels = false;

  //  HttpClient.enableTimelineLogging = true; // enable network traffic logging
  //  debugPrintGestureArenaDiagnostics = true;

  initPlatformServices();

  Isolate.current.addErrorListener(
    RawReceivePort((pair) {
      final errorAndStacktrace = pair as List;
      final error = errorAndStacktrace[0] as String;
      final stackTraceString = errorAndStacktrace[1] as String?;
      final stackTrace = stackTraceString != null ? StackTrace.fromString(stackTraceString) : null;
      reportService.recordError(error, stackTrace);
    }).sendPort,
  );

  // Errors during the widget build phase will show by default:
  // - in debug mode: error on red background
  // - in profile/release mode: plain grey background
  // This can be modified via `ErrorWidget.builder`
  // ErrorWidget.builder = (details) => ErrorWidget(details.exception);
  // cf https://docs.flutter.dev/testing/errors

  LeakTracking.start();
  FlutterMemoryAllocations.instance.addListener(
    (event) => LeakTracking.dispatchObjectEvent(event.toMap()),
  );
  runApp(AvesApp(flavor: flavor, debugIntentData: debugIntentData));
}
