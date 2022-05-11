import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapOverlayButton extends StatelessWidget {
  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const MapOverlayButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blurred = settings.enableOverlayBlurEffect;
    return Selector<MapThemeData, Animation<double>>(
      selector: (context, v) => v.scale,
      builder: (context, scale, child) => ScaleTransition(
        scale: scale,
        child: child,
      ),
      child: BlurredOval(
        enabled: blurred,
        child: Material(
          type: MaterialType.circle,
          color: Themes.overlayBackgroundColor(brightness: Theme.of(context).brightness, blurred: blurred),
          child: Ink(
            decoration: BoxDecoration(
              border: AvesBorder.border(context),
              shape: BoxShape.circle,
            ),
            child: Selector<MapThemeData, VisualDensity?>(
              selector: (context, v) => v.visualDensity,
              builder: (context, visualDensity, child) => IconButton(
                iconSize: 20,
                visualDensity: visualDensity,
                icon: icon,
                onPressed: onPressed,
                tooltip: tooltip,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
