import 'dart:typed_data';
import 'dart:ui' as ui show Codec;

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/service_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ThumbnailProvider extends ImageProvider<ThumbnailProviderKey> {
  ThumbnailProvider({
    @required this.entry,
    @required this.extent,
    this.scale = 1.0,
  })  : assert(entry != null),
        assert(extent != null),
        assert(scale != null);

  final ImageEntry entry;
  final double extent;
  final double scale;

  final Object _cancellationKey = Uuid();

  @override
  Future<ThumbnailProviderKey> obtainKey(ImageConfiguration configuration) {
    // configuration can be empty (e.g. when obtaining key for eviction)
    // so we do not compute the target width/height here
    // and pass it to the key, to use it later for image loading
    return SynchronousFuture<ThumbnailProviderKey>(ThumbnailProviderKey(
      entry: entry,
      extent: extent,
      devicePixelRatio: configuration.devicePixelRatio,
      scale: scale,
    ));
  }

  @override
  ImageStreamCompleter load(ThumbnailProviderKey key, DecoderCallback decode) {
    return CancellableMultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('uri=${entry.uri}, extent=$extent');
      },
    );
  }

  Future<ui.Codec> _loadAsync(ThumbnailProviderKey key, DecoderCallback decode) async {
    final dimPixels = (extent * key.devicePixelRatio).round();
    final bytes = await ImageFileService.getThumbnail(key.entry, dimPixels, dimPixels, cancellationKey: _cancellationKey);
    return await decode(bytes ?? Uint8List(0));
  }

  Future<void> cancel() async {
    if (servicePolicy.cancel(_cancellationKey)) {
      await evict();
    }
  }
}

class ThumbnailProviderKey {
  final ImageEntry entry;
  final double extent;
  final double devicePixelRatio; // do not include configuration in key hashcode or == operator
  final double scale;

  const ThumbnailProviderKey({
    @required this.entry,
    @required this.extent,
    @required this.devicePixelRatio,
    this.scale,
  });

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ThumbnailProviderKey && other.entry.uri == entry.uri && other.extent == extent && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(entry.uri, extent, scale);

  @override
  String toString() {
    return 'ThumbnailProviderKey{uri=${entry.uri}, extent=$extent, scale=$scale}';
  }
}

class CancellableMultiFrameImageStreamCompleter extends MultiFrameImageStreamCompleter {
  CancellableMultiFrameImageStreamCompleter({
    @required Future<ui.Codec> codec,
    @required double scale,
    Stream<ImageChunkEvent> chunkEvents,
    InformationCollector informationCollector,
  }) : super(
          codec: codec,
          scale: scale,
          chunkEvents: chunkEvents,
          informationCollector: informationCollector,
        );

  @override
  void reportError({DiagnosticsNode context, dynamic exception, StackTrace stack, informationCollector, bool silent = false}) {
    // prevent default error reporting in case of planned cancellation
    if (exception is CancelledException) return;
    super.reportError(context: context, exception: exception, stack: stack, informationCollector: informationCollector, silent: silent);
  }
}
