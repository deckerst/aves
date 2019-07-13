import 'package:aves/thumbnail.dart';
import 'package:flutter/material.dart';

class ImageFullscreenPage extends StatelessWidget {
  final int id;

  ImageFullscreenPage({this.id});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Thumbnail(
      id: id,
      extent: width,
    );
  }
}
