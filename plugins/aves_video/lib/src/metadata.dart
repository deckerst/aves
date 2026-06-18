import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

abstract class AvesVideoMetadataFetcher {
  void init();

  Future<Map<String, Object?>> getMetadata({required String uri, required String mimeType});

  Future<(int, int?)> computeSlowMotionFactorAndDuration({required String uri, required String mimeType});

  Future<ui.ImageDescriptor?> getThumbnailDescriptor({required String uri, required String mimeType, required double targetExtentDip});

  static const _shortDuration = Duration(seconds: 15);

  // use same strategy on flutter and platform sides
  Duration getBestThumbnailTime(Duration duration) {
    if (duration < _shortDuration) {
      return Duration.zero;
    }
    return Duration(milliseconds: min((duration.inMilliseconds / 2).round(), _shortDuration.inMilliseconds));
  }
}
