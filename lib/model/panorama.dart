import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PanoramaInfo {
  final Rect croppedAreaRect;
  final Size fullPanoSize;
  final String projectionType;

  PanoramaInfo({
    this.croppedAreaRect,
    this.fullPanoSize,
    this.projectionType,
  });

  factory PanoramaInfo.fromMap(Map map) {
    var cLeft = map['croppedAreaLeft'] as int;
    var cTop = map['croppedAreaTop'] as int;
    final cWidth = map['croppedAreaWidth'] as int;
    final cHeight = map['croppedAreaHeight'] as int;
    var fWidth = map['fullPanoWidth'] as int;
    var fHeight = map['fullPanoHeight'] as int;
    final projectionType = map['projectionType'] as String;

    // handle missing `fullPanoHeight` (e.g. Samsung camera app panorama mode)
    if (fHeight == null && cWidth != null && cHeight != null) {
      // assume the cropped area is actually covering 360 degrees horizontally
      // even when `croppedAreaLeft` is non zero
      fWidth = cWidth;
      fHeight = (fWidth / 2).round();
      cTop = ((fHeight - cHeight) / 2).round();
      cLeft = 0;
    }

    Rect croppedAreaRect;
    if (cLeft != null && cTop != null && cWidth != null && cHeight != null) {
      croppedAreaRect = Rect.fromLTWH(cLeft.toDouble(), cTop.toDouble(), cWidth.toDouble(), cHeight.toDouble());
    }

    Size fullPanoSize;
    if (fWidth != null && fHeight != null) {
      fullPanoSize = Size(fWidth.toDouble(), fHeight.toDouble());
    }

    return PanoramaInfo(
      croppedAreaRect: croppedAreaRect,
      fullPanoSize: fullPanoSize,
      projectionType: projectionType,
    );
  }

  bool get hasCroppedArea => croppedAreaRect != null && fullPanoSize != null;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{croppedAreaRect=$croppedAreaRect, fullPanoSize=$fullPanoSize, projectionType=$projectionType}';
}
