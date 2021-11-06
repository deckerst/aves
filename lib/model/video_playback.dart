import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class VideoPlaybackRow extends Equatable {
  final int contentId, resumeTimeMillis;

  @override
  List<Object?> get props => [contentId, resumeTimeMillis];

  const VideoPlaybackRow({
    required this.contentId,
    required this.resumeTimeMillis,
  });

  static VideoPlaybackRow? fromMap(Map map) {
    return VideoPlaybackRow(
      contentId: map['contentId'],
      resumeTimeMillis: map['resumeTimeMillis'],
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'resumeTimeMillis': resumeTimeMillis,
      };
}
