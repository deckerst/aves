enum MetadataField {
  exifDate,
  exifDateOriginal,
  exifDateDigitized,
  exifGpsDate,
}

enum DateEditAction {
  set,
  shift,
  extractFromTitle,
  clear,
}

enum MetadataType {
  // JPEG COM marker or GIF comment
  comment,
  // Exif: https://en.wikipedia.org/wiki/Exif
  exif,
  // ICC profile: https://en.wikipedia.org/wiki/ICC_profile
  iccProfile,
  // IPTC: https://en.wikipedia.org/wiki/IPTC_Information_Interchange_Model
  iptc,
  // JPEG APP0 / JFIF: https://en.wikipedia.org/wiki/JPEG_File_Interchange_Format
  jfif,
  // JPEG APP14 / Adobe: https://www.exiftool.org/TagNames/JPEG.html#Adobe
  jpegAdobe,
  // JPEG APP12 / Ducky: https://www.exiftool.org/TagNames/APP12.html#Ducky
  jpegDucky,
  // Photoshop IRB: https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/
  photoshopIrb,
  // XMP: https://en.wikipedia.org/wiki/Extensible_Metadata_Platform
  xmp,
}

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
  // match `ExifInterface` directory names
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
      case MetadataType.photoshopIrb:
        return 'Photoshop';
      case MetadataType.xmp:
        return 'XMP';
    }
  }
}
