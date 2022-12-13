import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final bool enabled, showCaption;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
    required this.text,
    required this.icon,
    this.enabled = true,
    this.showCaption = true,
    this.onPressed,
  }) : assert(onPressed == null || enabled);

  static const int maxLines = 2;
  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    final textStyle = _textStyle(context);
    final _enabled = onPressed != null || enabled;
    return SizedBox(
      width: _width(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: padding),
          OverlayButton(
            child: IconButton(
              icon: icon ?? const SizedBox(),
              onPressed: onPressed ?? (_enabled ? () {} : null),
            ),
          ),
          if (showCaption) ...[
            const SizedBox(height: padding),
            Text(
              text,
              style: _enabled ? textStyle : textStyle.copyWith(color: textStyle.color!.withOpacity(.2)),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines,
            ),
          ],
          const SizedBox(height: padding),
        ],
      ),
    );
  }

  static TextStyle _textStyle(BuildContext context) => Theme.of(context).textTheme.bodySmall!;

  static double _width(BuildContext context) => OverlayButton.getSize(context) + padding * 2;

  static Size getSize(BuildContext context, String text, {required bool showCaption}) {
    final width = _width(context);
    var height = width;
    if (showCaption) {
      final para = RenderParagraph(
        TextSpan(text: text, style: _textStyle(context)),
        textDirection: TextDirection.ltr,
        textScaleFactor: MediaQuery.textScaleFactorOf(context),
        maxLines: maxLines,
      )..layout(const BoxConstraints(), parentUsesSize: true);
      height += para.getMaxIntrinsicHeight(width) + padding;
    }
    return Size(width, height);
  }
}
