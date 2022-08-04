import 'package:aves/model/entry.dart';
import 'package:aves/model/geotiff.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/fields.dart';
import 'package:aves/model/metadata/overlay.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/panorama.dart';
import 'package:aves/services/common/service_policy.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/metadata/xmp.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class MetadataFetchService {
  // returns Map<Map<Key, Value>> (map of directories, each directory being a map of metadata label and value description)
  Future<Map> getAllMetadata(AvesEntry entry);

  Future<CatalogMetadata?> getCatalogMetadata(AvesEntry entry, {bool background = false});

  Future<OverlayMetadata?> getOverlayMetadata(AvesEntry entry);

  Future<GeoTiffInfo?> getGeoTiffInfo(AvesEntry entry);

  Future<MultiPageInfo?> getMultiPageInfo(AvesEntry entry);

  Future<PanoramaInfo?> getPanoramaInfo(AvesEntry entry);

  Future<List<Map<String, dynamic>>?> getIptc(AvesEntry entry);

  Future<AvesXmp?> getXmp(AvesEntry entry);

  Future<bool> hasContentResolverProp(String prop);

  Future<String?> getContentResolverProp(AvesEntry entry, String prop);

  Future<DateTime?> getDate(AvesEntry entry, MetadataField field);
}

class PlatformMetadataFetchService implements MetadataFetchService {
  static const _platform = MethodChannel('deckers.thibault/aves/metadata_fetch');

  @override
  Future<Map> getAllMetadata(AvesEntry entry) async {
    if (entry.isSvg) return {};

    try {
      final result = await _platform.invokeMethod('getAllMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return {};
  }

  @override
  Future<CatalogMetadata?> getCatalogMetadata(AvesEntry entry, {bool background = false}) async {
    if (entry.isSvg) return null;

    Future<CatalogMetadata?> call() async {
      try {
        // returns map with:
        // 'mimeType': MIME type as reported by metadata extractors, not Media Store (string)
        // 'dateMillis': date taken in milliseconds since Epoch (long)
        // 'isAnimated': animated gif/webp (bool)
        // 'isFlipped': flipped according to EXIF orientation (bool)
        // 'rating': rating in [-1,5] (int)
        // 'rotationDegrees': rotation degrees according to EXIF orientation or other metadata (int)
        // 'latitude': latitude (double)
        // 'longitude': longitude (double)
        // 'xmpSubjects': ';' separated XMP subjects (string)
        // 'xmpTitleDescription': XMP title or XMP description (string)
        final result = await _platform.invokeMethod('getCatalogMetadata', <String, dynamic>{
          'mimeType': entry.mimeType,
          'uri': entry.uri,
          'path': entry.path,
          'sizeBytes': entry.sizeBytes,
        }) as Map;
        result['id'] = entry.id;
        return CatalogMetadata.fromMap(result);
      } on PlatformException catch (e, stack) {
        if (!entry.isMissingAtPath) {
          await reportService.recordError(e, stack);
        }
      }
      return null;
    }

    return background
        ? servicePolicy.call(
            call,
            priority: ServiceCallPriority.getMetadata,
          )
        : call();
  }

  @override
  Future<OverlayMetadata?> getOverlayMetadata(AvesEntry entry) async {
    if (entry.isSvg) return null;

    try {
      // returns map with values for: 'aperture' (double), 'exposureTime' (description), 'focalLength' (double), 'iso' (int)
      final result = await _platform.invokeMethod('getOverlayMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      }) as Map;
      return OverlayMetadata.fromMap(result);
    } on PlatformException catch (e, stack) {
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return null;
  }

  @override
  Future<GeoTiffInfo?> getGeoTiffInfo(AvesEntry entry) async {
    try {
      final result = await _platform.invokeMethod('getGeoTiffInfo', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      }) as Map;
      return GeoTiffInfo.fromMap(result);
    } on PlatformException catch (e, stack) {
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return null;
  }

  @override
  Future<MultiPageInfo?> getMultiPageInfo(AvesEntry entry) async {
    try {
      final result = await _platform.invokeMethod('getMultiPageInfo', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      final pageMaps = ((result as List?) ?? []).cast<Map>();
      if (entry.isMotionPhoto && pageMaps.isNotEmpty) {
        final imagePage = pageMaps[0];
        imagePage['width'] = entry.width;
        imagePage['height'] = entry.height;
        imagePage['rotationDegrees'] = entry.rotationDegrees;
      }
      return MultiPageInfo.fromPageMaps(entry, pageMaps);
    } on PlatformException catch (e, stack) {
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return null;
  }

  @override
  Future<PanoramaInfo?> getPanoramaInfo(AvesEntry entry) async {
    try {
      // returns map with values for:
      // 'croppedAreaLeft' (int), 'croppedAreaTop' (int), 'croppedAreaWidth' (int), 'croppedAreaHeight' (int),
      // 'fullPanoWidth' (int), 'fullPanoHeight' (int)
      final result = await _platform.invokeMethod('getPanoramaInfo', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      }) as Map;
      return PanoramaInfo.fromMap(result);
    } on PlatformException catch (e, stack) {
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>?> getIptc(AvesEntry entry) async {
    try {
      final result = await _platform.invokeMethod('getIptc', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
      });
      if (result != null) return (result as List).cast<Map>().map((fields) => fields.cast<String, dynamic>()).toList();
    } on PlatformException catch (e, stack) {
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return null;
  }

  @override
  Future<AvesXmp?> getXmp(AvesEntry entry) async {
    try {
      final result = await _platform.invokeMethod('getXmp', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      if (result != null) return AvesXmp.fromList((result as List).cast<String>());
    } on PlatformException catch (e, stack) {
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return null;
  }

  final Map<String, bool> _contentResolverProps = {};

  @override
  Future<bool> hasContentResolverProp(String prop) async {
    var exists = _contentResolverProps[prop];
    if (exists != null) return SynchronousFuture(exists);

    try {
      exists = await _platform.invokeMethod('hasContentResolverProp', <String, dynamic>{
        'prop': prop,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    exists ??= false;
    _contentResolverProps[prop] = exists;
    return exists;
  }

  @override
  Future<String?> getContentResolverProp(AvesEntry entry, String prop) async {
    try {
      return await _platform.invokeMethod('getContentResolverProp', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'prop': prop,
      });
    } on PlatformException catch (e, stack) {
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return null;
  }

  @override
  Future<DateTime?> getDate(AvesEntry entry, MetadataField field) async {
    try {
      final result = await _platform.invokeMethod('getDate', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
        'field': field.exifInterfaceTag,
      });
      if (result is int) {
        return dateTimeFromMillis(result, isUtc: false);
      }
    } on PlatformException catch (e, stack) {
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return null;
  }
}
