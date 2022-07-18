import 'package:aves/model/settings/enums/enums.dart';
import 'package:flutter/material.dart';

extension ExtraWidgetShape on WidgetShape {
  Path path(Size widgetSize, double devicePixelRatio) {
    final rect = Rect.fromLTWH(0, 0, widgetSize.width, widgetSize.height);
    switch (this) {
      case WidgetShape.rrect:
        return Path()..addRRect(BorderRadius.circular(24 * devicePixelRatio).toRRect(rect));
      case WidgetShape.circle:
        return Path()
          ..addOval(Rect.fromCircle(
            center: rect.center,
            radius: rect.shortestSide / 2,
          ));
      case WidgetShape.heart:
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
  }

  Size size(Size widgetSize) {
    switch (this) {
      case WidgetShape.rrect:
        return widgetSize;
      case WidgetShape.circle:
      case WidgetShape.heart:
        return Size.square(widgetSize.shortestSide);
    }
  }
}
