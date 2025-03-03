import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class InteropDecoding {
  static Future<ui.ImageDescriptor?> bytesToCodec(Uint8List bytes) async {
    const trailerLength = 4 * 2;
    final byteCount = bytes.length;
    if (byteCount < trailerLength) return null;

    final trailerOffset = byteCount - trailerLength;
    final trailer = ByteData.sublistView(bytes, trailerOffset);
    final bitmapWidth = trailer.getUint32(0);
    final bitmapHeight = trailer.getUint32(4);

    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return ui.ImageDescriptor.raw(
      buffer,
      width: bitmapWidth,
      height: bitmapHeight,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
  }
}
