import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class OverlayMetadata extends Equatable {
  final double? aperture, focalLength;
  final String? description, exposureTime;
  final int? iso;

  @override
  List<Object?> get props => [aperture, description, exposureTime, focalLength, iso];

  bool get hasShootingDetails => aperture != null || exposureTime != null || focalLength != null || iso != null;

  const OverlayMetadata({
    this.aperture,
    this.description,
    this.exposureTime,
    this.focalLength,
    this.iso,
  });

  factory OverlayMetadata.fromMap(Map map) {
    return OverlayMetadata(
      aperture: map['aperture'] as double?,
      description: map['description'] as String?,
      exposureTime: map['exposureTime'] as String?,
      focalLength: map['focalLength'] as double?,
      iso: map['iso'] as int?,
    );
  }
}
