import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:aves/geo/countries.dart';
import 'package:aves/model/entry_cache.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/video/metadata.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/service_policy.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/geocoding_service.dart';
import 'package:aves/services/metadata/svg_metadata_service.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:collection/collection.dart';
import 'package:country_code/country_code.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

enum EntryDataType { basic, catalog, address, references }

class AvesEntry {
  String uri;
  String? _path, _directory, _filename, _extension;
  int? pageId, contentId;
  final String sourceMimeType;
  int width;
  int height;
  int sourceRotationDegrees;
  int? sizeBytes;
  String? _sourceTitle;

  // `dateModifiedSecs` can be missing in viewer mode
  int? _dateModifiedSecs;
  int? sourceDateTakenMillis;
  int? _durationMillis;
  int? _catalogDateMillis;
  CatalogMetadata? _catalogMetadata;
  AddressDetails? _addressDetails;

  List<AvesEntry>? burstEntries;

  final AChangeNotifier imageChangeNotifier = AChangeNotifier(), metadataChangeNotifier = AChangeNotifier(), addressChangeNotifier = AChangeNotifier();

  AvesEntry({
    required this.uri,
    required String? path,
    required this.contentId,
    required this.pageId,
    required this.sourceMimeType,
    required this.width,
    required this.height,
    required this.sourceRotationDegrees,
    required this.sizeBytes,
    required String? sourceTitle,
    required int? dateModifiedSecs,
    required this.sourceDateTakenMillis,
    required int? durationMillis,
    this.burstEntries,
  }) {
    this.path = path;
    this.sourceTitle = sourceTitle;
    this.dateModifiedSecs = dateModifiedSecs;
    this.durationMillis = durationMillis;
  }

  bool get canDecode => !MimeTypes.undecodableImages.contains(mimeType);

  bool get canHaveAlpha => MimeTypes.alphaImages.contains(mimeType);

  AvesEntry copyWith({
    String? uri,
    String? path,
    int? contentId,
    String? title,
    int? dateModifiedSecs,
    List<AvesEntry>? burstEntries,
  }) {
    final copyContentId = contentId ?? this.contentId;
    final copied = AvesEntry(
      uri: uri ?? this.uri,
      path: path ?? this.path,
      contentId: copyContentId,
      pageId: null,
      sourceMimeType: sourceMimeType,
      width: width,
      height: height,
      sourceRotationDegrees: sourceRotationDegrees,
      sizeBytes: sizeBytes,
      sourceTitle: title ?? sourceTitle,
      dateModifiedSecs: dateModifiedSecs ?? this.dateModifiedSecs,
      sourceDateTakenMillis: sourceDateTakenMillis,
      durationMillis: durationMillis,
      burstEntries: burstEntries ?? this.burstEntries,
    )
      ..catalogMetadata = _catalogMetadata?.copyWith(contentId: copyContentId)
      ..addressDetails = _addressDetails?.copyWith(contentId: copyContentId);

    return copied;
  }

  // from DB or platform source entry
  factory AvesEntry.fromMap(Map map) {
    return AvesEntry(
      uri: map['uri'] as String,
      path: map['path'] as String?,
      pageId: null,
      contentId: map['contentId'] as int?,
      sourceMimeType: map['sourceMimeType'] as String,
      width: map['width'] as int? ?? 0,
      height: map['height'] as int? ?? 0,
      sourceRotationDegrees: map['sourceRotationDegrees'] as int? ?? 0,
      sizeBytes: map['sizeBytes'] as int?,
      sourceTitle: map['title'] as String?,
      dateModifiedSecs: map['dateModifiedSecs'] as int?,
      sourceDateTakenMillis: map['sourceDateTakenMillis'] as int?,
      durationMillis: map['durationMillis'] as int?,
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

  // do not implement [Object.==] and [Object.hashCode] using mutable attributes (e.g. `uri`)
  // so that we can reliably use instances in a `Set`, which requires consistent hash codes over time

  @override
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, path=$path, pageId=$pageId}';

  set path(String? path) {
    _path = path;
    _directory = null;
    _filename = null;
    _extension = null;
  }

  String? get path => _path;

  // directory path, without the trailing separator
  String? get directory {
    _directory ??= path != null ? pContext.dirname(path!) : null;
    return _directory;
  }

  String? get filenameWithoutExtension {
    _filename ??= path != null ? pContext.basenameWithoutExtension(path!) : null;
    return _filename;
  }

  // file extension, including the `.`
  String? get extension {
    _extension ??= path != null ? pContext.extension(path!) : null;
    return _extension;
  }

  bool get isMissingAtPath => path != null && !File(path!).existsSync();

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

  bool get useTiles => supportTiling && (width > 4096 || height > 4096);

  bool get isRaw => MimeTypes.rawImages.contains(mimeType);

  bool get isImage => MimeTypes.isImage(mimeType);

  bool get isVideo => MimeTypes.isVideo(mimeType);

  bool get isCatalogued => _catalogMetadata != null;

  bool get isAnimated => _catalogMetadata?.isAnimated ?? false;

  bool get isGeotiff => _catalogMetadata?.isGeotiff ?? false;

  bool get is360 => _catalogMetadata?.is360 ?? false;

  bool get canEdit => path != null;

  bool get canEditDate => canEdit && (canEditExif || canEditXmp);

  bool get canEditRating => canEdit && canEditXmp;

  bool get canEditTags => canEdit && canEditXmp;

  bool get canRotateAndFlip => canEdit && canEditExif;

  // as of androidx.exifinterface:exifinterface:1.3.3
  bool get canEditExif {
    switch (mimeType.toLowerCase()) {
      case MimeTypes.dng:
      case MimeTypes.jpeg:
      case MimeTypes.png:
      case MimeTypes.webp:
        return true;
      default:
        return false;
    }
  }

  // as of latest PixyMeta
  bool get canEditIptc {
    switch (mimeType.toLowerCase()) {
      case MimeTypes.jpeg:
      case MimeTypes.tiff:
        return true;
      default:
        return false;
    }
  }

  // as of latest PixyMeta
  bool get canEditXmp {
    switch (mimeType.toLowerCase()) {
      case MimeTypes.gif:
      case MimeTypes.jpeg:
      case MimeTypes.png:
      case MimeTypes.tiff:
        return true;
      default:
        return false;
    }
  }

  // as of latest PixyMeta
  bool get canRemoveMetadata {
    switch (mimeType.toLowerCase()) {
      case MimeTypes.jpeg:
      case MimeTypes.tiff:
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

  bool get isSized => width > 0 && height > 0;

  String get resolutionText {
    final ws = width;
    final hs = height;
    return isRotated ? '$hs$resolutionSeparator$ws' : '$ws$resolutionSeparator$hs';
  }

  String get aspectRatioText {
    if (width > 0 && height > 0) {
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

  Size videoDisplaySize(double sar) {
    final size = displaySize;
    if (sar != 1) {
      final dar = displayAspectRatio * sar;
      final w = size.width;
      final h = size.height;
      if (w >= h) return Size(w, w / dar);
      if (h > w) return Size(h * dar, h);
    }
    return size;
  }

  int get megaPixels => (width * height / 1000000).round();

  DateTime? _bestDate;

  DateTime? get bestDate {
    if (_bestDate == null) {
      try {
        if ((_catalogDateMillis ?? 0) > 0) {
          _bestDate = DateTime.fromMillisecondsSinceEpoch(_catalogDateMillis!);
        } else if ((sourceDateTakenMillis ?? 0) > 0) {
          _bestDate = DateTime.fromMillisecondsSinceEpoch(sourceDateTakenMillis!);
        } else if ((dateModifiedSecs ?? 0) > 0) {
          _bestDate = DateTime.fromMillisecondsSinceEpoch(dateModifiedSecs! * 1000);
        }
      } catch (e, stack) {
        // date millis may be out of range
        reportService.recordError(e, stack);
      }
    }
    return _bestDate;
  }

  int get rating => _catalogMetadata?.rating ?? 0;

  int get rotationDegrees => _catalogMetadata?.rotationDegrees ?? sourceRotationDegrees;

  set rotationDegrees(int rotationDegrees) {
    sourceRotationDegrees = rotationDegrees;
    _catalogMetadata?.rotationDegrees = rotationDegrees;
  }

  bool get isFlipped => _catalogMetadata?.isFlipped ?? false;

  set isFlipped(bool isFlipped) => _catalogMetadata?.isFlipped = isFlipped;

  String? get sourceTitle => _sourceTitle;

  set sourceTitle(String? sourceTitle) {
    _sourceTitle = sourceTitle;
    _bestTitle = null;
  }

  int? get dateModifiedSecs => _dateModifiedSecs;

  set dateModifiedSecs(int? dateModifiedSecs) {
    _dateModifiedSecs = dateModifiedSecs;
    _bestDate = null;
  }

  // TODO TLAD cache _monthTaken
  DateTime? get monthTaken {
    final d = bestDate;
    return d == null ? null : DateTime(d.year, d.month);
  }

  // TODO TLAD cache _dayTaken
  DateTime? get dayTaken {
    final d = bestDate;
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  int? get durationMillis => _durationMillis;

  set durationMillis(int? durationMillis) {
    _durationMillis = durationMillis;
    _durationText = null;
  }

  String? _durationText;

  String get durationText {
    _durationText ??= formatFriendlyDuration(Duration(milliseconds: durationMillis ?? 0));
    return _durationText!;
  }

  // returns whether this entry has GPS coordinates
  // (0, 0) coordinates are considered invalid, as it is likely a default value
  bool get hasGps => (_catalogMetadata?.latitude ?? 0) != 0 || (_catalogMetadata?.longitude ?? 0) != 0;

  bool get hasAddress => _addressDetails != null;

  // has a place, or at least the full country name
  // derived from Google reverse geocoding addresses
  bool get hasFineAddress => _addressDetails?.place?.isNotEmpty == true || (_addressDetails?.countryName?.length ?? 0) > 3;

  LatLng? get latLng => hasGps ? LatLng(_catalogMetadata!.latitude!, _catalogMetadata!.longitude!) : null;

  Set<String>? _tags;

  Set<String> get tags {
    _tags ??= _catalogMetadata?.xmpSubjects?.split(';').where((tag) => tag.isNotEmpty).toSet() ?? {};
    return _tags!;
  }

  String? _bestTitle;

  String? get bestTitle {
    _bestTitle ??= _catalogMetadata?.xmpTitleDescription?.isNotEmpty == true ? _catalogMetadata!.xmpTitleDescription : sourceTitle;
    return _bestTitle;
  }

  int? get catalogDateMillis => _catalogDateMillis;

  set catalogDateMillis(int? dateMillis) {
    _catalogDateMillis = dateMillis;
    _bestDate = null;
  }

  CatalogMetadata? get catalogMetadata => _catalogMetadata;

  set catalogMetadata(CatalogMetadata? newMetadata) {
    final oldMimeType = mimeType;
    final oldDateModifiedSecs = dateModifiedSecs;
    final oldRotationDegrees = rotationDegrees;
    final oldIsFlipped = isFlipped;

    catalogDateMillis = newMetadata?.dateMillis;
    _catalogMetadata = newMetadata;
    _bestTitle = null;
    _tags = null;
    metadataChangeNotifier.notify();

    _onVisualFieldChanged(oldMimeType, oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
  }

  void clearMetadata() {
    catalogMetadata = null;
    addressDetails = null;
  }

  Future<void> catalog({required bool background, required bool force, required bool persist}) async {
    if (isCatalogued && !force) return;
    if (isSvg) {
      // vector image sizing is not essential, so we should not spend time for it during loading
      // but it is useful anyway (for aspect ratios etc.) so we size them during cataloguing
      final size = await SvgMetadataService.getSize(this);
      if (size != null) {
        final fields = {
          'width': size.width.ceil(),
          'height': size.height.ceil(),
        };
        await applyNewFields(fields, persist: persist);
      }
      catalogMetadata = CatalogMetadata(contentId: contentId);
    } else {
      if (isVideo && (!isSized || durationMillis == 0)) {
        // exotic video that is not sized during loading
        final fields = await VideoMetadataFormatter.getLoadingMetadata(this);
        await applyNewFields(fields, persist: persist);
      }
      catalogMetadata = await metadataFetchService.getCatalogMetadata(this, background: background);

      if (isVideo && (catalogMetadata?.dateMillis ?? 0) == 0) {
        catalogMetadata = await VideoMetadataFormatter.getCatalogMetadata(this);
      }
    }
  }

  AddressDetails? get addressDetails => _addressDetails;

  set addressDetails(AddressDetails? newAddress) {
    _addressDetails = newAddress;
    addressChangeNotifier.notify();
  }

  Future<void> locate({required bool background, required bool force, required Locale geocoderLocale}) async {
    if (!hasGps) return;
    await _locateCountry(force: force);
    if (await availability.canLocatePlaces) {
      await locatePlace(background: background, force: force, geocoderLocale: geocoderLocale);
    }
  }

  // quick reverse geocoding to find the country, using an offline asset
  Future<void> _locateCountry({required bool force}) async {
    if (!hasGps || (hasAddress && !force)) return;
    final countryCode = await countryTopology.countryCode(latLng!);
    setCountry(countryCode);
  }

  void setCountry(CountryCode? countryCode) {
    if (hasFineAddress || countryCode == null) return;
    addressDetails = AddressDetails(
      contentId: contentId,
      countryCode: countryCode.alpha2,
      countryName: countryCode.alpha3,
    );
  }

  // full reverse geocoding, requiring Play Services and some connectivity
  Future<void> locatePlace({required bool background, required bool force, required Locale geocoderLocale}) async {
    if (!hasGps || (hasFineAddress && !force)) return;
    try {
      Future<List<Address>> call() => GeocodingService.getAddress(latLng!, geocoderLocale);
      final addresses = await (background
          ? servicePolicy.call(
              call,
              priority: ServiceCallPriority.getLocation,
            )
          : call());
      if (addresses.isNotEmpty) {
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
    } catch (error, stack) {
      debugPrint('$runtimeType locate failed with path=$path coordinates=$latLng error=$error\n$stack');
    }
  }

  Future<String?> findAddressLine({required Locale geocoderLocale}) async {
    if (!hasGps) return null;

    try {
      final addresses = await GeocodingService.getAddress(latLng!, geocoderLocale);
      if (addresses.isNotEmpty) {
        final address = addresses.first;
        return address.addressLine;
      }
    } catch (error, stack) {
      debugPrint('$runtimeType findAddressLine failed with path=$path coordinates=$latLng error=$error\n$stack');
    }
    return null;
  }

  String get shortAddress {
    // `admin area` examples: Seoul, Geneva, null
    // `locality` examples: Mapo-gu, Geneva, Annecy
    return {
      _addressDetails?.countryName,
      _addressDetails?.adminArea,
      _addressDetails?.locality,
    }.whereNotNull().where((v) => v.isNotEmpty).join(', ');
  }

  Future<void> applyNewFields(Map newFields, {required bool persist}) async {
    final oldMimeType = mimeType;
    final oldDateModifiedSecs = this.dateModifiedSecs;
    final oldRotationDegrees = this.rotationDegrees;
    final oldIsFlipped = this.isFlipped;

    final uri = newFields['uri'];
    if (uri is String) this.uri = uri;
    final path = newFields['path'];
    if (path is String) this.path = path;
    final contentId = newFields['contentId'];
    if (contentId is int) this.contentId = contentId;

    final sourceTitle = newFields['title'];
    if (sourceTitle is String) this.sourceTitle = sourceTitle;
    final sourceRotationDegrees = newFields['sourceRotationDegrees'];
    if (sourceRotationDegrees is int) this.sourceRotationDegrees = sourceRotationDegrees;
    final sourceDateTakenMillis = newFields['sourceDateTakenMillis'];
    if (sourceDateTakenMillis is int) this.sourceDateTakenMillis = sourceDateTakenMillis;

    final width = newFields['width'];
    if (width is int) this.width = width;
    final height = newFields['height'];
    if (height is int) this.height = height;
    final durationMillis = newFields['durationMillis'];
    if (durationMillis is int) this.durationMillis = durationMillis;

    final sizeBytes = newFields['sizeBytes'];
    if (sizeBytes is int) this.sizeBytes = sizeBytes;
    final dateModifiedSecs = newFields['dateModifiedSecs'];
    if (dateModifiedSecs is int) this.dateModifiedSecs = dateModifiedSecs;
    final rotationDegrees = newFields['rotationDegrees'];
    if (rotationDegrees is int) this.rotationDegrees = rotationDegrees;
    final isFlipped = newFields['isFlipped'];
    if (isFlipped is bool) this.isFlipped = isFlipped;

    if (persist) {
      await metadataDb.saveEntries({this});
      if (catalogMetadata != null) await metadataDb.saveMetadata({catalogMetadata!});
    }

    await _onVisualFieldChanged(oldMimeType, oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
    metadataChangeNotifier.notify();
  }

  Future<void> refresh({
    required bool background,
    required bool persist,
    required Set<EntryDataType> dataTypes,
    required Locale geocoderLocale,
  }) async {
    // clear derived fields
    _bestDate = null;
    _bestTitle = null;
    _tags = null;

    if (persist) {
      await metadataDb.removeIds({contentId!}, dataTypes: dataTypes);
    }

    final updatedEntry = await mediaFileService.getEntry(uri, mimeType);
    if (updatedEntry != null) {
      await applyNewFields(updatedEntry.toMap(), persist: persist);
    }
    await catalog(background: background, force: dataTypes.contains(EntryDataType.catalog), persist: persist);
    await locate(background: background, force: dataTypes.contains(EntryDataType.address), geocoderLocale: geocoderLocale);
  }

  Future<bool> delete() {
    final completer = Completer<bool>();
    mediaFileService.delete(entries: {this}).listen(
      (event) => completer.complete(event.success && !event.skipped),
      onError: completer.completeError,
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );
    return completer.future;
  }

  // when the MIME type or the image itself changed (e.g. after rotation)
  Future<void> _onVisualFieldChanged(String oldMimeType, int? oldDateModifiedSecs, int oldRotationDegrees, bool oldIsFlipped) async {
    if ((!MimeTypes.refersToSameType(oldMimeType, mimeType) && !MimeTypes.isVideo(oldMimeType)) || oldDateModifiedSecs != dateModifiedSecs || oldRotationDegrees != rotationDegrees || oldIsFlipped != isFlipped) {
      await EntryCache.evict(uri, oldMimeType, oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
      imageChangeNotifier.notify();
    }
  }

  // favourites

  Future<void> toggleFavourite() async {
    if (isFavourite) {
      await removeFromFavourites();
    } else {
      await addToFavourites();
    }
  }

  Future<void> addToFavourites() async {
    if (!isFavourite) {
      await favourites.add({this});
    }
  }

  Future<void> removeFromFavourites() async {
    if (isFavourite) {
      await favourites.remove({this});
    }
  }

  // multipage

  static final _burstFilenamePattern = RegExp(r'^(\d{8}_\d{6})_(\d+)$');

  bool get isMultiPage => (_catalogMetadata?.isMultiPage ?? false) || isBurst;

  bool get isBurst => burstEntries?.isNotEmpty == true;

  bool get isMotionPhoto => isMultiPage && !isBurst && mimeType == MimeTypes.jpeg;

  String? get burstKey {
    if (filenameWithoutExtension != null) {
      final match = _burstFilenamePattern.firstMatch(filenameWithoutExtension!);
      if (match != null) {
        return '$directory/${match.group(1)}';
      }
    }
    return null;
  }

  Future<MultiPageInfo?> getMultiPageInfo() async {
    if (isBurst) {
      return MultiPageInfo(
        mainEntry: this,
        pages: burstEntries!
            .mapIndexed((index, entry) => SinglePageInfo(
                  index: index,
                  pageId: entry.contentId!,
                  isDefault: index == 0,
                  uri: entry.uri,
                  mimeType: entry.mimeType,
                  width: entry.width,
                  height: entry.height,
                  rotationDegrees: entry.rotationDegrees,
                  durationMillis: entry.durationMillis,
                ))
            .toList(),
      );
    } else {
      return await metadataFetchService.getMultiPageInfo(this);
    }
  }

  // sort

  // compare by:
  // 1) title ascending
  // 2) extension ascending
  static int compareByName(AvesEntry a, AvesEntry b) {
    final c = compareAsciiUpperCase(a.bestTitle ?? '', b.bestTitle ?? '');
    return c != 0 ? c : compareAsciiUpperCase(a.extension ?? '', b.extension ?? '');
  }

  // compare by:
  // 1) date descending
  // 2) name descending
  static int compareByDate(AvesEntry a, AvesEntry b) {
    var c = (b.bestDate ?? epoch).compareTo(a.bestDate ?? epoch);
    if (c != 0) return c;
    return compareByName(b, a);
  }

  // compare by:
  // 1) rating descending
  // 2) date descending
  static int compareByRating(AvesEntry a, AvesEntry b) {
    final c = b.rating.compareTo(a.rating);
    return c != 0 ? c : compareByDate(a, b);
  }

  // compare by:
  // 1) size descending
  // 2) date descending
  static int compareBySize(AvesEntry a, AvesEntry b) {
    final c = (b.sizeBytes ?? 0).compareTo(a.sizeBytes ?? 0);
    return c != 0 ? c : compareByDate(a, b);
  }
}
