import 'dart:async';

import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/foundation.dart';
import 'package:leak_tracker/leak_tracker.dart';

abstract class AvesAudioControllerFactory {
  void init();

  AvesAudioController buildController(AvesEntryBase entry);
}

abstract class AvesAudioController(final AvesEntryBase entry) extends Disposer {
  bool _disposed = false;

  this {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$AvesAudioController',
        object: this,
      );
    }
  }

  @override
  Future<void> dispose() async {
    assert(!_disposed);
    _disposed = true;
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    super.dispose();
  }

  Future<void> enableLoop(bool enabled);

  Future<void> play();

  Future<void> pause();

  PlaybackStatus get status;

  Stream<PlaybackStatus> get statusStream;

  bool get isReady;

  Future<void> get untilReady {
    if (isReady) return Future.value();

    final completer = Completer();
    late StreamSubscription<PlaybackStatus> sub;
    sub = statusStream.where((_) => isReady).listen((_) {
      sub.cancel();
      completer.complete();
    });
    return completer.future;
  }

  bool get isPlaying => status == .playing;
}
