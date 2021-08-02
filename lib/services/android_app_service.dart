import 'dart:typed_data';

import 'package:aves/model/entry.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidAppService {
  static const platform = MethodChannel('deckers.thibault/aves/app');

  static Future<Set<Package>> getPackages() async {
    try {
      final result = await platform.invokeMethod('getPackages');
      final packages = (result as List).cast<Map>().map((map) => Package.fromMap(map)).toSet();
      // additional info for known directories
      final kakaoTalk = packages.firstWhereOrNull((package) => package.packageName == 'com.kakao.talk');
      if (kakaoTalk != null) {
        kakaoTalk.ownedDirs.add('KakaoTalkDownload');
      }
      return packages;
    } on PlatformException catch (e) {
      debugPrint('getPackages failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return {};
  }

  static Future<Uint8List> getAppIcon(String packageName, double size) async {
    try {
      final result = await platform.invokeMethod('getAppIcon', <String, dynamic>{
        'packageName': packageName,
        'sizeDip': size,
      });
      if (result != null) return result as Uint8List;
    } on PlatformException catch (e) {
      debugPrint('getAppIcon failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return Uint8List(0);
  }

  static Future<bool> copyToClipboard(String uri, String? label) async {
    try {
      final result = await platform.invokeMethod('copyToClipboard', <String, dynamic>{
        'uri': uri,
        'label': label,
      });
      if (result != null) return result as bool;
    } on PlatformException catch (e) {
      debugPrint('copyToClipboard failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return false;
  }

  static Future<bool> edit(String uri, String mimeType) async {
    try {
      final result = await platform.invokeMethod('edit', <String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
      });
      if (result != null) return result as bool;
    } on PlatformException catch (e) {
      debugPrint('edit failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return false;
  }

  static Future<bool> open(String uri, String mimeType) async {
    try {
      final result = await platform.invokeMethod('open', <String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
      });
      if (result != null) return result as bool;
    } on PlatformException catch (e) {
      debugPrint('open failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return false;
  }

  static Future<bool> openMap(String geoUri) async {
    try {
      final result = await platform.invokeMethod('openMap', <String, dynamic>{
        'geoUri': geoUri,
      });
      if (result != null) return result as bool;
    } on PlatformException catch (e) {
      debugPrint('openMap failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return false;
  }

  static Future<bool> setAs(String uri, String mimeType) async {
    try {
      final result = await platform.invokeMethod('setAs', <String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
      });
      if (result != null) return result as bool;
    } on PlatformException catch (e) {
      debugPrint('setAs failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return false;
  }

  static Future<bool> shareEntries(Iterable<AvesEntry> entries) async {
    // loosen mime type to a generic one, so we can share with badly defined apps
    // e.g. Google Lens declares receiving "image/jpeg" only, but it can actually handle more formats
    final urisByMimeType = groupBy<AvesEntry, String>(entries, (e) => e.mimeTypeAnySubtype).map((k, v) => MapEntry(k, v.map((e) => e.uri).toList()));
    try {
      final result = await platform.invokeMethod('share', <String, dynamic>{
        'urisByMimeType': urisByMimeType,
      });
      if (result != null) return result as bool;
    } on PlatformException catch (e) {
      debugPrint('shareEntries failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return false;
  }

  static Future<bool> shareSingle(String uri, String mimeType) async {
    try {
      final result = await platform.invokeMethod('share', <String, dynamic>{
        'urisByMimeType': {
          mimeType: [uri]
        },
      });
      if (result != null) return result as bool;
    } on PlatformException catch (e) {
      debugPrint('shareSingle failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return false;
  }
}
