import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:aves_video_mpv/aves_video_mpv.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:media_kit/media_kit.dart';

class MpvVideoMetadataFetcher extends AvesVideoMetadataFetcher {
  static const mpvTypeAudio = 'audio';
  static const mpvTypeVideo = 'video';
  static const mpvTypeSub = 'sub';

  static const probeTimeoutImage = 500;
  static const probeTimeoutVideo = 5000;

  @override
  void init() => MediaKit.ensureInitialized();

  Future<Player?> _openBackgroundPlayer({required String uri, required String mimeType}) async {
    final player = Player(
      configuration: PlayerConfiguration(
        logLevel: MPVLogLevel.warn,
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

    final timeoutMillis = mimeType.startsWith('image') ? probeTimeoutImage : probeTimeoutVideo;
    await Future.any([videoDecodedCompleter.future, Future.delayed(Duration(milliseconds: timeoutMillis))]);

    final videoParams = player.state.videoParams;
    if (videoParams.par == null) {
      debugPrint('failed to probe video metadata within $timeoutMillis ms for uri=$uri, mimeType=$mimeType');
      await player.dispose();
      return null;
    }

    return player;
  }

  @override
  Future<Map<String, Object?>> getMetadata({required String uri, required String mimeType}) async {
    final player = await _openBackgroundPlayer(uri: uri, mimeType: mimeType);
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
    final player = await _openBackgroundPlayer(uri: uri, mimeType: mimeType);
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

  @override
  Future<ui.ImageDescriptor?> getThumbnailDescriptor({required String uri, required String mimeType, required double targetExtentDip}) async {
    if (targetExtentDip == 0) return null;

    final player = await _openBackgroundPlayer(uri: uri, mimeType: mimeType);
    if (player == null) return null;

    final thumbnailTime = getBestThumbnailTime(player.state.duration);
    if (thumbnailTime > Duration.zero) {
      await player.seek(thumbnailTime);
    }

    final bgra = await player.screenshot(format: null);
    final videoParams = player.state.videoParams;
    await player.dispose();

    final videoWidth = videoParams.dw;
    final videoHeight = videoParams.dh;
    if (videoWidth == null || videoHeight == null || bgra == null) {
      return null;
    }

    final devicePixelRatio = PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1;

    final input = _ThumbnailByteInput(
      bytes: bgra,
      videoWidth: videoWidth,
      videoHeight: videoHeight,
      videoRotationDegrees: videoParams.rotate ?? 0,
      targetWidth: (targetExtentDip * devicePixelRatio).round(),
      targetHeight: (targetExtentDip * devicePixelRatio).round(),
    );
    final output = await compute(_getThumbnailBytes, input);
    if (output == null) return null;

    final buffer = await ui.ImmutableBuffer.fromUint8List(output.bytes);
    return ui.ImageDescriptor.raw(
      buffer,
      width: output.width,
      height: output.height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
  }
}

@immutable
class _ThumbnailByteInput {
  final Uint8List bytes;
  final int videoWidth;
  final int videoHeight;
  final int videoRotationDegrees;
  final int targetWidth;
  final int targetHeight;

  const _ThumbnailByteInput({
    required this.bytes,
    required this.videoWidth,
    required this.videoHeight,
    required this.videoRotationDegrees,
    required this.targetWidth,
    required this.targetHeight,
  });
}

@immutable
class _ThumbnailByteOutput {
  final Uint8List bytes;
  final int width;
  final int height;

  const _ThumbnailByteOutput({
    required this.bytes,
    required this.width,
    required this.height,
  });
}

const double _rescaleReductionThreshold = .15;

_ThumbnailByteOutput? _getThumbnailBytes(_ThumbnailByteInput input) {
  final bgra = input.bytes;
  final videoWidth = input.videoWidth;
  final videoHeight = input.videoHeight;
  final videoRotationDegrees = input.videoRotationDegrees;
  final targetWidth = input.targetWidth;
  final targetHeight = input.targetHeight;

  var sampleSize = 1;
  if (videoWidth > targetWidth || videoHeight > targetHeight) {
    while (videoHeight / (sampleSize * 2) >= targetHeight && videoWidth / (sampleSize * 2) >= targetWidth) {
      sampleSize *= 2;
    }
  }

  // normally, `stride = videoWidth * bpp`, but it can differ,
  // so we use the more reliable `stride = byte count / videoHeight` instead
  // cf https://mpv.io/manual/stable/#command-interface-screenshot-raw
  final stride = (bgra.lengthInBytes / videoHeight).round();

  final sampledWidth = (videoWidth / sampleSize).ceil();
  final sampledHeight = (videoHeight / sampleSize).ceil();
  var targetImage = img.Image(
    width: sampledWidth,
    height: sampledHeight,
    format: img.Format.uint8,
    // only 3 channels are necessary to store an opaque image,
    // but 4 allows usage as `ImageDescriptor` raw format
    numChannels: 4,
  );

  const bpp = 4;
  final xFactor = bpp * sampleSize;
  final yFactor = stride * sampleSize;
  for (var x = 0; x < sampledWidth; x++) {
    final ix = x * xFactor;
    for (var y = 0; y < sampledHeight; y++) {
      final i = y * yFactor + ix;
      targetImage.setPixelRgba(x, y, bgra[i + 2], bgra[i + 1], bgra[i], bgra[i + 3]);
    }
  }

  if (sampledWidth > targetWidth && sampledHeight > targetHeight) {
    // rescale when the resulting image is larger than requested
    final scalingFactor = min(sampledWidth / targetWidth, sampledHeight / targetHeight);
    final dstWidth = (sampledWidth / scalingFactor).round();
    final dstHeight = (sampledHeight / scalingFactor).round();
    final reduction = 1 - (dstWidth * dstHeight).toDouble() / (sampledWidth * sampledHeight);
    if (reduction > _rescaleReductionThreshold) {
      debugPrint(
        'rescale thumbnail for width=$targetWidth height=$targetHeight'
        ', with bitmap byteCount=${targetImage.lengthInBytes} size=${sampledWidth}x$sampledHeight, to target=${dstWidth}x$dstHeight'
        ', reduced by ${((reduction) * 100).round()}%)',
      );
      targetImage = img.copyResize(targetImage, width: dstWidth, height: dstHeight);
    }
  }

  if (videoRotationDegrees > 0) {
    targetImage = img.copyRotate(targetImage, angle: videoRotationDegrees);
  }

  return _ThumbnailByteOutput(
    bytes: targetImage.toUint8List(),
    width: targetImage.width,
    height: targetImage.height,
  );
}
