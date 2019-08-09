import 'package:geocoder/model.dart';

import 'mime_types.dart';

class ImageEntry {
  String uri;
  String path;
  int contentId;
  String mimeType;
  int width;
  int height;
  int orientationDegrees;
  int sizeBytes;
  String title;
  int dateModifiedSecs;
  int sourceDateTakenMillis;
  String bucketDisplayName;
  int durationMillis;

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

  bool get isGif => mimeType == MimeTypes.MIME_GIF;

  bool get isVideo => mimeType.startsWith(MimeTypes.MIME_VIDEO);

  double get aspectRatio => height == 0 ? 1 : width / height;

  int get megaPixels => (width * height / 1000000).round();

  DateTime get bestDate {
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
}

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
