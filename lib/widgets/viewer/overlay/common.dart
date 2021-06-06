import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:flutter/material.dart';

const kOverlayBackgroundColor = Colors.black26;

class OverlayButton extends StatelessWidget {
  final Animation<double> scale;
  final Widget child;

  const OverlayButton({
    Key? key,
    this.scale = kAlwaysCompleteAnimation,
    required this.child,
  }) : super(key: key);

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
              border: AvesBorder.border,
              shape: BoxShape.circle,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // icon (24) + icon padding (8) + button padding (16) + border (2)
  static double getSize(BuildContext context) => 50.0;
}

class OverlayTextButton extends StatelessWidget {
  final Animation<double> scale;
  final String buttonLabel;
  final VoidCallback? onPressed;

  const OverlayTextButton({
    Key? key,
    required this.scale,
    required this.buttonLabel,
    this.onPressed,
  }) : super(key: key);

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
            side: MaterialStateProperty.all<BorderSide>(AvesBorder.side),
            shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            )),
            // shape: MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
          ),
          child: Text(buttonLabel),
        ),
      ),
    );
  }
}
