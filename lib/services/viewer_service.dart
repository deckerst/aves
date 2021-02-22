import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ViewerService {
  static const platform = MethodChannel('deckers.thibault/aves/viewer');

  static Future<Map> getIntentData() async {
    try {
      // returns nullable map with 'action' and possibly 'uri' 'mimeType'
      return await platform.invokeMethod('getIntentData') as Map;
    } on PlatformException catch (e) {
      debugPrint('getIntentData failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }

  static Future<void> pick(String uri) async {
    try {
      await platform.invokeMethod('pick', <String, dynamic>{
        'uri': uri,
      });
    } on PlatformException catch (e) {
      debugPrint('pick failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }
}
