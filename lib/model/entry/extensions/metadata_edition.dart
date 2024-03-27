import 'dart:convert';
import 'dart:io';

import 'package:aves/convert/convert.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/catalog.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/ref/metadata/exif.dart';
import 'package:aves/ref/metadata/iptc.dart';
import 'package:aves/ref/metadata/xmp.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/metadata/xmp.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/utils/xmp_utils.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

extension ExtraAvesEntryMetadataEdition on AvesEntry {
  Future<Set<EntryDataType>> editDate(DateModifier userModifier) async {
    final dataTypes = <EntryDataType>{};

    final appliedModifier = await _applyDateModifierToEntry(userModifier);
    if (appliedModifier == null) {
      if (isValid && userModifier.action != DateEditAction.copyField) {
        await reportService.recordError('failed to get date for modifier=$userModifier, entry=$this', null);
      }
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
            case DateEditAction.copyItem:
            case DateEditAction.extractFromTitle:
              editCreateDateXmp(descriptions, appliedModifier.setDateTime);
            case DateEditAction.shift:
              final xmpDate = XMP.getString(descriptions, XmpAttributes.xmpCreateDate, namespace: XmpNamespaces.xmp);
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
            case DateEditAction.remove:
              editCreateDateXmp(descriptions, null);
          }
          return true;
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

  static const removalLocation = LatLng(0, 0);

  Future<Set<EntryDataType>> editLocation(LatLng? latLng) async {
    final dataTypes = <EntryDataType>{};
    final metadata = <MetadataType, dynamic>{};

    final missingDate = await _missingDateCheckAndExifEdit(dataTypes);

    if (canEditExif) {
      // clear every GPS field
      final exifFields = Map<MetadataField, dynamic>.fromEntries(MetadataFields.exifGpsFields.map((k) => MapEntry(k, null)));
      // add latitude & longitude, if any
      if (latLng != null && latLng != removalLocation) {
        final latitude = latLng.latitude;
        final longitude = latLng.longitude;
        exifFields.addAll({
          MetadataField.exifGpsLatitude: latitude.abs(),
          MetadataField.exifGpsLatitudeRef: latitude >= 0 ? Exif.latitudeNorth : Exif.latitudeSouth,
          MetadataField.exifGpsLongitude: longitude.abs(),
          MetadataField.exifGpsLongitudeRef: longitude >= 0 ? Exif.longitudeEast : Exif.longitudeWest,
        });
      }
      metadata[MetadataType.exif] = Map<String, dynamic>.fromEntries(exifFields.entries.map((kv) => MapEntry(kv.key.toPlatform!, kv.value)));

      if (canEditXmp && missingDate != null) {
        metadata[MetadataType.xmp] = await _editXmp((descriptions) {
          editCreateDateXmp(descriptions, missingDate);
          return true;
        });
      }
    }

    if (mimeType == MimeTypes.mp4) {
      final mp4Fields = <MetadataField, String?>{};

      String? iso6709String;
      if (latLng != null && latLng != removalLocation) {
        final latitude = latLng.latitude;
        final longitude = latLng.longitude;
        const locale = asciiLocale;
        final isoLat = '${latitude >= 0 ? '+' : '-'}${NumberFormat('00.0000', locale).format(latitude.abs())}';
        final isoLon = '${longitude >= 0 ? '+' : '-'}${NumberFormat('000.0000', locale).format(longitude.abs())}';
        iso6709String = '$isoLat$isoLon/';
      }
      mp4Fields[MetadataField.mp4GpsCoordinates] = iso6709String;

      if (missingDate != null) {
        final xmpParts = await _editXmp((descriptions) {
          editCreateDateXmp(descriptions, missingDate);
          return true;
        });
        mp4Fields[MetadataField.mp4Xmp] = xmpParts[xmpCoreKey];
      }

      metadata[MetadataType.mp4] = Map<String, String?>.fromEntries(mp4Fields.entries.map((kv) => MapEntry(kv.key.toPlatform!, kv.value)));
    }

    final newFields = await metadataEditService.editMetadata(this, metadata);
    if (newFields.isNotEmpty) {
      dataTypes.addAll({
        EntryDataType.catalog,
        EntryDataType.address,
      });
    }
    return dataTypes;
  }

  Future<Set<EntryDataType>> _changeExifOrientation(Future<Map<String, dynamic>> Function() apply) async {
    final dataTypes = <EntryDataType>{};

    await _missingDateCheckAndExifEdit(dataTypes);

    final newFields = await apply();
    // applying fields is only useful for a smoother visual change,
    // as proper refreshing and persistence happens at the caller level
    await applyNewFields(newFields, persist: false);
    if (newFields.isNotEmpty) {
      dataTypes.addAll({
        EntryDataType.basic,
        EntryDataType.aspectRatio,
        EntryDataType.catalog,
      });
    }
    return dataTypes;
  }

  Future<Set<EntryDataType>> _rotateMp4(int rotationDegrees) async {
    final dataTypes = <EntryDataType>{};

    final missingDate = await _missingDateCheckAndExifEdit(dataTypes);

    final mp4Fields = <MetadataField, String?>{
      MetadataField.mp4RotationDegrees: rotationDegrees.toString(),
    };

    if (missingDate != null) {
      final xmpParts = await _editXmp((descriptions) {
        editCreateDateXmp(descriptions, missingDate);
        return true;
      });
      mp4Fields[MetadataField.mp4Xmp] = xmpParts[xmpCoreKey];
    }

    final metadata = <MetadataType, dynamic>{
      MetadataType.mp4: Map<String, String?>.fromEntries(mp4Fields.entries.map((kv) => MapEntry(kv.key.toPlatform!, kv.value))),
    };

    final newFields = await metadataEditService.editMetadata(this, metadata);
    // applying fields is only useful for a smoother visual change,
    // as proper refreshing and persistence happens at the caller level
    await applyNewFields(newFields, persist: false);
    if (newFields.isNotEmpty) {
      dataTypes.addAll({
        EntryDataType.basic,
        EntryDataType.aspectRatio,
        EntryDataType.catalog,
      });
    }
    return dataTypes;
  }

  Future<Set<EntryDataType>> rotate({required bool clockwise}) {
    if (mimeType == MimeTypes.mp4) {
      return _rotateMp4((rotationDegrees + (clockwise ? 90 : -90) + 360) % 360);
    } else {
      return _changeExifOrientation(() => metadataEditService.rotate(this, clockwise: clockwise));
    }
  }

  Future<Set<EntryDataType>> flip() {
    return _changeExifOrientation(() => metadataEditService.flip(this));
  }

  // write title:
  // - IPTC / object-name, if IPTC exists
  // - XMP / dc:title
  // write description:
  // - Exif / ImageDescription
  // - IPTC / caption-abstract, if IPTC exists
  // - XMP / dc:description
  Future<Set<EntryDataType>> editTitleDescription(Map<DescriptionField, String?> fields) async {
    final dataTypes = <EntryDataType>{};
    final metadata = <MetadataType, dynamic>{};

    final missingDate = await _missingDateCheckAndExifEdit(dataTypes);

    final editTitle = fields.keys.contains(DescriptionField.title);
    final editDescription = fields.keys.contains(DescriptionField.description);
    final title = fields[DescriptionField.title];
    final description = fields[DescriptionField.description];

    if (canEditExif && editDescription) {
      metadata[MetadataType.exif] = {
        MetadataField.exifImageDescription.toPlatform!: null,
        MetadataField.exifUserComment.toPlatform!: null,
      };
    }

    if (canEditIptc) {
      final iptc = await metadataFetchService.getIptc(this);
      if (iptc != null) {
        if (editTitle) {
          editIptcValues(iptc, IPTC.applicationRecord, IPTC.objectName, {if (title != null) title});
        }
        if (editDescription) {
          editIptcValues(iptc, IPTC.applicationRecord, IPTC.captionAbstractTag, {if (description != null) description});
        }
        metadata[MetadataType.iptc] = iptc;
      }
    }

    if (canEditXmp) {
      metadata[MetadataType.xmp] = await _editXmp((descriptions) {
        var modified = false;
        if (editTitle) {
          modified |= XMP.setAttribute(
            descriptions,
            XmpElements.dcTitle,
            title,
            namespace: XmpNamespaces.dc,
            strat: XmpEditStrategy.always,
          );
        }
        if (editDescription) {
          modified |= XMP.setAttribute(
            descriptions,
            XmpElements.dcDescription,
            description,
            namespace: XmpNamespaces.dc,
            strat: XmpEditStrategy.always,
          );
        }
        if (modified && missingDate != null) {
          editCreateDateXmp(descriptions, missingDate);
        }
        return modified;
      });
    }

    final newFields = await metadataEditService.editMetadata(this, metadata);
    if (newFields.isNotEmpty) {
      dataTypes.addAll({
        EntryDataType.basic,
        EntryDataType.catalog,
      });
    }

    return dataTypes;
  }

  // write:
  // - IPTC / keywords, if IPTC exists
  // - XMP / dc:subject
  Future<Set<EntryDataType>> editTags(Set<String> tags) async {
    final dataTypes = <EntryDataType>{};
    final metadata = <MetadataType, dynamic>{};

    final missingDate = await _missingDateCheckAndExifEdit(dataTypes);

    if (canEditIptc) {
      final iptc = await metadataFetchService.getIptc(this);
      if (iptc != null) {
        editIptcValues(iptc, IPTC.applicationRecord, IPTC.keywordsTag, tags);
        metadata[MetadataType.iptc] = iptc;
      }
    }

    if (canEditXmp) {
      metadata[MetadataType.xmp] = await _editXmp((descriptions) {
        final modified = editTagsXmp(descriptions, tags);
        if (modified && missingDate != null) {
          editCreateDateXmp(descriptions, missingDate);
        }
        return modified;
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
    final dataTypes = <EntryDataType>{};
    final metadata = <MetadataType, dynamic>{};

    final missingDate = await _missingDateCheckAndExifEdit(dataTypes);

    if (canEditXmp) {
      metadata[MetadataType.xmp] = await _editXmp((descriptions) {
        final modified = editRatingXmp(descriptions, rating);
        if (modified && missingDate != null) {
          editCreateDateXmp(descriptions, missingDate);
        }
        return modified;
      });
    }

    final newFields = await metadataEditService.editMetadata(this, metadata);
    if (newFields.isNotEmpty) {
      dataTypes.add(EntryDataType.catalog);
    }
    return dataTypes;
  }

  // remove:
  // - trailer video
  // - XMP / Container:Directory
  // - XMP / GCamera:MicroVideo*
  // - XMP / GCamera:MotionPhoto*
  Future<Set<EntryDataType>> removeTrailerVideo() async {
    final dataTypes = <EntryDataType>{};
    final metadata = <MetadataType, dynamic>{};

    if (!canEditXmp) return dataTypes;

    final missingDate = await _missingDateCheckAndExifEdit(dataTypes);

    final newFields = await metadataEditService.removeTrailerVideo(this);

    metadata[MetadataType.xmp] = await _editXmp((descriptions) {
      final modified = removeContainerXmp(descriptions);
      if (modified && missingDate != null) {
        editCreateDateXmp(descriptions, missingDate);
      }
      return modified;
    });

    newFields.addAll(await metadataEditService.editMetadata(this, metadata, autoCorrectTrailerOffset: false));
    if (newFields.isNotEmpty) {
      dataTypes.add(EntryDataType.catalog);
    }
    return dataTypes;
  }

  Future<Set<EntryDataType>> removeMetadata(Set<MetadataType> types) async {
    final dataTypes = <EntryDataType>{};

    final newFields = await metadataEditService.removeTypes(this, types);
    if (newFields.isNotEmpty) {
      dataTypes.addAll({
        EntryDataType.basic,
        EntryDataType.aspectRatio,
        EntryDataType.catalog,
        EntryDataType.address,
      });
    }
    return dataTypes;
  }

  static void editIptcValues(List<Map<String, dynamic>> iptc, int record, int tag, Set<String> values) {
    iptc.removeWhere((v) => v['record'] == record && v['tag'] == tag);
    iptc.add({
      'record': record,
      'tag': tag,
      'values': values.map((v) => utf8.encode(v)).toList(),
    });
  }

  @visibleForTesting
  static bool editCreateDateXmp(List<XmlNode> descriptions, DateTime? date) {
    return XMP.setAttribute(
      descriptions,
      XmpAttributes.xmpCreateDate,
      date != null ? XMP.toXmpDate(date) : null,
      namespace: XmpNamespaces.xmp,
      strat: XmpEditStrategy.always,
    );
  }

  @visibleForTesting
  static bool editTagsXmp(List<XmlNode> descriptions, Set<String> tags) {
    return XMP.setStringBag(
      descriptions,
      XmpElements.dcSubject,
      tags,
      namespace: XmpNamespaces.dc,
      strat: XmpEditStrategy.always,
    );
  }

  @visibleForTesting
  static bool editRatingXmp(List<XmlNode> descriptions, int? rating) {
    bool modified = false;

    modified |= XMP.setAttribute(
      descriptions,
      XmpElements.xmpRating,
      (rating ?? 0) == 0 ? null : '$rating',
      namespace: XmpNamespaces.xmp,
      strat: XmpEditStrategy.always,
    );

    modified |= XMP.setAttribute(
      descriptions,
      XmpElements.msPhotoRating,
      XMP.toMsPhotoRating(rating),
      namespace: XmpNamespaces.microsoftPhoto,
      strat: XmpEditStrategy.updateIfPresent,
    );

    return modified;
  }

  @visibleForTesting
  static bool removeContainerXmp(List<XmlNode> descriptions) {
    bool modified = false;

    modified |= XMP.removeElements(
      descriptions,
      XmpElements.containerDirectory,
      XmpNamespaces.gContainer,
    );

    modified |= [
      XmpAttributes.gCameraMicroVideo,
      XmpAttributes.gCameraMicroVideoVersion,
      XmpAttributes.gCameraMicroVideoOffset,
      XmpAttributes.gCameraMicroVideoPresentationTimestampUs,
      XmpAttributes.gCameraMotionPhoto,
      XmpAttributes.gCameraMotionPhotoVersion,
      XmpAttributes.gCameraMotionPhotoPresentationTimestampUs,
    ].fold<bool>(modified, (prev, name) {
      return prev |= XMP.removeElements(
        descriptions,
        name,
        XmpNamespaces.gCamera,
      );
    });

    return modified;
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
    Set<MetadataField> mainMetadataDate() => {canEditExif ? MetadataField.exifDateOriginal : MetadataField.xmpXmpCreateDate};

    switch (modifier.action) {
      case DateEditAction.copyField:
        DateTime? date;
        final source = modifier.copyFieldSource;
        if (source != null) {
          switch (source) {
            case DateFieldSource.fileModifiedDate:
              try {
                if (path != null) {
                  final file = File(path!);
                  if (await file.exists()) {
                    date = await file.lastModified();
                  }
                }
              } on FileSystemException catch (_) {}
            default:
              date = await metadataFetchService.getDate(this, source.toMetadataField()!);
          }
        }
        return date != null ? DateModifier.setCustom(mainMetadataDate(), date) : null;
      case DateEditAction.extractFromTitle:
        final date = parseUnknownDateFormat(bestTitle);
        return date != null ? DateModifier.setCustom(mainMetadataDate(), date) : null;
      case DateEditAction.setCustom:
      case DateEditAction.copyItem:
        return DateModifier.setCustom(mainMetadataDate(), modifier.setDateTime!);
      case DateEditAction.shift:
      case DateEditAction.remove:
        return modifier;
    }
  }

  static const xmpCoreKey = 'xmp';
  static const xmpExtendedKey = 'extendedXmp';

  Future<Map<String, String?>> _editXmp(bool Function(List<XmlNode> descriptions) apply) async {
    final xmp = await metadataFetchService.getXmp(this);
    if (xmp == null) {
      throw Exception('failed to get XMP');
    }

    final xmpString = xmp.xmpString;
    final extendedXmpString = xmp.extendedXmpString;

    final editedXmpString = await XMP.edit(
      xmpString,
      'Aves v${device.packageVersion}',
      apply,
    );

    final editedXmp = AvesXmp(xmpString: editedXmpString, extendedXmpString: extendedXmpString);
    return {
      xmpCoreKey: editedXmp.xmpString,
      xmpExtendedKey: editedXmp.extendedXmpString,
    };
  }
}

enum DescriptionField { title, description }
