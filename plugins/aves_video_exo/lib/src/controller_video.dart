import 'dart:async';

import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class ExoVideoController extends AvesVideoController {
  late VideoPlayerController _controller;
  late PlaybackStatus _status;
  final List<StreamSubscription> _subscriptions = [];
  final StreamController<PlaybackStatus> _statusStreamController = StreamController.broadcast();
  final StreamController<VideoEvent> _eventStreamController = StreamController.broadcast();
  final StreamController<String?> _timedTextStreamController = StreamController.broadcast();
  final AChangeNotifier _completedNotifier = AChangeNotifier();
  final StreamController<VideoPlayerValue> _playerValueStreamController = StreamController.broadcast();

  @override
  double get minSpeed => .25;

  @override
  double get maxSpeed => 4;

  @override
  final ValueNotifier<bool> canCaptureFrameNotifier = ValueNotifier(false);

  @override
  final ValueNotifier<bool> canMuteNotifier = ValueNotifier(false);

  @override
  final ValueNotifier<bool> canSetSpeedNotifier = ValueNotifier(true);

  @override
  final ValueNotifier<bool> canSelectTrackNotifier = ValueNotifier(false);

  @override
  final ValueNotifier<double?> sarNotifier = ValueNotifier(null);

  new(
    super.entry, {
    required super.playbackStateHandler,
    required super.settings,
  }) {
    _status = .idle;
    _statusStreamController.add(_status);
    _initController();

    _startListening();
    _init();
  }

  @override
  Future<void> dispose() async {
    _stopListening();
    await _statusStreamController.close();
    await _timedTextStreamController.close();
    await _playerValueStreamController.close();
    await _controller.dispose();

    _completedNotifier.dispose();
    canCaptureFrameNotifier.dispose();
    canMuteNotifier.dispose();
    canSetSpeedNotifier.dispose();
    canSelectTrackNotifier.dispose();
    sarNotifier.dispose();

    await super.dispose();
  }

  void _startListening() {
    _subscriptions.add(
      statusStream.distinct().listen((v) {
        _status = v;
        if (_status == .completed) {
          _completedNotifier.notify();
        }
      }),
    );

    final settingsStream = settings.updateStream;
    _subscriptions.add(settingsStream.where((event) => event.key == SettingKeys.videoLoopModeKey).listen((_) => _applyLoop()));

    _controller.addListener(_onControllerStateChanged);
  }

  void _stopListening() {
    _controller.removeListener(_onControllerStateChanged);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  Future<void> _applyLoop() => enableLoop(settings.videoLoopMode.shouldLoop(entry));

  Future<void> _init() async {
    _onControllerStateChanged();
    await _applyLoop();
    await _controller.initialize();
  }

  void _initController() {
    _controller = VideoPlayerController.contentUri(Uri.parse(entry.uri));
  }

  void _onControllerStateChanged() {
    final value = _controller.value;
    _playerValueStreamController.add(value);

    final status = _getStatusFromPlayerValue(value);
    _statusStreamController.add(status);
  }

  static PlaybackStatus _getStatusFromPlayerValue(VideoPlayerValue value) {
    if (value.hasError) {
      return .error;
    } else if (!value.isInitialized) {
      return .idle;
    } else if (value.isCompleted) {
      return .completed;
    } else if (value.isPlaying) {
      return .playing;
    } else {
      return .paused;
    }
  }

  @override
  void onVisualChanged() {
    // TODO TLAD
  }

  @override
  Future<void> enableLoop(bool enabled) => _controller.setLooping(enabled);

  @override
  Future<void> play() async {
    await untilReady;
    await _controller.play();
  }

  @override
  Future<void> pause() async {
    await _controller.pause();
  }

  @override
  Future<void> seekTo(int targetMillis) async {
    await _controller.seekTo(Duration(milliseconds: targetMillis));
  }

  @override
  Future<void> skipFrames(int frameCount) async {
    // TODO TLAD
  }

  @override
  Listenable get playCompletedListenable => _completedNotifier;

  @override
  PlaybackStatus get status => _status;

  @override
  Stream<PlaybackStatus> get statusStream => _statusStreamController.stream;

  @override
  Stream<VideoEvent> get eventStream => _eventStreamController.stream;

  @override
  Stream<double> get volumeStream => _playerValueStreamController.stream.map((v) => v.volume).distinct();

  @override
  Stream<double> get speedStream => _playerValueStreamController.stream.map((v) => v.playbackSpeed).distinct();

  @override
  bool get isReady => _controller.value.isInitialized;

  @override
  int get duration => _controller.value.duration.inMilliseconds;

  @override
  int get currentPosition => _controller.value.position.inMilliseconds;

  @override
  Stream<int> get positionStream => _playerValueStreamController.stream.map((v) => v.position.inMilliseconds).distinct();

  @override
  Stream<String?> get timedTextStream => _timedTextStreamController.stream;

  @override
  bool get isMuted => false;

  @override
  Future<void> mute(bool muted) async {
    // TODO TLAD
  }

  @override
  double get speed => _controller.value.playbackSpeed;

  @override
  Future<void> setSpeed(double speed) => _controller.setPlaybackSpeed(speed);

  @override
  Future<Uint8List?> captureFrame() async {
    // TODO TLAD
    return null;
  }

  @override
  Widget buildPlayerWidget(BuildContext context) {
    final isInitialized = _controller.value.isInitialized;
    if (isInitialized) {
      return VideoPlayer(_controller);
    }
    return const SizedBox();
  }

  // streams (aka tracks)

  @override
  // TODO TLAD
  List<MediaTrackSummary> get tracks => [];

  @override
  Future<MediaTrackSummary?> getSelectedTrack(MediaTrackType type) async {
    // TODO TLAD
    return null;
  }

  @override
  Future<void> selectTrack(MediaTrackType type, MediaTrackSummary? selected) async {
    // TODO TLAD
  }
}
