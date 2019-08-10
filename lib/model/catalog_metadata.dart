import 'package:geocoder/model.dart';

class CatalogMetadata {
  final int contentId, dateMillis;
  final String xmpSubjects;
  final double latitude, longitude;
  Address address;

  CatalogMetadata({this.contentId, this.dateMillis, this.xmpSubjects, double latitude, double longitude})
      // Geocoder throws an IllegalArgumentException when a coordinate has a funky values like 1.7056881853375E7
      : this.latitude = latitude == null || latitude < -90.0 || latitude > 90.0 ? null : latitude,
        this.longitude = longitude == null || longitude < -180.0 || longitude > 180.0 ? null : longitude;

  factory CatalogMetadata.fromMap(Map map) {
    return CatalogMetadata(
      contentId: map['contentId'],
      dateMillis: map['dateMillis'],
      xmpSubjects: map['xmpSubjects'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'dateMillis': dateMillis,
        'xmpSubjects': xmpSubjects,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  String toString() {
    return 'CatalogMetadata{contentId=$contentId, dateMillis=$dateMillis, latitude=$latitude, longitude=$longitude, xmpSubjects=$xmpSubjects}';
  }
}
