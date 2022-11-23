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
  static const flv = 'video/flv';
  static const flvX = 'video/x-flv';
  static const mkv = 'video/mkv';
  static const mkvX = 'video/x-matroska';
  static const mov = 'video/quicktime';
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

  // JB2, JPC, JPX?
  static const octetStream = 'application/octet-stream';
  static const zip = 'application/zip';

  // groups

  // formats that support transparency
  static const Set<String> alphaImages = {avif, bmp, bmpX, gif, heic, heif, ico, png, svg, tiff, webp};

  static const Set<String> rawImages = {arw, cr2, crw, dcr, dng, dngX, erf, k25, kdc, mrw, nef, nrw, orf, pef, raf, raw, rw2, sr2, srf, srw, x3f};

  // TODO TLAD [codec] make it dynamic if it depends on OS/lib versions
  static const Set<String> undecodableImages = {art, cdr, crw, djvu, jpeg2000, jxl, pat, pcx, pnm, psdVnd, psdX, octetStream, zip};

  static const Set<String> _knownOpaqueImages = {jpeg};

  static const Set<String> _knownVideos = {v3gpp, asf, avi, aviMSVideo, aviVnd, aviXMSVideo, flv, flvX, mkv, mkvX, mov, mp2p, mp2t, mp2ts, mp4, mpeg, ogv, realVideo, webm, wmv};

  static final Set<String> knownMediaTypes = {
    anyImage,
    ..._knownOpaqueImages,
    ...alphaImages,
    ...rawImages,
    ...undecodableImages,
    anyVideo,
    ..._knownVideos,
  };

  static bool isImage(String mimeType) => mimeType.startsWith('image');

  static bool isVideo(String mimeType) => mimeType.startsWith('video');

  static bool isVisual(String mimeType) => isImage(mimeType) || isVideo(mimeType);

  static bool refersToSameType(String a, b) {
    switch (a) {
      case avi:
      case aviMSVideo:
      case aviVnd:
      case aviXMSVideo:
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

  static String? forExtension(String extension) {
    switch (extension) {
      case '.jpg':
        return jpeg;
      case '.svg':
        return svg;
    }
    return null;
  }

  // `exifinterface` v1.3.3 declared support for DNG, but it strips non-standard Exif tags when saving attributes,
  // and DNG requires DNG-specific tags saved along standard Exif. So it was actually breaking DNG files.
  static bool canEditExif(String mimeType) {
    switch (mimeType.toLowerCase()) {
      // as of androidx.exifinterface:exifinterface:1.3.4
      case jpeg:
      case png:
      case webp:
        return true;
      default:
        return false;
    }
  }

  static bool canEditIptc(String mimeType) {
    switch (mimeType.toLowerCase()) {
      // as of latest PixyMeta
      case jpeg:
      case tiff:
        return true;
      default:
        return false;
    }
  }

  static bool canEditXmp(String mimeType) {
    switch (mimeType.toLowerCase()) {
      // as of latest PixyMeta
      case gif:
      case jpeg:
      case png:
      case tiff:
        return true;
      // using `mp4parser`
      case mp4:
        return true;
      default:
        return false;
    }
  }

  static bool canRemoveMetadata(String mimeType) {
    switch (mimeType.toLowerCase()) {
      // as of latest PixyMeta
      case jpeg:
      case tiff:
        return true;
      default:
        return false;
    }
  }
}
