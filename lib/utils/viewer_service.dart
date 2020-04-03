import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ViewerService {
  static const platform = MethodChannel('deckers.thibault/aves/viewer');

  static Future<Map> getSharedEntry() async {
    try {
      // return nullable map with: 'uri' 'mimeType'
      return await platform.invokeMethod('getSharedEntry') as Map;
    } on PlatformException catch (e) {
      debugPrint('getSharedEntry failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }
}
