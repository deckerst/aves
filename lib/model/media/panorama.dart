import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PanoramaInfo {
  final Rect? croppedAreaRect;
  final Size? fullPanoSize;
  final String? projectionType;

  PanoramaInfo({
    this.croppedAreaRect,
    this.fullPanoSize,
    this.projectionType,
  });

  factory PanoramaInfo.fromMap(Map map) {
    var cLeft = map['croppedAreaLeft'] as int?;
    var cTop = map['croppedAreaTop'] as int?;
    var cWidth = map['croppedAreaWidth'] as int?;
    var cHeight = map['croppedAreaHeight'] as int?;
    var fWidth = map['fullPanoWidth'] as int?;
    var fHeight = map['fullPanoHeight'] as int?;
    final projectionType = map['projectionType'] as String?;

    // handle missing `fullPanoHeight` (e.g. Samsung camera app panorama mode)
    if (fHeight == null && fWidth != null && cHeight != null) {
      fHeight = (fWidth / 2).round();
      cTop = ((fHeight - cHeight) / 2).round();
    }

    // handle inconsistent sizing (e.g. rotated image taken with OnePlus EB2103)
    if (cWidth != null && cHeight != null && fWidth != null && fHeight != null) {
      final croppedOrientation = cWidth > cHeight ? Orientation.landscape : Orientation.portrait;
      final fullOrientation = fWidth > fHeight ? Orientation.landscape : Orientation.portrait;
      var inconsistent = false;
      if (croppedOrientation != fullOrientation) {
        // inconsistent orientation
        inconsistent = true;
        final tmp = cHeight;
        cHeight = cWidth;
        cWidth = tmp;
      }

      if (cWidth > fWidth) {
        // inconsistent full/cropped width
        inconsistent = true;
        final tmp = fWidth;
        fWidth = cWidth;
        cWidth = tmp;
      }

      if (cHeight > fHeight) {
        // inconsistent full/cropped height
        inconsistent = true;
        final tmp = cHeight;
        cHeight = fHeight;
        fHeight = tmp;
      }

      if (inconsistent) {
        cLeft = (fWidth - cWidth) ~/ 2;
        cTop = (fHeight - cHeight) ~/ 2;
      }
    }

    Rect? croppedAreaRect;
    if (cLeft != null && cTop != null && cWidth != null && cHeight != null) {
      croppedAreaRect = Rect.fromLTWH(cLeft.toDouble(), cTop.toDouble(), cWidth.toDouble(), cHeight.toDouble());
    }

    Size? fullPanoSize;
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
