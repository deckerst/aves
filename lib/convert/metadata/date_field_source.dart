import 'package:aves_model/aves_model.dart';

extension ExtraDateFieldSourceConvert on DateFieldSource {
  MetadataField? toMetadataField() {
    switch (this) {
      case .fileModifiedDate:
        return null;
      case .exifDate:
        return .exifDate;
      case .exifDateOriginal:
        return .exifDateOriginal;
      case .exifDateDigitized:
        return .exifDateDigitized;
      case .exifGpsDate:
        return .exifGpsDatestamp;
    }
  }
}
