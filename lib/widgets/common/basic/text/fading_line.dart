import 'package:flutter/widgets.dart';

class const FadingLine(
  final String data, {
  super.key,
  final TextStyle? style,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      softWrap: false,
      overflow: .fade,
      maxLines: 1,
    );
  }
}
