import 'dart:collection';

import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:tuple/tuple.dart';

import 'mime_types.dart';

class ImageEntry with ChangeNotifier {
  final String uri;
  final String path;
  final int contentId;
  final String mimeType;
  final int width;
  final int height;
  final int orientationDegrees;
  final int sizeBytes;
  final String title;
  final int dateModifiedSecs;
  final int sourceDateTakenMillis;
  final String bucketDisplayName;
  final int durationMillis;
  CatalogMetadata catalogMetadata;
  AddressDetails addressDetails;

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
  });

  factory ImageEntry.fromMap(Map map) {
    return ImageEntry(
      uri: map['uri'],
      path: map['path'],
      contentId: map['contentId'],
      mimeType: map['mimeType'],
      width: map['width'],
      height: map['height'],
      orientationDegrees: map['orientationDegrees'],
      sizeBytes: map['sizeBytes'],
      title: map['title'],
      dateModifiedSecs: map['dateModifiedSecs'],
      sourceDateTakenMillis: map['sourceDateTakenMillis'],
      bucketDisplayName: map['bucketDisplayName'],
      durationMillis: map['durationMillis'],
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

  @override
  String toString() {
    return 'ImageEntry{uri=$uri, path=$path}';
  }

  bool get isGif => mimeType == MimeTypes.MIME_GIF;

  bool get isVideo => mimeType.startsWith(MimeTypes.MIME_VIDEO);

  bool get isCataloged => catalogMetadata != null;

  double get aspectRatio {
    if (width == 0 || height == 0) return 1;
    if (isVideo && isCataloged) {
      if (catalogMetadata.videoRotation % 180 == 90) return height / width;
    }
    return width / height;
  }

  int get megaPixels => (width * height / 1000000).round();

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

  String get durationText {
    final d = Duration(milliseconds: durationMillis);

    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(Duration.secondsPerMinute));
    if (d.inHours == 0) return '${d.inMinutes}:$twoDigitSeconds';

    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(Duration.minutesPerHour));
    return '${d.inHours}:$twoDigitMinutes:$twoDigitSeconds';
  }

  bool get hasGps => isCataloged && catalogMetadata.latitude != null;

  bool get isLocated => addressDetails != null;

  Tuple2<double, double> get latLng => isCataloged ? Tuple2(catalogMetadata.latitude, catalogMetadata.longitude) : null;

  String get geoUri => hasGps ? 'geo:${catalogMetadata.latitude},${catalogMetadata.longitude}' : null;

  List<String> get xmpSubjects => catalogMetadata?.xmpSubjects?.split(';')?.where((tag) => tag.isNotEmpty)?.toList() ?? [];

  catalog() async {
    if (isCataloged) return;
    catalogMetadata = await MetadataService.getCatalogMetadata(this);
    notifyListeners();
  }

  locate() async {
    if (isLocated) return;
    await catalog();
    final latitude = catalogMetadata?.latitude;
    final longitude = catalogMetadata?.longitude;
    if (latitude != null && longitude != null) {
      final coordinates = Coordinates(latitude, longitude);
      try {
        final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
        if (addresses != null && addresses.length > 0) {
          final address = addresses.first;
          addressDetails = AddressDetails(
            contentId: contentId,
            addressLine: address.addressLine,
            countryName: address.countryName,
            adminArea: address.adminArea,
            locality: address.locality,
          );
          notifyListeners();
        }
      } catch (e) {
        debugPrint('$runtimeType addAddressToMetadata failed with exception=${e.message}');
      }
    }
  }

  String get shortAddress {
    if (!isLocated) return '';

    // admin area examples: Seoul, Geneva, null
    // locality examples: Mapo-gu, Geneva, Annecy
    return LinkedHashSet.of(
      [addressDetails.countryName, addressDetails.adminArea, addressDetails.locality],
    ).where((part) => part != null && part.isNotEmpty).join(', ');
  }

  bool search(String query) {
    if (title.toLowerCase().contains(query)) return true;
    if (catalogMetadata?.xmpSubjects?.toLowerCase()?.contains(query) ?? false) return true;
    if (isLocated && addressDetails.addressLine.toLowerCase().contains(query)) return true;
    return false;
  }
}
