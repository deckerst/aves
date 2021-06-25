import 'package:aves/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UriPicture extends PictureProvider<UriPicture> {
  const UriPicture({
    required this.uri,
    required this.mimeType,
    ColorFilter? colorFilter,
  }) : super(colorFilter);

  final String uri, mimeType;

  @override
  Future<UriPicture> obtainKey(PictureConfiguration picture) {
    return SynchronousFuture<UriPicture>(this);
  }

  @override
  PictureStreamCompleter load(UriPicture key, {PictureErrorListener? onError}) {
    return OneFramePictureStreamCompleter(_loadAsync(key, onError: onError), informationCollector: () sync* {
      yield DiagnosticsProperty<String>('uri', uri);
    });
  }

  Future<PictureInfo?> _loadAsync(UriPicture key, {PictureErrorListener? onError}) async {
    assert(key == this);

    final data = await imageFileService.getSvg(uri, mimeType);
    if (data.isEmpty) {
      return null;
    }

    final decoder = SvgPicture.svgByteDecoder;
    if (onError != null) {
      return decoder(
        data,
        colorFilter,
        key.toString(),
      ).catchError((error, stack) async {
        onError(error, stack);
        return Future<PictureInfo>.error(error, stack);
      });
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
