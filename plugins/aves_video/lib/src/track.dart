import 'package:flutter/foundation.dart';

enum MediaTrackType { video, audio, text }

class const MediaTrackSummary({
  required final MediaTrackType type,
  required final int? index,
  required final String? codecName,
  required final String? language,
  required final String? title,
  required final int? width,
  required final int? height,
}) {
  @override
  String toString() =>
      '$runtimeType#${shortHash(this)}{'
      'type: $type, index: $index, codecName: $codecName, '
      'language: $language, title: $title, width: $width, height: $height'
      '}';
}
