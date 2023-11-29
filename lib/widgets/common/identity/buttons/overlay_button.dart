import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:flutter/material.dart';

class OverlayButton extends StatefulWidget {
  final Animation<double> scale;
  final BorderRadius? borderRadius;
  final FocusNode? focusNode;
  final Widget child;

  const OverlayButton({
    super.key,
    this.scale = kAlwaysCompleteAnimation,
    this.borderRadius,
    this.focusNode,
    required this.child,
  });

  @override
  State<OverlayButton> createState() => _OverlayButtonState();

  // icon (24) + icon padding (8) + button padding (16)
  static double getSize(BuildContext context) => 48;
}

class _OverlayButtonState extends State<OverlayButton> {
  final ValueNotifier<bool> _focusedNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant OverlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _focusedNotifier.dispose();
    super.dispose();
  }

  void _registerWidget(OverlayButton widget) {
    widget.focusNode?.addListener(_onFocusChanged);
  }

  void _unregisterWidget(OverlayButton widget) {
    widget.focusNode?.removeListener(_onFocusChanged);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = widget.borderRadius;

    final blurred = settings.enableBlurEffect;
    final overlayBackground = Themes.overlayBackgroundColor(
      brightness: colorScheme.brightness,
      blurred: blurred,
    );

    return Theme(
      data: theme.copyWith(
        colorScheme: colorScheme.copyWith(
          onSurfaceVariant: colorScheme.onSurface,
        ),
      ),
      child: ScaleTransition(
        scale: widget.scale,
        child: ValueListenableBuilder<bool>(
          valueListenable: _focusedNotifier,
          builder: (context, focused, child) {
            final border = AvesBorder.border(
              context,
              width: AvesBorder.curvedBorderWidth(context) * (focused ? 3 : 1),
            );
            return borderRadius != null
                ? BlurredRRect(
                    enabled: blurred,
                    borderRadius: borderRadius,
                    child: Material(
                      type: MaterialType.button,
                      borderRadius: borderRadius,
                      color: overlayBackground,
                      child: AnimatedContainer(
                        foregroundDecoration: BoxDecoration(
                          border: border,
                          borderRadius: borderRadius,
                        ),
                        duration: const Duration(milliseconds: 200),
                        child: widget.child,
                      ),
                    ),
                  )
                : BlurredOval(
                    enabled: blurred,
                    child: Material(
                      type: MaterialType.circle,
                      color: overlayBackground,
                      child: AnimatedContainer(
                        foregroundDecoration: BoxDecoration(
                          border: border,
                          shape: BoxShape.circle,
                        ),
                        duration: const Duration(milliseconds: 200),
                        child: widget.child,
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  void _onFocusChanged() => _focusedNotifier.value = widget.focusNode?.hasFocus ?? false;
}

class ScalingOverlayTextButton extends StatelessWidget {
  final Animation<double> scale;
  final VoidCallback? onPressed;
  final Widget child;

  const ScalingOverlayTextButton({
    super.key,
    required this.scale,
    this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: scale,
      child: OverlayTextButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class OverlayTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const OverlayTextButton({
    super.key,
    this.onPressed,
    required this.child,
  });

  static const _borderRadius = 123.0;
  static final _minSize = MaterialStateProperty.all<Size>(const Size(kMinInteractiveDimension, kMinInteractiveDimension));

  @override
  Widget build(BuildContext context) {
    final blurred = settings.enableBlurEffect;
    final theme = Theme.of(context);
    return BlurredRRect.all(
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
        child: child,
      ),
    );
  }
}
