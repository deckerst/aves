import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:flutter/material.dart';

class OverlayButton extends StatelessWidget {
  final Animation<double> scale;
  final BorderRadius? borderRadius;
  final Widget child;

  const OverlayButton({
    Key? key,
    this.scale = kAlwaysCompleteAnimation,
    this.borderRadius,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final blurred = settings.enableOverlayBlurEffect;
    return ScaleTransition(
      scale: scale,
      child: borderRadius != null
          ? BlurredRRect(
              enabled: blurred,
              borderRadius: borderRadius,
              child: Material(
                type: MaterialType.button,
                borderRadius: borderRadius,
                color: Themes.overlayBackgroundColor(brightness: brightness, blurred: blurred),
                child: Ink(
                  decoration: BoxDecoration(
                    border: AvesBorder.border(context),
                    borderRadius: borderRadius,
                  ),
                  child: child,
                ),
              ),
            )
          : BlurredOval(
              enabled: blurred,
              child: Material(
                type: MaterialType.circle,
                color: Themes.overlayBackgroundColor(brightness: brightness, blurred: blurred),
                child: Ink(
                  decoration: BoxDecoration(
                    border: AvesBorder.border(context),
                    shape: BoxShape.circle,
                  ),
                  child: child,
                ),
              ),
            ),
    );
  }

  // icon (24) + icon padding (8) + button padding (16) + border (1 or 2)
  static double getSize(BuildContext context) => 48.0 + AvesBorder.curvedBorderWidth * 2;
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
  static final _minSize = MaterialStateProperty.all<Size>(const Size(kMinInteractiveDimension, kMinInteractiveDimension));

  @override
  Widget build(BuildContext context) {
    final blurred = settings.enableOverlayBlurEffect;
    final theme = Theme.of(context);
    return SizeTransition(
      sizeFactor: scale,
      child: BlurredRRect.all(
        enabled: blurred,
        borderRadius: _borderRadius,
        child: OutlinedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Themes.overlayBackgroundColor(brightness: theme.brightness, blurred: blurred)),
            foregroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.onSurface),
            overlayColor: theme.brightness == Brightness.dark ? MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.12)) : null,
            minimumSize: _minSize,
            side: MaterialStateProperty.all<BorderSide>(AvesBorder.curvedSide(context)),
            shape: MaterialStateProperty.all<OutlinedBorder>(const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
            )),
          ),
          child: Text(buttonLabel),
        ),
      ),
    );
  }
}
