import 'dart:math';

import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/entry_background.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/fx/checkered_decoration.dart';
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
    final pictureProvider = UriPicture(
      uri: entry.uri,
      mimeType: entry.mimeType,
    );

    final child = Center(
      child: Selector<Settings, EntryBackground>(
        selector: (context, s) => s.vectorBackground,
        builder: (context, background, child) {
          if (background == EntryBackground.transparent) {
            return SvgPicture(
              pictureProvider,
              width: extent,
              height: extent,
            );
          }

          final longestSide = max(entry.width, entry.height);
          final picture = SvgPicture(
            pictureProvider,
            width: extent * (entry.width / longestSide),
            height: extent * (entry.height / longestSide),
          );

          Decoration decoration;
          if (background == EntryBackground.checkered) {
            decoration = CheckeredDecoration(checkSize: extent / 8);
          } else if (background.isColor) {
            decoration = BoxDecoration(color: background.color);
          }
          return DecoratedBox(
            decoration: decoration,
            child: picture,
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
