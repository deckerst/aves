import 'package:aves_model/aves_model.dart';

extension ExtraMetadataTypeView on MetadataType {
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
}
