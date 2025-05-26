import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:aves_video/aves_video.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

abstract class MediaSessionService {
  Stream<MediaCommandEvent> get mediaCommands;

  Future<void> update({
    required AvesEntry entry,
    required AvesVideoController controller,
    required bool canSkipToNext,
    required bool canSkipToPrevious,
  });

  Future<void> release();
}

class PlatformMediaSessionService implements MediaSessionService, Disposable {
  static const _platformObject = MethodChannel('deckers.thibault/aves/media_session');

  final Set<StreamSubscription> _subscriptions = {};
  final EventChannel _mediaCommandChannel = const OptionalEventChannel('deckers.thibault/aves/media_command');
  final StreamController _streamController = StreamController.broadcast();

  PlatformMediaSessionService() {
    _subscriptions.add(_mediaCommandChannel.receiveBroadcastStream().listen((event) => _onMediaCommand(event as Map?)));
  }

  @override
  FutureOr onDispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Stream<MediaCommandEvent> get mediaCommands => _streamController.stream.where((event) => event is MediaCommandEvent).cast<MediaCommandEvent>();

  @override
  Future<void> update({
    required AvesEntry entry,
    required AvesVideoController controller,
    required bool canSkipToNext,
    required bool canSkipToPrevious,
  }) async {
    try {
      await _platformObject.invokeMethod('update', <String, dynamic>{
        'uri': entry.uri,
        'title': entry.bestTitle,
        'durationMillis': controller.duration,
        'state': _toPlatformState(controller.status),
        'positionMillis': controller.currentPosition,
        'playbackSpeed': controller.speed,
        'canSkipToNext': canSkipToNext,
        'canSkipToPrevious': canSkipToPrevious,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  @override
  Future<void> release() async {
    try {
      await _platformObject.invokeMethod('release');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  String _toPlatformState(VideoStatus status) {
    switch (status) {
      case VideoStatus.paused:
        return 'paused';
      case VideoStatus.playing:
        return 'playing';
      case VideoStatus.idle:
      case VideoStatus.initialized:
      case VideoStatus.completed:
      case VideoStatus.error:
        return 'stopped';
    }
  }

  void _onMediaCommand(Map? fields) {
    if (fields == null) return;
    final command = fields['command'] as String?;
    MediaCommandEvent? event;
    switch (command) {
      case 'play':
        event = const MediaCommandEvent(MediaCommand.play);
      case 'pause':
        event = const MediaCommandEvent(MediaCommand.pause);
      case 'skip_to_next':
        event = const MediaCommandEvent(MediaCommand.skipToNext);
      case 'skip_to_previous':
        event = const MediaCommandEvent(MediaCommand.skipToPrevious);
      case 'stop':
        event = const MediaCommandEvent(MediaCommand.stop);
      case 'seek':
        final position = fields['position'] as int?;
        if (position != null) {
          event = MediaSeekCommandEvent(MediaCommand.stop, position: position);
        }
    }
    if (event != null) {
      _streamController.add(event);
    }
  }
}

enum MediaCommand { play, pause, skipToNext, skipToPrevious, stop, seek }

@immutable
class MediaCommandEvent extends Equatable {
  final MediaCommand command;

  @override
  List<Object?> get props => [command];

  const MediaCommandEvent(this.command);
}

@immutable
class MediaSeekCommandEvent extends MediaCommandEvent {
  final int position;

  @override
  List<Object?> get props => [...super.props, position];

  const MediaSeekCommandEvent(super.command, {required this.position});
}
