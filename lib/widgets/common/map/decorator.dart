import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/providers/map_theme_provider.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapDecorator extends StatelessWidget {
  final Widget child;

  static const mapBorderRadius = BorderRadius.all(Radius.circular(24)); // to match button circles
  static const mapBackground = Color(0xFFDBD5D3);
  static const mapLoadingGrid = Color(0xFFC4BEBB);

  const MapDecorator({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget _child = ClipRRect(
      borderRadius: mapBorderRadius,
      child: Container(
        color: mapBackground,
        foregroundDecoration: BoxDecoration(
          border: AvesBorder.border(context),
          borderRadius: mapBorderRadius,
        ),
        child: Stack(
          children: [
            const GridPaper(
              color: mapLoadingGrid,
              interval: 10,
              divisions: 1,
              subdivisions: 1,
              child: CustomPaint(
                size: Size.infinite,
              ),
            ),
            child,
          ],
        ),
      ),
    );

    final animate = context.select<Settings, bool>((v) => v.animate);
    if (animate) {
      _child = Hero(
        tag: 'map-canvas',
        flightShuttleBuilder: MapTheme.heroFlightShuttleBuilder,
        child: _child,
      );
    }

    final interactive = context.select<MapThemeData, bool>((v) => v.interactive);
    return GestureDetector(
      onScaleStart: interactive
          ? null
          : (details) {
              // absorb scale gesture here to prevent scrolling
              // and triggering by mistake a move to the image page above
            },
      child: _child,
    );
  }
}
