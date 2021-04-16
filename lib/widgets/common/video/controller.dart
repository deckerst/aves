import 'package:aves/model/entry.dart';
import 'package:flutter/material.dart';

abstract class AvesVideoController {
  AvesVideoController();

  void dispose();

  Future<void> setDataSource(String uri, {int startMillis = 0});

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(int targetMillis);

  Future<void> seekToProgress(double progress) async {
    if (duration != null) {
      await seekTo((duration * progress).toInt());
    }
  }

  Listenable get playCompletedListenable;

  VideoStatus get status;

  Stream<VideoStatus> get statusStream;

  bool get isPlayable;

  bool get isPlaying => status == VideoStatus.playing;

  int get duration;

  int get currentPosition;

  double get progress => duration == null ? 0 : (currentPosition ?? 0).toDouble() / duration;

  Stream<int> get positionStream;

  Widget buildPlayerWidget(BuildContext context, AvesEntry entry);
}

enum VideoStatus {
  idle,
  initialized,
  paused,
  playing,
  completed,
  error,
}
