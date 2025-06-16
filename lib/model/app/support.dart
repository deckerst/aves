import 'package:aves/ref/mime_types.dart';

class AppSupport {
  // TODO TLAD [codec] make it dynamic if it depends on OS/lib versions
  static const Set<String> undecodableImages = {
    MimeTypes.art,
    MimeTypes.cdr,
    MimeTypes.crw,
    MimeTypes.djvu,
    MimeTypes.dwg,
    MimeTypes.jpeg2000,
    MimeTypes.jxl,
    MimeTypes.pat,
    MimeTypes.pcx,
    MimeTypes.pnm,
    MimeTypes.psdVnd,
    MimeTypes.psdX,
    MimeTypes.octetStream,
    MimeTypes.rgbe,
    MimeTypes.zip,
  };

  static bool canDecode(String mimeType) => !undecodableImages.contains(mimeType);

  // `exifinterface` v1.3.3 declared support for DNG, but it strips non-standard Exif tags when saving attributes,
  // and DNG requires DNG-specific tags saved along standard Exif. So it was actually breaking DNG files.
  static bool canEditExif(String mimeType) {
    switch (mimeType.toLowerCase()) {
      // as of androidx.exifinterface:exifinterface:1.3.4
      case MimeTypes.jpeg:
      case MimeTypes.png:
      case MimeTypes.webp:
        return true;
      default:
        return false;
    }
  }

  static bool canEditIptc(String mimeType) {
    switch (mimeType.toLowerCase()) {
      // as of latest PixyMeta
      case MimeTypes.jpeg:
      case MimeTypes.tiff:
        return true;
      default:
        return false;
    }
  }

  static bool canEditXmp(String mimeType) {
    switch (mimeType.toLowerCase()) {
      // as of latest PixyMeta
      case MimeTypes.gif:
      case MimeTypes.jpeg:
      case MimeTypes.png:
      case MimeTypes.tiff:
        return true;
      // using `mp4parser`
      case MimeTypes.mp4:
        return true;
      default:
        return false;
    }
  }

  static bool canRemoveMetadata(String mimeType) {
    switch (mimeType.toLowerCase()) {
      // as of latest PixyMeta
      case MimeTypes.jpeg:
      case MimeTypes.tiff:
        return true;
      default:
        return false;
    }
  }
}
