import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmptyContent extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Widget? bottom;
  final AlignmentGeometry alignment;
  final double fontSize;
  final bool safeBottom;

  const EmptyContent({
    super.key,
    this.icon,
    required this.text,
    this.bottom,
    this.alignment = const FractionalOffset(.5, .35),
    this.fontSize = 22,
    this.safeBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary.withOpacity(.5);
    return Padding(
      padding: safeBottom
          ? EdgeInsets.only(
              bottom: context.select<MediaQueryData, double>((mq) => mq.effectiveBottomPadding),
            )
          : EdgeInsets.zero,
      child: Align(
        alignment: alignment,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: color,
              ),
              const SizedBox(height: 16)
            ],
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.center,
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}
