import 'dart:async';

import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class AvesVideoControllerFactory {
  void init();

  AvesVideoController buildController(
      AvesEntryBase entry, {
        required PlaybackStateHandler playbackStateHandler,
        required VideoSettings settings,
      });
}

abstract class AvesVideoController {
  final AvesEntryBase _entry;
  final PlaybackStateHandler playbackStateHandler;
  final VideoSettings settings;

  AvesEntryBase get entry => _entry;

  static const resumeTimeSaveMinDuration = Duration(minutes: 2);

  AvesVideoController(
    AvesEntryBase entry, {
    required this.playbackStateHandler,
    required this.settings,
  }) : _entry = entry {
    if (kFlutterMemoryAllocationsEnabled) {
      MemoryAllocations.instance.dispatchObjectCreated(
        library: 'aves',
        className: '$AvesVideoController',
        object: this,
      );
    }
    entry.visualChangeNotifier.addListener(onVisualChanged);
  }

  @mustCallSuper
  Future<void> dispose() async {
    if (kFlutterMemoryAllocationsEnabled) {
      MemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _entry.visualChangeNotifier.removeListener(onVisualChanged);
    await _savePlaybackState();
  }

  Future<void> _savePlaybackState() async {
    if (!isReady || duration < resumeTimeSaveMinDuration.inMilliseconds) return;
    await playbackStateHandler.saveResumeTime(entryId: _entry.id, position: currentPosition, progress: progress);
  }

  Future<int?> getResumeTime(BuildContext context) => playbackStateHandler.getResumeTime(entryId: _entry.id, context: context);

  void onVisualChanged();

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(int targetMillis);

  Future<void> seekToProgress(double progress) => seekTo((duration * progress.clamp(0, 1)).toInt());

  Listenable get playCompletedListenable;

  VideoStatus get status;

  Stream<VideoStatus> get statusStream;

  Stream<double> get volumeStream;

  Stream<double> get speedStream;

  bool get isReady;

  Future<void> get untilReady {
    if (isReady) return Future.value();

    final completer = Completer();
    late StreamSubscription<VideoStatus> sub;
    sub = statusStream.where((_) => isReady).listen((_) {
      sub.cancel();
      completer.complete();
    });
    return completer.future;
  }

  bool get isPlaying => status == VideoStatus.playing;

  int get duration;

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

  ValueNotifier<bool> get canSelectStreamNotifier;

  ValueNotifier<double?> get sarNotifier;

  bool get isMuted;

  double get speed;

  double get minSpeed;

  double get maxSpeed;

  set speed(double speed);

  Future<void> selectStream(MediaStreamType type, MediaStreamSummary? selected);

  Future<MediaStreamSummary?> getSelectedStream(MediaStreamType type);

  List<MediaStreamSummary> get streams;

  Future<Uint8List?> captureFrame();

  Future<void> mute(bool muted);

  Widget buildPlayerWidget(BuildContext context);
}

enum VideoStatus {
  idle,
  initialized,
  paused,
  playing,
  completed,
  error,
}

abstract class PlaybackStateHandler {
  Future<int?> getResumeTime({required int entryId, required BuildContext context});

  Future<void> saveResumeTime({required int entryId, required int position, required double progress});
}
