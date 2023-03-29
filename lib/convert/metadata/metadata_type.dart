import 'package:aves_model/aves_model.dart';

extension ExtraMetadataTypeConvert on MetadataType {
  String get toPlatform {
    switch (this) {
      case MetadataType.comment:
        return 'comment';
      case MetadataType.exif:
        return 'exif';
      case MetadataType.iccProfile:
        return 'icc_profile';
      case MetadataType.iptc:
        return 'iptc';
      case MetadataType.jfif:
        return 'jfif';
      case MetadataType.jpegAdobe:
        return 'jpeg_adobe';
      case MetadataType.jpegDucky:
        return 'jpeg_ducky';
      case MetadataType.mp4:
        return 'mp4';
      case MetadataType.photoshopIrb:
        return 'photoshop_irb';
      case MetadataType.xmp:
        return 'xmp';
    }
  }
}
