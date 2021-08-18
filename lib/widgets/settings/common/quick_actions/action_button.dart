import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final bool enabled, showCaption;

  const ActionButton({
    Key? key,
    required this.text,
    required this.icon,
    this.enabled = true,
    this.showCaption = true,
  }) : super(key: key);

  static const padding = 8.0;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.caption;
    return SizedBox(
      width: OverlayButton.getSize(context) + padding * 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: padding),
          OverlayButton(
            child: IconButton(
              icon: icon ?? const SizedBox(),
              onPressed: enabled ? () {} : null,
            ),
          ),
          if (showCaption) ...[
            const SizedBox(height: padding),
            Text(
              text,
              style: enabled ? textStyle : textStyle!.copyWith(color: textStyle.color!.withOpacity(.2)),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
          const SizedBox(height: padding),
        ],
      ),
    );
  }
}
