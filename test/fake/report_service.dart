import 'package:aves_report/aves_report.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeReportService extends ReportService {
  @override
  Future<void> init() => SynchronousFuture(null);

  @override
  Map<String, String> get state => {};

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
