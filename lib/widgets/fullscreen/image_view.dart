import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_picture_provider.dart';
import 'package:aves/widgets/fullscreen/video_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tuple/tuple.dart';
import 'package:video_player/video_player.dart';

class ImageView extends StatelessWidget {
  final ImageEntry entry;
  final Object heroTag;
  final ValueChanged<PhotoViewScaleState> onScaleChanged;
  final VoidCallback onTap;
  final List<Tuple2<String, VideoPlayerController>> videoControllers;

  const ImageView({
    this.entry,
    this.heroTag,
    this.onScaleChanged,
    this.onTap,
    this.videoControllers,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundDecoration = BoxDecoration(color: Colors.transparent);

    if (entry.isVideo) {
      final videoController = videoControllers.firstWhere((kv) => kv.item1 == entry.uri, orElse: () => null)?.item2;
      return PhotoView.customChild(
        child: videoController != null
            ? AvesVideo(
                entry: entry,
                controller: videoController,
              )
            : const SizedBox(),
        backgroundDecoration: backgroundDecoration,
        // no hero as most videos fullscreen image is different from its thumbnail
        scaleStateChangedCallback: onScaleChanged,
        minScale: PhotoViewComputedScale.contained,
        initialScale: PhotoViewComputedScale.contained,
        onTapUp: (tapContext, details, value) => onTap?.call(),
      );
    }

    final placeholderBuilder = (context) => const Center(
          child: SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
    final heroAttributes = heroTag != null
        ? PhotoViewHeroAttributes(
            tag: heroTag,
            transitionOnUserGestures: true,
          )
        : null;

    if (entry.isSvg) {
      return PhotoView.customChild(
        child: SvgPicture(
          UriPicture(
            uri: entry.uri,
            mimeType: entry.mimeType,
            colorFilter: Constants.svgColorFilter,
          ),
          placeholderBuilder: placeholderBuilder,
        ),
        backgroundDecoration: backgroundDecoration,
        heroAttributes: heroAttributes,
        scaleStateChangedCallback: onScaleChanged,
        minScale: PhotoViewComputedScale.contained,
        initialScale: PhotoViewComputedScale.contained,
        onTapUp: (tapContext, details, value) => onTap?.call(),
      );
    }

    return PhotoView(
      // key includes size and orientation to refresh when the image is rotated
      key: ValueKey('${entry.orientationDegrees}_${entry.width}_${entry.height}_${entry.path}'),
      imageProvider: UriImage(uri: entry.uri, mimeType: entry.mimeType),
      loadingBuilder: (context, event) => placeholderBuilder(context),
      backgroundDecoration: backgroundDecoration,
      heroAttributes: heroAttributes,
      scaleStateChangedCallback: onScaleChanged,
      minScale: PhotoViewComputedScale.contained,
      initialScale: PhotoViewComputedScale.contained,
      onTapUp: (tapContext, details, value) => onTap?.call(),
      filterQuality: FilterQuality.low,
    );
  }
}
