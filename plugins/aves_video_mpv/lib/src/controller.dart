import 'dart:async';
import 'dart:io';

import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:aves_video/aves_video.dart';
import 'package:aves_video_mpv/src/tracks.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;

class MpvVideoController extends AvesVideoController {
  late Player _instance;
  late VideoStatus _status;
  bool _firstFrameRendered = false, _abRepeatSeeking = false;
  final ValueNotifier<VideoController?> _controllerNotifier = ValueNotifier(null);
  final List<StreamSubscription> _subscriptions = [];
  final StreamController<VideoStatus> _statusStreamController = StreamController.broadcast();
  final StreamController<String?> _timedTextStreamController = StreamController.broadcast();
  final AChangeNotifier _completedNotifier = AChangeNotifier();
  final List<SubtitleTrack> _externalSubtitleTracks = [];

  static final _pContext = p.Context();

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
      configuration: PlayerConfiguration(
        title: entry.bestTitle ?? entry.uri,
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
    _controllerNotifier.dispose();

    _completedNotifier.dispose();
    canCaptureFrameNotifier.dispose();
    canMuteNotifier.dispose();
    canSetSpeedNotifier.dispose();
    canSelectStreamNotifier.dispose();
    sarNotifier.dispose();
  }

  void _startListening() {
    _subscriptions.add(statusStream.listen((v) => _status = v));

    final playerStream = _instance.stream;
    _subscriptions.add(playerStream.completed.listen((completed) {
      if (completed) {
        _statusStreamController.add(VideoStatus.completed);
        _completedNotifier.notify();
      }
    }));
    _subscriptions.add(playerStream.playing.listen((playing) {
      if (status == VideoStatus.idle) return;
      _statusStreamController.add(playing ? VideoStatus.playing : VideoStatus.paused);
    }));
    _subscriptions.add(playerStream.position.listen((v) {
      final abRepeat = abRepeatNotifier.value;
      if (abRepeat != null && status == VideoStatus.playing) {
        final start = abRepeat.start;
        final end = abRepeat.end;
        if (start != null && end != null) {
          if (v.inMilliseconds < end) {
            _abRepeatSeeking = false;
          } else if (!_abRepeatSeeking) {
            _abRepeatSeeking = true;
            _instance.seek(Duration(milliseconds: start));
          }
        }
      }
    }));
    _subscriptions.add(playerStream.subtitle.listen((v) => _timedTextStreamController.add(v.isEmpty ? null : v[0])));
    _subscriptions.add(playerStream.videoParams.listen((v) => sarNotifier.value = v.par));
    _subscriptions.add(playerStream.log.listen((v) => debugPrint('libmpv log: $v')));
    _subscriptions.add(playerStream.error.listen((v) => debugPrint('libmpv error: $v')));

    final settingsStream = settings.updateStream;
    _subscriptions.add(settingsStream.where((event) => event.key == SettingKeys.enableVideoHardwareAccelerationKey).listen((_) => _initController()));
    _subscriptions.add(settingsStream.where((event) => event.key == SettingKeys.videoLoopModeKey).listen((_) => _applyLoop()));

    final path = entry.path;
    if (path != null) {
      final videoBasename = _pContext.basenameWithoutExtension(path);
      // list subtitle files in the same directory
      // some files may be visible to the app (e.g. SRT) while others may not (e.g. SUB, VTT)
      _subscriptions.add(File(path).parent.list().where((v) => v is File && _isSubtitle(v.path)).listen((v) {
        final subtitleBasename = _pContext.basename(v.path);
        if (subtitleBasename.startsWith(videoBasename)) {
          _externalSubtitleTracks.add(SubtitleTrack.uri(
            v.uri.toString(),
            title: 'File ${subtitleBasename.substring(videoBasename.length)}',
          ));
          _externalSubtitleTracks.sort((a, b) => a.title!.compareTo(b.title!));
        }
      }));
    }
  }

  void _stopListening() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  Future<void> _applyLoop() async {
    final loopEnabled = settings.videoLoopMode.shouldLoop(entry);
    await _instance.setPlaylistMode(loopEnabled ? PlaylistMode.single : PlaylistMode.none);
  }

  Future<void> _init({int startMillis = 0}) async {
    final playing = _instance.state.playing;

    await _applyLoop();
    await _instance.open(Media(entry.uri), play: playing);
    await _instance.setSubtitleTrack(SubtitleTrack.no());
    if (startMillis > 0) {
      await seekTo(startMillis);
    }

    _fetchStreams();
    _statusStreamController.add(_instance.state.playing ? VideoStatus.playing : VideoStatus.paused);
  }

  void _initController() {
    _firstFrameRendered = false;
    _controllerNotifier.value = VideoController(
      _instance,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: settings.enableVideoHardwareAcceleration,
      ),
    )..waitUntilFirstFrameRendered.then((v) {
        _firstFrameRendered = true;
        _statusStreamController.add(_status);
      });
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
    targetMillis = abRepeatNotifier.value?.clamp(targetMillis) ?? targetMillis;
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
        return _firstFrameRendered;
    }
  }

  @override
  int get duration => _instance.state.duration.inMilliseconds;

  @override
  int get currentPosition => _instance.state.position.inMilliseconds;

  @override
  Stream<int> get positionStream => _instance.stream.position.map((pos) => pos.inMilliseconds);

  @override
  Stream<String?> get timedTextStream => _timedTextStreamController.stream;

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
        return ValueListenableBuilder<VideoController?>(
            valueListenable: _controllerNotifier,
            builder: (context, controller, child) {
              if (controller == null) return const SizedBox();
              return Video(
                controller: controller,
                fill: Colors.transparent,
                aspectRatio: dar,
                controls: NoVideoControls,
                wakelock: false,
                subtitleViewConfiguration: const SubtitleViewConfiguration(
                  visible: false,
                ),
              );
            });
      },
    );
  }

  // streams (aka tracks)

  // `auto` and `no` are the first 2 tracks in the player state track lists
  static const int fakeTrackCount = 2;

  Tracks get _tracks => _instance.state.tracks;

  List<VideoTrack> get _videoTracks => _tracks.video.skip(fakeTrackCount).toList();

  List<AudioTrack> get _audioTracks => _tracks.audio.skip(fakeTrackCount).toList();

  List<SubtitleTrack> get _subtitleTracks {
    final externalTitles = _externalSubtitleTracks.map((v) => v.title).toSet();
    return [
      ..._tracks.subtitle.skip(fakeTrackCount).where((v) => !externalTitles.contains(v.title)),
      ..._externalSubtitleTracks,
    ];
  }

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

  static const Set<String> _subtitleExtensions = {'.srt', '.sub', '.vtt'};

  static bool _isSubtitle(String path) => _subtitleExtensions.contains(_pContext.extension(path));
}
