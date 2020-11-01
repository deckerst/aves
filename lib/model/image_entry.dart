import 'dart:async';

import 'package:aves/model/entry_cache.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/services/service_policy.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:path/path.dart' as ppath;
import 'package:tuple/tuple.dart';

import 'mime_types.dart';

class ImageEntry {
  String uri;
  String _path, _directory, _filename, _extension;
  int contentId;
  final String sourceMimeType;
  int width;
  int height;
  int sourceRotationDegrees;
  final int sizeBytes;
  String sourceTitle;
  int _dateModifiedSecs;
  final int sourceDateTakenMillis;
  final int durationMillis;
  int _catalogDateMillis;
  CatalogMetadata _catalogMetadata;
  AddressDetails _addressDetails;

  final AChangeNotifier imageChangeNotifier = AChangeNotifier(), metadataChangeNotifier = AChangeNotifier(), addressChangeNotifier = AChangeNotifier();

  ImageEntry({
    this.uri,
    String path,
    this.contentId,
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

  bool get canDecode => !MimeTypes.undecodable.contains(mimeType);

  ImageEntry copyWith({
    @required String uri,
    @required String path,
    @required int contentId,
    @required int dateModifiedSecs,
  }) {
    final copyContentId = contentId ?? this.contentId;
    final copied = ImageEntry(
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

  // from DB or platform source entry
  factory ImageEntry.fromMap(Map map) {
    return ImageEntry(
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
  String toString() {
    return 'ImageEntry{uri=$uri, path=$path}';
  }

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
  bool get isPhoto => [MimeTypes.heic, MimeTypes.heif, MimeTypes.jpeg].contains(mimeType) || isRaw;

  bool get isRaw => MimeTypes.rawImages.contains(mimeType);

  bool get isVideo => mimeType.startsWith('video');

  bool get isCatalogued => _catalogMetadata != null;

  bool get isAnimated => _catalogMetadata?.isAnimated ?? false;

  bool get canEdit => path != null;

  bool get canPrint => !isVideo;

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

  bool get isPortrait => rotationDegrees % 180 == 90;

  String get resolutionText {
    final w = width ?? '?';
    final h = height ?? '?';
    return isPortrait ? '$h × $w' : '$w × $h';
  }

  double get displayAspectRatio {
    if (width == 0 || height == 0) return 1;
    return isPortrait ? height / width : width / height;
  }

  Size get displaySize => isPortrait ? Size(height.toDouble(), width.toDouble()) : Size(width.toDouble(), height.toDouble());

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

  Tuple2<double, double> get latLng => isCatalogued ? Tuple2(_catalogMetadata.latitude, _catalogMetadata.longitude) : null;

  String get geoUri => hasGps ? 'geo:${_catalogMetadata.latitude},${_catalogMetadata.longitude}?q=${_catalogMetadata.latitude},${_catalogMetadata.longitude}' : null;

  List<String> get xmpSubjects => _catalogMetadata?.xmpSubjects?.split(';')?.where((tag) => tag.isNotEmpty)?.toList() ?? [];

  String _bestTitle;

  String get bestTitle {
    _bestTitle ??= (isCatalogued && _catalogMetadata.xmpTitleDescription.isNotEmpty) ? _catalogMetadata.xmpTitleDescription : sourceTitle;
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
    metadataChangeNotifier.notifyListeners();

    _onImageChanged(oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
  }

  void clearMetadata() {
    catalogMetadata = null;
    addressDetails = null;
  }

  Future<void> catalog({bool background = false}) async {
    if (isCatalogued) return;
    catalogMetadata = await MetadataService.getCatalogMetadata(this, background: background);
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
      Future<List<Address>> call() => Geocoder.local.findAddressesFromCoordinates(coordinates);
      final addresses = await (background
          ? servicePolicy.call(
              call,
              priority: ServiceCallPriority.getLocation,
            )
          : call());
      if (addresses != null && addresses.isNotEmpty) {
        final address = addresses.first;
        addressDetails = AddressDetails(
          contentId: contentId,
          addressLine: address.addressLine,
          countryCode: address.countryCode,
          countryName: address.countryName,
          adminArea: address.adminArea,
          locality: address.locality,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('$runtimeType locate failed with path=$path coordinates=$coordinates error=$error\n$stackTrace');
    }
  }

  String get shortAddress {
    if (!isLocated) return '';

    // admin area examples: Seoul, Geneva, null
    // locality examples: Mapo-gu, Geneva, Annecy
    return {
      _addressDetails.countryName,
      _addressDetails.adminArea,
      _addressDetails.locality,
    }.where((part) => part != null && part.isNotEmpty).join(', ');
  }

  bool search(String query) {
    if (bestTitle?.toUpperCase()?.contains(query) ?? false) return true;
    if (_catalogMetadata?.xmpSubjects?.toUpperCase()?.contains(query) ?? false) return true;
    if (_addressDetails?.addressLine?.toUpperCase()?.contains(query) ?? false) return true;
    return false;
  }

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
  static int compareByName(ImageEntry a, ImageEntry b) {
    final c = compareAsciiUpperCase(a.bestTitle, b.bestTitle);
    return c != 0 ? c : compareAsciiUpperCase(a.extension, b.extension);
  }

  // compare by:
  // 1) size descending
  // 2) name ascending
  static int compareBySize(ImageEntry a, ImageEntry b) {
    final c = b.sizeBytes.compareTo(a.sizeBytes);
    return c != 0 ? c : compareByName(a, b);
  }

  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0);

  // compare by:
  // 1) date descending
  // 2) name ascending
  static int compareByDate(ImageEntry a, ImageEntry b) {
    final c = (b.bestDate ?? _epoch).compareTo(a.bestDate ?? _epoch);
    return c != 0 ? c : compareByName(a, b);
  }
}
