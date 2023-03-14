import 'dart:async';

import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class AvesVideoController {
  final AvesEntryBase _entry;
  final PlaybackStateHandler playbackStateHandler;

  AvesEntryBase get entry => _entry;

  static const resumeTimeSaveMinDuration = Duration(minutes: 2);

  AvesVideoController(AvesEntryBase entry, {required this.playbackStateHandler}) : _entry = entry {
    entry.visualChangeNotifier.addListener(onVisualChanged);
  }

  @mustCallSuper
  Future<void> dispose() async {
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

  Future<void> seekToProgress(double progress) => seekTo((duration * progress).toInt());

  Listenable get playCompletedListenable;

  VideoStatus get status;

  Stream<VideoStatus> get statusStream;

  Stream<double> get volumeStream;

  Stream<double> get speedStream;

  bool get isReady;

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

  ValueNotifier<double> get sarNotifier;

  bool get isMuted;

  double get speed;

  double get minSpeed;

  double get maxSpeed;

  set speed(double speed);

  Future<void> selectStream(StreamType type, StreamSummary? selected);

  Future<StreamSummary?> getSelectedStream(StreamType type);

  List<StreamSummary> get streams;

  Future<Uint8List> captureFrame();

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

enum StreamType { video, audio, text }

class StreamSummary {
  final StreamType type;
  final int? index, width, height;
  final String? codecName, language, title;

  const StreamSummary({
    required this.type,
    required this.index,
    required this.codecName,
    required this.language,
    required this.title,
    required this.width,
    required this.height,
  });

  @override
  String toString() => '$runtimeType#${shortHash(this)}{type: type, index: $index, codecName: $codecName, language: $language, title: $title, width: $width, height: $height}';
}

abstract class PlaybackStateHandler {
  Future<int?> getResumeTime({required int entryId, required BuildContext context});

  Future<void> saveResumeTime({required int entryId, required int position, required double progress});
}
