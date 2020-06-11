import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:flutter/material.dart';

class FullscreenOverlay {
  static const backgroundColor = Colors.black26;

  static BoxBorder buildBorder(BuildContext context) {
    final subPixel = MediaQuery.of(context).devicePixelRatio > 2;
    return Border.all(
      color: Colors.white30,
      width: subPixel ? 0.5 : 1.0,
    );
  }
}

class OverlayButton extends StatelessWidget {
  final Animation<double> scale;
  final Widget child;

  const OverlayButton({Key key, this.scale, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: BlurredOval(
        child: Material(
          type: MaterialType.circle,
          color: FullscreenOverlay.backgroundColor,
          child: Ink(
            decoration: BoxDecoration(
              border: FullscreenOverlay.buildBorder(context),
              shape: BoxShape.circle,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
