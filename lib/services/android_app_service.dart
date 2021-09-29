import 'dart:typed_data';

import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (_, __) {
      // ignore, as some packages legitimately do not have icons
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  static Future<bool> openMap(LatLng latLng) async {
    final latitude = roundToPrecision(latLng.latitude, decimals: 6);
    final longitude = roundToPrecision(latLng.longitude, decimals: 6);
    final geoUri = 'geo:$latitude,$longitude?q=$latitude,$longitude';

    try {
      final result = await platform.invokeMethod('openMap', <String, dynamic>{
        'geoUri': geoUri,
      });
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  // app shortcuts

  // this ability will not change over the lifetime of the app
  static bool? _canPin;

  static Future<bool> canPinToHomeScreen() async {
    if (_canPin != null) return SynchronousFuture(_canPin!);

    try {
      final result = await platform.invokeMethod('canPin');
      if (result != null) {
        _canPin = result;
        return result;
      }
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  static Future<void> pinToHomeScreen(String label, AvesEntry? entry, Set<CollectionFilter> filters) async {
    Uint8List? iconBytes;
    if (entry != null) {
      final size = entry.isVideo ? 0.0 : 256.0;
      iconBytes = await mediaFileService.getThumbnail(
        uri: entry.uri,
        mimeType: entry.mimeType,
        pageId: entry.pageId,
        rotationDegrees: entry.rotationDegrees,
        isFlipped: entry.isFlipped,
        dateModifiedSecs: entry.dateModifiedSecs,
        extent: size,
      );
    }
    try {
      await platform.invokeMethod('pin', <String, dynamic>{
        'label': label,
        'iconBytes': iconBytes,
        'filters': filters.map((filter) => filter.toJson()).toList(),
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }
}
