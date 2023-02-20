import 'package:aves/services/common/services.dart';
import 'package:flutter/material.dart';

class ReportingRouteTracker extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => reportService.log('Nav push to ${_name(route)}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => reportService.log('Nav pop to ${_name(previousRoute)}');

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => reportService.log('Nav remove to ${_name(previousRoute)}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => reportService.log('Nav replace to ${_name(newRoute)}');

  String _name(Route<dynamic>? route) => route?.settings.name ?? 'unnamed ${route?.runtimeType}';
}
