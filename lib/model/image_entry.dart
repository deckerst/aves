import 'package:aves/model/image_file_service.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_service.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoder/geocoder.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';

import 'mime_types.dart';

class ImageEntry {
  String uri;
  String path;
  String directory;
  int contentId;
  final String mimeType;
  int width;
  int height;
  int orientationDegrees;
  final int sizeBytes;
  String title;
  final int dateModifiedSecs;
  final int sourceDateTakenMillis;
  final String bucketDisplayName;
  final int durationMillis;
  CatalogMetadata catalogMetadata;
  AddressDetails addressDetails;

  final AChangeNotifier imageChangeNotifier = AChangeNotifier(), metadataChangeNotifier = AChangeNotifier(), addressChangeNotifier = AChangeNotifier();

  ImageEntry({
    this.uri,
    this.path,
    this.contentId,
    this.mimeType,
    this.width,
    this.height,
    this.orientationDegrees,
    this.sizeBytes,
    this.title,
    this.dateModifiedSecs,
    this.sourceDateTakenMillis,
    this.bucketDisplayName,
    this.durationMillis,
  }) : directory = path != null ? dirname(path) : null;

  factory ImageEntry.fromMap(Map map) {
    return ImageEntry(
      uri: map['uri'] as String,
      path: map['path'] as String,
      contentId: map['contentId'] as int,
      mimeType: map['mimeType'] as String,
      width: map['width'] as int,
      height: map['height'] as int,
      orientationDegrees: map['orientationDegrees'] as int,
      sizeBytes: map['sizeBytes'] as int,
      title: map['title'] as String,
      dateModifiedSecs: map['dateModifiedSecs'] as int,
      sourceDateTakenMillis: map['sourceDateTakenMillis'] as int,
      bucketDisplayName: map['bucketDisplayName'] as String,
      durationMillis: map['durationMillis'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uri': uri,
      'path': path,
      'contentId': contentId,
      'mimeType': mimeType,
      'width': width,
      'height': height,
      'orientationDegrees': orientationDegrees,
      'sizeBytes': sizeBytes,
      'title': title,
      'dateModifiedSecs': dateModifiedSecs,
      'sourceDateTakenMillis': sourceDateTakenMillis,
      'bucketDisplayName': bucketDisplayName,
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

  String get filename => basenameWithoutExtension(path);

  String get mimeTypeAnySubtype => mimeType.replaceAll(RegExp('/.*'), '/*');

  bool get isGif => mimeType == MimeTypes.MIME_GIF;

  bool get isVideo => mimeType.startsWith(MimeTypes.MIME_VIDEO);

  bool get isCatalogued => catalogMetadata != null;

  bool get canPrint => !isVideo;

  bool get canRename => path != null;

  bool get canRotate => mimeType == MimeTypes.MIME_JPEG || mimeType == MimeTypes.MIME_PNG;

  double get aspectRatio {
    if (width == 0 || height == 0) return 1;
    if (isVideo && isCatalogued) {
      if (catalogMetadata.videoRotation % 180 == 90) return height / width;
    }
    return width / height;
  }

  int get megaPixels => width != null && height != null ? (width * height / 1000000).round() : null;

  DateTime get bestDate {
    if ((catalogMetadata?.dateMillis ?? 0) > 0) return DateTime.fromMillisecondsSinceEpoch(catalogMetadata.dateMillis);
    if (sourceDateTakenMillis != null && sourceDateTakenMillis > 0) return DateTime.fromMillisecondsSinceEpoch(sourceDateTakenMillis);
    if (dateModifiedSecs != null && dateModifiedSecs > 0) return DateTime.fromMillisecondsSinceEpoch(dateModifiedSecs * 1000);
    return null;
  }

  DateTime get monthTaken {
    final d = bestDate;
    return d == null ? null : DateTime(d.year, d.month);
  }

  DateTime get dayTaken {
    final d = bestDate;
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  String get durationText => formatDuration(Duration(milliseconds: durationMillis));

  bool get hasGps => isCatalogued && catalogMetadata.latitude != null;

  bool get isLocated => addressDetails != null;

  Tuple2<double, double> get latLng => isCatalogued ? Tuple2(catalogMetadata.latitude, catalogMetadata.longitude) : null;

  String get geoUri => hasGps ? 'geo:${catalogMetadata.latitude},${catalogMetadata.longitude}?q=${catalogMetadata.latitude},${catalogMetadata.longitude}' : null;

  List<String> get xmpSubjects => catalogMetadata?.xmpSubjects?.split(';')?.where((tag) => tag.isNotEmpty)?.toList() ?? [];

  Future<void> catalog() async {
    if (isCatalogued) return;
    catalogMetadata = await MetadataService.getCatalogMetadata(this);
    if (catalogMetadata != null) {
      metadataChangeNotifier.notifyListeners();
    }
  }

  Future<void> locate() async {
    if (isLocated) return;

    await catalog();
    final latitude = catalogMetadata?.latitude;
    final longitude = catalogMetadata?.longitude;
    if (latitude == null || longitude == null) return;

    final coordinates = Coordinates(latitude, longitude);
    try {
      final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      if (addresses != null && addresses.isNotEmpty) {
        final address = addresses.first;
        addressDetails = AddressDetails(
          contentId: contentId,
          addressLine: address.addressLine,
          countryName: address.countryName,
          adminArea: address.adminArea,
          locality: address.locality,
        );
        addressChangeNotifier.notifyListeners();
      }
    } catch (exception) {
      debugPrint('$runtimeType addAddressToMetadata failed with path=$path coordinates=$coordinates exception=$exception');
    }
  }

  String get shortAddress {
    if (!isLocated) return '';

    // admin area examples: Seoul, Geneva, null
    // locality examples: Mapo-gu, Geneva, Annecy
    return {
      addressDetails.countryName,
      addressDetails.adminArea,
      addressDetails.locality,
    }.where((part) => part != null && part.isNotEmpty).join(', ');
  }

  bool search(String query) {
    if (title.toLowerCase().contains(query)) return true;
    if (catalogMetadata?.xmpSubjects?.toLowerCase()?.contains(query) ?? false) return true;
    if (isLocated && addressDetails.addressLine.toLowerCase().contains(query)) return true;
    return false;
  }

  Future<bool> rename(String newName) async {
    if (newName == filename) return true;

    final newFields = await ImageFileService.rename(this, '$newName${extension(this.path)}');
    if (newFields.isEmpty) return false;

    final uri = newFields['uri'];
    if (uri is String) this.uri = uri;
    final path = newFields['path'];
    if (path is String) this.path = path;
    final contentId = newFields['contentId'];
    if (contentId is int) this.contentId = contentId;
    final title = newFields['title'];
    if (title is String) this.title = title;
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

  Future<bool> delete() => ImageFileService.delete(this);
}
