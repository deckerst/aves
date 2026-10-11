import 'dart:async';

import 'package:aves_video_mpv/aves_video_mpv.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

class BackgroundPlayer {
  static const _probeTimeoutImage = 500;
  static const _probeTimeoutVideo = 5000;

  static Future<Player?> open({required String uri, required String mimeType}) async {
    final player = Player(
      configuration: PlayerConfiguration(
        logLevel: .warn,
        protocolWhitelist: MpvVideoController.protocolWhitelist,
      ),
    );
    final platform = player.platform;
    if (platform is! NativePlayer) {
      throw Exception('Platform player ${platform.runtimeType} does not support property retrieval');
    }

    // We need to enable video decoding to retrieve video params,
    // but it is disabled by default unless a `VideoController` is attached.
    // Attaching a `VideoController` is problematic, because `player.open()` may not return
    // unless a new frame is rendered, and triggering fails from a background service.
    // It is simpler to enable the video track via properties.
    await platform.setProperty('vid', 'auto');

    // deselect audio track to prevent triggering Android audio sessions
    await platform.setProperty('aid', 'no');

    final videoDecodedCompleter = Completer();
    StreamSubscription? subscription;
    subscription = player.stream.videoParams.listen((v) {
      if (v.par != null) {
        subscription?.cancel();
        videoDecodedCompleter.complete();
      }
    });

    await player.open(Media(uri), play: false);

    final timeoutMillis = mimeType.startsWith('image') ? _probeTimeoutImage : _probeTimeoutVideo;
    await Future.any([videoDecodedCompleter.future, Future.delayed(Duration(milliseconds: timeoutMillis))]);

    final videoParams = player.state.videoParams;
    if (videoParams.par == null) {
      debugPrint('failed to probe video metadata within $timeoutMillis ms for uri=$uri, mimeType=$mimeType');
      await player.dispose();
      return null;
    }

    return player;
  }
}
