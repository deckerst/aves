import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidFileService {
  static const platform = MethodChannel('deckers.thibault/aves/file');

  static Future<List<Map>> getStorageVolumes() async {
    try {
      final result = await platform.invokeMethod('getStorageVolumes');
      return (result as List).cast<Map>();
    } on PlatformException catch (e) {
      debugPrint('getStorageVolumes failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return [];
  }
}
