import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
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

    // no hero for videos, as a typical video first frame is different from its thumbnail

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
        scaleStateChangedCallback: onScaleChanged,
        minScale: PhotoViewComputedScale.contained,
        initialScale: PhotoViewComputedScale.contained,
        onTapUp: (tapContext, details, value) => onTap?.call(),
      );
    }

    // if the hero tag is defined in the `loadingBuilder` and also set by the `heroAttributes`,
    // the route transition becomes visible if the final is loaded before the hero animation is done.

    // if the hero tag wraps the whole `PhotoView` and the `loadingBuilder` is not provided,
    // there's a black frame between the hero animation and the final image, even when it's cached.

    final loadingBuilder = (context) => Center(
          child: AspectRatio(
            // enforce original aspect ratio, as some thumbnails aspect ratios slightly differ
            aspectRatio: entry.displayAspectRatio,
            child: Image(
              image: ThumbnailProvider(
                entry: entry,
                extent: Constants.thumbnailCacheExtent,
              ),
              fit: BoxFit.fill,
            ),
          ),
        );

    Widget child;
    if (entry.isSvg) {
      child = PhotoView.customChild(
        child: SvgPicture(
          UriPicture(
            uri: entry.uri,
            mimeType: entry.mimeType,
            colorFilter: Constants.svgColorFilter,
          ),
          placeholderBuilder: loadingBuilder,
        ),
        backgroundDecoration: backgroundDecoration,
        scaleStateChangedCallback: onScaleChanged,
        minScale: PhotoViewComputedScale.contained,
        initialScale: PhotoViewComputedScale.contained,
        onTapUp: (tapContext, details, value) => onTap?.call(),
      );
    } else {
      child = PhotoView(
        // key includes size and orientation to refresh when the image is rotated
        key: ValueKey('${entry.orientationDegrees}_${entry.width}_${entry.height}_${entry.path}'),
        imageProvider: UriImage(
          uri: entry.uri,
          mimeType: entry.mimeType,
        ),
        loadingBuilder: (context, event) => loadingBuilder(context),
        backgroundDecoration: backgroundDecoration,
        scaleStateChangedCallback: onScaleChanged,
        minScale: PhotoViewComputedScale.contained,
        initialScale: PhotoViewComputedScale.contained,
        onTapUp: (tapContext, details, value) => onTap?.call(),
        filterQuality: FilterQuality.low,
      );
    }

    return heroTag != null
        ? Hero(
            tag: heroTag,
            transitionOnUserGestures: true,
            child: child,
          )
        : child;
  }
}
