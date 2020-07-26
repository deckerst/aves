import 'dart:typed_data';

import 'package:aves/model/image_entry.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidAppService {
  static const platform = MethodChannel('deckers.thibault/aves/app');

  static Future<Map> getAppNames() async {
    try {
      final result = await platform.invokeMethod('getAppNames');
      return result as Map;
    } on PlatformException catch (e) {
      debugPrint('getAppNames failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return {};
  }

  static Future<Uint8List> getAppIcon(String packageName, double size) async {
    try {
      final result = await platform.invokeMethod('getAppIcon', <String, dynamic>{
        'packageName': packageName,
        'sizeDip': size,
      });
      return result as Uint8List;
    } on PlatformException catch (e) {
      debugPrint('getAppIcon failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return Uint8List(0);
  }

  static Future<Map> getEnv() async {
    try {
      final result = await platform.invokeMethod('getEnv');
      return result as Map;
    } on PlatformException catch (e) {
      debugPrint('getEnv failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return {};
  }

  static Future<void> edit(String uri, String mimeType) async {
    try {
      await platform.invokeMethod('edit', <String, dynamic>{
        'title': 'Edit with:',
        'uri': uri,
        'mimeType': mimeType,
      });
    } on PlatformException catch (e) {
      debugPrint('edit failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }

  static Future<void> open(String uri, String mimeType) async {
    try {
      await platform.invokeMethod('open', <String, dynamic>{
        'title': 'Open with:',
        'uri': uri,
        'mimeType': mimeType,
      });
    } on PlatformException catch (e) {
      debugPrint('open failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }

  static Future<void> openMap(String geoUri) async {
    if (geoUri == null) return;
    try {
      await platform.invokeMethod('openMap', <String, dynamic>{
        'geoUri': geoUri,
      });
    } on PlatformException catch (e) {
      debugPrint('openMap failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }

  static Future<void> setAs(String uri, String mimeType) async {
    try {
      await platform.invokeMethod('setAs', <String, dynamic>{
        'title': 'Set as:',
        'uri': uri,
        'mimeType': mimeType,
      });
    } on PlatformException catch (e) {
      debugPrint('setAs failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }

  static Future<void> share(Iterable<ImageEntry> entries) async {
    // loosen mime type to a generic one, so we can share with badly defined apps
    // e.g. Google Lens declares receiving "image/jpeg" only, but it can actually handle more formats
    final urisByMimeType = groupBy<ImageEntry, String>(entries, (e) => e.mimeTypeAnySubtype).map((k, v) => MapEntry(k, v.map((e) => e.uri).toList()));
    try {
      await platform.invokeMethod('share', <String, dynamic>{
        'title': 'Share via:',
        'urisByMimeType': urisByMimeType,
      });
    } on PlatformException catch (e) {
      debugPrint('share failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }
}
