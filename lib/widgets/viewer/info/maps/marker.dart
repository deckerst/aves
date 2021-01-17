import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/collection/thumbnail/raster.dart';
import 'package:aves/widgets/collection/thumbnail/vector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ImageMarker extends StatelessWidget {
  final ImageEntry entry;
  final double extent;
  final Size pointerSize;

  static const double outerBorderRadiusDim = 8;
  static const double outerBorderWidth = 1.5;
  static const double innerBorderWidth = 2;
  static const outerBorderColor = Colors.white30;
  static final innerBorderColor = Colors.grey[900];

  const ImageMarker({
    @required this.entry,
    @required this.extent,
    this.pointerSize = Size.zero,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = entry.isSvg
        ? VectorImageThumbnail(
            entry: entry,
            extent: extent,
          )
        : RasterImageThumbnail(
            entry: entry,
            extent: extent,
          );

    final outerBorderRadius = BorderRadius.circular(outerBorderRadiusDim);
    final innerBorderRadius = BorderRadius.circular(outerBorderRadiusDim - outerBorderWidth);

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
          decoration: BoxDecoration(
            border: Border.all(
              color: outerBorderColor,
              width: outerBorderWidth,
            ),
            borderRadius: outerBorderRadius,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: innerBorderColor,
                width: innerBorderWidth,
              ),
              borderRadius: innerBorderRadius,
            ),
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
    this.color,
    this.outlineColor,
    this.outlineWidth,
    this.size,
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
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// generate bitmap from widget, for Google Maps
class MarkerGeneratorWidget extends StatefulWidget {
  final List<Widget> markers;
  final Duration delay;
  final Function(List<Uint8List> bitmaps) onComplete;

  const MarkerGeneratorWidget({
    Key key,
    @required this.markers,
    this.delay = Duration.zero,
    @required this.onComplete,
  }) : super(key: key);

  @override
  _MarkerGeneratorWidgetState createState() => _MarkerGeneratorWidgetState();
}

class _MarkerGeneratorWidgetState extends State<MarkerGeneratorWidget> {
  final _globalKeys = <GlobalKey>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.delay > Duration.zero) {
        await Future.delayed(widget.delay);
      }
      widget.onComplete(await _getBitmaps(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(MediaQuery.of(context).size.width, 0),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: widget.markers.map((i) {
            final key = GlobalKey();
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
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Future.wait(_globalKeys.map((key) async {
      RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData.buffer.asUint8List();
    }));
  }
}
