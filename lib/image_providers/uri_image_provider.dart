import 'dart:async';
import 'dart:ui' as ui;

import 'package:aves/services/common/services.dart';
import 'package:aves_report/aves_report.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class UriImage extends ImageProvider<UriImage> with EquatableMixin {
  final String uri, mimeType;
  final int? pageId, rotationDegrees, sizeBytes;
  final bool isFlipped;
  final double scale;

  @override
  List<Object?> get props => [uri, pageId, rotationDegrees, isFlipped, scale];

  const UriImage({
    required this.uri,
    required this.mimeType,
    required this.pageId,
    required this.rotationDegrees,
    required this.isFlipped,
    this.sizeBytes,
    this.scale = 1.0,
  });

  @override
  Future<UriImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<UriImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(UriImage key, ImageDecoderCallback decode) {
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

  Future<ui.Codec> _loadAsync(UriImage key, ImageDecoderCallback decode, StreamController<ImageChunkEvent> chunkEvents) async {
    assert(key == this);

    try {
      final bytes = await mediaFetchService.getImage(
        uri,
        mimeType,
        rotationDegrees: rotationDegrees,
        isFlipped: isFlipped,
        pageId: pageId,
        sizeBytes: sizeBytes,
        onBytesReceived: (cumulative, total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );
      if (bytes.isEmpty) {
        throw UnreportedStateError('$uri ($mimeType) loading failed');
      }
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return await decode(buffer);
    } catch (error) {
      // loading may fail if the provided MIME type is incorrect (e.g. the Media Store may report a JPEG as a TIFF)
      debugPrint('$runtimeType _loadAsync failed with mimeType=$mimeType, uri=$uri, error=$error');
      throw UnreportedStateError('$mimeType decoding failed (page $pageId)');
    } finally {
      unawaited(chunkEvents.close());
    }
  }
}
