import 'dart:async';

import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:flutter/services.dart';

abstract class MediaSessionService {
  Future<void> update(AvesVideoController controller);

  Future<void> release(String uri);
}

class PlatformMediaSessionService implements MediaSessionService {
  static const _platformObject = MethodChannel('deckers.thibault/aves/media_session');

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
  Future<void> release(String uri) async {
    try {
      await _platformObject.invokeMethod('release', <String, dynamic>{
        'uri': uri,
      });
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
}
