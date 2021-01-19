import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/entry_background.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/fx/checkered_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class VectorImageThumbnail extends StatelessWidget {
  final ImageEntry entry;
  final double extent;
  final Object heroTag;

  const VectorImageThumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Selector<Settings, EntryBackground>(
      selector: (context, s) => s.vectorBackground,
      builder: (context, background, child) {
        const fit = BoxFit.contain;
        if (background == EntryBackground.checkered) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final availableSize = constraints.biggest;
              final fitSize = applyBoxFit(fit, entry.displaySize, availableSize).destination;
              final offset = fitSize / 2 - availableSize / 2;
              final child = DecoratedBox(
                decoration: CheckeredDecoration(checkSize: extent / 8, offset: offset),
                child: SvgPicture(
                  UriPicture(
                    uri: entry.uri,
                    mimeType: entry.mimeType,
                  ),
                  width: fitSize.width,
                  height: fitSize.height,
                  fit: fit,
                ),
              );
              // the thumbnail is centered for correct decoration sizing
              // when constraints are tight during hero animation
              return constraints.isTight ? Center(child: child) : child;
            },
          );
        }

        final colorFilter = background.isColor ? ColorFilter.mode(background.color, BlendMode.dstOver) : null;
        return SvgPicture(
          UriPicture(
            uri: entry.uri,
            mimeType: entry.mimeType,
            colorFilter: colorFilter,
          ),
          width: extent,
          height: extent,
          fit: fit,
        );
      },
    );
    return heroTag == null
        ? child
        : Hero(
            tag: heroTag,
            child: child,
          );
  }
}
