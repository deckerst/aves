import 'dart:async';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_picture_provider.dart';
import 'package:aves/widgets/fullscreen/tiled_view.dart';
import 'package:aves/widgets/fullscreen/video_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ImageView extends StatefulWidget {
  final ImageEntry entry;
  final Object heroTag;
  final VoidCallback onTap;
  final List<Tuple2<String, IjkMediaController>> videoControllers;
  final VoidCallback onDisposed;

  const ImageView({
    Key key,
    @required this.entry,
    this.heroTag,
    @required this.onTap,
    @required this.videoControllers,
    this.onDisposed,
  }) : super(key: key);

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  final PhotoViewController _photoViewController = PhotoViewController();
  final ValueNotifier<ViewState> _viewStateNotifier = ValueNotifier<ViewState>(ViewState.zero);
  StreamSubscription<PhotoViewControllerValue> _subscription;

  static const backgroundDecoration = BoxDecoration(color: Colors.transparent);

  ImageEntry get entry => widget.entry;

  VoidCallback get onTap => widget.onTap;

  @override
  void initState() {
    super.initState();
    _subscription = _photoViewController.outputStateStream.listen(_onViewChanged);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _subscription = null;
    widget.onDisposed?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (entry.isVideo) {
      child = _buildVideoView();
    } else if (entry.isSvg) {
      child = _buildSvgView();
    } else if (entry.canDecode) {
      if (isLargeImage) {
        child = _buildTiledImageView();
      } else {
        child = _buildImageView();
      }
    } else {
      child = _buildError();
    }

    // if the hero tag is defined in the `loadingBuilder` and also set by the `heroAttributes`,
    // the route transition becomes visible if the final image is loaded before the hero animation is done.

    // if the hero tag wraps the whole `PhotoView` and the `loadingBuilder` is not provided,
    // there's a black frame between the hero animation and the final image, even when it's cached.

    // no hero for videos, as a typical video first frame is different from its thumbnail
    return widget.heroTag != null && !entry.isVideo
        ? Hero(
            tag: widget.heroTag,
            transitionOnUserGestures: true,
            child: child,
          )
        : child;
  }

  // the images loaded by `PhotoView` cannot have a width or height larger than 8192
  // so the reported offset and scale does not match expected values derived from the original dimensions
  // besides, large images should be tiled to be memory-friendly
  bool get isLargeImage => entry.width > 4096 || entry.height > 4096;

  ImageProvider get fastThumbnailProvider => ThumbnailProvider(ThumbnailProviderKey.fromEntry(entry));

  // this loading builder shows a transition image until the final image is ready
  // if the image is already in the cache it will show the final image, otherwise the thumbnail
  // in any case, we should use `Center` + `AspectRatio` + `BoxFit.fill` so that the transition image
  // appears as the final image with `PhotoViewComputedScale.contained` for `initialScale`
  Widget _loadingBuilder(BuildContext context, ImageProvider imageProvider) {
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

  Widget _buildImageView() {
    final uriImage = UriImage(
      uri: entry.uri,
      mimeType: entry.mimeType,
      rotationDegrees: entry.rotationDegrees,
      isFlipped: entry.isFlipped,
      expectedContentLength: entry.sizeBytes,
    );
    return PhotoView(
      // key includes size and orientation to refresh when the image is rotated
      key: ValueKey('${entry.rotationDegrees}_${entry.isFlipped}_${entry.width}_${entry.height}_${entry.path}'),
      imageProvider: uriImage,
      // when the full image is ready, we use it in the `loadingBuilder`
      // we still provide a `loadingBuilder` in that case to avoid a black frame after hero animation
      loadingBuilder: (context, event) => _loadingBuilder(
        context,
        imageCache.statusForKey(uriImage).keepAlive ? uriImage : fastThumbnailProvider,
      ),
      loadFailedChild: _buildError(),
      backgroundDecoration: backgroundDecoration,
      controller: _photoViewController,
      minScale: PhotoViewComputedScale.contained,
      initialScale: PhotoViewComputedScale.contained,
      onTapUp: (tapContext, details, value) => onTap?.call(),
      filterQuality: FilterQuality.low,
    );
  }

  Widget _buildTiledImageView() {
    return PhotoView.customChild(
      // key includes size and orientation to refresh when the image is rotated
      key: ValueKey('${entry.rotationDegrees}_${entry.isFlipped}_${entry.width}_${entry.height}_${entry.path}'),
      child: Selector<MediaQueryData, Size>(
        selector: (context, mq) => mq.size,
        builder: (context, mqSize, child) {
          return TiledImageView(
            entry: entry,
            viewportSize: mqSize,
            viewStateNotifier: _viewStateNotifier,
            baseChild: _loadingBuilder(context, fastThumbnailProvider),
            errorBuilder: (context, error, stackTrace) => _buildError(),
          );
        },
      ),
      childSize: entry.displaySize,
      backgroundDecoration: backgroundDecoration,
      controller: _photoViewController,
      minScale: PhotoViewComputedScale.contained,
      initialScale: PhotoViewComputedScale.contained,
      onTapUp: (tapContext, details, value) => onTap?.call(),
      filterQuality: FilterQuality.low,
    );
  }

  Widget _buildSvgView() {
    final colorFilter = ColorFilter.mode(Color(settings.svgBackground), BlendMode.dstOver);
    return PhotoView.customChild(
      child: SvgPicture(
        UriPicture(
          uri: entry.uri,
          mimeType: entry.mimeType,
        ),
        placeholderBuilder: (context) => _loadingBuilder(context, fastThumbnailProvider),
        colorFilter: colorFilter,
      ),
      backgroundDecoration: backgroundDecoration,
      controller: _photoViewController,
      minScale: PhotoViewComputedScale.contained,
      initialScale: PhotoViewComputedScale.contained,
      onTapUp: (tapContext, details, value) => onTap?.call(),
    );
  }

  Widget _buildVideoView() {
    final videoController = widget.videoControllers.firstWhere((kv) => kv.item1 == entry.uri, orElse: () => null)?.item2;
    return PhotoView.customChild(
      child: videoController != null
          ? AvesVideo(
              entry: entry,
              controller: videoController,
            )
          : SizedBox(),
      childSize: entry.displaySize,
      backgroundDecoration: backgroundDecoration,
      controller: _photoViewController,
      minScale: PhotoViewComputedScale.contained,
      initialScale: PhotoViewComputedScale.contained,
      onTapUp: (tapContext, details, value) => onTap?.call(),
    );
  }

  Widget _buildError() => GestureDetector(
        onTap: () => onTap?.call(),
        // use a `Container` with a dummy color to make it expand
        // so that we can also detect taps around the title `Text`
        child: Container(
          color: Colors.transparent,
          child: EmptyContent(
            icon: AIcons.error,
            text: 'Oops!',
            alignment: Alignment.center,
          ),
        ),
      );

  void _onViewChanged(PhotoViewControllerValue v) {
    final viewState = ViewState(v.position, v.scale);
    _viewStateNotifier.value = viewState;
    ViewStateNotification(entry.uri, viewState).dispatch(context);
  }
}

class ViewState {
  final Offset position;
  final double scale;

  static const ViewState zero = ViewState(Offset(0.0, 0.0), 0);

  const ViewState(this.position, this.scale);

  @override
  String toString() {
    return '$runtimeType#${shortHash(this)}{position=$position, scale=$scale}';
  }
}

class ViewStateNotification extends Notification {
  final String uri;
  final ViewState viewState;

  const ViewStateNotification(this.uri, this.viewState);

  @override
  String toString() {
    return '$runtimeType#${shortHash(this)}{uri=$uri, viewState=$viewState}';
  }
}
