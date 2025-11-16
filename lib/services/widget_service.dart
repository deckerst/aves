import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

class WidgetService {
  static const _configureChannel = AvesMethodChannel('deckers.thibault/aves/widget_configure');
  static const _updateChannel = AvesMethodChannel('deckers.thibault/aves/widget_update');

  static Future<bool> configure() async {
    try {
      await _configureChannel.invokeMethod('configure');
      return true;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  static Future<bool> update(int widgetId) async {
    try {
      await _updateChannel.invokeMethod('update', <String, dynamic>{
        'widgetId': widgetId,
      });
      return true;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }
}
