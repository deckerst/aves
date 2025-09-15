import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/painting.dart';

extension ExtraWidgetShape on WidgetShape {
  static const double _defaultCornerRadius = 24;

  Path path(Size widgetSize, double devicePixelRatio, {double? cornerRadiusPx}) {
    final rect = Offset.zero & widgetSize;
    switch (this) {
      case WidgetShape.rrect:
        return Path()..addRRect(BorderRadius.circular(cornerRadiusPx ?? (_defaultCornerRadius * devicePixelRatio)).toRRect(rect));
      case WidgetShape.circle:
        return Path()
          ..addOval(Rect.fromCircle(
            center: rect.center,
            radius: rect.shortestSide / 2,
          ));
      case WidgetShape.concaveSquare:
        return _buildConcaveSquarePath(rect);
      case WidgetShape.heart:
        return _buildHeartPath(rect);
      case WidgetShape.tearRectLeft:
        final radius = cornerRadiusPx ?? (_defaultCornerRadius * devicePixelRatio);
        return _buildTearRectPath(rect, topLeftRadiusPx: radius, topRightRadiusPx: radius * 2);
      case WidgetShape.tearRectRight:
        final radius = cornerRadiusPx ?? (_defaultCornerRadius * devicePixelRatio);
        return _buildTearRectPath(rect, topLeftRadiusPx: radius * 2, topRightRadiusPx: radius);
      case WidgetShape.wavyCircle16:
        return _buildWavyCirclePath(rect, 16, .5);
    }
  }

  Path _buildConcaveSquarePath(Rect rect) {
    final center = rect.center;
    final dim = rect.shortestSide;
    final radius = dim / 4;

    final tl = center + Offset(-radius, -radius);
    final tr = center + Offset(radius, -radius);
    final br = center + Offset(radius, radius);
    final bl = center + Offset(-radius, radius);

    final outsideDim = radius * (1 + sqrt(3));
    final left = center + Offset(-outsideDim, 0);
    final top = center + Offset(0, -outsideDim);
    final right = center + Offset(outsideDim, 0);
    final bottom = center + Offset(0, outsideDim);

    final tlTop = (tl + top) / 2;
    final topTr = (top + tr) / 2;
    final trRight = (tr + right) / 2;
    final rightBr = (right + br) / 2;
    final brBottom = (br + bottom) / 2;
    final bottomBl = (bottom + bl) / 2;
    final blLeft = (bl + left) / 2;
    final leftTl = (left + tl) / 2;

    final r = Radius.circular(radius);
    return Path()
      ..moveTo(tlTop.dx, tlTop.dy)
      ..arcToPoint(topTr, radius: r, clockwise: false)
      ..arcToPoint(trRight, radius: r)
      ..arcToPoint(rightBr, radius: r, clockwise: false)
      ..arcToPoint(brBottom, radius: r)
      ..arcToPoint(bottomBl, radius: r, clockwise: false)
      ..arcToPoint(blLeft, radius: r)
      ..arcToPoint(leftTl, radius: r, clockwise: false)
      ..arcToPoint(tlTop, radius: r);
  }

  Path _buildHeartPath(Rect rect) {
    final center = rect.center;
    final dim = rect.shortestSide;
    const p0dy = -.4;
    const p1dx = .5;
    const p1dy = -.4;
    const p2dx = .8;
    const p2dy = .5;
    const p3dy = .5 - p0dy;
    return Path()
      ..moveTo(center.dx, center.dy)
      ..relativeMoveTo(0, dim * p0dy)
      ..relativeCubicTo(dim * -p1dx, dim * p1dy, dim * -p2dx, dim * p2dy, 0, dim * p3dy)
      ..moveTo(center.dx, center.dy)
      ..relativeMoveTo(0, dim * p0dy)
      ..relativeCubicTo(dim * p1dx, dim * p1dy, dim * p2dx, dim * p2dy, 0, dim * p3dy);
  }

  Path _buildTearRectPath(Rect rect, {required double topLeftRadiusPx, required double topRightRadiusPx}) {
    final topLeftRadius = Radius.circular(topLeftRadiusPx);
    final topRightRadius = Radius.circular(topRightRadiusPx);
    return Path()
      ..addRRect(BorderRadius.only(
        topLeft: topLeftRadius,
        topRight: topRightRadius,
        bottomLeft: topRightRadius,
        bottomRight: topLeftRadius,
      ).toRRect(rect));
  }

  Path _buildWavyCirclePath(Rect rect, int bumpCount, double amplitudeFactor, {double angleOffset = 0}) {
    final center = rect.center;
    final dim = rect.shortestSide;

    final waveAmplitude = amplitudeFactor / bumpCount;
    final circleRadius = (dim / 2) * (1 - waveAmplitude);

    final pointCount = (dim * dim).round();
    final angleIncrement = 2 * pi / pointCount;
    final points = List.generate(pointCount, (i) {
      final t = angleIncrement * i;
      final r = cos((t + angleOffset) * bumpCount) * waveAmplitude + 1;
      final dx = r * cos(t) * circleRadius;
      final dy = r * sin(t) * circleRadius;
      return Offset(center.dx + dx, center.dy + dy);
    });
    final origin = points.first;

    final path = Path()..moveTo(origin.dx, origin.dy);
    for (var i = 0; i <= pointCount; i++) {
      final p = points[i % pointCount];
      path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  double extentPx(Size widgetSizePx, AvesEntry entry) {
    switch (this) {
      case WidgetShape.rrect:
      case WidgetShape.tearRectLeft:
      case WidgetShape.tearRectRight:
        final entryRatio = entry.displayAspectRatio;
        final widgetRatio = widgetSizePx.width / widgetSizePx.height;
        if (entryRatio > 1) {
          // landscape entry, must return thumbnail height as extent
          if (widgetRatio > entryRatio) {
            return widgetSizePx.width / entryRatio;
          } else {
            return widgetSizePx.height;
          }
        } else {
          // portrait entry, must return thumbnail width as extent
          if (widgetRatio > entryRatio) {
            return widgetSizePx.width;
          } else {
            return widgetSizePx.height * entryRatio;
          }
        }
      case WidgetShape.circle:
      case WidgetShape.heart:
      case WidgetShape.wavyCircle16:
      case WidgetShape.concaveSquare:
        return widgetSizePx.shortestSide;
    }
  }
}
