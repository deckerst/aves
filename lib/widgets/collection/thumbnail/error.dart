import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';

class ErrorThumbnail extends StatelessWidget {
  final double extent;
  final String tooltip;

  const ErrorThumbnail({@required this.extent, @required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        child: Icon(
          AIcons.error,
          size: extent / 2,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}
