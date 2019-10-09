import 'package:aves/widgets/common/blurred.dart';
import 'package:flutter/material.dart';

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
          color: Colors.black26,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 0.5),
              shape: BoxShape.circle,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
