import 'package:aves/ref/mime_types.dart';

class MimeUtils {
  static String displayType(String mime) {
    switch (mime) {
      case MimeTypes.art:
        return 'ART';
      case MimeTypes.ico:
        return 'ICO';
      case MimeTypes.mov:
        return 'MOV';
      case MimeTypes.psdVnd:
      case MimeTypes.psdX:
        return 'PSD';
      default:
        final patterns = [
          RegExp('.*/'), // remove type, keep subtype
          RegExp('(X-|VND.(WAP.)?)'), // noisy prefixes
          '+XML', // noisy suffix
        ];
        mime = mime.toUpperCase();
        patterns.forEach((pattern) => mime = mime.replaceFirst(pattern, ''));
        return mime;
    }
  }
}
