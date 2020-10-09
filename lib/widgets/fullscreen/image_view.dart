import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_picture_provider.dart';
import 'package:aves/widgets/fullscreen/video_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tuple/tuple.dart';

class ImageView extends StatelessWidget {
  final ImageEntry entry;
  final Object heroTag;
  final ValueChanged<PhotoViewScaleState> onScaleChanged;
  final VoidCallback onTap;
  final List<Tuple2<String, IjkMediaController>> videoControllers;

  const ImageView({
    Key key,
    this.entry,
    this.heroTag,
    this.onScaleChanged,
    this.onTap,
    this.videoControllers,
  }) : super(key: key);

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
            : SizedBox(),
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

    final fastThumbnailProvider = ThumbnailProvider(entry: entry);
    // this loading builder shows a transition image until the final image is ready
    // if the image is already in the cache it will show the final image, otherwise the thumbnail
    // in any case, we should use `Center` + `AspectRatio` + `Fill` so that the transition image
    // appears as the final image with `PhotoViewComputedScale.contained` for `initialScale`
    Widget loadingBuilder(BuildContext context, ImageProvider imageProvider) {
      return Center(
        child: AspectRatio(
          // enforce original aspect ratio, as some thumbnails aspect ratios slightly differ
          aspectRatio: entry.displayAspectRatio,
          child: Image(
            image: imageProvider,
            fit: BoxFit.fill,
          ),
        ),
      );
    }

    Widget child;
    if (entry.isSvg) {
      final colorFilter = ColorFilter.mode(Color(settings.svgBackground), BlendMode.dstOver);
      child = PhotoView.customChild(
        child: SvgPicture(
          UriPicture(
            uri: entry.uri,
            mimeType: entry.mimeType,
          ),
          placeholderBuilder: (context) => loadingBuilder(context, fastThumbnailProvider),
          colorFilter: colorFilter,
        ),
        backgroundDecoration: backgroundDecoration,
        scaleStateChangedCallback: onScaleChanged,
        minScale: PhotoViewComputedScale.contained,
        initialScale: PhotoViewComputedScale.contained,
        onTapUp: (tapContext, details, value) => onTap?.call(),
      );
    } else {
      final uriImage = UriImage(
        uri: entry.uri,
        mimeType: entry.mimeType,
        rotationDegrees: entry.rotationDegrees,
        expectedContentLength: entry.sizeBytes,
      );
      child = PhotoView(
        // key includes size and orientation to refresh when the image is rotated
        key: ValueKey('${entry.rotationDegrees}_${entry.width}_${entry.height}_${entry.path}'),
        imageProvider: uriImage,
        // when the full image is ready, we use it in the `loadingBuilder`
        // we still provide a `loadingBuilder` in that case to avoid a black frame after hero animation
        loadingBuilder: (context, event) => loadingBuilder(
          context,
          imageCache.statusForKey(uriImage).keepAlive ? uriImage : fastThumbnailProvider,
        ),
        loadFailedChild: EmptyContent(
          icon: AIcons.error,
          text: 'Oops!',
          alignment: Alignment.center,
        ),
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
