import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/providers/map_theme_provider.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapDecorator extends StatelessWidget {
  final Widget child;

  static const mapBackground = Color(0xFFDBD5D3);
  static const mapLoadingGrid = Color(0xFFC4BEBB);

  const MapDecorator({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // derive matching optical radius as follow: outer radius - padding = inner radius
    // i.e. map corner radius = button corner radius + padding
    final visualDensity = context.select<MapThemeData, VisualDensity>((v) => v.visualDensity);
    final buttonPadding = context.select<MapThemeData, double>((v) => v.buttonPadding);
    final scale = context.select<MapThemeData, Animation<double>>((v) => v.scale);
    final innerRadius = (kMinInteractiveDimension + visualDensity.horizontal * 4) / 2; // from `IconButton` and `VisualDensity`
    final outerRadius = innerRadius + buttonPadding;

    Widget _child = AnimatedBuilder(
      animation: scale,
      builder: (context, child) {
        final mapBorderRadius = BorderRadius.all(Radius.circular(outerRadius * scale.value));
        return ClipRRect(
          borderRadius: mapBorderRadius,
          child: Container(
            color: mapBackground,
            foregroundDecoration: BoxDecoration(
              border: AvesBorder.border(context),
              borderRadius: mapBorderRadius,
            ),
            child: child,
          ),
        );
      },
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
