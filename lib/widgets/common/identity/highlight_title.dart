import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/fx/highlight_decoration.dart';
import 'package:flutter/material.dart';

class HighlightTitle extends StatelessWidget {
  final String title;
  final Color color;
  final double fontSize;
  final bool enabled, selectable;

  const HighlightTitle(
    this.title, {
    this.color,
    this.fontSize = 18,
    this.enabled = true,
    this.selectable = false,
  }) : assert(title != null);

  static const disabledColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      shadows: [
        Shadow(
          color: Colors.black,
          offset: Offset(1, 1),
          blurRadius: 2,
        )
      ],
      fontSize: fontSize,
      fontFamily: 'Concourse Caps',
    );

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        decoration: HighlightDecoration(
          color: enabled ? color ?? stringToColor(title) : disabledColor,
        ),
        margin: EdgeInsets.symmetric(vertical: 4.0),
        child: selectable
            ? SelectableText(
                title,
                style: style,
                maxLines: 1,
              )
            : Text(
                title,
                style: style,
                softWrap: false,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
      ),
    );
  }
}
