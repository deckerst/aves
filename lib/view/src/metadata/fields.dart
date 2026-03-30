import 'package:aves_model/aves_model.dart';

extension ExtraMetadataFieldView on MetadataField {
  String get title {
    switch (this) {
      case .exifDate:
        return 'Exif date';
      case .exifDateOriginal:
        return 'Exif original date';
      case .exifDateDigitized:
        return 'Exif digitized date';
      case .exifGpsDatestamp:
        return 'Exif GPS date';
      case .exifMake:
        return 'Exif make';
      case .exifModel:
        return 'Exif model';
      case .xmpXmpCreateDate:
        return 'XMP xmp:CreateDate';
      default:
        return name;
    }
  }
}
