import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class CrashlyticsRouteTracker extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => FirebaseCrashlytics.instance.log('Nav didPush to ${_name(route)}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => FirebaseCrashlytics.instance.log('Nav didPop to ${_name(previousRoute)}');

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => FirebaseCrashlytics.instance.log('Nav didRemove to ${_name(previousRoute)}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => FirebaseCrashlytics.instance.log('Nav didReplace to ${_name(newRoute)}');

  String _name(Route<dynamic>? route) => route?.settings.name ?? 'unnamed ${route?.runtimeType}';
}
