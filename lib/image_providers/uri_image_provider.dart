import 'dart:async';
import 'dart:ui' as ui show Codec;

import 'package:aves/services/image_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

class UriImage extends ImageProvider<UriImage> {
  final String uri, mimeType;
  final int page, rotationDegrees, expectedContentLength;
  final bool isFlipped;
  final double scale;

  const UriImage({
    @required this.uri,
    @required this.mimeType,
    @required this.page,
    @required this.rotationDegrees,
    @required this.isFlipped,
    this.expectedContentLength,
    this.scale = 1.0,
  })  : assert(uri != null),
        assert(scale != null);

  @override
  Future<UriImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<UriImage>(this);
  }

  @override
  ImageStreamCompleter load(UriImage key, DecoderCallback decode) {
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode, chunkEvents),
      scale: key.scale,
      chunkEvents: chunkEvents.stream,
      informationCollector: () sync* {
        yield ErrorDescription('uri=$uri, page=$page, mimeType=$mimeType');
      },
    );
  }

  Future<ui.Codec> _loadAsync(UriImage key, DecoderCallback decode, StreamController<ImageChunkEvent> chunkEvents) async {
    assert(key == this);

    try {
      final bytes = await ImageFileService.getImage(
        uri,
        mimeType,
        rotationDegrees,
        isFlipped,
        page: page,
        expectedContentLength: expectedContentLength,
        onBytesReceived: (cumulative, total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );
      if (bytes == null) {
        throw StateError('$uri ($mimeType) loading failed');
      }
      return await decode(bytes);
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with mimeType=$mimeType, uri=$uri, error=$error');
      throw StateError('$mimeType decoding failed (page $page)');
    } finally {
      unawaited(chunkEvents.close());
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is UriImage && other.uri == uri && other.mimeType == mimeType && other.rotationDegrees == rotationDegrees && other.isFlipped == isFlipped && other.page == page && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(
        uri,
        mimeType,
        rotationDegrees,
        isFlipped,
        page,
        scale,
      );

  @override
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, mimeType=$mimeType, rotationDegrees=$rotationDegrees, isFlipped=$isFlipped, page=$page, scale=$scale}';
}
