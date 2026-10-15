import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves_model/aves_model.dart';

abstract class AvesVideoThumbnailFetcher {
  void init();

  // to size thumbnail descriptor when out of window context
  set devicePixelRatio(double value);

  Future<ui.ImageDescriptor?> getThumbnailDescriptor({
    required String uri,
    required String mimeType,
    required double targetExtentDip,
    required List<VideoThumbnailMethod> methods,
  });

  static const _shortDuration = Duration(seconds: 15);

  // use same strategy on flutter and platform sides
  Duration getPreviewThumbnailTime(Duration duration) {
    if (duration < _shortDuration) {
      return Duration.zero;
    }
    return Duration(milliseconds: min((duration.inMilliseconds / 2).round(), _shortDuration.inMilliseconds));
  }
}
