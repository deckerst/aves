import 'dart:async';

import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/services/service_policy.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/utils/time_utils.dart';
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
  int orientationDegrees;
  final int sizeBytes;
  String sourceTitle;
  final int dateModifiedSecs;
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
    this.orientationDegrees,
    this.sizeBytes,
    this.sourceTitle,
    this.dateModifiedSecs,
    this.sourceDateTakenMillis,
    this.durationMillis,
  })  : assert(width != null),
        assert(height != null) {
    this.path = path;
  }

  ImageEntry copyWith({
    @required String uri,
    @required String path,
    @required int contentId,
  }) {
    final copyContentId = contentId ?? this.contentId;
    final copied = ImageEntry(
      uri: uri ?? uri,
      path: path ?? this.path,
      contentId: copyContentId,
      sourceMimeType: sourceMimeType,
      width: width,
      height: height,
      orientationDegrees: orientationDegrees,
      sizeBytes: sizeBytes,
      sourceTitle: sourceTitle,
      dateModifiedSecs: dateModifiedSecs,
      sourceDateTakenMillis: sourceDateTakenMillis,
      durationMillis: durationMillis,
    )
      .._catalogMetadata = _catalogMetadata?.copyWith(contentId: copyContentId)
      .._addressDetails = _addressDetails?.copyWith(contentId: copyContentId);

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
      orientationDegrees: map['orientationDegrees'] as int,
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
      'orientationDegrees': orientationDegrees,
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
  String get mimeType => catalogMetadata?.mimeType ?? sourceMimeType;

  String get mimeTypeAnySubtype => mimeType.replaceAll(RegExp('/.*'), '/*');

  bool get isFavourite => favourites.isFavourite(this);

  bool get isSvg => mimeType == MimeTypes.svg;

  // guess whether this is a photo, according to file type (used as a hint to e.g. display megapixels)
  bool get isPhoto => [MimeTypes.heic, MimeTypes.heif, MimeTypes.jpeg].contains(mimeType) || isRaw;

  bool get isRaw => [MimeTypes.dng].contains(mimeType);

  bool get isVideo => mimeType.startsWith('video');

  bool get isCatalogued => _catalogMetadata != null;

  bool get isAnimated => _catalogMetadata?.isAnimated ?? false;

  bool get canEdit => path != null;

  bool get canPrint => !isVideo;

  bool get canRotate => canEdit && (mimeType == MimeTypes.jpeg || mimeType == MimeTypes.png);

  bool get rotated => ((isVideo && isCatalogued) ? _catalogMetadata.videoRotation : orientationDegrees) % 180 == 90;

  double get displayAspectRatio {
    if (width == 0 || height == 0) return 1;
    return rotated ? height / width : width / height;
  }

  Size get displaySize => rotated ? Size(height.toDouble(), width.toDouble()) : Size(width.toDouble(), height.toDouble());

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
    _bestTitle ??= (_catalogMetadata != null && _catalogMetadata.xmpTitleDescription.isNotEmpty) ? _catalogMetadata.xmpTitleDescription : sourceTitle;
    return _bestTitle;
  }

  CatalogMetadata get catalogMetadata => _catalogMetadata;

  set catalogDateMillis(int dateMillis) {
    _catalogDateMillis = dateMillis;
    _bestDate = null;
  }

  set catalogMetadata(CatalogMetadata newMetadata) {
    catalogDateMillis = newMetadata?.dateMillis;
    _catalogMetadata = newMetadata;
    _bestTitle = null;
    metadataChangeNotifier.notifyListeners();
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
    } catch (exception, stack) {
      debugPrint('$runtimeType locate failed with path=$path coordinates=$coordinates exception=$exception\n$stack');
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

  Future<bool> rename(String newName) async {
    if (newName == filenameWithoutExtension) return true;

    final newFields = await ImageFileService.rename(this, '$newName$extension');
    if (newFields.isEmpty) return false;

    final uri = newFields['uri'];
    if (uri is String) this.uri = uri;
    final path = newFields['path'];
    if (path is String) this.path = path;
    final contentId = newFields['contentId'];
    if (contentId is int) this.contentId = contentId;
    final sourceTitle = newFields['title'];
    if (sourceTitle is String) this.sourceTitle = sourceTitle;
    _bestTitle = null;
    metadataChangeNotifier.notifyListeners();
    return true;
  }

  Future<bool> rotate({@required bool clockwise}) async {
    final newFields = await ImageFileService.rotate(this, clockwise: clockwise);
    if (newFields.isEmpty) return false;

    final width = newFields['width'];
    if (width is int) this.width = width;
    final height = newFields['height'];
    if (height is int) this.height = height;
    final orientationDegrees = newFields['orientationDegrees'];
    if (orientationDegrees is int) this.orientationDegrees = orientationDegrees;

    imageChangeNotifier.notifyListeners();
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
}
