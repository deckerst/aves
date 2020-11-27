import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ThumbnailVectorImage extends StatelessWidget {
  final ImageEntry entry;
  final double extent;
  final Object heroTag;

  const ThumbnailVectorImage({
    Key key,
    @required this.entry,
    @required this.extent,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Container(
      // center `SvgPicture` inside `Container` with the thumbnail dimensions
      // so that `SvgPicture` doesn't get aligned by the `Stack` like the overlay icons
      width: extent,
      height: extent,
      child: Selector<Settings, int>(
        selector: (context, s) => s.svgBackground,
        builder: (context, svgBackground, child) {
          final colorFilter = ColorFilter.mode(Color(svgBackground), BlendMode.dstOver);
          return SvgPicture(
            UriPicture(
              uri: entry.uri,
              mimeType: entry.mimeType,
              colorFilter: colorFilter,
            ),
            width: extent,
            height: extent,
          );
        },
      ),
    );
    return heroTag == null
        ? child
        : Hero(
            tag: heroTag,
            child: child,
          );
  }
}
