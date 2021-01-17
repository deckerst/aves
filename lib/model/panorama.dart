import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PanoramaInfo {
  final Rect croppedAreaRect;
  final Size fullPanoSize;

  PanoramaInfo({
    this.croppedAreaRect,
    this.fullPanoSize,
  });

  factory PanoramaInfo.fromMap(Map map) {
    final cLeft = map['croppedAreaLeft'] as int;
    final cTop = map['croppedAreaTop'] as int;
    final cWidth = map['croppedAreaWidth'] as int;
    final cHeight = map['croppedAreaHeight'] as int;
    Rect croppedAreaRect;
    if (cLeft != null && cTop != null && cWidth != null && cHeight != null) {
      croppedAreaRect = Rect.fromLTWH(cLeft.toDouble(), cTop.toDouble(), cWidth.toDouble(), cHeight.toDouble());
    }

    final fWidth = map['fullPanoWidth'] as int;
    final fHeight = map['fullPanoHeight'] as int;
    Size fullPanoSize;
    if (fWidth != null && fHeight != null) {
      fullPanoSize = Size(fWidth.toDouble(), fHeight.toDouble());
    }

    return PanoramaInfo(
      croppedAreaRect: croppedAreaRect,
      fullPanoSize: fullPanoSize,
    );
  }

  bool get hasCroppedArea => croppedAreaRect != null && fullPanoSize != null;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{croppedAreaRect=$croppedAreaRect, fullPanoSize=$fullPanoSize}';
}
