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
