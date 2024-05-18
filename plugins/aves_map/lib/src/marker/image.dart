import 'package:aves_map/aves_map.dart';
import 'package:aves_map/src/marker/arrow_painter.dart';
import 'package:collection/collection.dart';
import 'package:custom_rounded_rectangle_border/custom_rounded_rectangle_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart' as intl;
import 'package:latlong2/latlong.dart';

class ImageMarker extends StatelessWidget {
  final int? count;
  final intl.NumberFormat numberFormat;
  final bool drawArrow;
  final Widget Function(double extent) buildThumbnailImage;

  static const double outerBorderRadiusDim = 8;
  static const outerBorderWidth = MapThemeData.markerOuterBorderWidth;
  static const innerBorderWidth = MapThemeData.markerInnerBorderWidth;
  static const extent = MapThemeData.markerImageExtent;
  static const arrowSize = MapThemeData.markerArrowSize;
  static const outerBorderRadius = BorderRadius.all(Radius.circular(outerBorderRadiusDim));
  static const innerRadius = Radius.circular(outerBorderRadiusDim - outerBorderWidth);
  static const innerBorderRadius = BorderRadius.all(innerRadius);

  ImageMarker({
    super.key,
    required this.count,
    required String locale,
    this.drawArrow = true,
    required this.buildThumbnailImage,
  }) : numberFormat = intl.NumberFormat.decimalPattern(locale);

  @override
  Widget build(BuildContext context) {
    Widget child = buildThumbnailImage(extent);

    // need to be sized for the Google map marker generator
    child = SizedBox(
      width: extent,
      height: extent,
      child: child,
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final outerBorderColor = MapThemeData.markerThemedOuterBorderColor(isDark);
    final innerBorderColor = MapThemeData.markerThemedInnerBorderColor(isDark);

    final outerDecoration = BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: outerBorderColor,
        width: outerBorderWidth,
      )),
      borderRadius: outerBorderRadius,
    );

    final innerDecoration = BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: innerBorderColor,
        width: innerBorderWidth,
      )),
      borderRadius: innerBorderRadius,
    );

    child = DecoratedBox(
      decoration: innerDecoration,
      position: DecorationPosition.foreground,
      child: ClipRRect(
        borderRadius: innerBorderRadius,
        child: child,
      ),
    );

    if (count != null) {
      final borderSide = BorderSide(
        color: innerBorderColor,
        width: innerBorderWidth,
      );
      child = Stack(
        children: [
          child,
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
            decoration: ShapeDecoration(
              color: theme.colorScheme.primary,
              shape: Directionality.of(context) == TextDirection.rtl
                  ? CustomRoundedRectangleBorder(
                      leftSide: borderSide,
                      rightSide: borderSide,
                      topSide: borderSide,
                      bottomSide: borderSide,
                      topRightCornerSide: borderSide,
                      bottomLeftCornerSide: borderSide,
                      borderRadius: const BorderRadius.only(
                        topRight: innerRadius,
                        bottomLeft: innerRadius,
                      ),
                    )
                  : CustomRoundedRectangleBorder(
                      leftSide: borderSide,
                      rightSide: borderSide,
                      topSide: borderSide,
                      bottomSide: borderSide,
                      topLeftCornerSide: borderSide,
                      bottomRightCornerSide: borderSide,
                      borderRadius: const BorderRadius.only(
                        topLeft: innerRadius,
                        bottomRight: innerRadius,
                      ),
                    ),
            ),
            child: Text(
              numberFormat.format(count),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    }

    child = Container(
      decoration: outerDecoration,
      child: child,
    );

    if (drawArrow) {
      child = CustomPaint(
        foregroundPainter: MarkerArrowPainter(
          color: innerBorderColor,
          outlineColor: outerBorderColor,
          outlineWidth: outerBorderWidth,
          size: arrowSize,
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: arrowSize.height),
          child: child,
        ),
      );
    }

    return child;
  }

  static const _crs = Epsg3857();

  static GeoEntry<T>? markerMatch<T>(LatLng position, double zoom, Set<GeoEntry<T>> markers) {
    final pressPoint = _crs.latLngToPoint(position, zoom);
    final pressOffset = Offset(pressPoint.x.toDouble(), pressPoint.y.toDouble());

    const double markerWidth = extent;
    const double markerHeight = extent;

    return markers.firstWhereOrNull((marker) {
      final latitude = marker.latitude;
      final longitude = marker.longitude;
      if (latitude == null || longitude == null) return false;

      final markerAnchorPoint = _crs.latLngToPoint(LatLng(latitude, longitude), zoom);
      final bottom = markerAnchorPoint.y.toDouble();
      final top = bottom - markerHeight;
      final left = markerAnchorPoint.x.toDouble() - markerWidth / 2;
      final right = left + markerWidth;
      final markerRect = Rect.fromLTRB(left, top, right, bottom);

      return markerRect.contains(pressOffset);
    });
  }
}
