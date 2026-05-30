import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

class InteropDecoding {
  static const _kIntegerByteCount = 4;
  static const _trailerLength = _kIntegerByteCount * 2 + 1; // 2 integers + decoded/encoded format byte

  // bytes are expected to be in a basic format decodable by Flutter
  static Future<ui.Codec?> encodedBytesToCodec(Uint8List? bytes, ImageDecoderCallback? decode) async {
    if (bytes == null || decode == null) return null;

    const trailerLength = 1; // decoded/encoded format byte
    final byteCount = bytes.lengthInBytes;
    if (byteCount < trailerLength) return null;

    final trailerOffset = byteCount - trailerLength;

    // trim custom trailer
    // a view does not reallocate memory and uses the underlying buffer
    final imageBytes = Uint8List.sublistView(bytes, 0, trailerOffset);

    final buffer = await ui.ImmutableBuffer.fromUint8List(imageBytes);
    return await decode(buffer);
  }

  // bytes are expected to be in ARGB_8888
  // with a custom trailer from the platform side
  static Future<ui.ImageDescriptor?> rawBytesToDescriptor(Uint8List? bytes) async {
    if (bytes == null) return null;

    final trailerOffset = bytes.lengthInBytes - _trailerLength;
    if (trailerOffset < 0) return null;

    // fetch trailer
    final trailer = ByteData.sublistView(bytes, trailerOffset);
    final bitmapWidth = trailer.getUint32(0);
    final bitmapHeight = trailer.getUint32(_kIntegerByteCount);

    // trim custom trailer
    // a view does not reallocate memory and uses the underlying buffer
    final imageBytes = Uint8List.sublistView(bytes, 0, trailerOffset);

    final buffer = await ui.ImmutableBuffer.fromUint8List(imageBytes);
    return ui.ImageDescriptor.raw(
      buffer,
      width: bitmapWidth,
      height: bitmapHeight,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
  }
}
