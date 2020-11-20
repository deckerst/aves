class MimeTypes {
  static const String anyImage = 'image/*';

  static const String gif = 'image/gif';
  static const String heic = 'image/heic';
  static const String heif = 'image/heif';
  static const String jpeg = 'image/jpeg';
  static const String png = 'image/png';
  static const String svg = 'image/svg+xml';
  static const String webp = 'image/webp';

  static const String tiff = 'image/tiff';
  static const String psd = 'image/vnd.adobe.photoshop';

  static const String arw = 'image/x-sony-arw';
  static const String cr2 = 'image/x-canon-cr2';
  static const String crw = 'image/x-canon-crw';
  static const String dcr = 'image/x-kodak-dcr';
  static const String dng = 'image/x-adobe-dng';
  static const String erf = 'image/x-epson-erf';
  static const String k25 = 'image/x-kodak-k25';
  static const String kdc = 'image/x-kodak-kdc';
  static const String mrw = 'image/x-minolta-mrw';
  static const String nef = 'image/x-nikon-nef';
  static const String nrw = 'image/x-nikon-nrw';
  static const String orf = 'image/x-olympus-orf';
  static const String pef = 'image/x-pentax-pef';
  static const String raf = 'image/x-fuji-raf';
  static const String raw = 'image/x-panasonic-raw';
  static const String rw2 = 'image/x-panasonic-rw2';
  static const String sr2 = 'image/x-sony-sr2';
  static const String srf = 'image/x-sony-srf';
  static const String srw = 'image/x-samsung-srw';
  static const String x3f = 'image/x-sigma-x3f';

  static const String anyVideo = 'video/*';

  static const String avi = 'video/avi';
  static const String mp2t = 'video/mp2t'; // .m2ts
  static const String mp4 = 'video/mp4';

  // groups
  static const List<String> rawImages = [arw, cr2, crw, dcr, dng, erf, k25, kdc, mrw, nef, nrw, orf, pef, raf, raw, rw2, sr2, srf, srw, x3f];
  static const List<String> undecodable = [crw, psd]; // TODO TLAD make it dynamic if it depends on OS/lib versions

  static String displayType(String mime) {
    switch (mime) {
      case 'image/x-icon':
        return 'ICO';
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
