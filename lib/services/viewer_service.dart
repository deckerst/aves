import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

class ViewerService {
  static const platform = MethodChannel('deckers.thibault/aves/viewer');

  static Future<Map<String, dynamic>> getIntentData() async {
    try {
      // returns nullable map with 'action' and possibly 'uri' 'mimeType'
      final result = await platform.invokeMethod('getIntentData');
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<void> pick(String uri) async {
    try {
      await platform.invokeMethod('pick', <String, dynamic>{
        'uri': uri,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }
}
