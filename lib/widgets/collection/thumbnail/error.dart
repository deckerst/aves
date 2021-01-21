import 'package:aves/model/entry.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:flutter/material.dart';

class ErrorThumbnail extends StatelessWidget {
  final AvesEntry entry;
  final double extent;
  final String tooltip;

  const ErrorThumbnail({
    @required this.entry,
    @required this.extent,
    @required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.black,
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        child: Text(
          MimeUtils.displayType(entry.mimeType),
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: extent / 5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
