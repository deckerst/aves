import 'package:flutter/foundation.dart';

enum MediaTrackType { video, audio, text }

class MediaTrackSummary {
  final MediaTrackType type;
  final int? index, width, height;
  final String? codecName, language, title;

  const MediaTrackSummary({
    required this.type,
    required this.index,
    required this.codecName,
    required this.language,
    required this.title,
    required this.width,
    required this.height,
  });

  @override
  String toString() => '$runtimeType#${shortHash(this)}{type: $type, index: $index, codecName: $codecName, language: $language, title: $title, width: $width, height: $height}';
}
