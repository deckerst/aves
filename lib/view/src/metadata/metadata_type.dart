import 'package:aves_model/aves_model.dart';

extension ExtraMetadataTypeView on MetadataType {
  // match `metadata-extractor` directory names
  String getText() {
    return switch (this) {
      MetadataType.comment => 'Comment',
      MetadataType.exif => 'Exif',
      MetadataType.iccProfile => 'ICC Profile',
      MetadataType.iptc => 'IPTC',
      MetadataType.jfif => 'JFIF',
      MetadataType.jpegAdobe => 'Adobe JPEG',
      MetadataType.jpegDucky => 'Ducky',
      MetadataType.mp4 => 'MP4',
      MetadataType.photoshopIrb => 'Photoshop',
      MetadataType.xmp => 'XMP',
    };
  }
}
