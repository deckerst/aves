import 'package:flutter/widgets.dart';
import 'package:geocoder/model.dart';

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
  String toString() {
    return 'DateMetadata{contentId=$contentId, dateMillis=$dateMillis}';
  }
}

class CatalogMetadata {
  final int contentId, dateMillis, videoRotation;
  final bool isAnimated;
  final String mimeType, xmpSubjects, xmpTitleDescription;
  final double latitude, longitude;
  Address address;

  CatalogMetadata({
    this.contentId,
    this.mimeType,
    this.dateMillis,
    this.isAnimated,
    this.videoRotation,
    this.xmpSubjects,
    this.xmpTitleDescription,
    double latitude,
    double longitude,
  })
  // Geocoder throws an IllegalArgumentException when a coordinate has a funky values like 1.7056881853375E7
  : latitude = latitude == null || latitude < -90.0 || latitude > 90.0 ? null : latitude,
        longitude = longitude == null || longitude < -180.0 || longitude > 180.0 ? null : longitude;

  CatalogMetadata copyWith({
    @required int contentId,
  }) {
    return CatalogMetadata(
      contentId: contentId ?? this.contentId,
      mimeType: mimeType,
      dateMillis: dateMillis,
      isAnimated: isAnimated,
      videoRotation: videoRotation,
      xmpSubjects: xmpSubjects,
      xmpTitleDescription: xmpTitleDescription,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory CatalogMetadata.fromMap(Map map, {bool boolAsInteger = false}) {
    final isAnimated = map['isAnimated'] ?? (boolAsInteger ? 0 : false);
    return CatalogMetadata(
      contentId: map['contentId'],
      mimeType: map['mimeType'],
      dateMillis: map['dateMillis'] ?? 0,
      isAnimated: boolAsInteger ? isAnimated != 0 : isAnimated,
      videoRotation: map['videoRotation'] ?? 0,
      xmpSubjects: map['xmpSubjects'] ?? '',
      xmpTitleDescription: map['xmpTitleDescription'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap({bool boolAsInteger = false}) => {
        'contentId': contentId,
        'mimeType': mimeType,
        'dateMillis': dateMillis,
        'isAnimated': boolAsInteger ? (isAnimated ? 1 : 0) : isAnimated,
        'videoRotation': videoRotation,
        'xmpSubjects': xmpSubjects,
        'xmpTitleDescription': xmpTitleDescription,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  String toString() {
    return 'CatalogMetadata{contentId=$contentId, mimeType=$mimeType, dateMillis=$dateMillis, isAnimated=$isAnimated, videoRotation=$videoRotation, latitude=$latitude, longitude=$longitude, xmpSubjects=$xmpSubjects, xmpTitleDescription=$xmpTitleDescription}';
  }
}

class OverlayMetadata {
  final String aperture, exposureTime, focalLength, iso;

  OverlayMetadata({
    String aperture,
    this.exposureTime,
    this.focalLength,
    this.iso,
  }) : aperture = aperture.replaceFirst('f', 'ƒ');

  factory OverlayMetadata.fromMap(Map map) {
    return OverlayMetadata(
      aperture: map['aperture'] ?? '',
      exposureTime: map['exposureTime'] ?? '',
      focalLength: map['focalLength'] ?? '',
      iso: map['iso'] ?? '',
    );
  }

  bool get isEmpty => aperture.isEmpty && exposureTime.isEmpty && focalLength.isEmpty && iso.isEmpty;

  @override
  String toString() {
    return 'OverlayMetadata{aperture=$aperture, exposureTime=$exposureTime, focalLength=$focalLength, iso=$iso}';
  }
}

class AddressDetails {
  final int contentId;
  final String addressLine, countryCode, countryName, adminArea, locality;

  String get place => locality != null && locality.isNotEmpty ? locality : adminArea;

  AddressDetails({
    this.contentId,
    this.addressLine,
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
      addressLine: addressLine,
      countryCode: countryCode,
      countryName: countryName,
      adminArea: adminArea,
      locality: locality,
    );
  }

  factory AddressDetails.fromMap(Map map) {
    return AddressDetails(
      contentId: map['contentId'],
      addressLine: map['addressLine'] ?? '',
      countryCode: map['countryCode'] ?? '',
      countryName: map['countryName'] ?? '',
      adminArea: map['adminArea'] ?? '',
      locality: map['locality'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'addressLine': addressLine,
        'countryCode': countryCode,
        'countryName': countryName,
        'adminArea': adminArea,
        'locality': locality,
      };

  @override
  String toString() {
    return 'AddressDetails{contentId=$contentId, addressLine=$addressLine, countryCode=$countryCode, countryName=$countryName, adminArea=$adminArea, locality=$locality}';
  }
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
  String toString() {
    return 'FavouriteRow{contentId=$contentId, path=$path}';
  }
}
