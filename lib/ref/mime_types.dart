class MimeTypes {
  static const anyImage = 'image/*';

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

  static const art = 'image/x-jg';
  static const djvu = 'image/vnd.djvu';
  static const jxl = 'image/jxl';
  static const psdVnd = 'image/vnd.adobe.photoshop';
  static const psdX = 'image/x-photoshop';

  static const arw = 'image/x-sony-arw';
  static const cr2 = 'image/x-canon-cr2';
  static const crw = 'image/x-canon-crw';
  static const dcr = 'image/x-kodak-dcr';
  static const dng = 'image/x-adobe-dng';
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

  static const avi = 'video/avi';
  static const aviVnd = 'video/vnd.avi';
  static const flv = 'video/flv';
  static const flvX = 'video/x-flv';
  static const mkv = 'video/x-matroska';
  static const mov = 'video/quicktime';
  static const mp2t = 'video/mp2t'; // .m2ts, .ts
  static const mp2ts = 'video/mp2ts'; // .ts (prefer `mp2t` when possible)
  static const mp4 = 'video/mp4';
  static const mpeg = 'video/mpeg';
  static const ogv = 'video/ogg';
  static const webm = 'video/webm';

  static const json = 'application/json';
  static const plainText = 'text/plain';

  // JB2, JPC, JPX?
  static const octetStream = 'application/octet-stream';
  static const zip = 'application/zip';

  // groups

  // formats that support transparency
  static const Set<String> alphaImages = {bmp, bmpX, gif, ico, png, svg, tiff, webp};

  static const Set<String> rawImages = {arw, cr2, crw, dcr, dng, erf, k25, kdc, mrw, nef, nrw, orf, pef, raf, raw, rw2, sr2, srf, srw, x3f};

  // TODO TLAD [codec] make it dynamic if it depends on OS/lib versions
  static const Set<String> undecodableImages = {art, crw, djvu, jxl, psdVnd, psdX, octetStream, zip};

  static const Set<String> _knownOpaqueImages = {heic, heif, jpeg};

  static const Set<String> _knownVideos = {avi, aviVnd, flv, flvX, mkv, mov, mp2t, mp2ts, mp4, mpeg, ogv, webm};

  static final Set<String> knownMediaTypes = {..._knownOpaqueImages, ...alphaImages, ...rawImages, ...undecodableImages, ..._knownVideos};

  static bool isImage(String mimeType) => mimeType.startsWith('image');

  static bool isVideo(String mimeType) => mimeType.startsWith('video');

  static bool refersToSameType(String a, b) {
    switch (a) {
      case avi:
      case aviVnd:
        return [avi, aviVnd].contains(b);
      case bmp:
      case bmpX:
        return [bmp, bmpX].contains(b);
      case flv:
      case flvX:
        return [flv, flvX].contains(b);
      case heic:
      case heif:
        return [heic, heif].contains(b);
      case psdVnd:
      case psdX:
        return [psdVnd, psdX].contains(b);
      default:
        return a == b;
    }
  }
}
