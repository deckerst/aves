import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:flutter/widgets.dart';

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

  double extentPx(Size widgetSizePx, AvesEntry entry) {
    switch (this) {
      case WidgetShape.rrect:
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
        return widgetSizePx.shortestSide;
    }
  }
}
