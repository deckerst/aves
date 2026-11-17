import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/keys.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/media/geotiff.dart';
import 'package:aves/model/media/video/metadata.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/metadata/svg_metadata_service.dart';
import 'package:aves_utils/aves_utils.dart';

extension ExtraAvesEntryCatalog on AvesEntry {
  static final _unreliableSourceFields = {
    EntryFields.mimeType,
    EntryFields.sizeBytes,
    EntryFields.width,
    EntryFields.height,
    EntryFields.rotationDegrees,
  };

  Future<void> catalog({required bool background, required bool force, required bool persistSourceFields}) async {
    if (isCatalogued && !force) return;

    final _mimeType = mimeType;
    if (MimeTypes.isVideo(_mimeType) || _mimeType == MimeTypes.avif) {
      await _catalogVideoLike(background: background, persistSourceFields: persistSourceFields);
    } else if (_mimeType == MimeTypes.svg) {
      await _catalogVectorImage(persistSourceFields: persistSourceFields);
    } else {
      await _catalogRasterImage(background: background, persist: persistSourceFields);
    }
  }

  Future<void> _catalogRasterImage({required bool background, required bool persist}) async {
    final fields = await metadataFetchService.getCatalogMetadata(this, background: background);
    await _applyCatalogSourceFields(catalogFields: fields, persistSourceFields: persist);

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

  Future<void> _catalogVideoLike({required bool background, required bool persistSourceFields}) async {
    // pre-processing
    if (isVideo || mimeType == MimeTypes.avif) {
      // on initial loading, original source may report incorrect size, rotation or duration
      final fields = await VideoMetadataFormatter.getLoadingMetadata(this);
      // check size as the video interpreter may fail on some AVIF stills
      final width = fields[EntryFields.width];
      final height = fields[EntryFields.height];
      final isValid = (width == null || width > 0) && (height == null || height > 0);
      if (isValid) {
        await applyNewFields(fields, persist: persistSourceFields);
      }
    }

    // cataloguing on platform
    final fields = await metadataFetchService.getCatalogMetadata(this, background: background);
    await _applyCatalogSourceFields(catalogFields: fields, persistSourceFields: persistSourceFields);

    // post-processing
    if ((isVideo && !isDated) || (mimeType == MimeTypes.avif && durationMillis != null)) {
      final videoMetadata = await VideoMetadataFormatter.completeCatalogMetadata(this);
      if (videoMetadata != null) {
        catalogMetadata = videoMetadata;
      }
    }

    if (isSlowMotion) {
      final (slowMotionFactor, captureDurationMillis) = await videoMetadataFetcher.computeSlowMotionFactorAndDuration(uri: uri, mimeType: mimeType);
      if (slowMotionFactor == 1) {
        // correct false positive derived only from capture FPS
        catalogMetadata = catalogMetadata?.copyWith(isSlowMotion: false);
      } else if (captureDurationMillis != null) {
        durationMillis = captureDurationMillis;
        final fields = {
          EntryFields.durationMillis: captureDurationMillis,
        };
        await applyNewFields(fields, persist: persistSourceFields);
      }
    }
  }

  Future<void> _catalogVectorImage({required bool persistSourceFields}) async {
    // vector image sizing is not essential, so we should not spend time for it during loading
    // but it is useful anyway (for aspect ratios etc.) so we size them during cataloguing
    final size = await SvgMetadataService.getSize(this);
    if (size != null) {
      final fields = {
        EntryFields.width: size.width.ceil(),
        EntryFields.height: size.height.ceil(),
      };
      await applyNewFields(fields, persist: persistSourceFields);
    }
    catalogMetadata = CatalogMetadata(id: id);
  }

  Future<void> _applyCatalogSourceFields({required Map? catalogFields, required bool persistSourceFields}) async {
    if (catalogFields != null) {
      final sourceFields = Map.fromEntries(_unreliableSourceFields.where(catalogFields.containsKey).map((k) => MapEntry(k, catalogFields[k]))).whereNotNullValue();
      if (sourceFields.isNotEmpty) {
        await applyNewFields(sourceFields, persist: persistSourceFields);
      }
      catalogMetadata = CatalogMetadata.fromMap(catalogFields);
    } else {
      catalogMetadata = null;
    }
  }
}
