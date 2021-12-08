import 'dart:typed_data';

import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

abstract class AndroidAppService {
  Future<Set<Package>> getPackages();

  Future<Uint8List> getAppIcon(String packageName, double size);

  Future<bool> copyToClipboard(String uri, String? label);

  Future<bool> edit(String uri, String mimeType);

  Future<bool> open(String uri, String mimeType);

  Future<bool> openMap(LatLng latLng);

  Future<bool> setAs(String uri, String mimeType);

  Future<bool> shareEntries(Iterable<AvesEntry> entries);

  Future<bool> shareSingle(String uri, String mimeType);

  Future<void> pinToHomeScreen(String label, AvesEntry? coverEntry, {Set<CollectionFilter>? filters, String? uri});
}

class PlatformAndroidAppService implements AndroidAppService {
  static const platform = MethodChannel('deckers.thibault/aves/app');

  @override
  Future<Set<Package>> getPackages() async {
    try {
      final result = await platform.invokeMethod('getPackages');
      final packages = (result as List).cast<Map>().map((map) => Package.fromMap(map)).toSet();
      // additional info for known directories
      final kakaoTalk = packages.firstWhereOrNull((package) => package.packageName == 'com.kakao.talk');
      if (kakaoTalk != null) {
        kakaoTalk.ownedDirs.add('KakaoTalkDownload');
      }
      final imagingEdge = packages.firstWhereOrNull((package) => package.packageName == 'com.sony.playmemories.mobile');
      if (imagingEdge != null) {
        imagingEdge.ownedDirs.add('Imaging Edge Mobile');
      }
      return packages;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Uint8List> getAppIcon(String packageName, double size) async {
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

  @override
  Future<bool> copyToClipboard(String uri, String? label) async {
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

  @override
  Future<bool> edit(String uri, String mimeType) async {
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

  @override
  Future<bool> open(String uri, String mimeType) async {
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

  @override
  Future<bool> openMap(LatLng latLng) async {
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

  @override
  Future<bool> setAs(String uri, String mimeType) async {
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

  @override
  Future<bool> shareEntries(Iterable<AvesEntry> entries) async {
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

  @override
  Future<bool> shareSingle(String uri, String mimeType) async {
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

  @override
  Future<void> pinToHomeScreen(String label, AvesEntry? coverEntry, {Set<CollectionFilter>? filters, String? uri}) async {
    Uint8List? iconBytes;
    if (coverEntry != null) {
      final size = coverEntry.isVideo ? 0.0 : 256.0;
      iconBytes = await mediaFileService.getThumbnail(
        uri: coverEntry.uri,
        mimeType: coverEntry.mimeType,
        pageId: coverEntry.pageId,
        rotationDegrees: coverEntry.rotationDegrees,
        isFlipped: coverEntry.isFlipped,
        dateModifiedSecs: coverEntry.dateModifiedSecs,
        extent: size,
      );
    }
    try {
      await platform.invokeMethod('pinShortcut', <String, dynamic>{
        'label': label,
        'iconBytes': iconBytes,
        'filters': filters?.map((filter) => filter.toJson()).toList(),
        'uri': uri,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }
}
