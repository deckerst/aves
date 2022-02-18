import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class VideoPlaybackRow extends Equatable {
  final int entryId, resumeTimeMillis;

  @override
  List<Object?> get props => [entryId, resumeTimeMillis];

  const VideoPlaybackRow({
    required this.entryId,
    required this.resumeTimeMillis,
  });

  static VideoPlaybackRow? fromMap(Map map) {
    return VideoPlaybackRow(
      entryId: map['id'],
      resumeTimeMillis: map['resumeTimeMillis'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': entryId,
        'resumeTimeMillis': resumeTimeMillis,
      };
}
