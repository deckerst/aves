import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/media/geotiff.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/media/video/metadata.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/metadata/svg_metadata_service.dart';
import 'package:flutter/foundation.dart';

extension ExtraAvesEntryCatalog on AvesEntry {
  Future<void> catalog({required bool background, required bool force, required bool persist}) async {
    if (isCatalogued && !force) return;

    final beforeAvailableHeapSize = await deviceService.getAvailableHeapSize();

    if (isSvg) {
      // vector image sizing is not essential, so we should not spend time for it during loading
      // but it is useful anyway (for aspect ratios etc.) so we size them during cataloguing
      final size = await SvgMetadataService.getSize(this);
      if (size != null) {
        final fields = {
          'width': size.width.ceil(),
          'height': size.height.ceil(),
        };
        await applyNewFields(fields, persist: persist);
      }
      catalogMetadata = CatalogMetadata(id: id);
    } else {
      // pre-processing
      if ((isVideo && (!isSized || durationMillis == 0)) || mimeType == MimeTypes.avif) {
        // exotic video that is not sized during loading
        final fields = await VideoMetadataFormatter.getLoadingMetadata(this);
        // check size as the video interpreter may fail on some AVIF stills
        final width = fields['width'];
        final height = fields['height'];
        final isValid = (width == null || width > 0) && (height == null || height > 0);
        if (isValid) {
          await applyNewFields(fields, persist: persist);
        }
      }

      // cataloguing on platform
      catalogMetadata = await metadataFetchService.getCatalogMetadata(this, background: background);

      // post-processing
      if ((isVideo && (catalogMetadata?.dateMillis ?? 0) == 0) || (mimeType == MimeTypes.avif && durationMillis != null)) {
        catalogMetadata = await VideoMetadataFormatter.getCatalogMetadata(this);
      }
      if (isGeotiff && !hasGps) {
        final info = await metadataFetchService.getGeoTiffInfo(this);
        if (info != null) {
          final center = GeoTiffCoordinateConverter(
            info: info,
            entry: this,
          ).center;
          if (center != null) {
            catalogMetadata = catalogMetadata?.copyWith(
              latitude: center.latitude,
              longitude: center.longitude,
            );
          }
        }
      }
    }

    final afterAvailableHeapSize = await deviceService.getAvailableHeapSize();
    final diff = beforeAvailableHeapSize - afterAvailableHeapSize;
    const largeHeapUsageThreshold = 15 * (1 << 20); // MB

    if (diff > largeHeapUsageThreshold) {
      debugPrint('Large heap usage (${diff}B) from cataloguing entry=$this size=$sizeBytes');
      await deviceService.requestGarbageCollection();
    }
  }
}
