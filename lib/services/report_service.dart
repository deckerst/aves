import 'package:collection/collection.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stack_trace/stack_trace.dart';

abstract class ReportService {
  bool get isCollectionEnabled;

  Future<void> setCollectionEnabled(bool enabled);

  Future<void> log(String message);

  Future<void> setCustomKey(String key, Object value);

  Future<void> setCustomKeys(Map<String, Object> map);

  Future<void> recordError(dynamic exception, StackTrace? stack);

  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails);
}

class CrashlyticsReportService extends ReportService {
  FirebaseCrashlytics get instance => FirebaseCrashlytics.instance;

  @override
  bool get isCollectionEnabled => instance.isCrashlyticsCollectionEnabled;

  @override
  Future<void> setCollectionEnabled(bool enabled) => instance.setCrashlyticsCollectionEnabled(enabled);

  @override
  Future<void> log(String message) => instance.log(message);

  @override
  Future<void> setCustomKey(String key, Object value) => instance.setCustomKey(key, value);

  @override
  Future<void> setCustomKeys(Map<String, Object> map) {
    final _instance = instance;
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
    return instance.recordError(exception, stack);
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) {
    return instance.recordFlutterError(flutterErrorDetails);
  }
}
