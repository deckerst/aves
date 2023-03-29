import 'package:aves/ref/metadata/exif.dart';
import 'package:aves/ref/metadata/xmp.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';

// cf https://github.com/adobe/xmp-docs/blob/master/XMPNamespaces/exif.md
class XmpExifNamespace extends XmpNamespace {
  XmpExifNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: XmpNamespaces.exif);

  @override
  String formatValue(XmpProp prop) {
    final v = prop.value;
    final field = prop.path.replaceAll(nsPrefix, '');
    switch (field) {
      case 'ColorSpace':
        return Exif.getColorSpaceDescription(v);
      case 'Contrast':
        return Exif.getContrastDescription(v);
      case 'CustomRendered':
        return Exif.getCustomRenderedDescription(v);
      case 'ExifVersion':
      case 'FlashpixVersion':
        return Exif.getExifVersionDescription(v);
      case 'ExposureMode':
        return Exif.getExposureModeDescription(v);
      case 'ExposureProgram':
        return Exif.getExposureProgramDescription(v);
      case 'FileSource':
        return Exif.getFileSourceDescription(v);
      case 'Flash/Mode':
        return Exif.getFlashModeDescription(v);
      case 'Flash/Return':
        return Exif.getFlashReturnDescription(v);
      case 'FocalPlaneResolutionUnit':
        return Exif.getResolutionUnitDescription(v);
      case 'GainControl':
        return Exif.getGainControlDescription(v);
      case 'LightSource':
        return Exif.getLightSourceDescription(v);
      case 'MeteringMode':
        return Exif.getMeteringModeDescription(v);
      case 'Saturation':
        return Exif.getSaturationDescription(v);
      case 'SceneCaptureType':
        return Exif.getSceneCaptureTypeDescription(v);
      case 'SceneType':
        return Exif.getSceneTypeDescription(v);
      case 'SensingMethod':
        return Exif.getSensingMethodDescription(v);
      case 'Sharpness':
        return Exif.getSharpnessDescription(v);
      case 'SubjectDistanceRange':
        return Exif.getSubjectDistanceRangeDescription(v);
      case 'WhiteBalance':
        return Exif.getWhiteBalanceDescription(v);
      case 'GPSAltitudeRef':
        return Exif.getGPSAltitudeRefDescription(v);
      case 'GPSDestBearingRef':
      case 'GPSImgDirectionRef':
      case 'GPSTrackRef':
        return Exif.getGPSDirectionRefDescription(v);
      case 'GPSDestDistanceRef':
        return Exif.getGPSDestDistanceRefDescription(v);
      case 'GPSDifferential':
        return Exif.getGPSDifferentialDescription(v);
      case 'GPSMeasureMode':
        return Exif.getGPSMeasureModeDescription(v);
      case 'GPSSpeedRef':
        return Exif.getGPSSpeedRefDescription(v);
      case 'GPSStatus':
        return Exif.getGPSStatusDescription(v);
      default:
        return v;
    }
  }
}
