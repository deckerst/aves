import 'package:flutter/foundation.dart';

@immutable
class MapTile {
  final int width, height;
  final Uint8List data;

  const new({
    required this.width,
    required this.height,
    required this.data,
  });
}
