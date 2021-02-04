import 'dart:async';

import 'package:aves/model/entry_cache.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/services/service_policy.dart';
import 'package:aves/services/svg_metadata_service.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:latlong/latlong.dart';
import 'package:path/path.dart' as ppath;

import '../ref/mime_types.dart';

class AvesEntry {
  String uri;
  String _path, _directory, _filename, _extension;
  int pageId, contentId;
  final String sourceMimeType;
  int width;
  int height;
  int sourceRotationDegrees;
  final int sizeBytes;
  String sourceTitle;

  // `dateModifiedSecs` can be missing in viewer mode
  int _dateModifiedSecs;
  final int sourceDateTakenMillis;
  final int durationMillis;
  int _catalogDateMillis;
  CatalogMetadata _catalogMetadata;
  AddressDetails _addressDetails;

  final AChangeNotifier imageChangeNotifier = AChangeNotifier(), metadataChangeNotifier = AChangeNotifier(), addressChangeNotifier = AChangeNotifier();

  // Local geocoding requires Google Play Services
  // Google remote geocoding requires an API key and is not free
  final Future<List<Address>> Function(Coordinates coordinates) _findAddresses = Geocoder.local.findAddressesFromCoordinates;

  // TODO TLAD make it dynamic if it depends on OS/lib versions
  static const List<String> undecodable = [MimeTypes.crw, MimeTypes.psd];

  AvesEntry({
    this.uri,
    String path,
    this.contentId,
    this.pageId,
    this.sourceMimeType,
    @required this.width,
    @required this.height,
    this.sourceRotationDegrees,
    this.sizeBytes,
    this.sourceTitle,
    int dateModifiedSecs,
    this.sourceDateTakenMillis,
    this.durationMillis,
  })  : assert(width != null),
        assert(height != null) {
    this.path = path;
    this.dateModifiedSecs = dateModifiedSecs;
  }

  bool get canDecode => !undecodable.contains(mimeType);

  bool get canHaveAlpha => MimeTypes.alphaImages.contains(mimeType);

  AvesEntry copyWith({
    @required String uri,
    @required String path,
    @required int contentId,
    @required int dateModifiedSecs,
  }) {
    final copyContentId = contentId ?? this.contentId;
    final copied = AvesEntry(
      uri: uri ?? uri,
      path: path ?? this.path,
      contentId: copyContentId,
      sourceMimeType: sourceMimeType,
      width: width,
      height: height,
      sourceRotationDegrees: sourceRotationDegrees,
      sizeBytes: sizeBytes,
      sourceTitle: sourceTitle,
      dateModifiedSecs: dateModifiedSecs,
      sourceDateTakenMillis: sourceDateTakenMillis,
      durationMillis: durationMillis,
    )
      ..catalogMetadata = _catalogMetadata?.copyWith(contentId: copyContentId)
      ..addressDetails = _addressDetails?.copyWith(contentId: copyContentId);

    return copied;
  }

  AvesEntry getPageEntry(SinglePageInfo pageInfo, {bool eraseDefaultPageId = true}) {
    if (pageInfo == null) return this;

    // do not provide the page ID for the default page,
    // so that we can treat this page like the main entry
    // and retrieve cached images for it
    final pageId = eraseDefaultPageId && pageInfo.isDefault ? null : pageInfo.pageId;

    return AvesEntry(
      uri: uri,
      path: path,
      contentId: contentId,
      pageId: pageId,
      sourceMimeType: pageInfo.mimeType ?? sourceMimeType,
      width: pageInfo.width ?? width,
      height: pageInfo.height ?? height,
      sourceRotationDegrees: sourceRotationDegrees,
      sizeBytes: sizeBytes,
      sourceTitle: sourceTitle,
      dateModifiedSecs: dateModifiedSecs,
      sourceDateTakenMillis: sourceDateTakenMillis,
      durationMillis: pageInfo.durationMillis ?? durationMillis,
    )
      ..catalogMetadata = _catalogMetadata?.copyWith(
        mimeType: pageInfo.mimeType,
        isMultipage: false,
      )
      ..addressDetails = _addressDetails?.copyWith();
  }

  // from DB or platform source entry
  factory AvesEntry.fromMap(Map map) {
    return AvesEntry(
      uri: map['uri'] as String,
      path: map['path'] as String,
      contentId: map['contentId'] as int,
      sourceMimeType: map['sourceMimeType'] as String,
      width: map['width'] as int ?? 0,
      height: map['height'] as int ?? 0,
      sourceRotationDegrees: map['sourceRotationDegrees'] as int ?? 0,
      sizeBytes: map['sizeBytes'] as int,
      sourceTitle: map['title'] as String,
      dateModifiedSecs: map['dateModifiedSecs'] as int,
      sourceDateTakenMillis: map['sourceDateTakenMillis'] as int,
      durationMillis: map['durationMillis'] as int,
    );
  }

  // for DB only
  Map<String, dynamic> toMap() {
    return {
      'uri': uri,
      'path': path,
      'contentId': contentId,
      'sourceMimeType': sourceMimeType,
      'width': width,
      'height': height,
      'sourceRotationDegrees': sourceRotationDegrees,
      'sizeBytes': sizeBytes,
      'title': sourceTitle,
      'dateModifiedSecs': dateModifiedSecs,
      'sourceDateTakenMillis': sourceDateTakenMillis,
      'durationMillis': durationMillis,
    };
  }

  void dispose() {
    imageChangeNotifier.dispose();
    metadataChangeNotifier.dispose();
    addressChangeNotifier.dispose();
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AvesEntry && other.uri == uri && other.pageId == pageId && other._dateModifiedSecs == _dateModifiedSecs;
  }

  @override
  int get hashCode => hashValues(uri, pageId, _dateModifiedSecs);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, path=$path, pageId=$pageId}';

  set path(String path) {
    _path = path;
    _directory = null;
    _filename = null;
    _extension = null;
  }

  String get path => _path;

  String get directory {
    _directory ??= path != null ? ppath.dirname(path) : null;
    return _directory;
  }

  String get filenameWithoutExtension {
    _filename ??= path != null ? ppath.basenameWithoutExtension(path) : null;
    return _filename;
  }

  String get extension {
    _extension ??= path != null ? ppath.extension(path) : null;
    return _extension;
  }

  // the MIME type reported by the Media Store is unreliable
  // so we use the one found during cataloguing if possible
  String get mimeType => _catalogMetadata?.mimeType ?? sourceMimeType;

  String get mimeTypeAnySubtype => mimeType.replaceAll(RegExp('/.*'), '/*');

  bool get isFavourite => favourites.isFavourite(this);

  bool get isSvg => mimeType == MimeTypes.svg;

  // guess whether this is a photo, according to file type (used as a hint to e.g. display megapixels)
  bool get isPhoto => [MimeTypes.heic, MimeTypes.heif, MimeTypes.jpeg, MimeTypes.tiff].contains(mimeType) || isRaw;

  // Android's `BitmapRegionDecoder` documentation states that "only the JPEG and PNG formats are supported"
  // but in practice (tested on API 25, 27, 29), it successfully decodes the formats listed below,
  // and it actually fails to decode GIF, DNG and animated WEBP. Other formats were not tested.
  bool get _supportedByBitmapRegionDecoder =>
      [
        MimeTypes.heic,
        MimeTypes.heif,
        MimeTypes.jpeg,
        MimeTypes.webp,
        MimeTypes.arw,
        MimeTypes.cr2,
        MimeTypes.nef,
        MimeTypes.nrw,
        MimeTypes.orf,
        MimeTypes.pef,
        MimeTypes.raf,
        MimeTypes.rw2,
        MimeTypes.srw,
      ].contains(mimeType) &&
      !isAnimated;

  bool get supportTiling => _supportedByBitmapRegionDecoder || mimeType == MimeTypes.tiff;

  // as of panorama v0.3.1, the `Panorama` widget throws on initialization when the image is already resolved
  // so we use tiles for panoramas as a workaround to not collide with the `panorama` package resolution
  bool get useTiles => supportTiling && (width > 4096 || height > 4096 || is360);

  bool get isRaw => MimeTypes.rawImages.contains(mimeType);

  bool get isImage => MimeTypes.isImage(mimeType);

  bool get isVideo => MimeTypes.isVideo(mimeType);

  bool get isCatalogued => _catalogMetadata != null;

  bool get isAnimated => _catalogMetadata?.isAnimated ?? false;

  bool get isGeotiff => _catalogMetadata?.isGeotiff ?? false;

  bool get is360 => _catalogMetadata?.is360 ?? false;

  bool get isMultipage => _catalogMetadata?.isMultipage ?? false;

  bool get canEdit => path != null;

  bool get canRotateAndFlip => canEdit && canEditExif;

  // support for writing EXIF
  // as of androidx.exifinterface:exifinterface:1.3.0
  bool get canEditExif {
    switch (mimeType.toLowerCase()) {
      case MimeTypes.jpeg:
      case MimeTypes.png:
      case MimeTypes.webp:
        return true;
      default:
        return false;
    }
  }

  // Media Store size/rotation is inaccurate, e.g. a portrait FHD video is rotated according to its metadata,
  // so it should be registered as width=1920, height=1080, orientation=90,
  // but is incorrectly registered as width=1080, height=1920, orientation=0.
  // Double-checking the width/height during loading or cataloguing is the proper solution, but it would take space and time.
  // Comparing width and height can help with the portrait FHD video example,
  // but it fails for a portrait screenshot rotated, which is landscape with width=1080, height=1920, orientation=90
  bool get isRotated => rotationDegrees % 180 == 90;

  static const ratioSeparator = '\u2236';
  static const resolutionSeparator = ' \u00D7 ';

  String get resolutionText {
    final ws = width ?? '?';
    final hs = height ?? '?';
    return isRotated ? '$hs$resolutionSeparator$ws' : '$ws$resolutionSeparator$hs';
  }

  String get aspectRatioText {
    if (width != null && height != null && width > 0 && height > 0) {
      final gcd = width.gcd(height);
      final w = width ~/ gcd;
      final h = height ~/ gcd;
      return isRotated ? '$h$ratioSeparator$w' : '$w$ratioSeparator$h';
    } else {
      return '?$ratioSeparator?';
    }
  }

  double get displayAspectRatio {
    if (width == 0 || height == 0) return 1;
    return isRotated ? height / width : width / height;
  }

  Size get displaySize {
    final w = width.toDouble();
    final h = height.toDouble();
    return isRotated ? Size(h, w) : Size(w, h);
  }

  int get megaPixels => width != null && height != null ? (width * height / 1000000).round() : null;

  DateTime _bestDate;

  DateTime get bestDate {
    if (_bestDate == null) {
      if ((_catalogDateMillis ?? 0) > 0) {
        _bestDate = DateTime.fromMillisecondsSinceEpoch(_catalogDateMillis);
      } else if ((sourceDateTakenMillis ?? 0) > 0) {
        _bestDate = DateTime.fromMillisecondsSinceEpoch(sourceDateTakenMillis);
      } else if ((dateModifiedSecs ?? 0) > 0) {
        _bestDate = DateTime.fromMillisecondsSinceEpoch(dateModifiedSecs * 1000);
      }
    }
    return _bestDate;
  }

  int get rotationDegrees => _catalogMetadata?.rotationDegrees ?? sourceRotationDegrees ?? 0;

  set rotationDegrees(int rotationDegrees) {
    sourceRotationDegrees = rotationDegrees;
    _catalogMetadata?.rotationDegrees = rotationDegrees;
  }

  bool get isFlipped => _catalogMetadata?.isFlipped ?? false;

  set isFlipped(bool isFlipped) => _catalogMetadata?.isFlipped = isFlipped;

  int get dateModifiedSecs => _dateModifiedSecs;

  set dateModifiedSecs(int dateModifiedSecs) {
    _dateModifiedSecs = dateModifiedSecs;
    _bestDate = null;
  }

  DateTime get monthTaken {
    final d = bestDate;
    return d == null ? null : DateTime(d.year, d.month);
  }

  DateTime get dayTaken {
    final d = bestDate;
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  String _durationText;

  String get durationText {
    _durationText ??= formatDuration(Duration(milliseconds: durationMillis ?? 0));
    return _durationText;
  }

  bool get hasGps => isCatalogued && _catalogMetadata.latitude != null;

  bool get isLocated => _addressDetails != null;

  LatLng get latLng => hasGps ? LatLng(_catalogMetadata.latitude, _catalogMetadata.longitude) : null;

  String get geoUri {
    if (!hasGps) return null;
    final latitude = roundToPrecision(_catalogMetadata.latitude, decimals: 6);
    final longitude = roundToPrecision(_catalogMetadata.longitude, decimals: 6);
    return 'geo:$latitude,$longitude?q=$latitude,$longitude';
  }

  List<String> _xmpSubjects;

  List<String> get xmpSubjects {
    _xmpSubjects ??= _catalogMetadata?.xmpSubjects?.split(';')?.where((tag) => tag.isNotEmpty)?.toList() ?? [];
    return _xmpSubjects;
  }

  String _bestTitle;

  String get bestTitle {
    _bestTitle ??= (isCatalogued && _catalogMetadata.xmpTitleDescription?.isNotEmpty == true) ? _catalogMetadata.xmpTitleDescription : sourceTitle;
    return _bestTitle;
  }

  CatalogMetadata get catalogMetadata => _catalogMetadata;

  set catalogDateMillis(int dateMillis) {
    _catalogDateMillis = dateMillis;
    _bestDate = null;
  }

  set catalogMetadata(CatalogMetadata newMetadata) {
    final oldDateModifiedSecs = dateModifiedSecs;
    final oldRotationDegrees = rotationDegrees;
    final oldIsFlipped = isFlipped;

    catalogDateMillis = newMetadata?.dateMillis;
    _catalogMetadata = newMetadata;
    _bestTitle = null;
    _xmpSubjects = null;
    metadataChangeNotifier.notifyListeners();

    _onImageChanged(oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
  }

  void clearMetadata() {
    catalogMetadata = null;
    addressDetails = null;
  }

  Future<void> catalog({bool background = false}) async {
    if (isCatalogued) return;
    if (isSvg) {
      // vector image sizing is not essential, so we should not spend time for it during loading
      // but it is useful anyway (for aspect ratios etc.) so we size them during cataloguing
      final size = await SvgMetadataService.getSize(this);
      if (size != null) {
        await _applyNewFields({
          'width': size.width.round(),
          'height': size.height.round(),
        });
      }
      catalogMetadata = CatalogMetadata(contentId: contentId);
    } else {
      catalogMetadata = await MetadataService.getCatalogMetadata(this, background: background);
    }
  }

  AddressDetails get addressDetails => _addressDetails;

  set addressDetails(AddressDetails newAddress) {
    _addressDetails = newAddress;
    addressChangeNotifier.notifyListeners();
  }

  Future<void> locate({bool background = false}) async {
    if (isLocated) return;

    await catalog(background: background);
    final latitude = _catalogMetadata?.latitude;
    final longitude = _catalogMetadata?.longitude;
    if (latitude == null || longitude == null || (latitude == 0 && longitude == 0)) return;

    final coordinates = Coordinates(latitude, longitude);
    try {
      Future<List<Address>> call() => _findAddresses(coordinates);
      final addresses = await (background
          ? servicePolicy.call(
              call,
              priority: ServiceCallPriority.getLocation,
            )
          : call());
      if (addresses != null && addresses.isNotEmpty) {
        final address = addresses.first;
        final cc = address.countryCode;
        final cn = address.countryName;
        final aa = address.adminArea;
        addressDetails = AddressDetails(
          contentId: contentId,
          countryCode: cc,
          countryName: cn,
          adminArea: aa,
          // if country & admin fields are null, it is likely the ocean,
          // which is identified by `featureName` but we default to the address line anyway
          locality: address.locality ?? (cc == null && cn == null && aa == null ? address.addressLine : null),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('$runtimeType locate failed with path=$path coordinates=$coordinates error=$error\n$stackTrace');
    }
  }

  Future<String> findAddressLine() async {
    final latitude = _catalogMetadata?.latitude;
    final longitude = _catalogMetadata?.longitude;
    if (latitude == null || longitude == null || (latitude == 0 && longitude == 0)) return null;

    final coordinates = Coordinates(latitude, longitude);
    try {
      final addresses = await _findAddresses(coordinates);
      if (addresses != null && addresses.isNotEmpty) {
        final address = addresses.first;
        return address.addressLine;
      }
    } catch (error, stackTrace) {
      debugPrint('$runtimeType findAddressLine failed with path=$path coordinates=$coordinates error=$error\n$stackTrace');
    }
    return null;
  }

  String get shortAddress {
    if (!isLocated) return '';

    // `admin area` examples: Seoul, Geneva, null
    // `locality` examples: Mapo-gu, Geneva, Annecy
    return {
      _addressDetails.countryName,
      _addressDetails.adminArea,
      _addressDetails.locality,
    }.where((part) => part != null && part.isNotEmpty).join(', ');
  }

  bool search(String query) => {
        bestTitle,
        _catalogMetadata?.xmpSubjects,
        _addressDetails?.countryName,
        _addressDetails?.adminArea,
        _addressDetails?.locality,
      }.any((s) => s != null && s.toUpperCase().contains(query));

  Future<void> _applyNewFields(Map newFields) async {
    final uri = newFields['uri'];
    if (uri is String) this.uri = uri;
    final path = newFields['path'];
    if (path is String) this.path = path;
    final contentId = newFields['contentId'];
    if (contentId is int) this.contentId = contentId;
    final sourceTitle = newFields['title'];
    if (sourceTitle is String) {
      this.sourceTitle = sourceTitle;
      _bestTitle = null;
    }

    final width = newFields['width'];
    if (width is int) this.width = width;
    final height = newFields['height'];
    if (height is int) this.height = height;

    final dateModifiedSecs = newFields['dateModifiedSecs'];
    if (dateModifiedSecs is int) this.dateModifiedSecs = dateModifiedSecs;
    final rotationDegrees = newFields['rotationDegrees'];
    if (rotationDegrees is int) this.rotationDegrees = rotationDegrees;
    final isFlipped = newFields['isFlipped'];
    if (isFlipped is bool) this.isFlipped = isFlipped;

    await metadataDb.saveEntries({this});
    await metadataDb.saveMetadata({catalogMetadata});

    metadataChangeNotifier.notifyListeners();
  }

  Future<bool> rename(String newName) async {
    if (newName == filenameWithoutExtension) return true;

    final newFields = await ImageFileService.rename(this, '$newName$extension');
    if (newFields.isEmpty) return false;

    await _applyNewFields(newFields);
    return true;
  }

  Future<bool> rotate({@required bool clockwise}) async {
    final newFields = await ImageFileService.rotate(this, clockwise: clockwise);
    if (newFields.isEmpty) return false;

    final oldDateModifiedSecs = dateModifiedSecs;
    final oldRotationDegrees = rotationDegrees;
    final oldIsFlipped = isFlipped;
    await _applyNewFields(newFields);
    await _onImageChanged(oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
    return true;
  }

  Future<bool> flip() async {
    final newFields = await ImageFileService.flip(this);
    if (newFields.isEmpty) return false;

    final oldDateModifiedSecs = dateModifiedSecs;
    final oldRotationDegrees = rotationDegrees;
    final oldIsFlipped = isFlipped;
    await _applyNewFields(newFields);
    await _onImageChanged(oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
    return true;
  }

  Future<bool> delete() {
    Completer completer = Completer<bool>();
    ImageFileService.delete([this]).listen(
      (event) => completer.complete(event.success),
      onError: completer.completeError,
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );
    return completer.future;
  }

  // when the entry image itself changed (e.g. after rotation)
  void _onImageChanged(int oldDateModifiedSecs, int oldRotationDegrees, bool oldIsFlipped) async {
    if (oldDateModifiedSecs != dateModifiedSecs || oldRotationDegrees != rotationDegrees || oldIsFlipped != isFlipped) {
      await EntryCache.evict(uri, mimeType, oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
      imageChangeNotifier.notifyListeners();
    }
  }

  // favourites

  void toggleFavourite() {
    if (isFavourite) {
      removeFromFavourites();
    } else {
      addToFavourites();
    }
  }

  void addToFavourites() {
    if (!isFavourite) {
      favourites.add([this]);
    }
  }

  void removeFromFavourites() {
    if (isFavourite) {
      favourites.remove([this]);
    }
  }

  // compare by:
  // 1) title ascending
  // 2) extension ascending
  static int compareByName(AvesEntry a, AvesEntry b) {
    final c = compareAsciiUpperCase(a.bestTitle, b.bestTitle);
    return c != 0 ? c : compareAsciiUpperCase(a.extension, b.extension);
  }

  // compare by:
  // 1) size descending
  // 2) name ascending
  static int compareBySize(AvesEntry a, AvesEntry b) {
    final c = b.sizeBytes.compareTo(a.sizeBytes);
    return c != 0 ? c : compareByName(a, b);
  }

  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0);

  // compare by:
  // 1) date descending
  // 2) name descending
  static int compareByDate(AvesEntry a, AvesEntry b) {
    var c = (b.bestDate ?? _epoch).compareTo(a.bestDate ?? _epoch);
    if (c != 0) return c;
    c = (b.dateModifiedSecs ?? 0).compareTo(a.dateModifiedSecs ?? 0);
    if (c != 0) return c;
    return -compareByName(a, b);
  }
}
