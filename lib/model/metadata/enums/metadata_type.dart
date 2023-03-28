import 'package:aves_model/aves_model.dart';

class MetadataTypes {
  static const main = {
    MetadataType.exif,
    MetadataType.xmp,
  };

  static const common = {
    MetadataType.exif,
    MetadataType.xmp,
    MetadataType.comment,
    MetadataType.iccProfile,
    MetadataType.iptc,
    MetadataType.photoshopIrb,
  };

  static const jpeg = {
    MetadataType.jfif,
    MetadataType.jpegAdobe,
    MetadataType.jpegDucky,
  };
}

extension ExtraMetadataType on MetadataType {
  // match `metadata-extractor` directory names
  String getText() {
    switch (this) {
      case MetadataType.comment:
        return 'Comment';
      case MetadataType.exif:
        return 'Exif';
      case MetadataType.iccProfile:
        return 'ICC Profile';
      case MetadataType.iptc:
        return 'IPTC';
      case MetadataType.jfif:
        return 'JFIF';
      case MetadataType.jpegAdobe:
        return 'Adobe JPEG';
      case MetadataType.jpegDucky:
        return 'Ducky';
      case MetadataType.mp4:
        return 'MP4';
      case MetadataType.photoshopIrb:
        return 'Photoshop';
      case MetadataType.xmp:
        return 'XMP';
    }
  }

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
