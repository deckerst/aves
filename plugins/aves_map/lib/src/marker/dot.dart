import 'package:aves_map/src/theme.dart';
import 'package:aves_ui/aves_ui.dart';
import 'package:material_ui/material_ui.dart';

class DotMarker extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const AvesDot(
      diameter: MapThemeData.markerDotDiameter,
      outerBorderWidth: MapThemeData.markerOuterBorderWidth,
      innerBorderWidth: MapThemeData.markerInnerBorderWidth,
      getOuterBorderColor: MapThemeData.markerThemedOuterBorderColor,
      getInnerBorderColor: MapThemeData.markerThemedInnerBorderColor,
    );
  }
}
