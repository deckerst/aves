import 'dart:io';
import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorThumbnail extends StatefulWidget {
  final AvesEntry entry;
  final double extent;

  const ErrorThumbnail({
    super.key,
    required this.entry,
    required this.extent,
  });

  @override
  State<ErrorThumbnail> createState() => _ErrorThumbnailState();
}

class _ErrorThumbnailState extends State<ErrorThumbnail> {
  late Future<bool> _exists;

  AvesEntry get entry => widget.entry;

  double get extent => widget.extent;

  @override
  void initState() {
    super.initState();
    final path = entry.trashDetails?.path ?? entry.path;
    _exists = path != null ? File(path).exists() : SynchronousFuture(true);
  }

  @override
  Widget build(BuildContext context) {
    final color = Themes.backgroundTextColor(context);
    return FutureBuilder<bool>(
        future: _exists,
        builder: (context, snapshot) {
          Widget child;
          if (snapshot.connectionState != ConnectionState.done) {
            child = const SizedBox();
          } else {
            final exists = snapshot.data!;
            child = exists
                ? LayoutBuilder(builder: (context, constraints) {
                    final fontSize = min(extent, constraints.biggest.width) / 5;
                    return Text(
                      MimeUtils.displayType(entry.mimeType),
                      style: TextStyle(
                        color: color,
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.center,
                    );
                  })
                : Icon(
                    AIcons.broken,
                    size: extent / 2,
                    color: color,
                  );
          }
          return Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.background,
            width: extent,
            height: extent,
            child: child,
          );
        });
  }
}
