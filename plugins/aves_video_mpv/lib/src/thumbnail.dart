import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:aves_video_mpv/src/background_player.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:media_kit/media_kit.dart';

class MpvVideoThumbnailFetcher extends AvesVideoThumbnailFetcher {
  @override
  void init() => MediaKit.ensureInitialized();

  double? _devicePixelRatio;

  @override
  set devicePixelRatio(double value) => _devicePixelRatio = value;

  @override
  Future<ui.ImageDescriptor?> getThumbnailDescriptor({
    required String uri,
    required String mimeType,
    required double targetExtentDip,
    required List<VideoThumbnailMethod> methods,
  }) async {
    if (targetExtentDip == 0) return null;

    final player = await BackgroundPlayer.open(uri: uri, mimeType: mimeType);
    if (player == null) return null;

    final bgra = await _getPreferredThumbnail(player, methods);
    final videoParams = player.state.videoParams;
    await player.dispose();

    final videoWidth = videoParams.dw;
    final videoHeight = videoParams.dh;
    if (videoWidth == null || videoHeight == null || bgra == null) {
      return null;
    }

    final devicePixelRatio = _devicePixelRatio ?? PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1;

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

  // return bytes in BGRA
  Future<Uint8List?> _getPreferredThumbnail(Player player, List<VideoThumbnailMethod> methods) async {
    for (final method in methods) {
      Uint8List? bytes;
      switch (method) {
        case VideoThumbnailMethod.embedded:
          // skip
          bytes = null;
        case VideoThumbnailMethod.preview:
          bytes = await _getFrameAtTime(player, getPreviewThumbnailTime(player.state.duration));
        case VideoThumbnailMethod.first:
          bytes = await _getFrameAtTime(player, Duration.zero);
      }
      if (bytes != null) return bytes;
    }
    return null;
  }

  // return bytes in BGRA
  Future<Uint8List?> _getFrameAtTime(Player player, Duration thumbnailTime) async {
    if (thumbnailTime != player.state.position) {
      await player.seek(thumbnailTime);
    }
    return await player.screenshot(format: null);
  }
}

@immutable
class const _ThumbnailByteInput({
  required final Uint8List bytes,
  required final int videoWidth,
  required final int videoHeight,
  required final int videoRotationDegrees,
  required final int targetWidth,
  required final int targetHeight,
});

@immutable
class const _ThumbnailByteOutput({
  required final Uint8List bytes,
  required final int width,
  required final int height,
});

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
