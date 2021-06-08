import 'dart:io';

import 'package:aves/model/entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorThumbnail extends StatefulWidget {
  final AvesEntry entry;
  final double extent;
  final String tooltip;

  const ErrorThumbnail({
    required this.entry,
    required this.extent,
    required this.tooltip,
  });

  @override
  _ErrorThumbnailState createState() => _ErrorThumbnailState();
}

class _ErrorThumbnailState extends State<ErrorThumbnail> {
  late Future<bool> _exists;

  AvesEntry get entry => widget.entry;

  double get extent => widget.extent;

  @override
  void initState() {
    super.initState();
    _exists = entry.path != null ? File(entry.path!).exists() : SynchronousFuture(true);
  }

  @override
  Widget build(BuildContext context) {
    const color = Colors.blueGrey;
    return FutureBuilder<bool>(
        future: _exists,
        builder: (context, snapshot) {
          Widget child;
          if (snapshot.connectionState != ConnectionState.done) {
            child = const SizedBox();
          } else {
            final exists = snapshot.data!;
            child = Tooltip(
              message: exists ? widget.tooltip : context.l10n.viewerErrorDoesNotExist,
              preferBelow: false,
              child: exists
                  ? Text(
                      MimeUtils.displayType(entry.mimeType),
                      style: TextStyle(
                        color: color,
                        fontSize: extent / 5,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Icon(
                      AIcons.broken,
                      size: extent / 2,
                      color: color,
                    ),
            );
          }
          return Container(
            alignment: Alignment.center,
            color: Colors.black,
            width: extent,
            height: extent,
            child: child,
          );
        });
  }
}
