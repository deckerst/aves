import 'dart:convert';
import 'dart:io';

import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/metadata/enums.dart';
import 'package:aves/ref/iptc.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/metadata/xmp.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/utils/xmp_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xml/xml.dart';

extension ExtraAvesEntryMetadataEdition on AvesEntry {
  Future<Set<EntryDataType>> editDate(DateModifier modifier) async {
    switch (modifier.action) {
      case DateEditAction.copyField:
        DateTime? date;
        final source = modifier.copyFieldSource;
        if (source != null) {
          switch (source) {
            case DateFieldSource.fileModifiedDate:
              try {
                date = path != null ? await File(path!).lastModified() : null;
              } on FileSystemException catch (_) {}
              break;
            default:
              date = await metadataFetchService.getDate(this, source.toMetadataField()!);
              break;
          }
        }
        if (date != null) {
          modifier = DateModifier.setCustom(modifier.fields, date);
        } else {
          await reportService.recordError('failed to get date for modifier=$modifier, uri=$uri', null);
          return {};
        }
        break;
      case DateEditAction.extractFromTitle:
        final date = parseUnknownDateFormat(bestTitle);
        if (date != null) {
          modifier = DateModifier.setCustom(modifier.fields, date);
        } else {
          await reportService.recordError('failed to get date for modifier=$modifier, uri=$uri', null);
          return {};
        }
        break;
      case DateEditAction.setCustom:
      case DateEditAction.shift:
      case DateEditAction.remove:
        break;
    }
    final newFields = await metadataEditService.editDate(this, modifier);
    return newFields.isEmpty
        ? {}
        : {
            EntryDataType.basic,
            EntryDataType.catalog,
          };
  }

  Future<Set<EntryDataType>> _changeOrientation(Future<Map<String, dynamic>> Function() apply) async {
    final Set<EntryDataType> dataTypes = {};

    // when editing a file that has no metadata date,
    // we will set one, using the file modified date, if any
    var missingDate = await _getMissingMetadataDate();
    if (missingDate != null && canEditExif) {
      dataTypes.addAll(await editDate(DateModifier.setCustom(
        const {MetadataField.exifDateOriginal},
        missingDate,
      )));
      missingDate = null;
    }

    final newFields = await apply();
    // applying fields is only useful for a smoother visual change,
    // as proper refreshing and persistence happens at the caller level
    await applyNewFields(newFields, persist: false);
    if (newFields.isNotEmpty) {
      dataTypes.addAll({
        EntryDataType.basic,
        EntryDataType.catalog,
      });
    }
    return dataTypes;
  }

  Future<Set<EntryDataType>> rotate({required bool clockwise}) {
    return _changeOrientation(() => metadataEditService.rotate(this, clockwise: clockwise));
  }

  Future<Set<EntryDataType>> flip() {
    return _changeOrientation(() => metadataEditService.flip(this));
  }

  // write:
  // - IPTC / keywords, if IPTC exists
  // - XMP / dc:subject
  Future<Set<EntryDataType>> editTags(Set<String> tags) async {
    final Set<EntryDataType> dataTypes = {};
    final Map<MetadataType, dynamic> metadata = {};

    // when editing a file that has no metadata date,
    // we will set one, using the file modified date, if any
    var missingDate = await _getMissingMetadataDate();
    if (missingDate != null && canEditExif) {
      dataTypes.addAll(await editDate(DateModifier.setCustom(
        const {MetadataField.exifDateOriginal},
        missingDate,
      )));
      missingDate = null;
    }

    if (canEditIptc) {
      final iptc = await metadataFetchService.getIptc(this);
      if (iptc != null) {
        editTagsIptc(iptc, tags);
        metadata[MetadataType.iptc] = iptc;
      }
    }

    if (canEditXmp) {
      metadata[MetadataType.xmp] = await _editXmp((descriptions) {
        if (missingDate != null) {
          editDateXmp(descriptions, missingDate!);
          missingDate = null;
        }
        editTagsXmp(descriptions, tags);
      });
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
    final Set<EntryDataType> dataTypes = {};
    final Map<MetadataType, dynamic> metadata = {};

    // when editing a file that has no metadata date,
    // we will set one, using the file modified date, if any
    var missingDate = await _getMissingMetadataDate();
    if (missingDate != null && canEditExif) {
      dataTypes.addAll(await editDate(DateModifier.setCustom(
        const {MetadataField.exifDateOriginal},
        missingDate,
      )));
      missingDate = null;
    }

    if (canEditXmp) {
      metadata[MetadataType.xmp] = await _editXmp((descriptions) {
        if (missingDate != null) {
          editDateXmp(descriptions, missingDate!);
          missingDate = null;
        }
        editRatingXmp(descriptions, rating);
      });
    }

    final newFields = await metadataEditService.editMetadata(this, metadata);
    if (newFields.isNotEmpty) {
      dataTypes.add(EntryDataType.catalog);
    }
    return dataTypes;
  }

  Future<Set<EntryDataType>> removeMetadata(Set<MetadataType> types) async {
    final newFields = await metadataEditService.removeTypes(this, types);
    return newFields.isEmpty
        ? {}
        : {
            EntryDataType.basic,
            EntryDataType.catalog,
            EntryDataType.address,
          };
  }

  @visibleForTesting
  static void editDateXmp(List<XmlNode> descriptions, DateTime date) {
    XMP.setAttribute(
      descriptions,
      XMP.xmpCreateDate,
      XMP.toXmpDate(date),
      namespace: Namespaces.xmp,
      strat: XmpEditStrategy.always,
    );
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

  Future<DateTime?> _getMissingMetadataDate() async {
    if (path == null) return null;

    // make sure entry is catalogued before we check whether is has a metadata date
    if (!isCatalogued) {
      await catalog(background: false, force: false, persist: true);
    }
    final metadataDate = catalogMetadata?.dateMillis;
    if (metadataDate != null && metadataDate > 0) return null;

    try {
      return await File(path!).lastModified();
    } on FileSystemException catch (_) {}
  }

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
