import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/fx/highlight_decoration.dart';
import 'package:flutter/material.dart';

class HighlightTitle extends StatelessWidget {
  final String name;
  final Color color;
  final double fontSize;
  final bool enabled;

  const HighlightTitle(
    this.name, {
    this.color,
    this.fontSize = 20,
    this.enabled = true,
  }) : assert(name != null);

  static const disabledColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        decoration: HighlightDecoration(
          color: enabled ? color ?? stringToColor(name) : disabledColor,
        ),
        margin: EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          name,
          style: TextStyle(
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(1, 1),
                blurRadius: 2,
              )
            ],
            fontSize: fontSize,
            fontFamily: 'Concourse Caps',
          ),
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      ),
    );
  }
}
