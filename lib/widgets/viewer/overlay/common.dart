import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:flutter/material.dart';

const kOverlayBackgroundColor = Colors.black26;

class OverlayButton extends StatelessWidget {
  final Animation<double> scale;
  final Widget child;

  const OverlayButton({
    Key key,
    @required this.scale,
    @required this.child,
  })  : assert(scale != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: BlurredOval(
        child: Material(
          type: MaterialType.circle,
          color: kOverlayBackgroundColor,
          child: Ink(
            decoration: BoxDecoration(
              border: AvesCircleBorder.build(context),
              shape: BoxShape.circle,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class OverlayTextButton extends StatelessWidget {
  final Animation<double> scale;
  final String buttonLabel;
  final VoidCallback onPressed;

  const OverlayTextButton({
    Key key,
    @required this.scale,
    @required this.buttonLabel,
    this.onPressed,
  })  : assert(scale != null),
        super(key: key);

  static const _borderRadius = 123.0;
  static final _minSize = MaterialStateProperty.all<Size>(Size(kMinInteractiveDimension, kMinInteractiveDimension));

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: scale,
      child: BlurredRRect(
        borderRadius: _borderRadius,
        child: OutlinedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(kOverlayBackgroundColor),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            overlayColor: MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.12)),
            minimumSize: _minSize,
            side: MaterialStateProperty.all<BorderSide>(AvesCircleBorder.buildSide(context)),
            shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
            )),
            // shape: MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
          ),
          child: Text(buttonLabel),
        ),
      ),
    );
  }
}
