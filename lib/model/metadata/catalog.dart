import 'package:aves/services/geocoding_service.dart';
import 'package:aves/services/media/enums.dart';
import 'package:flutter/foundation.dart';

typedef DateAndZone = (int dateMillis, int? timeZoneOffsetMinutes);

class CatalogMetadata({
  required final int id,
  final String? mimeType,
  final int? dateMillis,
  final int? timeZoneOffsetMinutes,
  final bool isAnimated = false,
  var bool isFlipped = false,
  final bool isGeotiff = false,
  final bool is360 = false,
  final bool isMultiPage = false,
  final bool isMotionPhoto = false,
  final bool isHdr = false,
  final bool isSlowMotion = false,
  final C2paValidity credentialsValidity = .unknown,
  var int? rotationDegrees,
  final String? xmpSubjects,
  final String? xmpTitle,
  double? latitude,
  double? longitude,
  var int rating = 0,
}) {
  double? latitude, longitude;
  Address? address;

  // less lenient than Flutter's `precisionErrorTolerance` (1e-10)
  static const double _precisionErrorTolerance = 1e-9;

  static const _isAnimatedMask = 1 << 0;
  static const _isFlippedMask = 1 << 1;
  static const _isGeotiffMask = 1 << 2;
  static const _is360Mask = 1 << 3;
  static const _isMultiPageMask = 1 << 4;
  static const _isMotionPhotoMask = 1 << 5;
  static const _isHdr = 1 << 6; // for images: embedded HDR gainmap, for videos: HDR color transfer
  static const _isSlowMotion = 1 << 7;
  static const _areCredentialsPresent = 1 << 8;
  static const _areCredentialsValid = 1 << 9;
  static const _areCredentialsTrusted = 1 << 10;

  this {
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
    int? id,
    String? mimeType,
    int? dateMillis,
    int? timeZoneOffsetMinutes,
    bool? isAnimated,
    bool? isMultiPage,
    bool? isSlowMotion,
    int? rotationDegrees,
    double? latitude,
    double? longitude,
  }) {
    return CatalogMetadata(
      id: id ?? this.id,
      mimeType: mimeType ?? this.mimeType,
      dateMillis: dateMillis ?? this.dateMillis,
      timeZoneOffsetMinutes: timeZoneOffsetMinutes ?? this.timeZoneOffsetMinutes,
      isAnimated: isAnimated ?? this.isAnimated,
      isFlipped: isFlipped,
      isGeotiff: isGeotiff,
      is360: is360,
      isMultiPage: isMultiPage ?? this.isMultiPage,
      isMotionPhoto: isMotionPhoto,
      isHdr: isHdr,
      isSlowMotion: isSlowMotion ?? this.isSlowMotion,
      credentialsValidity: credentialsValidity,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      xmpSubjects: xmpSubjects,
      xmpTitle: xmpTitle,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating,
    );
  }

  factory fromMap(Map map) {
    final flags = map['flags'] ?? 0;
    return CatalogMetadata(
      id: map['id'],
      mimeType: map['mimeType'],
      dateMillis: map['dateMillis'] ?? 0,
      timeZoneOffsetMinutes: map['timeZoneOffsetMinutes'],
      isAnimated: flags & _isAnimatedMask != 0,
      isFlipped: flags & _isFlippedMask != 0,
      isGeotiff: flags & _isGeotiffMask != 0,
      is360: flags & _is360Mask != 0,
      isMultiPage: flags & _isMultiPageMask != 0,
      isMotionPhoto: flags & _isMotionPhotoMask != 0,
      isHdr: flags & _isHdr != 0,
      isSlowMotion: flags & _isSlowMotion != 0,
      credentialsValidity: _toC2paValidity(
        flags & _areCredentialsPresent != 0,
        flags & _areCredentialsValid != 0,
        flags & _areCredentialsTrusted != 0,
      ),
      // `rotationDegrees` should default to `sourceRotationDegrees`, not 0
      rotationDegrees: map['rotationDegrees'],
      xmpSubjects: map['xmpSubjects'] ?? '',
      xmpTitle: map['xmpTitle'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
      rating: map['rating'] ?? 0,
    );
  }

  static C2paValidity _toC2paValidity(bool present, bool valid, bool trusted) {
    if (trusted) return .trusted;
    if (valid) return .valid;
    if (present) return .invalid;
    return .unknown;
  }

  static (bool present, bool valid, bool trusted) _toCredentialFlags(C2paValidity validity) {
    switch (validity) {
      case .unknown:
        return (false, false, false);
      case .invalid:
        return (true, false, false);
      case .valid:
        return (true, true, false);
      case .trusted:
        return (true, true, true);
    }
  }

  Map<String, Object?> toMap() {
    final (areCredentialsPresent, areCredentialsValid, areCredentialsTrusted) = _toCredentialFlags(credentialsValidity);
    return {
      'id': id,
      'mimeType': mimeType,
      'dateMillis': dateMillis,
      'timeZoneOffsetMinutes': timeZoneOffsetMinutes,
      'flags':
          (isAnimated ? _isAnimatedMask : 0) |
          (isFlipped ? _isFlippedMask : 0) |
          (isGeotiff ? _isGeotiffMask : 0) |
          (is360 ? _is360Mask : 0) |
          (isMultiPage ? _isMultiPageMask : 0) |
          (isMotionPhoto ? _isMotionPhotoMask : 0) |
          (isHdr ? _isHdr : 0) |
          (isSlowMotion ? _isSlowMotion : 0) |
          (areCredentialsPresent ? _areCredentialsPresent : 0) |
          (areCredentialsValid ? _areCredentialsValid : 0) |
          (areCredentialsTrusted ? _areCredentialsTrusted : 0),
      'rotationDegrees': rotationDegrees,
      'xmpSubjects': xmpSubjects,
      'xmpTitle': xmpTitle,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
    };
  }

  Map<String, Object?> toDbMap() => toMap();

  @override
  String toString() =>
      '$runtimeType#${shortHash(this)}{id=$id, mimeType=$mimeType, dateMillis=$dateMillis timeZoneOffsetMinutes=$timeZoneOffsetMinutes'
      ', isAnimated=$isAnimated, isFlipped=$isFlipped, isGeotiff=$isGeotiff, is360=$is360, isMultiPage=$isMultiPage'
      ', isMotionPhoto=$isMotionPhoto, isHdr=$isHdr, isSlowMotion=$isSlowMotion, credentialsValidity=$credentialsValidity'
      ', rotationDegrees=$rotationDegrees, xmpSubjects=$xmpSubjects, xmpTitle=$xmpTitle, latitude=$latitude, longitude=$longitude, rating=$rating}';
}
