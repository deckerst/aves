import 'dart:typed_data';

import 'package:aves/model/entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class AvesVideoController {
  final AvesEntry _entry;

  AvesEntry get entry => _entry;

  AvesVideoController(AvesEntry entry) : _entry = entry;

  Future<void> dispose();

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(int targetMillis);

  Future<void> seekToProgress(double progress) => seekTo((duration * progress).toInt());

  Listenable get playCompletedListenable;

  VideoStatus get status;

  Stream<VideoStatus> get statusStream;

  ValueNotifier<bool> get renderingVideoNotifier;

  bool get isReady;

  bool get isPlaying => status == VideoStatus.playing;

  int get duration;

  int get currentPosition;

  double get progress => currentPosition.toDouble() / duration;

  Stream<int> get positionStream;

  Stream<String?> get timedTextStream;

  ValueNotifier<double> get sarNotifier;

  double get speed;

  double get minSpeed;

  double get maxSpeed;

  set speed(double speed);

  Future<void> selectStream(StreamType type, StreamSummary? selected);

  Future<StreamSummary?> getSelectedStream(StreamType type);

  Map<StreamSummary, bool> get streams;

  Future<Uint8List> captureFrame();

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
