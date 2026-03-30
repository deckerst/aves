import 'package:aves_model/aves_model.dart';

extension ExtraMetadataTypeConvert on MetadataType {
  String get toPlatform {
    switch (this) {
      case .comment:
        return 'comment';
      case .exif:
        return 'exif';
      case .iccProfile:
        return 'icc_profile';
      case .iptc:
        return 'iptc';
      case .jfif:
        return 'jfif';
      case .jpegAdobe:
        return 'jpeg_adobe';
      case .jpegDucky:
        return 'jpeg_ducky';
      case .mp4:
        return 'mp4';
      case .photoshopIrb:
        return 'photoshop_irb';
      case .xmp:
        return 'xmp';
      case .file:
        return 'file';
    }
  }
}
