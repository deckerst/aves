import 'package:aves/services/image_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pedantic/pedantic.dart';

class UriPicture extends PictureProvider<UriPicture> {
  const UriPicture({
    @required this.uri,
    @required this.mimeType,
    this.colorFilter,
  }) : assert(uri != null);

  final String uri, mimeType;

  final ColorFilter colorFilter;

  @override
  Future<UriPicture> obtainKey(PictureConfiguration configuration) {
    return SynchronousFuture<UriPicture>(this);
  }

  @override
  PictureStreamCompleter load(UriPicture key, {PictureErrorListener onError}) {
    return OneFramePictureStreamCompleter(_loadAsync(key, onError: onError), informationCollector: () sync* {
      yield DiagnosticsProperty<String>('uri', uri);
    });
  }

  Future<PictureInfo> _loadAsync(UriPicture key, {PictureErrorListener onError}) async {
    assert(key == this);

    final data = await ImageFileService.getImage(uri, mimeType, 0, false);
    if (data == null || data.isEmpty) {
      return null;
    }

    final decoder = SvgPicture.svgByteDecoder;
    if (onError != null) {
      final future = decoder(data, colorFilter, key.toString());
      unawaited(future.catchError(onError));
      return future;
    }
    return decoder(data, colorFilter, key.toString());
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is UriPicture && other.uri == uri && other.colorFilter == colorFilter;
  }

  @override
  int get hashCode => hashValues(uri, colorFilter);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, mimeType=$mimeType, colorFilter=$colorFilter}';
}
