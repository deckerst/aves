import 'package:aves/model/entry.dart';
// import 'package:aves/widgets/common/video/fijkplayer.dart';
import 'package:aves/widgets/common/video/flutter_ijkplayer.dart';
import 'package:flutter/material.dart';

abstract class AvesVideoController {
  AvesVideoController();

  factory AvesVideoController.flutterIjkPlayer() => FlutterIjkPlayerAvesVideoController();

  // factory AvesVideoController.fijkPlayer() => FijkPlayerAvesVideoController();

  void dispose();

  Future<void> setDataSource(String uri);

  Future<void> refreshVideoInfo();

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(int targetMillis);

  Future<void> seekToProgress(double progress);

  Listenable get playCompletedListenable;

  VideoStatus get status;

  Stream<VideoStatus> get statusStream;

  bool get isPlayable;

  bool get isPlaying => status == VideoStatus.playing;

  bool get isVideoReady;

  Stream<bool> get isVideoReadyStream;

  int get duration;

  int get currentPosition;

  double get progress => (currentPosition ?? 0).toDouble() / (duration ?? 1);

  Stream<int> get positionStream;

  Widget buildPlayerWidget(AvesEntry entry);
}

class AvesVideoInfo {
  // in millis
  int duration, currentPosition;

  AvesVideoInfo({
    this.duration,
    this.currentPosition,
  });
}

enum VideoStatus {
  idle,
  initialized,
  preparing,
  prepared,
  playing,
  paused,
  completed,
  stopped,
  disposed,
  error,
}
