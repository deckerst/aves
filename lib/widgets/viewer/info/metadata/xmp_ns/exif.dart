import 'package:aves/ref/exif.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';

// cf https://github.com/adobe/xmp-docs/blob/master/XMPNamespaces/exif.md
class XmpExifNamespace extends XmpNamespace {
  static const ns = 'exif';

  XmpExifNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  String get displayTitle => 'Exif';

  @override
  String formatValue(XmpProp prop) {
    final v = prop.value;
    switch (prop.path) {
      case 'exif:ColorSpace':
        return Exif.getColorSpaceDescription(v);
      case 'exif:Contrast':
        return Exif.getContrastDescription(v);
      case 'exif:CustomRendered':
        return Exif.getCustomRenderedDescription(v);
      case 'exif:ExifVersion':
      case 'exif:FlashpixVersion':
        return Exif.getExifVersionDescription(v);
      case 'exif:ExposureMode':
        return Exif.getExposureModeDescription(v);
      case 'exif:ExposureProgram':
        return Exif.getExposureProgramDescription(v);
      case 'exif:FileSource':
        return Exif.getFileSourceDescription(v);
      case 'exif:Flash/exif:Mode':
        return Exif.getFlashModeDescription(v);
      case 'exif:Flash/exif:Return':
        return Exif.getFlashReturnDescription(v);
      case 'exif:FocalPlaneResolutionUnit':
        return Exif.getResolutionUnitDescription(v);
      case 'exif:GainControl':
        return Exif.getGainControlDescription(v);
      case 'exif:LightSource':
        return Exif.getLightSourceDescription(v);
      case 'exif:MeteringMode':
        return Exif.getMeteringModeDescription(v);
      case 'exif:Saturation':
        return Exif.getSaturationDescription(v);
      case 'exif:SceneCaptureType':
        return Exif.getSceneCaptureTypeDescription(v);
      case 'exif:SceneType':
        return Exif.getSceneTypeDescription(v);
      case 'exif:SensingMethod':
        return Exif.getSensingMethodDescription(v);
      case 'exif:Sharpness':
        return Exif.getSharpnessDescription(v);
      case 'exif:SubjectDistanceRange':
        return Exif.getSubjectDistanceRangeDescription(v);
      case 'exif:WhiteBalance':
        return Exif.getWhiteBalanceDescription(v);
      case 'exif:GPSAltitudeRef':
        return Exif.getGPSAltitudeRefDescription(v);
      case 'exif:GPSDestBearingRef':
      case 'exif:GPSImgDirectionRef':
      case 'exif:GPSTrackRef':
        return Exif.getGPSDirectionRefDescription(v);
      case 'exif:GPSDestDistanceRef':
        return Exif.getGPSDestDistanceRefDescription(v);
      case 'exif:GPSDifferential':
        return Exif.getGPSDifferentialDescription(v);
      case 'exif:GPSMeasureMode':
        return Exif.getGPSMeasureModeDescription(v);
      case 'exif:GPSSpeedRef':
        return Exif.getGPSSpeedRefDescription(v);
      case 'exif:GPSStatus':
        return Exif.getGPSStatusDescription(v);
      default:
        return v;
    }
  }
}
