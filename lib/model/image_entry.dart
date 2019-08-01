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

  bool get isVideo => mimeType.startsWith(MimeTypes.MIME_VIDEO);

  int getMegaPixels() {
    return ((width * height) / 1000000).round();
  }

  DateTime getBestDate() {
    if (sourceDateTakenMillis != null && sourceDateTakenMillis > 0) return DateTime.fromMillisecondsSinceEpoch(sourceDateTakenMillis);
    if (dateModifiedSecs != null && dateModifiedSecs > 0) return DateTime.fromMillisecondsSinceEpoch(dateModifiedSecs * 1000);
    return null;
  }

  DateTime getMonthTaken() {
    final d = getBestDate();
    return d == null ? null : DateTime(d.year, d.month);
  }
}
