import 'package:aves/services/geocoding_service.dart';
import 'package:flutter/foundation.dart';

class CatalogMetadata {
  final int? contentId, dateMillis;
  final bool isAnimated, isGeotiff, is360, isMultiPage;
  bool isFlipped;
  int? rating, rotationDegrees;
  final String? mimeType, xmpSubjects, xmpTitleDescription;
  double? latitude, longitude;
  Address? address;

  static const double _precisionErrorTolerance = 1e-9;
  static const _isAnimatedMask = 1 << 0;
  static const _isFlippedMask = 1 << 1;
  static const _isGeotiffMask = 1 << 2;
  static const _is360Mask = 1 << 3;
  static const _isMultiPageMask = 1 << 4;

  CatalogMetadata({
    this.contentId,
    this.mimeType,
    this.dateMillis,
    this.isAnimated = false,
    this.isFlipped = false,
    this.isGeotiff = false,
    this.is360 = false,
    this.isMultiPage = false,
    this.rotationDegrees,
    this.xmpSubjects,
    this.xmpTitleDescription,
    double? latitude,
    double? longitude,
    this.rating,
  }) {
    // Geocoder throws an `IllegalArgumentException` when a coordinate has a funky value like `1.7056881853375E7`
    // We also exclude zero coordinates, taking into account precision errors (e.g. {5.952380952380953e-11,-2.7777777777777777e-10}),
    // but Flutter's `precisionErrorTolerance` (1e-10) is slightly too lenient for this case.
    if (latitude != null && longitude != null && (latitude.abs() > _precisionErrorTolerance || longitude.abs() > _precisionErrorTolerance)) {
      // funny case: some files have latitude and longitude reverse
      // (e.g. a Japanese location at lat~=133 and long~=34, which is a valid longitude but an invalid latitude)
      // so we should check and assign both coordinates at once
      if (latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0) {
        this.latitude = latitude;
        this.longitude = longitude;
      }
    }
  }

  CatalogMetadata copyWith({
    int? contentId,
    String? mimeType,
    int? dateMillis,
    bool? isMultiPage,
    int? rotationDegrees,
  }) {
    return CatalogMetadata(
      contentId: contentId ?? this.contentId,
      mimeType: mimeType ?? this.mimeType,
      dateMillis: dateMillis ?? this.dateMillis,
      isAnimated: isAnimated,
      isFlipped: isFlipped,
      isGeotiff: isGeotiff,
      is360: is360,
      isMultiPage: isMultiPage ?? this.isMultiPage,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      xmpSubjects: xmpSubjects,
      xmpTitleDescription: xmpTitleDescription,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
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
      isMultiPage: flags & _isMultiPageMask != 0,
      // `rotationDegrees` should default to `sourceRotationDegrees`, not 0
      rotationDegrees: map['rotationDegrees'],
      xmpSubjects: map['xmpSubjects'] ?? '',
      xmpTitleDescription: map['xmpTitleDescription'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
      // `rotationDegrees` should default to `null`, not 0
      rating: map['rating'],
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'mimeType': mimeType,
        'dateMillis': dateMillis,
        'flags': (isAnimated ? _isAnimatedMask : 0) | (isFlipped ? _isFlippedMask : 0) | (isGeotiff ? _isGeotiffMask : 0) | (is360 ? _is360Mask : 0) | (isMultiPage ? _isMultiPageMask : 0),
        'rotationDegrees': rotationDegrees,
        'xmpSubjects': xmpSubjects,
        'xmpTitleDescription': xmpTitleDescription,
        'latitude': latitude,
        'longitude': longitude,
        'rating': rating,
      };

  @override
  String toString() => '$runtimeType#${shortHash(this)}{contentId=$contentId, mimeType=$mimeType, dateMillis=$dateMillis, isAnimated=$isAnimated, isFlipped=$isFlipped, isGeotiff=$isGeotiff, is360=$is360, isMultiPage=$isMultiPage, rotationDegrees=$rotationDegrees, xmpSubjects=$xmpSubjects, xmpTitleDescription=$xmpTitleDescription, latitude=$latitude, longitude=$longitude, rating=$rating}';
}
