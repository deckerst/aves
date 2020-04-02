import 'package:flutter/widgets.dart';
import 'package:geocoder/model.dart';

class CatalogMetadata {
  final int contentId, dateMillis, videoRotation;
  final String xmpSubjects, xmpTitleDescription;
  final double latitude, longitude;
  Address address;

  CatalogMetadata({
    this.contentId,
    this.dateMillis,
    this.videoRotation,
    this.xmpSubjects,
    this.xmpTitleDescription,
    double latitude,
    double longitude,
  })  
  // Geocoder throws an IllegalArgumentException when a coordinate has a funky values like 1.7056881853375E7
  : latitude = latitude == null || latitude < -90.0 || latitude > 90.0 ? null : latitude,
        longitude = longitude == null || longitude < -180.0 || longitude > 180.0 ? null : longitude;

  factory CatalogMetadata.fromMap(Map map) {
    return CatalogMetadata(
      contentId: map['contentId'],
      dateMillis: map['dateMillis'] ?? 0,
      videoRotation: map['videoRotation'] ?? 0,
      xmpSubjects: map['xmpSubjects'] ?? '',
      xmpTitleDescription: map['xmpTitleDescription'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'dateMillis': dateMillis,
        'videoRotation': videoRotation,
        'xmpSubjects': xmpSubjects,
        'xmpTitleDescription': xmpTitleDescription,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  String toString() {
    return 'CatalogMetadata{contentId=$contentId, dateMillis=$dateMillis, videoRotation=$videoRotation, latitude=$latitude, longitude=$longitude, xmpSubjects=$xmpSubjects, xmpTitleDescription=$xmpTitleDescription}';
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
  final String addressLine, countryName, adminArea, locality;

  String get city => locality != null && locality.isNotEmpty ? locality : adminArea;

  AddressDetails({
    this.contentId,
    this.addressLine,
    this.countryName,
    this.adminArea,
    this.locality,
  });

  factory AddressDetails.fromMap(Map map) {
    return AddressDetails(
      contentId: map['contentId'],
      addressLine: map['addressLine'] ?? '',
      countryName: map['countryName'] ?? '',
      adminArea: map['adminArea'] ?? '',
      locality: map['locality'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'addressLine': addressLine,
        'countryName': countryName,
        'adminArea': adminArea,
        'locality': locality,
      };

  @override
  String toString() {
    return 'AddressDetails{contentId=$contentId, addressLine=$addressLine, countryName=$countryName, adminArea=$adminArea, locality=$locality}';
  }
}

class FavouriteRow {
  final int contentId;
  final String path;

  FavouriteRow({
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
