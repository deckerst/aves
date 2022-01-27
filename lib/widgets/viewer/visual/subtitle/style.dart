import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class SubtitleStyle extends Equatable with Diagnosticable {
  final TextAlign? hAlign;
  final TextAlignVertical? vAlign;
  final Color? borderColor;
  final double? borderWidth, edgeBlur, rotationX, rotationY, rotationZ, scaleX, scaleY, shearX, shearY;
  final List<Path>? drawingPaths;

  bool get rotating => (rotationX ?? 0) != 0 || (rotationY ?? 0) != 0 || (rotationZ ?? 0) != 0;

  bool get scaling => (scaleX ?? 1) != 1 || (scaleY ?? 1) != 1;

  bool get shearing => (shearX ?? 0) != 0 || (shearY ?? 0) != 0;

  @override
  List<Object?> get props => [
        hAlign,
        vAlign,
        borderColor,
        borderWidth,
        edgeBlur,
        rotationX,
        rotationY,
        rotationZ,
        scaleX,
        scaleY,
        shearX,
        shearY,
        drawingPaths?.length,
      ];

  const SubtitleStyle({
    this.hAlign,
    this.vAlign,
    this.borderColor,
    this.borderWidth,
    this.edgeBlur,
    this.rotationX,
    this.rotationY,
    this.rotationZ,
    this.scaleX,
    this.scaleY,
    this.shearX,
    this.shearY,
    this.drawingPaths,
  });

  SubtitleStyle copyWith({
    TextAlign? hAlign,
    TextAlignVertical? vAlign,
    Color? borderColor,
    double? borderWidth,
    double? edgeBlur,
    double? rotationX,
    double? rotationY,
    double? rotationZ,
    double? scaleX,
    double? scaleY,
    double? shearX,
    double? shearY,
    List<Path>? drawingPaths,
  }) {
    return SubtitleStyle(
      hAlign: hAlign ?? this.hAlign,
      vAlign: vAlign ?? this.vAlign,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      edgeBlur: edgeBlur ?? this.edgeBlur,
      rotationX: rotationX ?? this.rotationX,
      rotationY: rotationY ?? this.rotationY,
      rotationZ: rotationZ ?? this.rotationZ,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      shearX: shearX ?? this.shearX,
      shearY: shearY ?? this.shearY,
      drawingPaths: drawingPaths ?? this.drawingPaths,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextAlign>('hAlign', hAlign));
    properties.add(EnumProperty<TextAlignVertical>('vAlign', vAlign));
    properties.add(ColorProperty('borderColor', borderColor));
    properties.add(DoubleProperty('borderWidth', borderWidth));
    properties.add(DoubleProperty('edgeBlur', edgeBlur));
    properties.add(DoubleProperty('rotationX', rotationX));
    properties.add(DoubleProperty('rotationY', rotationY));
    properties.add(DoubleProperty('rotationZ', rotationZ));
    properties.add(DoubleProperty('scaleX', scaleX));
    properties.add(DoubleProperty('scaleY', scaleY));
    properties.add(DoubleProperty('shearX', shearX));
    properties.add(DoubleProperty('shearY', shearY));
    properties.add(DiagnosticsProperty<List<Path>>('drawingPaths', drawingPaths));
  }
}
