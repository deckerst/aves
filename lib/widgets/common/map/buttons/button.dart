import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapOverlayButton extends StatelessWidget {
  final ValueWidgetBuilder<VisualDensity> builder;

  const MapOverlayButton({
    super.key,
    required this.builder,
  });

  factory MapOverlayButton.icon({
    Key? buttonKey,
    required Widget icon,
    required String tooltip,
    VoidCallback? onPressed,
  }) {
    return MapOverlayButton(
      builder: (context, visualDensity, child) => IconButton(
        key: buttonKey,
        iconSize: iconSize(visualDensity),
        visualDensity: visualDensity,
        icon: icon,
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MapThemeData, Animation<double>>(
      selector: (context, v) => v.scale,
      builder: (context, scale, child) => OverlayButton(
        scale: scale,
        child: child!,
      ),
      child: Selector<MapThemeData, VisualDensity>(
        selector: (context, v) => v.visualDensity,
        builder: builder,
      ),
    );
  }

  static double iconSize(VisualDensity visualDensity) => 20 + 1.5 * visualDensity.horizontal;
}
