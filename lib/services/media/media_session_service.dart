import 'dart:async';

import 'package:aves/services/common/optional_event_channel.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class MediaSessionService {
  Stream<MediaCommandEvent> get mediaCommands;

  Future<void> update(AvesVideoController controller);

  Future<void> release();
}

class PlatformMediaSessionService implements MediaSessionService {
  static const _platformObject = MethodChannel('deckers.thibault/aves/media_session');

  final EventChannel _mediaCommandChannel = const OptionalEventChannel('deckers.thibault/aves/media_command');
  final StreamController _streamController = StreamController.broadcast();

  PlatformMediaSessionService() {
    _mediaCommandChannel.receiveBroadcastStream().listen((event) => _onMediaCommand(event as Map?));
  }

  @override
  Stream<MediaCommandEvent> get mediaCommands => _streamController.stream.where((event) => event is MediaCommandEvent).cast<MediaCommandEvent>();

  @override
  Future<void> update(AvesVideoController controller) async {
    final entry = controller.entry;
    try {
      await _platformObject.invokeMethod('update', <String, dynamic>{
        'uri': entry.uri,
        'title': entry.bestTitle,
        'durationMillis': controller.duration,
        'state': _toPlatformState(controller.status),
        'positionMillis': controller.currentPosition,
        'playbackSpeed': controller.speed,
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
        break;
      case 'pause':
        event = const MediaCommandEvent(MediaCommand.pause);
        break;
      case 'stop':
        event = const MediaCommandEvent(MediaCommand.stop);
        break;
      case 'seek':
        final position = fields['position'] as int?;
        if (position != null) {
          event = MediaSeekCommandEvent(MediaCommand.stop, position: position);
        }
        break;
    }
    if (event != null) {
      _streamController.add(event);
    }
  }
}

enum MediaCommand { play, pause, stop, seek }

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
