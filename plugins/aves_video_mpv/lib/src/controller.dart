import 'dart:async';

import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:aves_video/aves_video.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MpvVideoController extends AvesVideoController {
  late Player _instance;
  late VideoController _controller;
  late VideoStatus _status;
  final List<StreamSubscription> _subscriptions = [];
  final StreamController<VideoStatus> _statusStreamController = StreamController.broadcast();
  final StreamController<String?> _timedTextStreamController = StreamController.broadcast();
  final AChangeNotifier _completedNotifier = AChangeNotifier();

  @override
  double get minSpeed => .25;

  @override
  double get maxSpeed => 4;

  @override
  final ValueNotifier<bool> canCaptureFrameNotifier = ValueNotifier(true);

  @override
  final ValueNotifier<bool> canMuteNotifier = ValueNotifier(true);

  @override
  final ValueNotifier<bool> canSetSpeedNotifier = ValueNotifier(true);

  @override
  final ValueNotifier<bool> canSelectStreamNotifier = ValueNotifier(false);

  @override
  final ValueNotifier<double?> sarNotifier = ValueNotifier(null);

  MpvVideoController(
    super.entry, {
    required super.playbackStateHandler,
    required super.settings,
  }) {
    _status = VideoStatus.idle;
    _statusStreamController.add(_status);

    _instance = Player(
      configuration: const PlayerConfiguration(
        libass: false,
        logLevel: MPVLogLevel.warn,
      ),
    );
    _initController();
    _init();

    _startListening();
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    _stopListening();
    _stopStreamFetchTimer();
    await _statusStreamController.close();
    await _timedTextStreamController.close();
    await _instance.dispose();
  }

  void _startListening() {
    _subscriptions.add(statusStream.listen((v) => _status = v));
    _subscriptions.add(_instance.stream.completed.listen((v) {
      if (v) {
        _statusStreamController.add(VideoStatus.completed);
        _completedNotifier.notify();
      }
    }));
    _subscriptions.add(_instance.stream.playing.listen((v) {
      if (status == VideoStatus.idle) return;
      _statusStreamController.add(v ? VideoStatus.playing : VideoStatus.paused);
    }));
    _subscriptions.add(_instance.stream.videoParams.listen((v) => sarNotifier.value = v.par));
    _subscriptions.add(_instance.stream.log.listen((v) => debugPrint('libmpv log: $v')));
    _subscriptions.add(_instance.stream.error.listen((v) => debugPrint('libmpv error: $v')));
    _subscriptions.add(settings.updateStream.where((event) => event.key == SettingKeys.enableVideoHardwareAccelerationKey).listen((_) => _initController()));
    _subscriptions.add(settings.updateStream.where((event) => event.key == SettingKeys.videoLoopModeKey).listen((_) => _applyLoop()));
  }

  void _stopListening() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  Future<void> _applyLoop() async {
    final loopEnabled = settings.videoLoopMode.shouldLoop(entry.durationMillis);
    await _instance.setPlaylistMode(loopEnabled ? PlaylistMode.single : PlaylistMode.none);
  }

  Future<void> _init({int startMillis = 0}) async {
    final playing = _instance.state.playing;

    await _applyLoop();
    await _instance.open(Media(entry.uri), play: playing);
    if (startMillis > 0) {
      await seekTo(startMillis);
    }

    _fetchStreams();
    _statusStreamController.add(_instance.state.playing ? VideoStatus.playing : VideoStatus.paused);
  }

  void _initController() {
    _controller = VideoController(
      _instance,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: settings.enableVideoHardwareAcceleration,
      ),
    );
  }

  @override
  void onVisualChanged() => _init(startMillis: currentPosition);

  @override
  Future<void> play() async {
    await untilReady;
    await _instance.play();
  }

  @override
  Future<void> pause() => _instance.pause();

  @override
  Future<void> seekTo(int targetMillis) async {
    if (!isReady) {
      await untilReady;
      // When the player gets ready, it can play from the beginning right away,
      // but trying to seek then just plays from the start.
      // There is no state or hook identifying readiness to seek on start,
      // and `PlayerConfiguration.ready` hook is useless.
      await Future.delayed(const Duration(milliseconds: 500));
    }
    await _instance.seek(Duration(milliseconds: targetMillis));
  }

  @override
  Listenable get playCompletedListenable => _completedNotifier;

  @override
  VideoStatus get status => _status;

  @override
  Stream<VideoStatus> get statusStream => _statusStreamController.stream;

  @override
  Stream<double> get volumeStream => _instance.stream.volume;

  @override
  Stream<double> get speedStream => _instance.stream.rate;

  @override
  bool get isReady {
    switch (_status) {
      case VideoStatus.error:
      case VideoStatus.idle:
      case VideoStatus.initialized:
        return false;
      case VideoStatus.paused:
      case VideoStatus.playing:
      case VideoStatus.completed:
        return true;
    }
  }

  @override
  int get duration => _instance.state.duration.inMilliseconds;

  @override
  int get currentPosition => _instance.state.position.inMilliseconds;

  @override
  Stream<int> get positionStream => _instance.stream.position.map((pos) => pos.inMilliseconds);

  @override
  Stream<String?> get timedTextStream => _instance.stream.subtitle.map((v) => v.isEmpty ? null : v[0]);

  @override
  bool get isMuted => _instance.state.volume == 0;

  @override
  Future<void> mute(bool muted) => _instance.setVolume(muted ? 0 : 100);

  @override
  double get speed => _instance.state.rate;

  @override
  set speed(double speed) => _instance.setRate(speed);

  @override
  Future<Uint8List?> captureFrame() => _instance.screenshot();

  @override
  Widget buildPlayerWidget(BuildContext context) {
    return ValueListenableBuilder<double?>(
      valueListenable: sarNotifier,
      builder: (context, sar, child) {
        if (sar == null) return const SizedBox();

        // derive DAR (Display Aspect Ratio) from SAR (Storage Aspect Ratio), if any
        // e.g. 960x536 (~16:9) with SAR 4:3 should be displayed as ~2.39:1
        final dar = entry.displayAspectRatio * sar;
        return Video(
          controller: _controller,
          fill: Colors.transparent,
          aspectRatio: dar,
          controls: NoVideoControls,
          wakelock: false,
          subtitleViewConfiguration: const SubtitleViewConfiguration(
            style: TextStyle(color: Colors.transparent),
          ),
        );
      },
    );
  }

  // streams (aka tracks)

  // `auto` and `no` are the first 2 tracks in the player state track lists
  static const int fakeTrackCount = 2;

  Tracks get _tracks => _instance.state.tracks;

  List<VideoTrack> get _videoTracks => _tracks.video.skip(fakeTrackCount).toList();

  List<AudioTrack> get _audioTracks => _tracks.audio.skip(fakeTrackCount).toList();

  List<SubtitleTrack> get _subtitleTracks => _tracks.subtitle.skip(fakeTrackCount).toList();

  @override
  List<MediaStreamSummary> get streams {
    return {
      ..._videoTracks.mapIndexed((i, v) => v.toAves(i)),
      ..._audioTracks.mapIndexed((i, v) => v.toAves(i)),
      ..._subtitleTracks.mapIndexed((i, v) => v.toAves(i)),
    }.toList();
  }

  Timer? _streamFetchTimer;

  void _stopStreamFetchTimer() {
    _streamFetchTimer?.cancel();
    _streamFetchTimer = null;
  }

  void _fetchStreams() {
    _stopStreamFetchTimer();
    _streamFetchTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (status != VideoStatus.error) {
        if (_videoTracks.isEmpty && _audioTracks.isEmpty) return;

        final videoStreamCount = _videoTracks.length;
        final audioStreamCount = _audioTracks.length;
        final textStreamCount = _subtitleTracks.length;
        canSelectStreamNotifier.value = videoStreamCount > 1 || audioStreamCount > 1 || textStreamCount > 0;
      }
      _stopStreamFetchTimer();
    });
  }

  @override
  Future<MediaStreamSummary?> getSelectedStream(MediaStreamType type) async {
    final track = _instance.state.track;
    switch (type) {
      case MediaStreamType.video:
        final video = track.video;
        if (video != VideoTrack.no()) {
          final index = video == VideoTrack.auto() ? 0 : _videoTracks.indexOf(video);
          return video.toAves(index);
        }
      case MediaStreamType.audio:
        final audio = track.audio;
        if (audio != AudioTrack.no()) {
          final index = audio == AudioTrack.auto() ? 0 : _audioTracks.indexOf(audio);
          return audio.toAves(index);
        }
      case MediaStreamType.text:
        final subtitle = track.subtitle;
        if (subtitle != SubtitleTrack.no()) {
          final index = subtitle == SubtitleTrack.auto() ? 0 : _subtitleTracks.indexOf(subtitle);
          return subtitle.toAves(index);
        }
    }
    return null;
  }

  @override
  Future<void> selectStream(MediaStreamType type, MediaStreamSummary? selected) async {
    final current = await getSelectedStream(type);
    if (current == selected) return;

    if (selected != null) {
      final newIndex = selected.index;
      if (newIndex != null) {
        // select track
        switch (type) {
          case MediaStreamType.video:
            await _instance.setVideoTrack(_videoTracks[selected.index ?? 0]);
            break;
          case MediaStreamType.audio:
            await _instance.setAudioTrack(_audioTracks[selected.index ?? 0]);
            break;
          case MediaStreamType.text:
            await _instance.setSubtitleTrack(_subtitleTracks[selected.index ?? 0]);
            break;
        }
      }
    } else if (current != null) {
      // deselect track
      switch (type) {
        case MediaStreamType.video:
          await _instance.setVideoTrack(VideoTrack.no());
          break;
        case MediaStreamType.audio:
          await _instance.setAudioTrack(AudioTrack.no());
          break;
        case MediaStreamType.text:
          await _instance.setSubtitleTrack(SubtitleTrack.no());
          break;
      }
    }
  }
}

extension ExtraVideoTrack on VideoTrack {
  MediaStreamSummary toAves(int index) {
    return MediaStreamSummary(
      type: MediaStreamType.video,
      index: index,
      codecName: null,
      language: language,
      title: title,
      width: null,
      height: null,
    );
  }
}

extension ExtraAudioTrack on AudioTrack {
  MediaStreamSummary toAves(int index) {
    return MediaStreamSummary(
      type: MediaStreamType.audio,
      index: index,
      codecName: null,
      language: language,
      title: title,
      width: null,
      height: null,
    );
  }
}

extension ExtraSubtitleTrack on SubtitleTrack {
  MediaStreamSummary toAves(int index) {
    return MediaStreamSummary(
      type: MediaStreamType.text,
      index: index,
      codecName: null,
      language: language,
      title: title,
      width: null,
      height: null,
    );
  }
}
