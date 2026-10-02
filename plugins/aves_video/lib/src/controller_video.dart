import 'dart:async';

import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:leak_tracker/leak_tracker.dart';

abstract class AvesVideoControllerFactory {
  void init();

  AvesVideoController buildController(
    AvesEntryBase entry, {
    required PlaybackStateHandler playbackStateHandler,
    required VideoSettings settings,
  });
}

abstract class AvesVideoController(
  final AvesEntryBase entry, {
  required final PlaybackStateHandler playbackStateHandler,
  required final VideoSettings settings,
}) extends Disposer with ABRepeatMixin, SlowMotionMixin {
  bool _disposed = false;

  static const resumeTimeSaveMinDuration = Duration(minutes: 2);

  this {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$AvesVideoController',
        object: this,
      );
    }
    entry.visualChangeNotifier.addListener(onVisualChanged);
  }

  @override
  Future<void> dispose() async {
    assert(!_disposed);
    _disposed = true;
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    entry.visualChangeNotifier.removeListener(onVisualChanged);
    await _savePlaybackState();
    super.dispose();
  }

  Future<void> _savePlaybackState() async {
    if (!isReady || duration < resumeTimeSaveMinDuration.inMilliseconds) return;
    await playbackStateHandler.saveResumeTime(entryId: entry.id, position: currentPosition, progress: progress);
  }

  Future<int?> getResumeTime(BuildContext context) => playbackStateHandler.getResumeTime(entryId: entry.id, context: context);

  void onVisualChanged();

  Future<void> enableLoop(bool enabled);

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(int targetMillis);

  Future<void> seekToProgress(double progress) => seekTo((duration * progress.clamp(0, 1)).toInt());

  Future<void> skipFrames(int frameCount);

  Listenable get playCompletedListenable;

  PlaybackStatus get status;

  Stream<PlaybackStatus> get statusStream;

  Stream<VideoEvent> get eventStream;

  Stream<double> get volumeStream;

  Stream<double> get speedStream;

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

  int get duration;

  @override
  int get currentPosition;

  double get progress {
    final _duration = duration;
    return _duration != 0 ? currentPosition.toDouble() / _duration : 0;
  }

  Stream<int> get positionStream;

  Stream<String?> get timedTextStream;

  ValueNotifier<bool> get canCaptureFrameNotifier;

  ValueNotifier<bool> get canMuteNotifier;

  ValueNotifier<bool> get canSetSpeedNotifier;

  ValueNotifier<bool> get canSelectTrackNotifier;

  ValueNotifier<double?> get sarNotifier;

  bool get isMuted;

  double get speed;

  double get minSpeed;

  double get maxSpeed;

  Future<void> setSpeed(double speed);

  Future<void> selectTrack(MediaTrackType type, MediaTrackSummary? selected);

  Future<MediaTrackSummary?> getSelectedTrack(MediaTrackType type);

  List<MediaTrackSummary> get tracks;

  Future<Uint8List?> captureFrame();

  Future<void> mute(bool muted);

  Widget buildPlayerWidget(BuildContext context);
}

enum PlaybackStatus {
  idle,
  initialized,
  paused,
  playing,
  completed,
  error,
}

class VideoEvent;

class LagEvent extends VideoEvent;

abstract class PlaybackStateHandler {
  Future<int?> getResumeTime({required int entryId, required BuildContext context});

  Future<void> saveResumeTime({required int entryId, required int position, required double progress});
}
