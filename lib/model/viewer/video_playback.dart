import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class const VideoPlaybackRow({
  required final int entryId,
  required final int resumeTimeMillis,
}) extends Equatable {
  @override
  List<Object?> get props => [entryId, resumeTimeMillis];

  static VideoPlaybackRow? fromMap(Map map) {
    return VideoPlaybackRow(
      entryId: map['id'],
      resumeTimeMillis: map['resumeTimeMillis'],
    );
  }

  Map<String, Object?> toMap() => {
    'id': entryId,
    'resumeTimeMillis': resumeTimeMillis,
  };

  Map<String, Object?> toDbMap() => toMap();
}
