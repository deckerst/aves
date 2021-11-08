library aves_report;

import 'package:flutter/foundation.dart';

abstract class ReportService {
  Future<void> init();

  Map<String, String> get state;

  Future<void> setCollectionEnabled(bool enabled);

  Future<void> log(String message);

  Future<void> setCustomKey(String key, Object value);

  Future<void> setCustomKeys(Map<String, Object> map);

  Future<void> recordError(dynamic exception, StackTrace? stack);

  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails);
}
