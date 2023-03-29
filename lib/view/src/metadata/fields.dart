import 'package:aves_model/aves_model.dart';

extension ExtraMetadataFieldView on MetadataField {
  String get title {
    switch (this) {
      case MetadataField.exifDate:
        return 'Exif date';
      case MetadataField.exifDateOriginal:
        return 'Exif original date';
      case MetadataField.exifDateDigitized:
        return 'Exif digitized date';
      case MetadataField.exifGpsDatestamp:
        return 'Exif GPS date';
      case MetadataField.xmpXmpCreateDate:
        return 'XMP xmp:CreateDate';
      default:
        return name;
    }
  }
}
