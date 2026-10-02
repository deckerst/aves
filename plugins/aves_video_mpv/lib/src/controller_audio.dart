import 'dart:async';

import 'package:aves_video/aves_video.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MpvAudioController(super.entry) extends AvesAudioController {
  late Player _mkPlayer;
  late PlaybackStatus _status;
  final ValueNotifier<VideoController?> _mkControllerNotifier = ValueNotifier(null);
  final List<StreamSubscription> _subscriptions = [];
  final StreamController<PlaybackStatus> _statusStreamController = StreamController.broadcast();

  static final protocolWhitelist = [
    ...const PlayerConfiguration().protocolWhitelist,
    // Android `content` URIs are considered unsafe by default,
    // as they are transferred via a custom `fd` protocol
    'fd',
  ];

  this {
    _status = .idle;
    _statusStreamController.add(_status);

    _mkPlayer = Player(
      configuration: PlayerConfiguration(
        title: entry.bestTitle ?? entry.uri,
        logLevel: .warn,
        protocolWhitelist: protocolWhitelist,
      ),
    );
    _initController();
    _init();

    _startListening();
  }

  @override
  Future<void> dispose() async {
    _stopListening();
    await _statusStreamController.close();
    await _mkPlayer.dispose();

    final _mkController = _mkControllerNotifier.value;
    _mkControllerNotifier.dispose();
    _mkController?.dispose();

    await super.dispose();
  }

  void _startListening() {
    _subscriptions.add(statusStream.listen((v) => _status = v));

    final playerStream = _mkPlayer.stream;
    _subscriptions.add(
      playerStream.completed.listen((completed) {
        if (completed) {
          _statusStreamController.add(.completed);

          // the player incorrectly loop for some videos
          // even when the playlist mode is configured not to loop
          // so we explicitly stop on completion
          final shouldStop = _mkPlayer.platform?.state.playlistMode == .none;
          if (shouldStop) {
            pause();
          }
        }
      }),
    );
    _subscriptions.add(
      playerStream.playing.listen((playing) {
        if (status == .idle) return;
        _statusStreamController.add(playing ? .playing : .paused);
      }),
    );
    _subscriptions.add(playerStream.log.listen(_onPlayerLog));
    _subscriptions.add(playerStream.error.listen(_onPlayerError));
  }

  void _stopListening() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  Future<void> _init() async {
    final playing = _mkPlayer.state.playing;

    // Audio quality is better with `audiotrack` than `opensles` (the default).
    // Calling `setAudioDevice` does not seem to work.
    // As of 2025/01/13, directly setting audio output via property works for some files but not all,
    // and switching from a supported file to an unsupported file crashes:
    // cf https://github.com/media-kit/media-kit/issues/1061
    await _mkPlayer.open(Media(entry.uri), play: playing);

    _statusStreamController.add(_mkPlayer.state.playing ? .playing : .paused);
  }

  void _initController() {
    final oldController = _mkControllerNotifier.value;
    final newController = VideoController(_mkPlayer)
      ..waitUntilFirstFrameRendered.then((v) {
        _statusStreamController.add(_status);
      });
    _mkControllerNotifier.value = newController;
    oldController?.dispose();
  }

  void _onPlayerLog(PlayerLog log) {
    debugPrint('libmpv log: $log');
  }

  void _onPlayerError(String error) {
    debugPrint('libmpv error: $error');
  }

  @override
  Future<void> enableLoop(bool enabled) => _mkPlayer.setPlaylistMode(enabled ? .single : .none);

  @override
  Future<void> play() async {
    await untilReady;
    await _mkPlayer.play();
  }

  @override
  Future<void> pause() => _mkPlayer.pause();

  @override
  PlaybackStatus get status => _status;

  @override
  Stream<PlaybackStatus> get statusStream => _statusStreamController.stream;

  @override
  bool get isReady {
    switch (_status) {
      case .error:
      case .idle:
      case .initialized:
        return false;
      case .paused:
      case .playing:
      case .completed:
        return true;
    }
  }
}
