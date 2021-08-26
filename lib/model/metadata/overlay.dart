import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class OverlayMetadata {
  final String? aperture, exposureTime, focalLength, iso;

  static final apertureFormat = NumberFormat('0.0', 'en_US');
  static final focalLengthFormat = NumberFormat('0.#', 'en_US');

  OverlayMetadata({
    double? aperture,
    this.exposureTime,
    double? focalLength,
    int? iso,
  })  : aperture = aperture != null ? 'ƒ/${apertureFormat.format(aperture)}' : null,
        focalLength = focalLength != null ? '${focalLengthFormat.format(focalLength)} mm' : null,
        iso = iso != null ? 'ISO$iso' : null;

  factory OverlayMetadata.fromMap(Map map) {
    return OverlayMetadata(
      aperture: map['aperture'] as double?,
      exposureTime: map['exposureTime'] as String?,
      focalLength: map['focalLength'] as double?,
      iso: map['iso'] as int?,
    );
  }

  bool get isEmpty => aperture == null && exposureTime == null && focalLength == null && iso == null;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{aperture=$aperture, exposureTime=$exposureTime, focalLength=$focalLength, iso=$iso}';
}
