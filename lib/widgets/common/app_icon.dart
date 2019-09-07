import 'dart:typed_data';

import 'package:aves/utils/android_app_service.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class AppIcon extends StatefulWidget {
  final String packageName;
  final double size;
  final double devicePixelRatio;

  const AppIcon({
    Key key,
    @required this.packageName,
    @required this.size,
    @required this.devicePixelRatio,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppIconState();
}

class AppIconState extends State<AppIcon> {
  Future<Uint8List> _byteLoader;

  @override
  void initState() {
    super.initState();
    final dim = (widget.size * widget.devicePixelRatio).round();
    _byteLoader = AndroidAppService.getAppIcon(widget.packageName, dim);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _byteLoader,
      builder: (futureContext, AsyncSnapshot<Uint8List> snapshot) {
        final bytes = (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) ? snapshot.data : kTransparentImage;
        return bytes.length > 0
            ? Image.memory(
                bytes,
                width: widget.size,
                height: widget.size,
              )
            : SizedBox.shrink();
      },
    );
  }
}
