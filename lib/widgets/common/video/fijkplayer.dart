import 'dart:async';
import 'dart:ui';

import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/settings/video_loop_mode.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/widgets/common/video/controller.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

class IjkPlayerAvesVideoController extends AvesVideoController {
  FijkPlayer _instance;
  final List<StreamSubscription> _subscriptions = [];
  final StreamController<FijkValue> _valueStreamController = StreamController.broadcast();
  final AChangeNotifier _completedNotifier = AChangeNotifier();
  Offset _macroBlockCrop = Offset.zero;

  Stream<FijkValue> get _valueStream => _valueStreamController.stream;

  IjkPlayerAvesVideoController(AvesEntry entry) {
    _instance = FijkPlayer();

    // FFmpeg options
    // cf https://github.com/Bilibili/ijkplayer/blob/master/ijkmedia/ijkplayer/ff_ffplay_options.h
    // cf https://www.jianshu.com/p/843c86a9e9ad

    final option = FijkOption();

    // when accurate seek is enabled and seeking fails, it takes time (cf `accurate-seek-timeout`) to acknowledge the error and proceed
    // failure seems to happen when pause-seeking videos with an audio stream, whatever container or video stream
    // player cannot be dynamically set to use accurate seek only when playing
    const accurateSeekEnabled = false;

    // when HW acceleration is enabled, videos with dimensions that do not fit 16x macroblocks need cropping
    // TODO TLAD HW codecs sometimes fail when seek-starting some videos, e.g. MP2TS/h264(HDPR)
    final hwAccelerationEnabled = settings.isVideoHardwareAccelerationEnabled;
    if (hwAccelerationEnabled) {
      final s = entry.displaySize % 16 * -1 % 16;
      _macroBlockCrop = Offset(s.width, s.height);
    }

    final loopEnabled = settings.videoLoopMode.shouldLoop(entry);

    // `fastseek`: enable fast, but inaccurate seeks for some formats
    // in practice the flag seems ineffective, but harmless too
    option.setFormatOption('fflags', 'fastseek');

    // `enable-accurate-seek`: enable accurate seek, default: 0, in [0, 1]
    option.setPlayerOption('enable-accurate-seek', accurateSeekEnabled ? 1 : 0);

    // `accurate-seek-timeout`: accurate seek timeout, default: 5000 ms, in [0, 5000]
    option.setPlayerOption('accurate-seek-timeout', 1000);

    // `framedrop`: drop frames when cpu is too slow, default: 0, in [-1, 120]
    option.setPlayerOption('framedrop', 5);

    // `loop`: set number of times the playback shall be looped, default: 1, in [INT_MIN, INT_MAX]
    option.setPlayerOption('loop', loopEnabled ? -1 : 1);

    // `mediacodec-all-videos`: MediaCodec: enable all videos, default: 0, in [0, 1]
    option.setPlayerOption('mediacodec-all-videos', hwAccelerationEnabled ? 1 : 0);

    _instance.applyOptions(option);

    _instance.addListener(_onValueChanged);
    _subscriptions.add(_valueStream.where((value) => value.state == FijkState.completed).listen((_) => _completedNotifier.notifyListeners()));
  }

  @override
  void dispose() {
    _instance.removeListener(_onValueChanged);
    _valueStreamController.close();
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _instance.release();
  }

  void _onValueChanged() => _valueStreamController.add(_instance.value);

  // enable autoplay, even when seeking on uninitialized player, otherwise the texture is not updated
  // as a workaround, pausing after a brief duration is possible, but fiddly
  @override
  Future<void> setDataSource(String uri, {int startMillis = 0}) async {
    if (startMillis > 0) {
      // `seek-at-start`: set offset of player should be seeked, default: 0, in [0, INT_MAX]
      await _instance.setOption(FijkOption.playerCategory, 'seek-at-start', startMillis);
    }
    await _instance.setDataSource(uri, autoPlay: true);
  }

  @override
  Future<void> play() => _instance.start();

  @override
  Future<void> pause() => _instance.pause();

  @override
  Future<void> seekTo(int targetMillis) => _instance.seekTo(targetMillis);

  @override
  Listenable get playCompletedListenable => _completedNotifier;

  @override
  VideoStatus get status => _instance.state.toAves;

  @override
  Stream<VideoStatus> get statusStream => _valueStream.map((value) => value.state.toAves);

  @override
  bool get isPlayable => _instance.isPlayable();

  @override
  int get duration => _instance.value.duration.inMilliseconds;

  @override
  int get currentPosition => _instance.currentPos.inMilliseconds;

  @override
  Stream<int> get positionStream => _instance.onCurrentPosUpdate.map((pos) => pos.inMilliseconds);

  @override
  Widget buildPlayerWidget(BuildContext context, AvesEntry entry) {
    return FijkView(
      player: _instance,
      fit: FijkFit(
        sizeFactor: 1.0,
        aspectRatio: -1,
        alignment: Alignment.topLeft,
        macroBlockCrop: _macroBlockCrop,
      ),
      panelBuilder: (player, data, context, viewSize, texturePos) => SizedBox(),
      color: Colors.transparent,
    );
  }
}

extension ExtraIjkStatus on FijkState {
  VideoStatus get toAves {
    switch (this) {
      case FijkState.idle:
      case FijkState.end:
      case FijkState.stopped:
        return VideoStatus.idle;
      case FijkState.initialized:
      case FijkState.asyncPreparing:
        return VideoStatus.initialized;
      case FijkState.prepared:
      case FijkState.paused:
        return VideoStatus.paused;
      case FijkState.started:
        return VideoStatus.playing;
      case FijkState.completed:
        return VideoStatus.completed;
      case FijkState.error:
        return VideoStatus.error;
    }
    return VideoStatus.idle;
  }
}
