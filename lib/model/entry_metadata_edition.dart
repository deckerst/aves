import 'dart:convert';
import 'dart:io';

import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/metadata/enums.dart';
import 'package:aves/model/metadata/fields.dart';
import 'package:aves/ref/exif.dart';
import 'package:aves/ref/iptc.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/metadata/xmp.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/utils/xmp_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xml/xml.dart';

extension ExtraAvesEntryMetadataEdition on AvesEntry {
  Future<Set<EntryDataType>> editDate(DateModifier userModifier) async {
    final Set<EntryDataType> dataTypes = {};

    final appliedModifier = await _applyDateModifierToEntry(userModifier);
    if (appliedModifier == null) {
      await reportService.recordError('failed to get date for modifier=$userModifier, entry=$this', null);
      return {};
    }

    if (canEditExif && appliedModifier.fields.any((v) => v.type == MetadataType.exif)) {
      final newFields = await metadataEditService.editExifDate(this, appliedModifier);
      if (newFields.isNotEmpty) {
        dataTypes.addAll({
          EntryDataType.basic,
          EntryDataType.catalog,
        });
      }
    }

    if (canEditXmp && appliedModifier.fields.any((v) => v.type == MetadataType.xmp)) {
      final metadata = {
        MetadataType.xmp: await _editXmp((descriptions) {
          switch (appliedModifier.action) {
            case DateEditAction.setCustom:
            case DateEditAction.copyField:
            case DateEditAction.extractFromTitle:
              editCreateDateXmp(descriptions, appliedModifier.setDateTime);
              break;
            case DateEditAction.shift:
              final xmpDate = XMP.getString(descriptions, XMP.xmpCreateDate, namespace: Namespaces.xmp);
              if (xmpDate != null) {
                final date = DateTime.tryParse(xmpDate);
                if (date != null) {
                  // TODO TLAD [date] DateTime.tryParse converts to UTC time, losing the time zone offset
                  final shiftedDate = date.add(Duration(minutes: appliedModifier.shiftMinutes!));
                  editCreateDateXmp(descriptions, shiftedDate);
                } else {
                  reportService.recordError('failed to parse XMP date=$xmpDate', null);
                }
              }
              break;
            case DateEditAction.remove:
              editCreateDateXmp(descriptions, null);
              break;
          }
        }),
      };
      final newFields = await metadataEditService.editMetadata(this, metadata);
      if (newFields.isNotEmpty) {
        dataTypes.addAll({
          EntryDataType.basic,
          EntryDataType.catalog,
        });
      }
    }

    return dataTypes;
  }

  Future<Set<EntryDataType>> editLocation(LatLng? latLng) async {
    final Set<EntryDataType> dataTypes = {};

    await _missingDateCheckAndExifEdit(dataTypes);

    // clear every GPS field
    final exifFields = Map<MetadataField, dynamic>.fromEntries(MetadataFields.exifGpsFields.map((k) => MapEntry(k, null)));
    // add latitude & longitude, if any
    if (latLng != null) {
      final latitude = latLng.latitude;
      final longitude = latLng.longitude;
      if (latitude != 0 && longitude != 0) {
        exifFields.addAll({
          MetadataField.exifGpsLatitude: latitude.abs(),
          MetadataField.exifGpsLatitudeRef: latitude >= 0 ? Exif.latitudeNorth : Exif.latitudeSouth,
          MetadataField.exifGpsLongitude: longitude.abs(),
          MetadataField.exifGpsLongitudeRef: longitude >= 0 ? Exif.longitudeEast : Exif.longitudeWest,
        });
      }
    }

    final metadata = {
      MetadataType.exif: Map<String, dynamic>.fromEntries(exifFields.entries.map((kv) => MapEntry(kv.key.exifInterfaceTag!, kv.value))),
    };
    final newFields = await metadataEditService.editMetadata(this, metadata);
    if (newFields.isNotEmpty) {
      dataTypes.addAll({
        EntryDataType.catalog,
        EntryDataType.address,
      });
    }
    return dataTypes;
  }

  Future<Set<EntryDataType>> _changeOrientation(Future<Map<String, dynamic>> Function() apply) async {
    final Set<EntryDataType> dataTypes = {};

    await _missingDateCheckAndExifEdit(dataTypes);

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

    final missingDate = await _missingDateCheckAndExifEdit(dataTypes);

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
          editCreateDateXmp(descriptions, missingDate);
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

    final missingDate = await _missingDateCheckAndExifEdit(dataTypes);

    if (canEditXmp) {
      metadata[MetadataType.xmp] = await _editXmp((descriptions) {
        if (missingDate != null) {
          editCreateDateXmp(descriptions, missingDate);
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
  static void editCreateDateXmp(List<XmlNode> descriptions, DateTime? date) {
    XMP.setAttribute(
      descriptions,
      XMP.xmpCreateDate,
      date != null ? XMP.toXmpDate(date) : null,
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

  // convenience methods

  // This method checks whether the item already has a metadata date,
  // and adds a date (the file modified date) via Exif if possible.
  // It returns a date if the caller needs to add it via other metadata types (e.g. XMP).
  Future<DateTime?> _missingDateCheckAndExifEdit(Set<EntryDataType> dataTypes) async {
    if (path == null) return null;

    // make sure entry is catalogued before we check whether is has a metadata date
    if (!isCatalogued) {
      await catalog(background: false, force: false, persist: true);
    }
    final dateMillis = catalogMetadata?.dateMillis;
    if (dateMillis != null && dateMillis > 0) return null;

    late DateTime date;
    try {
      date = await File(path!).lastModified();
    } on FileSystemException catch (_) {
      return null;
    }

    if (canEditExif) {
      final newFields = await metadataEditService.editExifDate(this, DateModifier.setCustom(const {MetadataField.exifDateOriginal}, date));
      if (newFields.isNotEmpty) {
        dataTypes.addAll({
          EntryDataType.basic,
          EntryDataType.catalog,
        });
        return null;
      }
    }

    return date;
  }

  Future<DateModifier?> _applyDateModifierToEntry(DateModifier modifier) async {
    Set<MetadataField> mainMetadataDate() => {canEditExif ? MetadataField.exifDateOriginal : MetadataField.xmpCreateDate};

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
        return date != null ? DateModifier.setCustom(mainMetadataDate(), date) : null;
      case DateEditAction.extractFromTitle:
        final date = parseUnknownDateFormat(bestTitle);
        return date != null ? DateModifier.setCustom(mainMetadataDate(), date) : null;
      case DateEditAction.setCustom:
        return DateModifier.setCustom(mainMetadataDate(), modifier.setDateTime!);
      case DateEditAction.shift:
      case DateEditAction.remove:
        return modifier;
    }
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
