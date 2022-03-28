import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class OverlayMetadata extends Equatable {
  final double? aperture, focalLength;
  final String? exposureTime;
  final int? iso;

  @override
  List<Object?> get props => [aperture, exposureTime, focalLength, iso];

  bool get isEmpty => aperture == null && exposureTime == null && focalLength == null && iso == null;

  bool get isNotEmpty => !isEmpty;

  const OverlayMetadata({
    this.aperture,
    this.exposureTime,
    this.focalLength,
    this.iso,
  });

  factory OverlayMetadata.fromMap(Map map) {
    return OverlayMetadata(
      aperture: map['aperture'] as double?,
      exposureTime: map['exposureTime'] as String?,
      focalLength: map['focalLength'] as double?,
      iso: map['iso'] as int?,
    );
  }
}
