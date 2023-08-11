import 'dart:typed_data';
import 'dart:ui';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/viewer/overlay/top.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ImageHistogram extends StatefulWidget {
  final AvesEntry entry;
  final ImageProvider image;

  const ImageHistogram({
    super.key,
    required this.entry,
    required this.image,
  });

  @override
  State<ImageHistogram> createState() => _ImageHistogramState();
}

class _ImageHistogramState extends State<ImageHistogram> {
  Map<Color, List<double>> _levels = {};
  ImageStream? _imageStream;
  late ImageStreamListener _imageListener;

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

  static const int bins = 256;
  static const int normMax = bins - 1;

  Future<void> _updateLevels(ImageInfo info) async {
    final image = info.image;
    final data = (await image.toByteData(format: ImageByteFormat.rawExtendedRgba128))!;
    final floats = Float32List.view(data.buffer);

    final newLevels = switch (settings.overlayHistogramStyle) {
      OverlayHistogramStyle.rgb => _computeRgbLevels(floats),
      OverlayHistogramStyle.luminance => _computeLuminanceLevels(floats),
      _ => <Color, List<double>>{},
    };

    setState(() => _levels = newLevels);
  }

  Map<Color, List<double>> _computeRgbLevels(Float32List floats) {
    final redLevels = List.filled(bins, 0);
    final greenLevels = List.filled(bins, 0);
    final blueLevels = List.filled(bins, 0);

    final pixelCount = floats.length / 4;
    for (var i = 0; i < pixelCount; i += 4) {
      final a = floats[i + 3];
      if (a > 0) {
        final r = floats[i + 0];
        final g = floats[i + 1];
        final b = floats[i + 2];
        redLevels[(r * normMax).round()]++;
        greenLevels[(g * normMax).round()]++;
        blueLevels[(b * normMax).round()]++;
      }
    }

    final max = [
      redLevels.max,
      greenLevels.max,
      blueLevels.max,
    ].max;
    if (max == 0) return {};

    final f = 1.0 / max;
    return {
      Colors.red: redLevels.map((v) => v * f).toList(),
      Colors.green: greenLevels.map((v) => v * f).toList(),
      Colors.blue: blueLevels.map((v) => v * f).toList(),
    };
  }

  Map<Color, List<double>> _computeLuminanceLevels(Float32List floats) {
    final lumLevels = List.filled(bins, 0);

    final pixelCount = floats.length / 4;
    for (var i = 0; i < pixelCount; i += 4) {
      final a = floats[i + 3];
      if (a > 0) {
        final r = floats[i + 0];
        final g = floats[i + 1];
        final b = floats[i + 2];
        final c = Color.fromARGB((a * 255).round(), (r * 255).round(), (g * 255).round(), (b * 255).round());
        lumLevels[(c.computeLuminance() * normMax).round()]++;
      }
    }

    final max = lumLevels.max;
    if (max == 0) return {};

    final f = 1.0 / max;
    return {
      Colors.white: lumLevels.map((v) => v * f).toList(),
    };
  }
}

class _HistogramPainter extends CustomPainter {
  final Map<Color, List<double>> levels;
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
    final backgroundRect = Rect.fromPoints(Offset.zero, Offset(size.width, size.height));
    canvas.drawRect(backgroundRect, fill);
    levels.forEach((color, values) => _drawLevels(canvas, size, color, values));
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
