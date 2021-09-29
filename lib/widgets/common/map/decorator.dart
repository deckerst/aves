import 'package:aves/widgets/common/map/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapDecorator extends StatelessWidget {
  final Widget? child;

  static const mapBorderRadius = BorderRadius.all(Radius.circular(24)); // to match button circles
  static const mapBackground = Color(0xFFDBD5D3);
  static const mapLoadingGrid = Color(0xFFC4BEBB);

  const MapDecorator({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final interactive = context.select<MapThemeData, bool>((v) => v.interactive);
    return GestureDetector(
      onScaleStart: interactive
          ? null
          : (details) {
              // absorb scale gesture here to prevent scrolling
              // and triggering by mistake a move to the image page above
            },
      child: ClipRRect(
        borderRadius: mapBorderRadius,
        child: Container(
          color: mapBackground,
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
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }
}
