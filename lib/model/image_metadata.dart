import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoder/model.dart';
import 'package:intl/intl.dart';

class DateMetadata {
  final int contentId, dateMillis;

  DateMetadata({
    this.contentId,
    this.dateMillis,
  });

  factory DateMetadata.fromMap(Map map) {
    return DateMetadata(
      contentId: map['contentId'],
      dateMillis: map['dateMillis'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'dateMillis': dateMillis,
      };

  @override
  String toString() => '$runtimeType#${shortHash(this)}{contentId=$contentId, dateMillis=$dateMillis}';
}

class CatalogMetadata {
  final int contentId, dateMillis;
  final bool isAnimated, isGeotiff, is360, isMultipage;
  bool isFlipped;
  int rotationDegrees;
  final String mimeType, xmpSubjects, xmpTitleDescription;
  double latitude, longitude;
  Address address;

  static const double _precisionErrorTolerance = 1e-9;
  static const _isAnimatedMask = 1 << 0;
  static const _isFlippedMask = 1 << 1;
  static const _isGeotiffMask = 1 << 2;
  static const _is360Mask = 1 << 3;
  static const _isMultipageMask = 1 << 4;

  CatalogMetadata({
    this.contentId,
    this.mimeType,
    this.dateMillis,
    this.isAnimated = false,
    this.isFlipped = false,
    this.isGeotiff = false,
    this.is360 = false,
    this.isMultipage = false,
    this.rotationDegrees,
    this.xmpSubjects,
    this.xmpTitleDescription,
    double latitude,
    double longitude,
  }) {
    // Geocoder throws an `IllegalArgumentException` when a coordinate has a funky values like `1.7056881853375E7`
    // We also exclude zero coordinates, taking into account precision errors (e.g. {5.952380952380953e-11,-2.7777777777777777e-10}),
    // but Flutter's `precisionErrorTolerance` (1e-10) is slightly too lenient for this case.
    if (latitude != null && longitude != null && (latitude.abs() > _precisionErrorTolerance || longitude.abs() > _precisionErrorTolerance)) {
      this.latitude = latitude < -90.0 || latitude > 90.0 ? null : latitude;
      this.longitude = longitude < -180.0 || longitude > 180.0 ? null : longitude;
    }
  }

  CatalogMetadata copyWith({
    @required int contentId,
  }) {
    return CatalogMetadata(
      contentId: contentId ?? this.contentId,
      mimeType: mimeType,
      dateMillis: dateMillis,
      isAnimated: isAnimated,
      isFlipped: isFlipped,
      isGeotiff: isGeotiff,
      is360: is360,
      isMultipage: isMultipage,
      rotationDegrees: rotationDegrees,
      xmpSubjects: xmpSubjects,
      xmpTitleDescription: xmpTitleDescription,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory CatalogMetadata.fromMap(Map map) {
    final flags = map['flags'] ?? 0;
    return CatalogMetadata(
      contentId: map['contentId'],
      mimeType: map['mimeType'],
      dateMillis: map['dateMillis'] ?? 0,
      isAnimated: flags & _isAnimatedMask != 0,
      isFlipped: flags & _isFlippedMask != 0,
      isGeotiff: flags & _isGeotiffMask != 0,
      is360: flags & _is360Mask != 0,
      isMultipage: flags & _isMultipageMask != 0,
      // `rotationDegrees` should default to `sourceRotationDegrees`, not 0
      rotationDegrees: map['rotationDegrees'],
      xmpSubjects: map['xmpSubjects'] ?? '',
      xmpTitleDescription: map['xmpTitleDescription'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'mimeType': mimeType,
        'dateMillis': dateMillis,
        'flags': (isAnimated ? _isAnimatedMask : 0) | (isFlipped ? _isFlippedMask : 0) | (isGeotiff ? _isGeotiffMask : 0) | (is360 ? _is360Mask : 0) | (isMultipage ? _isMultipageMask : 0),
        'rotationDegrees': rotationDegrees,
        'xmpSubjects': xmpSubjects,
        'xmpTitleDescription': xmpTitleDescription,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  String toString() => '$runtimeType#${shortHash(this)}{contentId=$contentId, mimeType=$mimeType, dateMillis=$dateMillis, isAnimated=$isAnimated, isFlipped=$isFlipped, isGeotiff=$isGeotiff, is360=$is360, isMultipage=$isMultipage, rotationDegrees=$rotationDegrees, latitude=$latitude, longitude=$longitude, xmpSubjects=$xmpSubjects, xmpTitleDescription=$xmpTitleDescription}';
}

class OverlayMetadata {
  final String aperture, exposureTime, focalLength, iso;

  static final apertureFormat = NumberFormat('0.0', 'en_US');
  static final focalLengthFormat = NumberFormat('0.#', 'en_US');

  OverlayMetadata({
    double aperture,
    String exposureTime,
    double focalLength,
    int iso,
  })  : aperture = aperture != null ? 'ƒ/${apertureFormat.format(aperture)}' : null,
        exposureTime = exposureTime,
        focalLength = focalLength != null ? '${focalLengthFormat.format(focalLength)} mm' : null,
        iso = iso != null ? 'ISO$iso' : null;

  factory OverlayMetadata.fromMap(Map map) {
    return OverlayMetadata(
      aperture: map['aperture'] as double,
      exposureTime: map['exposureTime'] as String,
      focalLength: map['focalLength'] as double,
      iso: map['iso'] as int,
    );
  }

  bool get isEmpty => aperture == null && exposureTime == null && focalLength == null && iso == null;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{aperture=$aperture, exposureTime=$exposureTime, focalLength=$focalLength, iso=$iso}';
}

class AddressDetails {
  final int contentId;
  final String countryCode, countryName, adminArea, locality;

  String get place => locality != null && locality.isNotEmpty ? locality : adminArea;

  AddressDetails({
    this.contentId,
    this.countryCode,
    this.countryName,
    this.adminArea,
    this.locality,
  });

  AddressDetails copyWith({
    @required int contentId,
  }) {
    return AddressDetails(
      contentId: contentId ?? this.contentId,
      countryCode: countryCode,
      countryName: countryName,
      adminArea: adminArea,
      locality: locality,
    );
  }

  factory AddressDetails.fromMap(Map map) {
    return AddressDetails(
      contentId: map['contentId'],
      countryCode: map['countryCode'] ?? '',
      countryName: map['countryName'] ?? '',
      adminArea: map['adminArea'] ?? '',
      locality: map['locality'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'countryCode': countryCode,
        'countryName': countryName,
        'adminArea': adminArea,
        'locality': locality,
      };

  @override
  String toString() => '$runtimeType#${shortHash(this)}{contentId=$contentId, countryCode=$countryCode, countryName=$countryName, adminArea=$adminArea, locality=$locality}';
}

@immutable
class FavouriteRow {
  final int contentId;
  final String path;

  const FavouriteRow({
    this.contentId,
    this.path,
  });

  factory FavouriteRow.fromMap(Map map) {
    return FavouriteRow(
      contentId: map['contentId'],
      path: map['path'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'path': path,
      };

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FavouriteRow && other.contentId == contentId && other.path == path;
  }

  @override
  int get hashCode => hashValues(contentId, path);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{contentId=$contentId, path=$path}';
}
