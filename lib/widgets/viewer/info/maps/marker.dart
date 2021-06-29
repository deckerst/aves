import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aves/model/entry.dart';
import 'package:aves/widgets/collection/thumbnail/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ImageMarker extends StatelessWidget {
  final AvesEntry entry;
  final double extent;
  final Size pointerSize;

  static const double outerBorderRadiusDim = 8;
  static const double outerBorderWidth = 1.5;
  static const double innerBorderWidth = 2;
  static const outerBorderColor = Colors.white30;
  static const innerBorderColor = Color(0xFF212121);
  static const outerBorderRadius = BorderRadius.all(Radius.circular(outerBorderRadiusDim));
  static const innerBorderRadius = BorderRadius.all(Radius.circular(outerBorderRadiusDim - outerBorderWidth));

  const ImageMarker({
    Key? key,
    required this.entry,
    required this.extent,
    this.pointerSize = Size.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thumbnail = ThumbnailImage(
      entry: entry,
      extent: extent,
    );

    const outerDecoration = BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: outerBorderColor,
        width: outerBorderWidth,
      )),
      borderRadius: outerBorderRadius,
    );

    const innerDecoration = BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: innerBorderColor,
        width: innerBorderWidth,
      )),
      borderRadius: innerBorderRadius,
    );

    return CustomPaint(
      foregroundPainter: MarkerPointerPainter(
        color: innerBorderColor,
        outlineColor: outerBorderColor,
        outlineWidth: outerBorderWidth,
        size: pointerSize,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: pointerSize.height),
        child: Container(
          decoration: outerDecoration,
          child: DecoratedBox(
            decoration: innerDecoration,
            position: DecorationPosition.foreground,
            child: ClipRRect(
              borderRadius: innerBorderRadius,
              child: thumbnail,
            ),
          ),
        ),
      ),
    );
  }
}

class MarkerPointerPainter extends CustomPainter {
  final Color color, outlineColor;
  final double outlineWidth;
  final Size size;

  const MarkerPointerPainter({
    required this.color,
    required this.outlineColor,
    required this.outlineWidth,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pointerWidth = this.size.width;
    final pointerHeight = this.size.height;

    final bottomCenter = Offset(size.width / 2, size.height);
    final topLeft = bottomCenter + Offset(-pointerWidth / 2, -pointerHeight);
    final topRight = bottomCenter + Offset(pointerWidth / 2, -pointerHeight);

    canvas.drawPath(
        Path()
          ..moveTo(bottomCenter.dx, bottomCenter.dy)
          ..lineTo(topRight.dx, topRight.dy)
          ..lineTo(topLeft.dx, topLeft.dy)
          ..close(),
        Paint()..color = outlineColor);

    canvas.translate(0, -outlineWidth.ceilToDouble());
    canvas.drawPath(
        Path()
          ..moveTo(bottomCenter.dx, bottomCenter.dy)
          ..lineTo(topRight.dx, topRight.dy)
          ..lineTo(topLeft.dx, topLeft.dy)
          ..close(),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// generate bitmap from widget, for Google Maps
class MarkerGeneratorWidget extends StatefulWidget {
  final List<Widget> markers;
  final Duration delay;
  final Function(List<Uint8List> bitmaps) onComplete;

  const MarkerGeneratorWidget({
    Key? key,
    required this.markers,
    this.delay = Duration.zero,
    required this.onComplete,
  }) : super(key: key);

  @override
  _MarkerGeneratorWidgetState createState() => _MarkerGeneratorWidgetState();
}

class _MarkerGeneratorWidgetState extends State<MarkerGeneratorWidget> {
  final _globalKeys = <GlobalKey>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (widget.delay > Duration.zero) {
        await Future.delayed(widget.delay);
      }
      widget.onComplete(await _getBitmaps(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(context.select<MediaQueryData, double>((mq) => mq.size.width), 0),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: widget.markers.map((i) {
            final key = GlobalKey(debugLabel: 'map-marker-$i');
            _globalKeys.add(key);
            return RepaintBoundary(
              key: key,
              child: i,
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<List<Uint8List>> _getBitmaps(BuildContext context) async {
    final pixelRatio = context.read<MediaQueryData>().devicePixelRatio;
    return Future.wait(_globalKeys.map((key) async {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData != null ? byteData.buffer.asUint8List() : Uint8List(0);
    }));
  }
}
