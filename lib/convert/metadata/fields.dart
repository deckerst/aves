import 'package:aves_model/aves_model.dart';

extension ExtraMetadataSyntheticFieldConvert on MetadataSyntheticField {
  String? get toPlatform => name;
}

extension ExtraMetadataFieldConvert on MetadataField {
  MetadataType get type {
    switch (this) {
      case .exifDate:
      case .exifDateOriginal:
      case .exifDateDigitized:
      case .exifGpsAltitude:
      case .exifGpsAltitudeRef:
      case .exifGpsAreaInformation:
      case .exifGpsDatestamp:
      case .exifGpsDestBearing:
      case .exifGpsDestBearingRef:
      case .exifGpsDestDistance:
      case .exifGpsDestDistanceRef:
      case .exifGpsDestLatitude:
      case .exifGpsDestLatitudeRef:
      case .exifGpsDestLongitude:
      case .exifGpsDestLongitudeRef:
      case .exifGpsDifferential:
      case .exifGpsDOP:
      case .exifGpsHPositioningError:
      case .exifGpsImgDirection:
      case .exifGpsImgDirectionRef:
      case .exifGpsLatitude:
      case .exifGpsLatitudeRef:
      case .exifGpsLongitude:
      case .exifGpsLongitudeRef:
      case .exifGpsMapDatum:
      case .exifGpsMeasureMode:
      case .exifGpsProcessingMethod:
      case .exifGpsSatellites:
      case .exifGpsSpeed:
      case .exifGpsSpeedRef:
      case .exifGpsStatus:
      case .exifGpsTimestamp:
      case .exifGpsTrack:
      case .exifGpsTrackRef:
      case .exifGpsVersionId:
      case .exifImageDescription:
      case .exifMake:
      case .exifModel:
      case .exifUserComment:
        return MetadataType.exif;
      case .mp4GpsCoordinates:
      case .mp4RotationDegrees:
      case .mp4Xmp:
        return MetadataType.mp4;
      case .xmpXmpCreateDate:
        return MetadataType.xmp;
      case .hashMd5:
      case .hashSha1:
      case .hashSha256:
        return MetadataType.file;
    }
  }

  String? get toPlatform {
    switch (type) {
      case .exif:
        return _toExifInterfaceTag();
      case .file:
        return name;
      default:
        switch (this) {
          case .mp4GpsCoordinates:
            return 'gpsCoordinates';
          case .mp4RotationDegrees:
            return 'rotationDegrees';
          case .mp4Xmp:
            return 'xmp';
          default:
            return null;
        }
    }
  }

  String? _toExifInterfaceTag() {
    switch (this) {
      case .exifDate:
        return 'DateTime';
      case .exifDateOriginal:
        return 'DateTimeOriginal';
      case .exifDateDigitized:
        return 'DateTimeDigitized';
      case .exifGpsAltitude:
        return 'GPSAltitude';
      case .exifGpsAltitudeRef:
        return 'GPSAltitudeRef';
      case .exifGpsAreaInformation:
        return 'GPSAreaInformation';
      case .exifGpsDatestamp:
        return 'GPSDateStamp';
      case .exifGpsDestBearing:
        return 'GPSDestBearing';
      case .exifGpsDestBearingRef:
        return 'GPSDestBearingRef';
      case .exifGpsDestDistance:
        return 'GPSDestDistance';
      case .exifGpsDestDistanceRef:
        return 'GPSDestDistanceRef';
      case .exifGpsDestLatitude:
        return 'GPSDestLatitude';
      case .exifGpsDestLatitudeRef:
        return 'GPSDestLatitudeRef';
      case .exifGpsDestLongitude:
        return 'GPSDestLongitude';
      case .exifGpsDestLongitudeRef:
        return 'GPSDestLongitudeRef';
      case .exifGpsDifferential:
        return 'GPSDifferential';
      case .exifGpsDOP:
        return 'GPSDOP';
      case .exifGpsHPositioningError:
        return 'GPSHPositioningError';
      case .exifGpsImgDirection:
        return 'GPSImgDirection';
      case .exifGpsImgDirectionRef:
        return 'GPSImgDirectionRef';
      case .exifGpsLatitude:
        return 'GPSLatitude';
      case .exifGpsLatitudeRef:
        return 'GPSLatitudeRef';
      case .exifGpsLongitude:
        return 'GPSLongitude';
      case .exifGpsLongitudeRef:
        return 'GPSLongitudeRef';
      case .exifGpsMapDatum:
        return 'GPSMapDatum';
      case .exifGpsMeasureMode:
        return 'GPSMeasureMode';
      case .exifGpsProcessingMethod:
        return 'GPSProcessingMethod';
      case .exifGpsSatellites:
        return 'GPSSatellites';
      case .exifGpsSpeed:
        return 'GPSSpeed';
      case .exifGpsSpeedRef:
        return 'GPSSpeedRef';
      case .exifGpsStatus:
        return 'GPSStatus';
      case .exifGpsTimestamp:
        return 'GPSTimeStamp';
      case .exifGpsTrack:
        return 'GPSTrack';
      case .exifGpsTrackRef:
        return 'GPSTrackRef';
      case .exifGpsVersionId:
        return 'GPSVersionID';
      case .exifImageDescription:
        return 'ImageDescription';
      case .exifMake:
        return 'Make';
      case .exifModel:
        return 'Model';
      case .exifUserComment:
        return 'UserComment';
      default:
        return null;
    }
  }
}
