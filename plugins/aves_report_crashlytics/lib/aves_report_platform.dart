library aves_report_platform;

import 'dart:async';

import 'package:aves_report/aves_report.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformReportService extends ReportService {
  FirebaseCrashlytics? get _instance {
    try {
      return FirebaseCrashlytics.instance;
    } catch (error, stack) {
      // as of firebase_core v1.21.0 / firebase_crashlytics v2.8.8, `Firebase.app` sometimes fail with:
      // `No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()`
      debugPrint('failed to get Firebase Crashlytics instance with error=$error\n$stack');
    }
    return null;
  }

  @override
  Future<void> init() => Firebase.initializeApp();

  @override
  Map<String, String> get state {
    try {
      return {
        'Reporter': 'Crashlytics',
        'Firebase data collection enabled': '${Firebase.app().isAutomaticDataCollectionEnabled}',
        'Crashlytics collection enabled': '${_instance?.isCrashlyticsCollectionEnabled}',
      };
    } catch (error, stack) {
      // as of firebase_core v1.21.0 / firebase_crashlytics v2.8.8, `Firebase.app` sometimes fail with:
      // `No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()`
      debugPrint('failed to access Firebase properties with error=$error\n$stack');
    }
    return {};
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    debugPrint('${enabled ? 'enable' : 'disable'} Firebase & Crashlytics collection');
    try {
      await Firebase.app().setAutomaticDataCollectionEnabled(enabled);
      await _instance?.setCrashlyticsCollectionEnabled(enabled);
    } catch (error, stack) {
      // as of firebase_core v1.21.0 / firebase_crashlytics v2.8.8, `Firebase.app` sometimes fail with:
      // `No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()`
      debugPrint('failed to access Firebase properties with error=$error\n$stack');
    }
  }

  @override
  Future<void> log(String message) async {
    debugPrint('Report log=$message');
    await _instance?.log(message);
  }

  @override
  Future<void> setCustomKey(String key, Object value) async => _instance?.setCustomKey(key, value);

  @override
  Future<void> setCustomKeys(Map<String, Object> map) {
    return Future.forEach<MapEntry<String, Object>>(map.entries, (kv) => setCustomKey(kv.key, kv.value));
  }

  @override
  Future<void> recordError(dynamic exception, StackTrace? stack) async {
    if (exception is PlatformException && stack != null) {
      stack = ReportService.buildReportStack(stack, level: 2);
    }
    return _instance?.recordError(exception, stack);
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) async {
    return _instance?.recordFlutterError(flutterErrorDetails);
  }
}
