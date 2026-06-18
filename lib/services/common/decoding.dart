import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

class InteropDecoding {
  static const int _max2Bits = 0x3;
  static const int _max10Bits = 0x3ff;
  static const int _bppRgba1010102 = 4;
  static const int _uint32ByteCount = 4;
  static const int _trailerLength = _uint32ByteCount * 3 + 1; // 3 integers + decoded/encoded format byte

  // should match custom format codes on platform side
  static const int _pixelFormatCodeRgba8888 = 2;
  static const int _pixelFormatCodeRgba1010102 = 4;
  static const int _pixelFormatCodeRgbaFloat32 = 5;

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
    final bitmapHeight = trailer.getUint32(_uint32ByteCount);
    final pixelFormatCode = trailer.getUint32(_uint32ByteCount * 2);

    final Uint8List imageBytes;

    final ui.PixelFormat pixelFormat;
    switch (pixelFormatCode) {
      case _pixelFormatCodeRgba1010102:
        imageBytes = _fromRgba1010102ToRgbaFloat32(bytes, trailerOffset);
        pixelFormat = ui.PixelFormat.rgbaFloat32;
      case _pixelFormatCodeRgbaFloat32:
        // trim custom trailer, using a view which reuses the underlying buffer
        final dstFloat32x4 = Float32x4List.sublistView(bytes, 0, trailerOffset);
        imageBytes = dstFloat32x4.buffer.asUint8List();
        pixelFormat = ui.PixelFormat.rgbaFloat32;
      case _pixelFormatCodeRgba8888:
      default:
        // trim custom trailer, using a view which reuses the underlying buffer
        imageBytes = Uint8List.sublistView(bytes, 0, trailerOffset);
        pixelFormat = ui.PixelFormat.rgba8888;
    }

    final buffer = await ui.ImmutableBuffer.fromUint8List(imageBytes);
    return ui.ImageDescriptor.raw(
      buffer,
      width: bitmapWidth,
      height: bitmapHeight,
      pixelFormat: pixelFormat,
    );
  }

  static Uint8List _fromRgba1010102ToRgbaFloat32(Uint8List bytes, int trailerOffset) {
    // trim custom trailer, using a view which reuses the underlying buffer
    final srcByteData = ByteData.sublistView(bytes, 0, trailerOffset);
    final pixelCount = (srcByteData.lengthInBytes / _bppRgba1010102).round();
    final dstFloat32x4 = Float32x4List(pixelCount);
    for (var i = 0; i < pixelCount; i++) {
      // unpacking from RGBA_1010102
      // stored as [3,2,1,0] -> [AABBBBBB BBBBGGGG GGGGGGRR RRRRRRRR]
      final srcOffset = i * _bppRgba1010102;
      final i3 = srcByteData.getUint8(srcOffset + 3);
      final i2 = srcByteData.getUint8(srcOffset + 2);
      final i1 = srcByteData.getUint8(srcOffset + 1);
      final i0 = srcByteData.getUint8(srcOffset);

      final fA = (((i3 & 0xc0) >> 6)) / _max2Bits;
      final fB = (((i3 & 0x3f) << 4) | ((i2 & 0xf0) >> 4)) / _max10Bits;
      final fG = (((i2 & 0x0f) << 6) | ((i1 & 0xfc) >> 2)) / _max10Bits;
      final fR = (((i1 & 0x03) << 8) | ((i0 & 0xff) >> 0)) / _max10Bits;
      dstFloat32x4[i] = Float32x4(fR, fG, fB, fA);
    }
    return dstFloat32x4.buffer.asUint8List();
  }
}
