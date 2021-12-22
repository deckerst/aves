import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmptyContent extends StatelessWidget {
  final IconData? icon;
  final String text;
  final AlignmentGeometry alignment;
  final double fontSize;

  const EmptyContent({
    Key? key,
    this.icon,
    required this.text,
    this.alignment = const FractionalOffset(.5, .35),
    this.fontSize = 22,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const color = Colors.blueGrey;
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.select<MediaQueryData, double>((mq) => mq.effectiveBottomPadding),
      ),
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
          ],
        ),
      ),
    );
  }
}
