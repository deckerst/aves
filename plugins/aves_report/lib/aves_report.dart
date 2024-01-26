library aves_report;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart';

abstract class ReportService {
  Future<void> init();

  Map<String, String> get state;

  Future<void> setCollectionEnabled(bool enabled);

  Future<void> log(String message);

  Future<void> setCustomKey(String key, Object value);

  Future<void> setCustomKeys(Map<String, Object> map);

  Future<void> recordError(dynamic exception, StackTrace? stack);

  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails);

  static StackTrace? buildReportStack(StackTrace stack, {int level = 0}) {
    // simply creating a trace with `Trace.current(1)` or creating a `Trace` from modified frames
    // does not yield a stack trace that Crashlytics can segment,
    // so we reconstruct a string stack trace instead
    return StackTrace.fromString(Trace.from(stack)
        .frames
        .skip(level)
        .toList()
        .mapIndexed(
          (i, f) => '#${(i++).toString().padRight(8)}${f.member} (${f.uri}:${f.line}:${f.column})',
        )
        .join('\n'));
  }
}

class UnreportedStateError extends StateError {
  UnreportedStateError(super.message);
}