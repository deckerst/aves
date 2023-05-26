import 'package:aves/widgets/editor/transform/cropper.dart';
import 'package:flutter/material.dart';

class VertexHandle extends StatefulWidget {
  final EdgeInsets padding;
  final ValueGetter<Offset> getPosition;
  final ValueSetter<Offset> setPosition;
  final VoidCallback onDragStart, onDragEnd;

  const VertexHandle({
    super.key,
    required this.padding,
    required this.getPosition,
    required this.setPosition,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  State<VertexHandle> createState() => _VertexHandleState();
}

class _VertexHandleState extends State<VertexHandle> {
  Offset _start = Offset.zero;
  Offset _totalDelta = Offset.zero;

  static const double _handleDim = Cropper.handleDimension;

  EdgeInsets get padding => widget.padding;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: Rect.fromCenter(
        center: widget.getPosition().translate(padding.left, padding.right),
        width: _handleDim,
        height: _handleDim,
      ),
      child: GestureDetector(
        onPanStart: (details) {
          _totalDelta = Offset.zero;
          _start = widget.getPosition();
          widget.onDragStart();
        },
        onPanUpdate: (details) {
          _totalDelta += details.delta;
          widget.setPosition(_start + _totalDelta);
        },
        onPanEnd: (details) {
          widget.onDragEnd();
        },
        child: const ColoredBox(
          color: Colors.transparent,
        ),
      ),
    );
  }
}

class EdgeHandle extends StatefulWidget {
  final EdgeInsets padding;
  final ValueGetter<Rect> getEdge;
  final ValueSetter<Rect> setEdge;
  final VoidCallback onDragStart, onDragEnd;

  const EdgeHandle({
    super.key,
    required this.padding,
    required this.getEdge,
    required this.setEdge,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  State<EdgeHandle> createState() => _EdgeHandleState();
}

class _EdgeHandleState extends State<EdgeHandle> {
  Rect _start = Rect.zero;
  Offset _totalDelta = Offset.zero;

  static const double _handleDim = Cropper.handleDimension;

  EdgeInsets get padding => widget.padding;

  @override
  Widget build(BuildContext context) {
    var edge = widget.getEdge();
    if (edge.width > _handleDim && edge.height == 0) {
      // horizontal edge
      edge = Rect.fromLTWH(edge.left + _handleDim / 2, edge.top - _handleDim / 2, edge.width - _handleDim, _handleDim);
    } else if (edge.height > _handleDim && edge.width == 0) {
      // vertical edge
      edge = Rect.fromLTWH(edge.left - _handleDim / 2, edge.top + _handleDim / 2, _handleDim, edge.height - _handleDim);
    }
    edge = edge.translate(padding.left, padding.right);

    return Positioned.fromRect(
      rect: edge,
      child: GestureDetector(
        onPanStart: (details) {
          _totalDelta = Offset.zero;
          _start = widget.getEdge();
          widget.onDragStart();
        },
        onPanUpdate: (details) {
          _totalDelta += details.delta;
          widget.setEdge(Rect.fromLTWH(_start.left + _totalDelta.dx, _start.top + _totalDelta.dy, _start.width, _start.height));
        },
        onPanEnd: (details) {
          widget.onDragEnd();
        },
        child: const ColoredBox(
          color: Colors.transparent,
        ),
      ),
    );
  }
}
