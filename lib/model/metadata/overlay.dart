import 'package:aves/model/entry/extensions/keys.dart';
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
      aperture: map[EntryFields.aperture] as double?,
      exposureTime: map[EntryFields.exposureTime] as String?,
      focalLength: map[EntryFields.focalLength] as double?,
      iso: map[EntryFields.iso] as int?,
      description: map[EntryFields.description] as String?,
    );
  }
}
