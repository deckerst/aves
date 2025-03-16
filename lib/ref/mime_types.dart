class MimeTypes {
  static const anyImage = 'image/*';

  static const avif = 'image/avif';
  static const bmp = 'image/bmp';
  static const bmpX = 'image/x-ms-bmp';
  static const gif = 'image/gif';
  static const heic = 'image/heic';
  static const heif = 'image/heif';
  static const ico = 'image/x-icon';
  static const jpeg = 'image/jpeg';
  static const png = 'image/png';
  static const svg = 'image/svg+xml';
  static const tiff = 'image/tiff';
  static const webp = 'image/webp';
  static const wbmp = 'image/vnd.wap.wbmp';

  static const art = 'image/x-jg';
  static const cdr = 'image/x-coreldraw';
  static const djvu = 'image/vnd.djvu';
  static const jpeg2000 = 'image/jp2';
  static const jxl = 'image/jxl';
  static const pat = 'image/x-coreldrawpattern';
  static const pcx = 'image/x-pcx';
  static const pnm = 'image/x-portable-anymap';
  static const psdVnd = 'image/vnd.adobe.photoshop';
  static const psdX = 'image/x-photoshop';

  static const arw = 'image/x-sony-arw';
  static const cr2 = 'image/x-canon-cr2';
  static const crw = 'image/x-canon-crw';
  static const dcr = 'image/x-kodak-dcr';
  static const dng = 'image/dng';
  static const dngX = 'image/x-adobe-dng';
  static const erf = 'image/x-epson-erf';
  static const k25 = 'image/x-kodak-k25';
  static const kdc = 'image/x-kodak-kdc';
  static const mrw = 'image/x-minolta-mrw';
  static const nef = 'image/x-nikon-nef';
  static const nrw = 'image/x-nikon-nrw';
  static const orf = 'image/x-olympus-orf';
  static const pef = 'image/x-pentax-pef';
  static const raf = 'image/x-fuji-raf';
  static const raw = 'image/x-panasonic-raw';
  static const rw2 = 'image/x-panasonic-rw2';
  static const sr2 = 'image/x-sony-sr2';
  static const srf = 'image/x-sony-srf';
  static const srw = 'image/x-samsung-srw';
  static const x3f = 'image/x-sigma-x3f';

  static const anyVideo = 'video/*';

  static const v3gpp = 'video/3gpp';
  static const asf = 'video/x-ms-asf';
  static const avi = 'video/avi';
  static const aviMSVideo = 'video/msvideo';
  static const aviVnd = 'video/vnd.avi';
  static const aviXMSVideo = 'video/x-msvideo';
  static const dvd = 'video/dvd';
  static const flv = 'video/flv';
  static const flvX = 'video/x-flv';
  static const mkv = 'video/mkv';
  static const mkvX = 'video/x-matroska';
  static const mov = 'video/quicktime';
  static const movX = 'video/x-quicktime';
  static const mp2p = 'video/mp2p';
  static const mp2t = 'video/mp2t'; // .m2ts, .ts
  static const mp2ts = 'video/mp2ts'; // .ts (prefer `mp2t` when possible)
  static const mp4 = 'video/mp4';
  static const mpeg = 'video/mpeg';
  static const ogv = 'video/ogg';
  static const realVideo = 'video/x-pn-realvideo';
  static const webm = 'video/webm';
  static const wmv = 'video/x-ms-wmv';

  static const json = 'application/json';
  static const plainText = 'text/plain';
  static const sqlite3 = 'application/vnd.sqlite3';

  // JB2, JPC, JPX?
  static const octetStream = 'application/octet-stream';
  static const zip = 'application/zip';

  // groups

  // formats that support transparency
  static const Set<String> alphaImages = {avif, bmp, bmpX, gif, heic, heif, ico, png, svg, tiff, webp};

  static const Set<String> rawImages = {arw, cr2, crw, dcr, dng, dngX, erf, k25, kdc, mrw, nef, nrw, orf, pef, raf, raw, rw2, sr2, srf, srw, x3f};

  static const Set<String> developedRawImages = {jpeg, heic, heif};

  static bool canHaveAlpha(String mimeType) => MimeTypes.alphaImages.contains(mimeType);

  static bool isRaw(String mimeType) => MimeTypes.rawImages.contains(mimeType);

  static bool isImage(String mimeType) => mimeType.startsWith('image');

  static bool isVideo(String mimeType) => mimeType.startsWith('video');

  static bool isVisual(String mimeType) => isImage(mimeType) || isVideo(mimeType);

  static String _collapsedType(String mimeType) {
    switch (mimeType) {
      case avi:
      case aviMSVideo:
      case aviVnd:
      case aviXMSVideo:
        return avi;
      case bmp:
      case bmpX:
        return bmp;
      case flv:
      case flvX:
        return flv;
      case heic:
      case heif:
        return heic;
      case mov:
      case movX:
        return mov;
      case psdVnd:
      case psdX:
        return psdVnd;
      default:
        return mimeType;
    }
  }

  static bool refersToSameType(String a, b) => _collapsedType(a) == _collapsedType(b);

  static String? forExtension(String extension) {
    switch (extension) {
      case '.jpg':
        return jpeg;
      case '.svg':
        return svg;
    }
    return null;
  }

  static const Map<String, String> _defaultExtensions = {
    bmp: '.bmp',
    gif: '.gif',
    jpeg: '.jpg',
    png: '.png',
    svg: '.svg',
    webp: '.webp',
  };

  static String? extensionFor(String mimeType) => _defaultExtensions[mimeType];
}
