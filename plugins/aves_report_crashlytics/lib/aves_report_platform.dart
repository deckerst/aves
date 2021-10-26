library aves_report_platform;

import 'dart:async';

import 'package:aves_report/aves_report.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stack_trace/stack_trace.dart';

class PlatformReportService extends ReportService {
  FirebaseCrashlytics get _instance => FirebaseCrashlytics.instance;

  @override
  Future<void> init() => Firebase.initializeApp();

  @override
  Map<String, String> get state => {
        'Reporter': 'Crashlytics',
        'Firebase data collection enabled': '${Firebase.app().isAutomaticDataCollectionEnabled}',
        'Crashlytics collection enabled': '${_instance.isCrashlyticsCollectionEnabled}',
      };

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    debugPrint('${enabled ? 'enable' : 'disable'} Firebase & Crashlytics collection');
    await Firebase.app().setAutomaticDataCollectionEnabled(enabled);
    await _instance.setCrashlyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> log(String message) => _instance.log(message);

  @override
  Future<void> setCustomKey(String key, Object value) => _instance.setCustomKey(key, value);

  @override
  Future<void> setCustomKeys(Map<String, Object> map) {
    return Future.forEach<MapEntry<String, Object>>(map.entries, (kv) => _instance.setCustomKey(kv.key, kv.value));
  }

  @override
  Future<void> recordError(dynamic exception, StackTrace? stack) {
    if (exception is PlatformException && stack != null) {
      // simply creating a trace with `Trace.current(1)` or creating a `Trace` from modified frames
      // does not yield a stack trace that Crashlytics can segment,
      // so we reconstruct a string stack trace instead
      stack = StackTrace.fromString(Trace.from(stack)
          .frames
          .skip(2)
          .toList()
          .mapIndexed(
            (i, f) => '#${(i++).toString().padRight(8)}${f.member} (${f.uri}:${f.line}:${f.column})',
          )
          .join('\n'));
    }
    return _instance.recordError(exception, stack);
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) {
    return _instance.recordFlutterError(flutterErrorDetails);
  }
}
