import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:aves/geo/uri.dart';
import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/model/app_inventory.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/decoding.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:streams_channel/streams_channel.dart';

abstract class AppService {
  Future<Set<Package>> getPackages();

  Future<ui.ImageDescriptor?> getAppIcon(String packageName, double size);

  Future<bool> copyToClipboard(String uri, String? label);

  Future<Map<String, dynamic>> edit(String uri, String mimeType);

  Future<bool> open(String uri, String mimeType, {required bool forceChooser});

  Future<bool> openMap(LatLng latLng);

  Future<bool> setAs(String uri, String mimeType);

  Future<bool> shareEntries(Iterable<AvesEntry> entries);

  Future<bool> shareSingle(String uri, String mimeType);

  Future<void> pinToHomeScreen(
    String label,
    AvesEntry? coverEntry, {
    required String route,
    Set<CollectionFilter>? filters,
    String? path,
    String? viewUri,
    String? geoUri,
  });
}

class PlatformAppService implements AppService {
  static const _platform = MethodChannel('deckers.thibault/aves/app');
  static final _stream = StreamsChannel('deckers.thibault/aves/activity_result_stream');

  static final _knownAppDirs = {
    'com.google.android.apps.photos': {'Google Photos'},
    'com.kakao.talk': {'KakaoTalkDownload'},
    'com.sony.playmemories.mobile': {'Imaging Edge Mobile'},
    'nekox.messenger': {'NekoX'},
    'org.telegram.messenger': {'Telegram Images', 'Telegram Video'},
    'com.whatsapp': {'WhatsApp Animated Gifs', 'WhatsApp Documents', 'WhatsApp Images', 'WhatsApp Video'}
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
  Future<ui.ImageDescriptor?> getAppIcon(String packageName, double size) async {
    try {
      final result = await _platform.invokeMethod('getAppIcon', <String, dynamic>{
        'packageName': packageName,
        'sizeDip': size,
      });
      if (result != null) {
        final bytes = result as Uint8List;
        return InteropDecoding.rawBytesToDescriptor(bytes);
      }
    } on PlatformException catch (_) {
      // ignore, as some packages legitimately do not have icons
    }
    return null;
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
      final opCompleter = Completer<Map?>();
      _stream.receiveBroadcastStream(<String, dynamic>{
        'op': 'edit',
        'uri': uri,
        'mimeType': mimeType,
      }).listen(
        (data) => opCompleter.complete(data as Map?),
        onError: opCompleter.completeError,
        onDone: () {
          if (!opCompleter.isCompleted) opCompleter.complete({'error': 'cancelled'});
        },
        cancelOnError: true,
      );
      // `await` here, so that `completeError` will be caught below
      final result = await opCompleter.future;
      if (result == null) return {'error': 'cancelled'};
      return result.cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      if (e.code != 'edit-resolve') {
        await reportService.recordError(e, stack);
      }
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
    try {
      final result = await _platform.invokeMethod('openMap', <String, dynamic>{
        'geoUri': toGeoUri(latLng),
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
  Future<void> pinToHomeScreen(
    String label,
    AvesEntry? coverEntry, {
    required String route,
    Set<CollectionFilter>? filters,
    String? path,
    String? viewUri,
    String? geoUri,
  }) async {
    Uint8List? iconBytes;
    if (coverEntry != null) {
      final size = coverEntry.isVideo ? 0.0 : 256.0;
      try {
        final codec = await mediaFetchService.getThumbnail(
          decoded: false,
          request: ThumbnailProviderKey(
            uri: coverEntry.uri,
            mimeType: coverEntry.mimeType,
            pageId: coverEntry.pageId,
            rotationDegrees: coverEntry.rotationDegrees,
            isFlipped: coverEntry.isFlipped,
            dateModifiedMillis: coverEntry.dateModifiedMillis ?? -1,
            extent: size,
          ),
        );
        final frameInfo = await codec.getNextFrame();
        final byteData = await frameInfo.image.toByteData(format: ImageByteFormat.png);
        iconBytes = byteData?.buffer.asUint8List();
      } catch (error) {
        debugPrint('failed to get home pin thumbnail for entry=$coverEntry, error=$error');
      }
    }
    try {
      await _platform.invokeMethod('pinShortcut', <String, dynamic>{
        'label': label,
        'iconBytes': iconBytes,
        'route': route,
        'filters': filters?.map((filter) => filter.toJson()).toList(),
        'path': path,
        'viewUri': viewUri,
        'geoUri': geoUri,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }
}

class TooManyItemsException implements Exception {}
