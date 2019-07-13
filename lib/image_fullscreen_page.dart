import 'package:aves/thumbnail.dart';
import 'package:flutter/material.dart';

class ImageFullscreenPage extends StatelessWidget {
  final Map entry;

  ImageFullscreenPage({this.entry});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Thumbnail(
      entry: entry,
      extent: width,
    );
  }
}
