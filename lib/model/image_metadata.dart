import 'package:geocoder/model.dart';

class CatalogMetadata {
  final int contentId, dateMillis, videoRotation;
  final String xmpSubjects;
  final double latitude, longitude;
  Address address;

  CatalogMetadata({
    this.contentId,
    this.dateMillis,
    this.videoRotation,
    this.xmpSubjects,
    double latitude,
    double longitude,
  })  
  // Geocoder throws an IllegalArgumentException when a coordinate has a funky values like 1.7056881853375E7
  : this.latitude = latitude == null || latitude < -90.0 || latitude > 90.0 ? null : latitude,
        this.longitude = longitude == null || longitude < -180.0 || longitude > 180.0 ? null : longitude;

  factory CatalogMetadata.fromMap(Map map) {
    return CatalogMetadata(
      contentId: map['contentId'],
      dateMillis: map['dateMillis'] ?? 0,
      videoRotation: map['videoRotation'] ?? 0,
      xmpSubjects: map['xmpSubjects'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'dateMillis': dateMillis,
        'videoRotation': videoRotation,
        'xmpSubjects': xmpSubjects,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  String toString() {
    return 'CatalogMetadata{contentId=$contentId, dateMillis=$dateMillis, videoRotation=$videoRotation, latitude=$latitude, longitude=$longitude, xmpSubjects=$xmpSubjects}';
  }
}

class OverlayMetadata {
  final String aperture, exposureTime, focalLength, iso;

  OverlayMetadata({
    String aperture,
    this.exposureTime,
    this.focalLength,
    this.iso,
  }) : this.aperture = aperture.replaceFirst('f', 'ƒ');

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
