import 'dart:async';

import 'package:aves/model/apps.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:streams_channel/streams_channel.dart';

abstract class AppService {
  Future<Set<Package>> getPackages();

  Future<Uint8List> getAppIcon(String packageName, double size);

  Future<bool> copyToClipboard(String uri, String? label);

  Future<Map<String, dynamic>> edit(String uri, String mimeType);

  Future<bool> open(String uri, String mimeType, {required bool forceChooser});

  Future<bool> openMap(LatLng latLng);

  Future<bool> setAs(String uri, String mimeType);

  Future<bool> shareEntries(Iterable<AvesEntry> entries);

  Future<bool> shareSingle(String uri, String mimeType);

  Future<void> pinToHomeScreen(String label, AvesEntry? coverEntry, {Set<CollectionFilter>? filters, String? uri});
}

class PlatformAppService implements AppService {
  static const _platform = MethodChannel('deckers.thibault/aves/app');
  static final _stream = StreamsChannel('deckers.thibault/aves/activity_result_stream');

  static final _knownAppDirs = {
    'com.kakao.talk': {'KakaoTalkDownload'},
    'com.sony.playmemories.mobile': {'Imaging Edge Mobile'},
    'nekox.messenger': {'NekoX'},
    'org.telegram.messenger': {'Telegram Images', 'Telegram Video'},
    'com.whatsapp': {'Whatsapp', 'WhatsApp Animated Gifs', 'WhatsApp Documents', 'WhatsApp Images', 'WhatsApp Video'}
  };

  @override
  Future<Set<Package>> getPackages() async {
    try {
      final result = await _platform.invokeMethod('getPackages');
      final packages = (result as List).cast<Map>().map(Package.fromMap).toSet();
      // additional info for known directories
      _knownAppDirs.forEach((packageName, dirs) {
        final package = packages.firstWhereOrNull((package) => package.packageName == packageName);
        if (package != null) {
          package.ownedDirs.addAll(dirs);
        }
      });
      return packages;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Uint8List> getAppIcon(String packageName, double size) async {
    try {
      final result = await _platform.invokeMethod('getAppIcon', <String, dynamic>{
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
      final result = await _platform.invokeMethod('copyToClipboard', <String, dynamic>{
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
  Future<Map<String, dynamic>> edit(String uri, String mimeType) async {
    try {
      final completer = Completer<Map?>();
      _stream.receiveBroadcastStream(<String, dynamic>{
        'op': 'edit',
        'uri': uri,
        'mimeType': mimeType,
      }).listen(
        (data) => completer.complete(data as Map?),
        onError: completer.completeError,
        onDone: () {
          if (!completer.isCompleted) completer.complete({'error': 'cancelled'});
        },
        cancelOnError: true,
      );
      // `await` here, so that `completeError` will be caught below
      final result = await completer.future;
      if (result == null) return {'error': 'cancelled'};
      return result.cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
      return {'error': e.code};
    }
  }

  @override
  Future<bool> open(String uri, String mimeType, {required bool forceChooser}) async {
    try {
      final result = await _platform.invokeMethod('open', <String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
        'forceChooser': forceChooser,
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
      final result = await _platform.invokeMethod('openMap', <String, dynamic>{
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
      final result = await _platform.invokeMethod('setAs', <String, dynamic>{
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
  Future<bool> shareEntries(Iterable<AvesEntry> entries) {
    return _share(groupBy<AvesEntry, String>(
      entries,
      // loosen MIME type to a generic one, so we can share with badly defined apps
      // e.g. Google Lens declares receiving "image/jpeg" only, but it can actually handle more formats
      (e) => e.mimeTypeAnySubtype,
    ).map((k, v) => MapEntry(k, v.map((e) => e.uri).toList())));
  }

  @override
  Future<bool> shareSingle(String uri, String mimeType) {
    return _share({
      mimeType: [uri]
    });
  }

  Future<bool> _share(Map<String, List<String>> urisByMimeType) async {
    try {
      final result = await _platform.invokeMethod('share', <String, dynamic>{
        'urisByMimeType': urisByMimeType,
      });
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      if (e.code == 'share-large') {
        throw TooManyItemsException();
      } else {
        await reportService.recordError(e, stack);
      }
    }
    return false;
  }

  // app shortcuts

  @override
  Future<void> pinToHomeScreen(String label, AvesEntry? coverEntry, {Set<CollectionFilter>? filters, String? uri}) async {
    Uint8List? iconBytes;
    if (coverEntry != null) {
      final size = coverEntry.isVideo ? 0.0 : 256.0;
      iconBytes = await mediaFetchService.getThumbnail(
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
      await _platform.invokeMethod('pinShortcut', <String, dynamic>{
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

class TooManyItemsException implements Exception {}
