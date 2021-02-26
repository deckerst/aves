class MimeUtils {
  static String displayType(String mime) {
    switch (mime) {
      case 'image/x-icon':
        return 'ICO';
      case 'image/x-jg':
        return 'ART';
      case 'image/vnd.adobe.photoshop':
      case 'image/x-photoshop':
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
