import 'dart:async';
import 'dart:convert';

import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:aves_video_mpv/src/background_player.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

class MpvVideoMetadataFetcher extends AvesVideoMetadataFetcher {
  static const mpvTypeAudio = 'audio';
  static const mpvTypeVideo = 'video';
  static const mpvTypeSub = 'sub';

  @override
  void init() => MediaKit.ensureInitialized();

  @override
  Future<Map<String, Object?>> getMetadata({required String uri, required String mimeType}) async {
    final player = await BackgroundPlayer.open(uri: uri, mimeType: mimeType);
    if (player == null) return {};

    final fields = await _describeAllMetadataFields(player);

    await player.dispose();
    return fields;
  }

  // mpv properties: https://mpv.io/manual/stable/#property-list
  static const _propertyChapterList = 'chapter-list';
  static const _propertyDurationFull = 'duration/full';
  static const _propertyMetadata = 'metadata';
  static const _propertyTrackList = 'track-list';

  static Future<Map<String, Object?>> _describeAllMetadataFields(Player player) async {
    final platform = player.platform;
    if (platform is! NativePlayer) {
      throw Exception('Platform player ${platform.runtimeType} does not support property retrieval');
    }

    final fields = <String, Object?>{};

    // mpv doc: "duration with milliseconds"
    final durationSecs = await platform.getProperty(_propertyDurationFull);
    if (durationSecs.isNotEmpty) {
      fields[Keys.duration] = durationSecs;
    }

    // mpv doc: "metadata key/value pairs"
    // note: seems to match FFprobe "format" > "tags" fields
    final metadata = await platform.getProperty(_propertyMetadata);
    if (metadata.isNotEmpty) {
      try {
        final jsonMap = jsonDecode(metadata) as Map<String, Object?>;
        jsonMap.forEach((key, value) {
          fields[key] = value;
        });
      } catch (error) {
        debugPrint('failed to parse metadata=$metadata with error=$error');
      }
    }

    final tracks = await platform.getProperty(_propertyTrackList);
    if (tracks.isNotEmpty) {
      try {
        final tracksJson = jsonDecode(tracks);
        if (tracksJson is List && tracksJson.isNotEmpty) {
          final videoParams = player.state.videoParams;
          fields[Keys.streams] = tracksJson.whereType<Map>().map((track) {
            return _normalizeTrack(track.cast<String, Object?>(), videoParams);
          }).toList();
        }
      } catch (error) {
        debugPrint('failed to parse tracks=$tracks with error=$error');
      }
    }

    final chapters = await platform.getProperty(_propertyChapterList);
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

    return fields;
  }

  static Map<String, Object?> _normalizeTrack(Map<String, Object?> stream, VideoParams videoParams) {
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
        if (isImage is bool && isImage) {
          stream.remove(Keys.fps);
        }

        // Some video properties are not in the video track props but accessible via `video-params` (or `video-out-params`).
        // These parameters are already stored in the player state, as `videoParams`.
        // Parameters `sigPeak` and `averageBpp` are ignored.
        final videoParamsTags = <String, Object?>{
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

  static Future<double?> _getPlaybackDurationSecs(Player player) async {
    final platform = player.platform;
    if (platform is NativePlayer) {
      final durationString = await platform.getProperty(_propertyDurationFull);
      return _toDoubleValue(durationString);
    }
    return null;
  }

  static Future<Map<String, Object?>> _getFields(
    Player player,
    Set<String> keys,
    Future<Map<String, Object?>> Function(NativePlayer platform) toJsonMap,
  ) async {
    final result = <String, Object?>{};
    final platform = player.platform;
    if (platform is NativePlayer) {
      final jsonMap = await toJsonMap(platform);
      result.addAll(
        Map.fromEntries(
          keys.map((key) {
            Object? value = jsonMap[key];
            switch (key) {
              case Keys.androidCaptureFramerate:
              case Keys.demuxFps:
                value = _toDoubleValue(value);
              case Keys.xiaomiSlowMoment:
                if (value is String) {
                  value = value == '1';
                }
            }
            return MapEntry(key, value);
          }),
        ),
      );
    }
    return result;
  }

  static Future<Map<String, Object?>> _getMetadataFields(Player player, Set<String> keys) async {
    return _getFields(player, keys, (platform) async {
      final metadata = await platform.getProperty(_propertyMetadata);
      if (metadata.isNotEmpty) {
        try {
          return jsonDecode(metadata) as Map<String, Object?>;
        } catch (error) {
          debugPrint('failed to parse metadata=$metadata with error=$error');
        }
      }
      return {};
    });
  }

  static Future<Map<String, Object?>> _getVideoTrackFields(Player player, Set<String> keys) async {
    return _getFields(player, keys, (platform) async {
      final tracks = await platform.getProperty(_propertyTrackList);
      if (tracks.isNotEmpty) {
        try {
          final tracksJson = jsonDecode(tracks);
          if (tracksJson is List && tracksJson.isNotEmpty) {
            final videoTrack = tracksJson.whereType<Map>().map((track) => track.cast<String, Object?>()).firstWhereOrNull((kv) => kv['type'] == mpvTypeVideo);
            return videoTrack ?? {};
          }
        } catch (error) {
          debugPrint('failed to parse tracks=$tracks with error=$error');
        }
      }
      return {};
    });
  }

  static double? _toDoubleValue(Object? value) {
    if (value is String) {
      return double.tryParse(value);
    } else if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  @override
  Future<(int, int?)> computeSlowMotionFactorAndDuration({required String uri, required String mimeType}) async {
    final player = await BackgroundPlayer.open(uri: uri, mimeType: mimeType);
    if (player == null) return (1, null);

    final playbackFps = (await _getVideoTrackFields(player, {Keys.demuxFps}))[Keys.demuxFps];

    int? slowMotionFactor;
    if (playbackFps is double) {
      slowMotionFactor = await computeSlowMotionFactor(player, playbackFps);
    }
    if (slowMotionFactor == null) return (1, null);

    final playbackDurationSecs = await _getPlaybackDurationSecs(player);
    await player.dispose();

    int? captureDurationMillis;
    if (playbackDurationSecs is double) {
      captureDurationMillis = (playbackDurationSecs * 1000 / slowMotionFactor).round();
    }
    return (slowMotionFactor, captureDurationMillis);
  }

  static Future<int> computeSlowMotionFactor(Player player, double? playbackFps) async {
    int slowMotionFactor = 1;

    if (playbackFps != null && playbackFps != 0) {
      final result = await _getMetadataFields(player, {
        Keys.androidCaptureFramerate,
        Keys.xiaomiSlowMoment,
      });
      final captureFps = result[Keys.androidCaptureFramerate];
      if (captureFps is double && captureFps != 0) {
        slowMotionFactor = (captureFps / playbackFps).round();
        if (slowMotionFactor == 1) {
          // Xiaomi slow motion videos set both FPS to 120
          final slowMoment = result[Keys.xiaomiSlowMoment];
          if (slowMoment is bool && slowMoment) {
            slowMotionFactor = (captureFps / SlowMotionMixin.fallbackPlaybackFps).round();
          }
        }
      }
    }
    return slowMotionFactor.isFinite && slowMotionFactor != 0 ? slowMotionFactor : 1;
  }
}
