import 'package:aves_report/aves_report.dart';
import 'package:flutter/foundation.dart';

class PlatformReportService extends ReportService {
  @override
  Future<void> init() => SynchronousFuture(null);

  @override
  Future<void> log(String message) async => debugPrint('Report log with message=$message');

  @override
  Future<void> recordError(dynamic exception, [StackTrace? stack]) async => debugPrint('Report error with exception=$exception, stack=$stack');

  @override
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) async => debugPrint('Report Flutter error with details=$flutterErrorDetails');

  @override
  Future<void> setCollectionEnabled(bool enabled) => SynchronousFuture(null);

  @override
  Future<void> setCustomKey(String key, Object value) async => debugPrint('Report set key $key=$value');

  @override
  Future<void> setCustomKeys(Map<String, Object> map) async => debugPrint('Report set keys ${map.entries.map((kv) => '${kv.key}=${kv.value}').join(', ')}');

  @override
  Map<String, String> get state => {'Reporter': 'Console'};
}
