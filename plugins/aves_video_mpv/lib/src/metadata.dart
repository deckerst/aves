import 'dart:async';
import 'dart:convert';

import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';

class MpvVideoMetadataFetcher extends AvesVideoMetadataFetcher {
  static const mpvTypeAudio = 'audio';
  static const mpvTypeVideo = 'video';
  static const mpvTypeSub = 'sub';

  static const probeTimeoutImage = 500;
  static const probeTimeoutVideo = 5000;

  @override
  void init() => MediaKit.ensureInitialized();

  @override
  Future<Map> getMetadata(AvesEntryBase entry) async {
    final player = Player(
      configuration: PlayerConfiguration(
        logLevel: MPVLogLevel.warn,
        protocolWhitelist: [
          ...const PlayerConfiguration().protocolWhitelist,
          // Android `content` URIs are considered unsafe by default,
          // as they are transferred via a custom `fd` protocol
          'fd',
        ],
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

    await player.open(Media(entry.uri), play: false);

    final timeoutMillis = entry.mimeType.startsWith('image') ? probeTimeoutImage : probeTimeoutVideo;
    await Future.any([videoDecodedCompleter.future, Future.delayed(Duration(milliseconds: timeoutMillis))]);

    final fields = <String, dynamic>{};

    final videoParams = player.state.videoParams;
    if (videoParams.par == null) {
      debugPrint('failed to probe video metadata within $timeoutMillis ms for entry=$entry');
    } else {
      // mpv properties: https://mpv.io/manual/stable/#property-list

      // mpv doc: "duration with milliseconds"
      final durationMs = await platform.getProperty('duration/full');
      if (durationMs.isNotEmpty) {
        fields[Keys.duration] = durationMs;
      }

      // mpv doc: "metadata key/value pairs"
      // note: seems to match FFprobe "format" > "tags" fields
      final metadata = await platform.getProperty('metadata');
      if (metadata.isNotEmpty) {
        try {
          jsonDecode(metadata).forEach((key, value) {
            fields[key] = value;
          });
        } catch (error) {
          debugPrint('failed to parse metadata=$metadata with error=$error');
        }
      }

      final tracks = await platform.getProperty('track-list');
      if (tracks.isNotEmpty) {
        try {
          final tracksJson = jsonDecode(tracks);
          if (tracksJson is List && tracksJson.isNotEmpty) {
            fields[Keys.streams] = tracksJson.whereType<Map>().map((stream) {
              return _normalizeStream(stream.cast<String, dynamic>(), videoParams);
            }).toList();
          }
        } catch (error) {
          debugPrint('failed to parse tracks=$tracks with error=$error');
        }
      }

      final chapters = await platform.getProperty('chapter-list');
      if (chapters.isNotEmpty) {
        try {
          final chaptersJson = jsonDecode(chapters);
          if (chaptersJson is List && chaptersJson.isNotEmpty) {
            final chapterMaps = chaptersJson.whereType<Map>().toList();
            if (chapterMaps.isNotEmpty) {
              fields[Keys.chapters] = chapterMaps;
            }
          }
        } catch (error) {
          debugPrint('failed to parse chapters=$chapters with error=$error');
        }
      }
    }

    await player.dispose();
    return fields;
  }

  Map<String, dynamic> _normalizeStream(Map<String, dynamic> stream, VideoParams videoParams) {
    void replaceKey(String k1, String k2) {
      final v = stream.remove(k1);
      if (v != null) {
        stream[k2] = v;
      }
    }

    void removeIfFalse(String k) {
      if (stream[k] == false) {
        stream.remove(k);
      }
    }

    stream.remove('id');
    stream.remove('decoder-desc');
    stream.remove('main-selection');
    stream.remove('selected');
    stream.remove('src-id');
    replaceKey('ff-index', Keys.index);
    replaceKey('codec', Keys.codecName);
    replaceKey('lang', Keys.language);
    replaceKey('demux-bitrate', Keys.bitrate);
    replaceKey('demux-channel-count', Keys.audioChannels);
    replaceKey('demux-fps', Keys.fps);
    replaceKey('demux-samplerate', Keys.sampleRate);
    replaceKey('hearing-impaired', Keys.hearingImpaired);
    replaceKey('visual-impaired', Keys.visualImpaired);

    stream.removeWhere((k, v) => k.startsWith('demux-'));
    removeIfFalse('albumart');
    removeIfFalse('default');
    removeIfFalse('dependent');
    removeIfFalse('external');
    removeIfFalse('forced');
    removeIfFalse(Keys.hearingImpaired);
    removeIfFalse(Keys.visualImpaired);

    final isImage = stream.remove('image');
    switch (stream.remove('type')) {
      case mpvTypeAudio:
        stream[Keys.streamType] = MediaStreamTypes.audio;
      case mpvTypeVideo:
        stream[Keys.streamType] = MediaStreamTypes.video;
        if (isImage) {
          stream.remove(Keys.fps);
        }

        // Some video properties are not in the video track props but accessible via `video-params` (or `video-out-params`).
        // These parameters are already stored in the player state, as `videoParams`.
        // Parameters `sigPeak` and `averageBpp` are ignored.
        final videoParamsTags = <String, dynamic>{
          Keys.alpha: videoParams.alpha,
          Keys.chromaLocation: videoParams.chromaLocation,
          Keys.codecPixelFormat: videoParams.pixelformat,
          Keys.colorLevels: videoParams.colorlevels,
          Keys.colorMatrix: videoParams.colormatrix,
          Keys.colorPrimaries: videoParams.primaries,
          Keys.dar: videoParams.aspect,
          Keys.decoderHeight: videoParams.dh,
          Keys.decoderWidth: videoParams.dw,
          Keys.gamma: videoParams.gamma,
          Keys.hwPixelFormat: videoParams.hwPixelformat,
          Keys.light: videoParams.light,
          Keys.par: videoParams.par,
          Keys.rotate: videoParams.rotate,
          Keys.stereo3dMode: videoParams.stereoIn,
          Keys.videoHeight: videoParams.h,
          Keys.videoWidth: videoParams.w,
        }..removeWhere((k, v) => v == null);
        stream.addAll(videoParamsTags);
      case mpvTypeSub:
        stream[Keys.streamType] = MediaStreamTypes.subtitle;
    }
    return stream;
  }
}
