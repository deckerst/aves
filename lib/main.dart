// @dart=2.9
import 'dart:isolate';

import 'package:aves/widgets/aves_app.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

void main() {
//  HttpClient.enableTimelineLogging = true; // enable network traffic logging
//  debugPrintGestureArenaDiagnostics = true;

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);

  runApp(AvesApp());
}
