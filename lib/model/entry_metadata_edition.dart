import 'dart:convert';

import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/enums.dart';
import 'package:aves/ref/iptc.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/metadata/xmp.dart';
import 'package:aves/utils/xmp_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xml/xml.dart';

extension ExtraAvesEntryMetadataEdition on AvesEntry {
  // write:
  // - IPTC / keywords, if IPTC exists
  // - XMP / dc:subject
  Future<Set<EntryDataType>> editTags(Set<String> tags) async {
    final Map<MetadataType, dynamic> metadata = {};

    final dataTypes = await setMetadataDateIfMissing();

    if (canEditIptc) {
      final iptc = await metadataFetchService.getIptc(this);
      if (iptc != null) {
        editTagsIptc(iptc, tags);
        metadata[MetadataType.iptc] = iptc;
      }
    }

    if (canEditXmp) {
      metadata[MetadataType.xmp] = await _editXmp((descriptions) => editTagsXmp(descriptions, tags));
    }

    final newFields = await metadataEditService.editMetadata(this, metadata);
    if (newFields.isNotEmpty) {
      dataTypes.add(EntryDataType.catalog);
    }
    return dataTypes;
  }

  // write:
  // - XMP / xmp:Rating
  // update:
  // - XMP / MicrosoftPhoto:Rating
  // ignore (Windows tags, not part of Exif 2.32 spec):
  // - Exif / Rating
  // - Exif / RatingPercent
  Future<Set<EntryDataType>> editRating(int? rating) async {
    final Map<MetadataType, dynamic> metadata = {};

    final dataTypes = await setMetadataDateIfMissing();

    if (canEditXmp) {
      metadata[MetadataType.xmp] = await _editXmp((descriptions) => editRatingXmp(descriptions, rating));
    }

    final newFields = await metadataEditService.editMetadata(this, metadata);
    if (newFields.isNotEmpty) {
      dataTypes.add(EntryDataType.catalog);
    }
    return dataTypes;
  }

  @visibleForTesting
  static void editTagsIptc(List<Map<String, dynamic>> iptc, Set<String> tags) {
    iptc.removeWhere((v) => v['record'] == IPTC.applicationRecord && v['tag'] == IPTC.keywordsTag);
    iptc.add({
      'record': IPTC.applicationRecord,
      'tag': IPTC.keywordsTag,
      'values': tags.map((v) => utf8.encode(v)).toList(),
    });
  }

  @visibleForTesting
  static void editTagsXmp(List<XmlNode> descriptions, Set<String> tags) {
    XMP.setStringBag(
      descriptions,
      XMP.dcSubject,
      tags,
      namespace: Namespaces.dc,
      strat: XmpEditStrategy.always,
    );
  }

  @visibleForTesting
  static void editRatingXmp(List<XmlNode> descriptions, int? rating) {
    XMP.setAttribute(
      descriptions,
      XMP.xmpRating,
      (rating ?? 0) == 0 ? null : '$rating',
      namespace: Namespaces.xmp,
      strat: XmpEditStrategy.always,
    );
    XMP.setAttribute(
      descriptions,
      XMP.msPhotoRating,
      XMP.toMsPhotoRating(rating),
      namespace: Namespaces.microsoftPhoto,
      strat: XmpEditStrategy.updateIfPresent,
    );
  }

  // convenience

  Future<Map<String, String?>> _editXmp(void Function(List<XmlNode> descriptions) apply) async {
    final xmp = await metadataFetchService.getXmp(this);
    final xmpString = xmp?.xmpString;
    final extendedXmpString = xmp?.extendedXmpString;

    final editedXmpString = await XMP.edit(
      xmpString,
      () => PackageInfo.fromPlatform().then((v) => 'Aves v${v.version}'),
      apply,
    );

    final editedXmp = AvesXmp(xmpString: editedXmpString, extendedXmpString: extendedXmpString);
    return {
      'xmp': editedXmp.xmpString,
      'extendedXmp': editedXmp.extendedXmpString,
    };
  }
}
