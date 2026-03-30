import 'dart:convert';
import 'dart:io';

import 'package:aves/convert/convert.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry/entry.dart';
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
  static final _iso6709LatitudeFormatter = NumberFormat('00.0000', asciiLocale);
  static final _iso6709LongitudeFormatter = NumberFormat('000.0000', asciiLocale);

  Future<Set<EntryDataType>> editDate(DateModifier userModifier) async {
    final dataTypes = <EntryDataType>{};

    final appliedModifier = await _applyDateModifierToEntry(userModifier);
    if (appliedModifier == null) {
      if (isValid && userModifier.action != DateEditAction.copyField) {
        await reportService.recordError('failed to get date for modifier=$userModifier, entry=$this');
      }
      return {};
    }

    if (isExifEditionSupported && appliedModifier.fields.any((v) => v.type == MetadataType.exif)) {
      final newFields = await metadataEditService.editExifDate(this, appliedModifier);
      if (newFields.isNotEmpty) {
        dataTypes.addAll({
          EntryDataType.basic,
          EntryDataType.catalog,
        });
      }
    }

    if (isXmpEditionSupported && appliedModifier.fields.any((v) => v.type == MetadataType.xmp)) {
      final metadata = {
        MetadataType.xmp: await _editXmp((descriptions) {
          switch (appliedModifier.action) {
            case .setCustom:
            case .copyField:
            case .copyItem:
            case .extractFromTitle:
              editCreateDateXmp(descriptions, appliedModifier.setDateTime);
            case .shift:
              final xmpDate = XMP.getString(descriptions, XmpAttributes.xmpCreateDate, namespace: XmpNamespaces.xmp);
              if (xmpDate != null) {
                final date = DateTime.tryParse(xmpDate);
                if (date != null) {
                  // TODO TLAD [date] DateTime.tryParse converts to UTC time, losing the time zone offset
                  final shiftedDate = date.add(Duration(seconds: appliedModifier.shiftSeconds!));
                  editCreateDateXmp(descriptions, shiftedDate);
                } else {
                  reportService.recordError('failed to parse XMP date=$xmpDate');
                }
              }
            case .remove:
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

    if (isExifEditionSupported) {
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
    }

    if (mimeType == MimeTypes.mp4) {
      final mp4Fields = <MetadataField, String?>{};

      String? iso6709String;
      if (latLng != null && latLng != removalLocation) {
        final latitude = latLng.latitude;
        final longitude = latLng.longitude;
        final isoLat = '${latitude >= 0 ? '+' : '-'}${_iso6709LatitudeFormatter.format(latitude.abs())}';
        final isoLon = '${longitude >= 0 ? '+' : '-'}${_iso6709LongitudeFormatter.format(longitude.abs())}';
        iso6709String = '$isoLat$isoLon/';
      }
      mp4Fields[MetadataField.mp4GpsCoordinates] = iso6709String;

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

    final mp4Fields = <MetadataField, String?>{
      MetadataField.mp4RotationDegrees: rotationDegrees.toString(),
    };

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
  // - Exif / ImageDescription (clear field)
  // - Exif / UserComment (clear field)
  // - IPTC / caption-abstract, if IPTC exists
  // - XMP / dc:description
  Future<Set<EntryDataType>> editTitleDescription(Map<DescriptionField, String?> fields) async {
    final dataTypes = <EntryDataType>{};
    final metadata = <MetadataType, dynamic>{};

    final editTitle = fields.keys.contains(DescriptionField.title);
    final editDescription = fields.keys.contains(DescriptionField.description);
    final title = fields[DescriptionField.title];
    final description = fields[DescriptionField.description];

    if (isExifEditionSupported && editDescription) {
      metadata[MetadataType.exif] = {
        // clear field because it is subpar, with ASCII support only
        MetadataField.exifImageDescription.toPlatform!: null,
        // clear field because it is subpar, with ambiguous encoding
        MetadataField.exifUserComment.toPlatform!: null,
      };
    }

    if (isIptcEditionSupported) {
      final iptc = await metadataFetchService.getIptc(this);
      if (iptc != null) {
        if (editTitle) {
          editIptcValues(iptc, IPTC.applicationRecord, IPTC.objectName, {?title});
        }
        if (editDescription) {
          editIptcValues(iptc, IPTC.applicationRecord, IPTC.captionAbstractTag, {?description});
        }
        metadata[MetadataType.iptc] = iptc;
      }
    }

    if (isXmpEditionSupported) {
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

    if (isIptcEditionSupported) {
      final iptc = await metadataFetchService.getIptc(this);
      if (iptc != null) {
        editIptcValues(iptc, IPTC.applicationRecord, IPTC.keywordsTag, tags);
        metadata[MetadataType.iptc] = iptc;
      }
    }

    if (isXmpEditionSupported) {
      metadata[MetadataType.xmp] = await _editXmp((descriptions) {
        return editTagsXmp(descriptions, tags);
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

    if (isXmpEditionSupported) {
      metadata[MetadataType.xmp] = await _editXmp((descriptions) {
        return editRatingXmp(descriptions, rating);
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

    if (!isXmpEditionSupported) return dataTypes;

    final newFields = await metadataEditService.removeTrailerVideo(this);

    metadata[MetadataType.xmp] = await _editXmp(removeContainerXmp);

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

    modified |=
        [
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

  Future<DateModifier?> _applyDateModifierToEntry(DateModifier modifier) async {
    Set<MetadataField> mainMetadataDate() => {isExifEditionSupported ? MetadataField.exifDateOriginal : MetadataField.xmpXmpCreateDate};

    switch (modifier.action) {
      case .copyField:
        DateTime? date;
        final source = modifier.copyFieldSource;
        if (source != null) {
          switch (source) {
            case .fileModifiedDate:
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
      case .extractFromTitle:
        final date = parseUnknownDateFormat(bestTitle);
        return date != null ? DateModifier.setCustom(mainMetadataDate(), date) : null;
      case .setCustom:
      case .copyItem:
        return DateModifier.setCustom(mainMetadataDate(), modifier.setDateTime!);
      case .shift:
      case .remove:
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
