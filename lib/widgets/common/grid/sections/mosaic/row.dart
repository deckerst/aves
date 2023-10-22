import 'package:aves/widgets/common/grid/sections/mosaic/section_layout.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MosaicGridRow extends MultiChildRenderObjectWidget {
  final MosaicRowLayout rowLayout;
  final double spacing;
  final TextDirection textDirection;

  const MosaicGridRow({
    super.key,
    required this.rowLayout,
    required this.spacing,
    required this.textDirection,
    required super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMosaicGridRow(
      rowLayout: rowLayout,
      spacing: spacing,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMosaicGridRow renderObject) {
    renderObject.rowLayout = rowLayout;
    renderObject.spacing = spacing;
    renderObject.textDirection = textDirection;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<MosaicRowLayout>('rowLayout', rowLayout));
    properties.add(DoubleProperty('spacing', spacing));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection));
  }
}

class _GridRowParentData extends ContainerBoxParentData<RenderBox> {}

class RenderMosaicGridRow extends RenderBox with ContainerRenderObjectMixin<RenderBox, _GridRowParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _GridRowParentData> {
  RenderMosaicGridRow({
    List<RenderBox>? children,
    required MosaicRowLayout rowLayout,
    required double spacing,
    required TextDirection textDirection,
  })  : _rowLayout = rowLayout,
        _spacing = spacing,
        _textDirection = textDirection {
    addAll(children);
  }

  MosaicRowLayout get rowLayout => _rowLayout;
  MosaicRowLayout _rowLayout;

  set rowLayout(MosaicRowLayout value) {
    if (_rowLayout == value) return;
    _rowLayout = value;
    markNeedsLayout();
  }

  double get spacing => _spacing;
  double _spacing;

  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GridRowParentData) {
      child.parentData = _GridRowParentData();
    }
  }

  double get intrinsicWidth => rowLayout.itemWidths.sum + spacing * (childCount - 1);

  @override
  double computeMinIntrinsicWidth(double height) => intrinsicWidth;

  @override
  double computeMaxIntrinsicWidth(double height) => intrinsicWidth;

  @override
  double computeMinIntrinsicHeight(double width) => rowLayout.height;

  @override
  double computeMaxIntrinsicHeight(double width) => rowLayout.height;

  @override
  void performLayout() {
    var child = firstChild;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    final thumbnailHeight = rowLayout.height - spacing;
    size = Size(constraints.maxWidth, rowLayout.height);
    final flipMainAxis = textDirection == TextDirection.rtl;
    final sign = (flipMainAxis ? -1.0 : 1.0);
    var i = 0;
    var offset = Offset(flipMainAxis ? size.width - rowLayout.itemWidths[i] : 0, 0);
    while (child != null) {
      final thumbnailWidth = rowLayout.itemWidths[i];
      final childConstraints = BoxConstraints.tight(Size(thumbnailWidth, thumbnailHeight));
      child.layout(childConstraints, parentUsesSize: false);
      final childParentData = child.parentData! as _GridRowParentData;
      childParentData.offset = offset;
      final dx = sign * (thumbnailWidth + spacing);
      offset += Offset(dx, 0);
      child = childParentData.nextSibling;
      i++;
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<MosaicRowLayout>('rowLayout', rowLayout));
    properties.add(DoubleProperty('spacing', spacing));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection));
  }
}
