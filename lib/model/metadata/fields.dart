import 'package:aves/model/metadata/enums.dart';

enum MetadataField {
  exifDate,
  exifDateOriginal,
  exifDateDigitized,
  exifGpsAltitude,
  exifGpsAltitudeRef,
  exifGpsAreaInformation,
  exifGpsDatestamp,
  exifGpsDestBearing,
  exifGpsDestBearingRef,
  exifGpsDestDistance,
  exifGpsDestDistanceRef,
  exifGpsDestLatitude,
  exifGpsDestLatitudeRef,
  exifGpsDestLongitude,
  exifGpsDestLongitudeRef,
  exifGpsDifferential,
  exifGpsDOP,
  exifGpsHPositioningError,
  exifGpsImgDirection,
  exifGpsImgDirectionRef,
  exifGpsLatitude,
  exifGpsLatitudeRef,
  exifGpsLongitude,
  exifGpsLongitudeRef,
  exifGpsMapDatum,
  exifGpsMeasureMode,
  exifGpsProcessingMethod,
  exifGpsSatellites,
  exifGpsSpeed,
  exifGpsSpeedRef,
  exifGpsStatus,
  exifGpsTimestamp,
  exifGpsTrack,
  exifGpsTrackRef,
  exifGpsVersionId,
  xmpCreateDate,
}

class MetadataFields {
  static const Set<MetadataField> exifGpsFields = {
    MetadataField.exifGpsAltitude,
    MetadataField.exifGpsAltitudeRef,
    MetadataField.exifGpsAreaInformation,
    MetadataField.exifGpsDatestamp,
    MetadataField.exifGpsDestBearing,
    MetadataField.exifGpsDestBearingRef,
    MetadataField.exifGpsDestDistance,
    MetadataField.exifGpsDestDistanceRef,
    MetadataField.exifGpsDestLatitude,
    MetadataField.exifGpsDestLatitudeRef,
    MetadataField.exifGpsDestLongitude,
    MetadataField.exifGpsDestLongitudeRef,
    MetadataField.exifGpsDifferential,
    MetadataField.exifGpsDOP,
    MetadataField.exifGpsHPositioningError,
    MetadataField.exifGpsImgDirection,
    MetadataField.exifGpsImgDirectionRef,
    MetadataField.exifGpsLatitude,
    MetadataField.exifGpsLatitudeRef,
    MetadataField.exifGpsLongitude,
    MetadataField.exifGpsLongitudeRef,
    MetadataField.exifGpsMapDatum,
    MetadataField.exifGpsMeasureMode,
    MetadataField.exifGpsProcessingMethod,
    MetadataField.exifGpsSatellites,
    MetadataField.exifGpsSpeed,
    MetadataField.exifGpsSpeedRef,
    MetadataField.exifGpsStatus,
    MetadataField.exifGpsTimestamp,
    MetadataField.exifGpsTrack,
    MetadataField.exifGpsTrackRef,
    MetadataField.exifGpsVersionId,
  };
}

extension ExtraMetadataField on MetadataField {
  MetadataType get type {
    switch (this) {
      case MetadataField.exifDate:
      case MetadataField.exifDateOriginal:
      case MetadataField.exifDateDigitized:
      case MetadataField.exifGpsAltitude:
      case MetadataField.exifGpsAltitudeRef:
      case MetadataField.exifGpsAreaInformation:
      case MetadataField.exifGpsDatestamp:
      case MetadataField.exifGpsDestBearing:
      case MetadataField.exifGpsDestBearingRef:
      case MetadataField.exifGpsDestDistance:
      case MetadataField.exifGpsDestDistanceRef:
      case MetadataField.exifGpsDestLatitude:
      case MetadataField.exifGpsDestLatitudeRef:
      case MetadataField.exifGpsDestLongitude:
      case MetadataField.exifGpsDestLongitudeRef:
      case MetadataField.exifGpsDifferential:
      case MetadataField.exifGpsDOP:
      case MetadataField.exifGpsHPositioningError:
      case MetadataField.exifGpsImgDirection:
      case MetadataField.exifGpsImgDirectionRef:
      case MetadataField.exifGpsLatitude:
      case MetadataField.exifGpsLatitudeRef:
      case MetadataField.exifGpsLongitude:
      case MetadataField.exifGpsLongitudeRef:
      case MetadataField.exifGpsMapDatum:
      case MetadataField.exifGpsMeasureMode:
      case MetadataField.exifGpsProcessingMethod:
      case MetadataField.exifGpsSatellites:
      case MetadataField.exifGpsSpeed:
      case MetadataField.exifGpsSpeedRef:
      case MetadataField.exifGpsStatus:
      case MetadataField.exifGpsTimestamp:
      case MetadataField.exifGpsTrack:
      case MetadataField.exifGpsTrackRef:
      case MetadataField.exifGpsVersionId:
        return MetadataType.exif;
      case MetadataField.xmpCreateDate:
        return MetadataType.xmp;
    }
  }

  String? get exifInterfaceTag {
    switch (this) {
      case MetadataField.exifDate:
        return 'DateTime';
      case MetadataField.exifDateOriginal:
        return 'DateTimeOriginal';
      case MetadataField.exifDateDigitized:
        return 'DateTimeDigitized';
      case MetadataField.exifGpsAltitude:
        return 'GPSAltitude';
      case MetadataField.exifGpsAltitudeRef:
        return 'GPSAltitudeRef';
      case MetadataField.exifGpsAreaInformation:
        return 'GPSAreaInformation';
      case MetadataField.exifGpsDatestamp:
        return 'GPSDateStamp';
      case MetadataField.exifGpsDestBearing:
        return 'GPSDestBearing';
      case MetadataField.exifGpsDestBearingRef:
        return 'GPSDestBearingRef';
      case MetadataField.exifGpsDestDistance:
        return 'GPSDestDistance';
      case MetadataField.exifGpsDestDistanceRef:
        return 'GPSDestDistanceRef';
      case MetadataField.exifGpsDestLatitude:
        return 'GPSDestLatitude';
      case MetadataField.exifGpsDestLatitudeRef:
        return 'GPSDestLatitudeRef';
      case MetadataField.exifGpsDestLongitude:
        return 'GPSDestLongitude';
      case MetadataField.exifGpsDestLongitudeRef:
        return 'GPSDestLongitudeRef';
      case MetadataField.exifGpsDifferential:
        return 'GPSDifferential';
      case MetadataField.exifGpsDOP:
        return 'GPSDOP';
      case MetadataField.exifGpsHPositioningError:
        return 'GPSHPositioningError';
      case MetadataField.exifGpsImgDirection:
        return 'GPSImgDirection';
      case MetadataField.exifGpsImgDirectionRef:
        return 'GPSImgDirectionRef';
      case MetadataField.exifGpsLatitude:
        return 'GPSLatitude';
      case MetadataField.exifGpsLatitudeRef:
        return 'GPSLatitudeRef';
      case MetadataField.exifGpsLongitude:
        return 'GPSLongitude';
      case MetadataField.exifGpsLongitudeRef:
        return 'GPSLongitudeRef';
      case MetadataField.exifGpsMapDatum:
        return 'GPSMapDatum';
      case MetadataField.exifGpsMeasureMode:
        return 'GPSMeasureMode';
      case MetadataField.exifGpsProcessingMethod:
        return 'GPSProcessingMethod';
      case MetadataField.exifGpsSatellites:
        return 'GPSSatellites';
      case MetadataField.exifGpsSpeed:
        return 'GPSSpeed';
      case MetadataField.exifGpsSpeedRef:
        return 'GPSSpeedRef';
      case MetadataField.exifGpsStatus:
        return 'GPSStatus';
      case MetadataField.exifGpsTimestamp:
        return 'GPSTimeStamp';
      case MetadataField.exifGpsTrack:
        return 'GPSTrack';
      case MetadataField.exifGpsTrackRef:
        return 'GPSTrackRef';
      case MetadataField.exifGpsVersionId:
        return 'GPSVersionID';
      case MetadataField.xmpCreateDate:
        return null;
    }
  }
}
