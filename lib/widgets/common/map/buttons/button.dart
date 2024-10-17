import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapOverlayButton extends StatelessWidget {
  final Key? buttonKey;
  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const MapOverlayButton({
    super.key,
    this.buttonKey,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

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
        builder: (context, visualDensity, child) => IconButton(
          key: buttonKey,
          iconSize: 20 + 1.5 * visualDensity.horizontal,
          visualDensity: visualDensity,
          icon: icon,
          onPressed: onPressed,
          tooltip: tooltip,
        ),
      ),
    );
  }
}
