import 'dart:ui';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/widgets/viewer/overlay/top.dart';
import 'package:aves/widgets/viewer/view/controller.dart';
import 'package:aves/widgets/viewer/view/histogram.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ImageHistogram extends StatefulWidget {
  final ViewStateController viewStateController;
  final ImageProvider image;

  const ImageHistogram({
    super.key,
    required this.viewStateController,
    required this.image,
  });

  @override
  State<ImageHistogram> createState() => _ImageHistogramState();
}

class _ImageHistogramState extends State<ImageHistogram> {
  HistogramLevels _levels = {};
  ImageStream? _imageStream;
  late ImageStreamListener _imageListener;

  ViewStateController get viewStateController => widget.viewStateController;

  AvesEntry get entry => viewStateController.entry;

  ImageProvider get imageProvider => widget.image;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ImageHistogram oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(ImageHistogram widget) {
    _imageStream = imageProvider.resolve(ImageConfiguration.empty);
    _imageListener = ImageStreamListener((image, synchronousCall) {
      _updateLevels(image);
    });
    _imageStream?.addListener(_imageListener);
  }

  void _unregisterWidget(ImageHistogram widget) {
    _imageStream?.removeListener(_imageListener);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _HistogramPainter(
          levels: _levels,
          borderColor: ViewerTopOverlay.componentBorderColor,
        ),
        size: const Size(ViewerTopOverlay.componentDimension, ViewerTopOverlay.componentDimension * .6),
      ),
    );
  }

  Future<void> _updateLevels(ImageInfo info) async {
    final targetEntry = entry;
    final newLevels = await viewStateController.getHistogramLevels(info);
    if (mounted) {
      setState(() => _levels = targetEntry == entry ? newLevels : {});
    }
  }
}

class _HistogramPainter extends CustomPainter {
  final HistogramLevels levels;
  final Color borderColor;

  late final Paint fill, borderStroke;

  _HistogramPainter({
    required this.levels,
    this.borderColor = Colors.white,
  }) {
    fill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x33000000);
    borderStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;

    final backgroundRect = Rect.fromPoints(Offset.zero, Offset(size.width, size.height));
    canvas.drawRect(backgroundRect, fill);
    levels.forEach((channel, values) {
      final color = _getChannelColor(channel);
      _drawLevels(canvas, size, color, values);
    });
    canvas.drawRect(backgroundRect, borderStroke);
  }

  void _drawLevels(Canvas canvas, Size size, Color color, List<double> values) {
    if (values.length < 2) return;

    final xFactor = size.width / (values.length - 1);
    final yFactor = size.height;

    final polyline = values.mapIndexed((i, v) => Offset(i * xFactor, size.height - v * yFactor)).toList();
    canvas.drawPoints(
        PointMode.polygon,
        polyline,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color);

    polyline.add(Offset(size.width, size.height));
    polyline.add(Offset(0, size.height));
    canvas.drawPath(
        Path()..addPolygon(polyline, true),
        Paint()
          ..style = PaintingStyle.fill
          ..color = color.withOpacity(.5));
  }

  Color _getChannelColor(HistogramChannel channel) {
    return switch (channel) {
      HistogramChannel.red => Colors.red,
      HistogramChannel.green => Colors.green,
      HistogramChannel.blue => Colors.blue,
      HistogramChannel.luminance => Colors.white,
    };
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
