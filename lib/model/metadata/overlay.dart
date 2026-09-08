import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class const OverlayMetadata({
  final double? aperture,
  final String? exposureTime,
  final double? focalLength,
  final int? iso,
  final String? description,
}) extends Equatable {
  @override
  List<Object?> get props => [aperture, exposureTime, focalLength, iso, description];

  bool get hasShootingDetails => aperture != null || exposureTime != null || focalLength != null || iso != null;

  factory fromMap(Map map) {
    return OverlayMetadata(
      aperture: map['aperture'] as double?,
      exposureTime: map['exposureTime'] as String?,
      focalLength: map['focalLength'] as double?,
      iso: map['iso'] as int?,
      description: map['description'] as String?,
    );
  }
}
