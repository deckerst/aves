import 'dart:async';
import 'dart:ui' as ui;

import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/media_fetch_service.dart';
import 'package:aves_report/aves_report.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class FullImage extends ImageProvider<FullImage> with EquatableMixin {
  final String uri, mimeType;
  final int? pageId, rotationDegrees, sizeBytes;
  final bool isFlipped, isAnimated;
  final double scale;
  // optional target pixel size requested by the consumer (in physical pixels)
  final Size? targetSize;

  @override
  List<Object?> get props => [uri, pageId, rotationDegrees, isFlipped, isAnimated, scale, targetSize?.width, targetSize?.height];

  const FullImage({
    required this.uri,
    required this.mimeType,
    required this.pageId,
    required this.rotationDegrees,
    required this.isFlipped,
    required this.isAnimated,
    this.sizeBytes,
    this.scale = 1.0,
    this.targetSize,
  });

  @override
  @override
  Future<FullImage> obtainKey(ImageConfiguration configuration) {
    // Try to infer a target decode size from the provided configuration so the
    // platform decoder can downscale early and reduce CPU/memory pressure while
    // the user is scrolling.
    final devicePixelRatio = configuration.devicePixelRatio ?? ui.window.devicePixelRatio;
    final size = configuration.size;
    if (size == null || size.isEmpty) return SynchronousFuture<FullImage>(this);
    final target = Size(size.width * devicePixelRatio, size.height * devicePixelRatio);
    if (target.width <= 0 || target.height <= 0) return SynchronousFuture<FullImage>(this);

    return SynchronousFuture<FullImage>(
      FullImage(
        uri: uri,
        mimeType: mimeType,
        pageId: pageId,
        rotationDegrees: rotationDegrees,
        isFlipped: isFlipped,
        isAnimated: isAnimated,
        sizeBytes: sizeBytes,
        scale: scale,
        targetSize: target,
      ),
    );
  }

  @override
  ImageStreamCompleter loadImage(FullImage key, ImageDecoderCallback decode) {
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode, chunkEvents),
      scale: key.scale,
      chunkEvents: chunkEvents.stream,
      informationCollector: () sync* {
        yield ErrorDescription('uri=$uri, pageId=$pageId, mimeType=$mimeType');
      },
    );
  }

  Future<ui.Codec> _loadAsync(FullImage key, ImageDecoderCallback decode, StreamController<ImageChunkEvent> chunkEvents) async {
    assert(key == this);

    final request = ImageRequest(
      uri,
      mimeType,
      rotationDegrees: rotationDegrees,
      isFlipped: isFlipped,
      isAnimated: isAnimated,
      pageId: pageId,
      sizeBytes: sizeBytes,
      onBytesReceived: (cumulative, total) {
        chunkEvents.add(ImageChunkEvent(
          cumulativeBytesLoaded: cumulative,
          expectedTotalBytes: total,
        ));
      },
    );

    try {
      // get original media bytes from platform, and rely on a codec instantiated by `ImageProvider`
      return await mediaFetchService.getFullImage(decoded: false, request: request, decode: decode);
    } catch (error) {
      // loading may fail if the provided MIME type is incorrect (e.g. the Media Store may report a JPEG as a TIFF)
      debugPrint('$runtimeType _loadAsync failed with mimeType=$mimeType, uri=$uri, error=$error');
      throw UnreportedStateError('$mimeType decoding failed (page $pageId)');
    } finally {
      unawaited(chunkEvents.close());
    }
  }
}
