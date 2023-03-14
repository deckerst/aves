import 'dart:async';

import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/enums/video_loop_mode.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/video/keys.dart';
import 'package:aves/model/video/metadata.dart';
import 'package:aves/services/common/optional_event_channel.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves_video/aves_video.dart';
import 'package:collection/collection.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IjkPlayerAvesVideoController extends AvesVideoController {
  final EventChannel _eventChannel = const OptionalEventChannel('befovy.com/fijk/event');

  late FijkPlayer _instance;
  final List<StreamSubscription> _subscriptions = [];
  final StreamController<FijkValue> _valueStreamController = StreamController.broadcast();
  final StreamController<String?> _timedTextStreamController = StreamController.broadcast();
  final StreamController<double> _volumeStreamController = StreamController.broadcast();
  final StreamController<double> _speedStreamController = StreamController.broadcast();
  final AChangeNotifier _completedNotifier = AChangeNotifier();
  Offset _macroBlockCrop = Offset.zero;
  final List<StreamSummary> _streams = [];
  Timer? _initialPlayTimer;
  double _speed = 1;
  double _volume = 1;

  // audio/video get out of sync with speed < .5
  // the video stream plays at .5 but the audio is slowed as requested
  @override
  final double minSpeed = .5;

  // ijkplayer configures `AudioTrack` buffer for a maximum speed of 2
  // but `SoundTouch` can go higher
  @override
  final double maxSpeed = 2;

  @override
  final ValueNotifier<bool> canCaptureFrameNotifier = ValueNotifier(false);

  @override
  final ValueNotifier<bool> canMuteNotifier = ValueNotifier(false);

  @override
  final ValueNotifier<bool> canSetSpeedNotifier = ValueNotifier(false);

  @override
  final ValueNotifier<bool> canSelectStreamNotifier = ValueNotifier(false);

  @override
  final ValueNotifier<double> sarNotifier = ValueNotifier(1);

  Stream<FijkValue> get _valueStream => _valueStreamController.stream;

  static const initialPlayDelay = Duration(milliseconds: 100);
  static const gifLikeVideoDurationThreshold = Duration(seconds: 10);
  static const gifLikeBitRateThreshold = 2 << 18; // 512kB/s (4Mb/s)
  static const captureFrameEnabled = true;

  IjkPlayerAvesVideoController(
    super.entry, {
    required super.playbackStateHandler,
  }) {
    _instance = FijkPlayer();
    _valueStream.map((value) => value.videoRenderStart).firstWhere((v) => v, orElse: () => false).then(
      (started) {
        canCaptureFrameNotifier.value = captureFrameEnabled && started;
      },
      onError: (error) {},
    );
    _valueStream.map((value) => value.audioRenderStart).firstWhere((v) => v, orElse: () => false).then(
      (started) {
        canMuteNotifier.value = started;
        canSetSpeedNotifier.value = started;
      },
      onError: (error) {},
    );
    _startListening();
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    _initialPlayTimer?.cancel();
    _stopListening();
    await _valueStreamController.close();
    await _timedTextStreamController.close();
    await _instance.release();
  }

  void _startListening() {
    _instance.addListener(_onValueChanged);
    _subscriptions.add(_eventChannel.receiveBroadcastStream().listen((event) => _onPluginEvent(event as Map?)));
    _subscriptions.add(_valueStream.where((value) => value.state == FijkState.completed).listen((_) => _completedNotifier.notify()));
    _subscriptions.add(_instance.onTimedText.listen(_timedTextStreamController.add));
    _subscriptions.add(settings.updateStream
        .where((event) => {
              Settings.enableVideoHardwareAccelerationKey,
              Settings.videoLoopModeKey,
            }.contains(event.key))
        .listen((_) => _instance.reset()));
  }

  void _stopListening() {
    _instance.removeListener(_onValueChanged);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  Future<void> _init({int startMillis = 0}) async {
    if (isReady) {
      _stopListening();
      await _instance.release();
      _instance = FijkPlayer();
      _startListening();
    }

    sarNotifier.value = 1;
    _streams.clear();
    _applyOptions(startMillis);

    // calling `setDataSource()` with `autoPlay` starts as soon as possible, but often yields initial artifacts
    // so we introduce a small delay after the player is declared `prepared`, before playing
    await _instance.setDataSourceUntilPrepared(entry.uri);
    await _applyVolume();
    if (speed != 1) {
      await _applySpeed();
    }
    _initialPlayTimer = Timer(initialPlayDelay, play);
  }

  void _applyOptions(int startMillis) {
    // FFmpeg options
    // `setHostOption`, cf:
    // - https://fijkplayer.befovy.com/docs/zh/host-option.html
    // - https://github.com/deckerst/fijkplayer/blob/master/android/src/main/java/com/befovy/fijkplayer/HostOption.java
    // `setFormatOption`, cf https://github.com/FFmpeg/FFmpeg/blob/master/libavcodec/options_table.h
    // `setCodecOption`, cf https://github.com/FFmpeg/FFmpeg/blob/master/libavformat/options_table.h
    // `setSwsOption`, cf https://github.com/FFmpeg/FFmpeg/blob/master/libswscale/options.c
    // `setPlayerOption`, cf https://github.com/Bilibili/ijkplayer/blob/master/ijkmedia/ijkplayer/ff_ffplay_options.h
    // cf https://www.jianshu.com/p/843c86a9e9ad
    // cf https://www.jianshu.com/p/3649c073b346

    final options = FijkOption();

    // when accurate seek is enabled and seeking fails, it takes time (cf `accurate-seek-timeout`) to acknowledge the error and proceed
    // failure seems to happen when pause-seeking videos with an audio stream, whatever container or video stream
    // player cannot be dynamically set to use accurate seek only when playing
    const accurateSeekEnabled = false;

    // playing with HW acceleration seems to skip the last frames of some videos
    // so HW acceleration is always disabled for GIF-like videos where the last frames may be significant
    final hwAccelerationEnabled = settings.enableVideoHardwareAcceleration && !_isGifLike();

    // TODO TLAD [video] flaky: HW codecs sometimes fail when seek-starting some videos, e.g. MP2TS/h264(HDPR)
    if (hwAccelerationEnabled) {
      // when HW acceleration is enabled, videos with dimensions that do not fit 16x macroblocks need cropping
      // TODO TLAD [video] flaky: not all formats/devices need this correction, e.g. 498x278 MP4 on S7, 408x244 WEBM on S10e do not
      final s = entry.displaySize % 16 * -1 % 16;
      _macroBlockCrop = Offset(s.width, s.height);
    }

    final loopEnabled = settings.videoLoopMode.shouldLoop(entry.durationMillis);

    // `fastseek`: enable fast, but inaccurate seeks for some formats
    // in practice the flag seems ineffective, but harmless too
    options.setFormatOption('fflags', 'fastseek');

    // `enable-snapshot`: enable snapshot interface
    // default: 0, in [0, 1]
    // there is a performance cost, and it should be set up before playing
    options.setHostOption('enable-snapshot', captureFrameEnabled ? 1 : 0);

    // default: 0, in [0, 1]
    options.setHostOption('request-audio-focus', 1);

    // default: 0, in [0, 1]
    options.setHostOption('release-audio-focus', 1);

    // `accurate-seek-timeout`: accurate seek timeout
    // default: 5000 ms, in [0, 5000]
    options.setPlayerOption('accurate-seek-timeout', 1000);

    // `cover-after-prepared`: show cover provided to `FijkView` when player is `prepared` without auto play
    // default: 0, in [0, 1]
    options.setPlayerOption('cover-after-prepared', 0);

    // `enable-accurate-seek`: enable accurate seek
    // default: 0, in [0, 1]
    // ignore: dead_code
    options.setPlayerOption('enable-accurate-seek', accurateSeekEnabled ? 1 : 0);

    // `min-frames`: minimal frames to stop pre-reading
    // default: 50000, in [2, 50000]
    // a comment in `IjkMediaPlayer.java` recommends setting this to 25 when de/selecting streams
    options.setPlayerOption('min-frames', 25);

    // `framedrop`: drop frames when cpu is too slow
    // default: 0, in [-1, 120]
    options.setPlayerOption('framedrop', 5);

    // `loop`: set number of times the playback shall be looped
    // default: 1, in [INT_MIN, INT_MAX]
    options.setPlayerOption('loop', loopEnabled ? -1 : 1);

    // `mediacodec-all-videos`: MediaCodec: enable all videos
    // default: 0, in [0, 1]
    options.setPlayerOption('mediacodec-all-videos', hwAccelerationEnabled ? 1 : 0);

    // `seek-at-start`: set offset of player should be seeked
    // default: 0, in [0, INT_MAX]
    options.setPlayerOption('seek-at-start', startMillis);

    // `soundtouch`: enable SoundTouch
    // default: 0, in [0, 1]
    // `SoundTouch` cannot be enabled/disabled after video is `prepared`
    // When `SoundTouch` is enabled:
    // - slowed down videos have a weird wobbly audio
    // - we can set speeds higher than the `AudioTrack` limit of 2
    options.setPlayerOption('soundtouch', _needSoundTouch(speed) ? 1 : 0);

    // `subtitle`: decode subtitle stream
    // default: 0, in [0, 1]
    options.setPlayerOption('subtitle', 1);

    _instance.applyOptions(options);
  }

  bool _isGifLike() {
    // short
    final durationSecs = (entry.durationMillis ?? 0) ~/ 1000;
    if (durationSecs == 0) return false;
    if (durationSecs > gifLikeVideoDurationThreshold.inSeconds) return false;

    // light
    final sizeBytes = entry.sizeBytes;
    if (sizeBytes == null) return false;
    if (sizeBytes / durationSecs > gifLikeBitRateThreshold) return false;

    return true;
  }

  void _fetchStreams() async {
    final mediaInfo = await _instance.getInfo();
    if (!mediaInfo.containsKey(Keys.streams)) return;

    var videoStreamCount = 0, audioStreamCount = 0, textStreamCount = 0;

    _streams.clear();
    final allStreams = (mediaInfo[Keys.streams] as List).cast<Map>();
    allStreams.forEach((stream) {
      final type = ExtraStreamType.fromTypeString(stream[Keys.streamType]);
      if (type != null) {
        final width = stream[Keys.width] as int?;
        final height = stream[Keys.height] as int?;
        _streams.add(StreamSummary(
          type: type,
          index: stream[Keys.index],
          codecName: stream[Keys.codecName],
          language: stream[Keys.language],
          title: stream[Keys.title],
          width: width,
          height: height,
        ));
        switch (type) {
          case StreamType.video:
            // check width/height to exclude image streams (that are included among video streams)
            if (width != null && height != null) {
              videoStreamCount++;
            }
            break;
          case StreamType.audio:
            audioStreamCount++;
            break;
          case StreamType.text:
            textStreamCount++;
            break;
        }
      }
    });

    canSelectStreamNotifier.value = videoStreamCount > 1 || audioStreamCount > 1 || textStreamCount > 0;

    final selectedVideo = await getSelectedStream(StreamType.video);
    if (selectedVideo != null) {
      final streamIndex = selectedVideo.index;
      final streamInfo = allStreams.firstWhereOrNull((stream) => stream[Keys.index] == streamIndex);
      if (streamInfo != null) {
        final num = streamInfo[Keys.sarNum] ?? 0;
        final den = streamInfo[Keys.sarDen] ?? 0;
        sarNotifier.value = (num != 0 ? num : 1) / (den != 0 ? den : 1);
      }
    }
  }

  // cf https://developer.android.com/reference/android/media/AudioManager
  static const int _audioFocusLoss = -1;
  static const int _audioFocusRequestFailed = 0;

  void _onPluginEvent(Map? fields) {
    if (fields == null) return;
    final event = fields['event'] as String?;
    switch (event) {
      case 'volume':
        // ignore
        break;
      case 'audiofocus':
        final value = fields['value'] as int?;
        if (value != null) {
          switch (value) {
            case _audioFocusLoss:
            case _audioFocusRequestFailed:
              pause();
              break;
          }
        }
        break;
    }
  }

  void _onValueChanged() {
    if (_instance.state == FijkState.prepared && _streams.isEmpty) {
      _fetchStreams();
    }
    _valueStreamController.add(_instance.value);
  }

  @override
  void onVisualChanged() => _init(startMillis: currentPosition);

  @override
  Future<void> play() async {
    if (isReady) {
      await _instance.start();
    } else {
      await _init();
    }
  }

  @override
  Future<void> pause() async {
    if (isReady) {
      _initialPlayTimer?.cancel();
      await _instance.pause();
    }
  }

  @override
  Future<void> seekTo(int targetMillis) async {
    targetMillis = targetMillis.clamp(0, duration);
    if (isReady) {
      await _instance.seekTo(targetMillis);
    } else {
      // always start playing, even when seeking on uninitialized player, otherwise the texture is not updated
      // as a workaround, pausing after a brief duration is possible, but fiddly
      await _init(startMillis: targetMillis);
    }
  }

  @override
  Listenable get playCompletedListenable => _completedNotifier;

  @override
  VideoStatus get status => _instance.state.toAves;

  @override
  Stream<VideoStatus> get statusStream => _valueStream.map((value) => value.state.toAves);

  @override
  Stream<double> get volumeStream => _volumeStreamController.stream;

  @override
  Stream<double> get speedStream => _speedStreamController.stream;

  @override
  bool get isReady => _instance.isPlayable();

  @override
  int get duration {
    final controllerDuration = _instance.value.duration.inMilliseconds;
    // use expected duration when controller duration is not set yet
    return controllerDuration == 0 ? (entry.durationMillis ?? 0) : controllerDuration;
  }

  @override
  int get currentPosition => _instance.currentPos.inMilliseconds;

  @override
  Stream<int> get positionStream => _instance.onCurrentPosUpdate.map((pos) => pos.inMilliseconds);

  @override
  Stream<String?> get timedTextStream => _timedTextStreamController.stream;

  @override
  bool get isMuted => _volume == 0;

  @override
  Future<void> mute(bool muted) async {
    _volume = muted ? 0 : 1;
    _volumeStreamController.add(_volume);
    await _applyVolume();
  }

  Future<void> _applyVolume() => _instance.setVolume(_volume);

  @override
  double get speed => _speed;

  @override
  set speed(double speed) {
    if (speed <= 0 || _speed == speed) return;
    final optionChange = _needSoundTouch(speed) != _needSoundTouch(_speed);
    _speed = speed;
    _speedStreamController.add(_speed);

    if (optionChange) {
      _init(startMillis: currentPosition);
    } else {
      _applySpeed();
    }
  }

  bool _needSoundTouch(double speed) => speed > 1;

  // TODO TLAD [video] bug: setting speed fails when there is no audio stream or audio is disabled
  Future<void> _applySpeed() => _instance.setSpeed(speed);

  // When a stream is selected, the video accelerates to catch up with it.
  // The duration of this acceleration phase depends on the player `min-frames` parameter.
  // Calling `seekTo` after stream de/selection is a workaround to:
  // 1) prevent video stream acceleration to catch up with audio
  // 2) apply timed text stream
  @override
  Future<void> selectStream(StreamType type, StreamSummary? selected) async {
    final current = await getSelectedStream(type);
    if (current != selected) {
      if (selected != null) {
        final newIndex = selected.index;
        if (newIndex != null) {
          await _instance.selectTrack(newIndex);
        }
      } else if (current != null) {
        await _instance.deselectTrack(current.index!);
      }
      if (type == StreamType.text) {
        _timedTextStreamController.add(null);
      }
      await seekTo(currentPosition);
    }
  }

  @override
  Future<StreamSummary?> getSelectedStream(StreamType type) async {
    final currentIndex = await _instance.getSelectedTrack(type.code);
    return currentIndex != -1 ? _streams.firstWhereOrNull((v) => v.index == currentIndex) : null;
  }

  @override
  List<StreamSummary> get streams => _streams;

  @override
  Future<Uint8List> captureFrame() {
    if (!_instance.value.videoRenderStart) {
      return Future.error('cannot capture frame when video is not rendered');
    }
    return _instance.takeSnapShot();
  }

  @override
  Widget buildPlayerWidget(BuildContext context) {
    return ValueListenableBuilder<double>(
        valueListenable: sarNotifier,
        builder: (context, sar, child) {
          // derive DAR (Display Aspect Ratio) from SAR (Storage Aspect Ratio), if any
          // e.g. 960x536 (~16:9) with SAR 4:3 should be displayed as ~2.39:1
          final dar = entry.displayAspectRatio * sar;
          return FijkView(
            player: _instance,
            fit: FijkFit(
              sizeFactor: 1.0,
              aspectRatio: dar,
              alignment: _alignmentForRotation(entry.rotationDegrees),
              macroBlockCrop: _macroBlockCrop,
            ),
            panelBuilder: (player, data, context, viewSize, texturePos) => const SizedBox(),
            color: Colors.transparent,
          );
        });
  }

  Alignment _alignmentForRotation(int rotation) {
    switch (rotation) {
      case 90:
        return Alignment.topRight;
      case 180:
        return Alignment.bottomRight;
      case 270:
        return Alignment.bottomLeft;
      case 0:
      default:
        return Alignment.topLeft;
    }
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
  }
}

extension ExtraFijkPlayer on FijkPlayer {
  Future<void> setDataSourceUntilPrepared(String uri) async {
    await setDataSource(uri, autoPlay: false, showCover: false);

    final completer = Completer();
    void onChanged() {
      switch (state) {
        case FijkState.prepared:
          removeListener(onChanged);
          completer.complete();
          break;
        case FijkState.error:
          removeListener(onChanged);
          completer.completeError(value.exception);
          break;
        default:
          break;
      }
    }

    addListener(onChanged);
    await prepareAsync();
    return completer.future;
  }
}

extension ExtraStreamType on StreamType {
  static StreamType? fromTypeString(String? type) {
    switch (type) {
      case StreamTypes.video:
        return StreamType.video;
      case StreamTypes.audio:
        return StreamType.audio;
      case StreamTypes.subtitle:
      case StreamTypes.timedText:
        return StreamType.text;
      default:
        return null;
    }
  }

  int get code {
    // codes from ijkplayer ITrackInfo.java
    switch (this) {
      case StreamType.video:
        return 1;
      case StreamType.audio:
        return 2;
      case StreamType.text:
        // TIMEDTEXT = 3, SUBTITLE = 4
        return 3;
      default:
        // METADATA = 5, UNKNOWN = 0
        return 0;
    }
  }
}
