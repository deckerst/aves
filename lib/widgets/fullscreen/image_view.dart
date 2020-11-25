import 'dart:async';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_image_provider.dart';
import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/empty.dart';
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
  final PhotoViewScaleStateController _photoViewScaleStateController = PhotoViewScaleStateController();
  final ValueNotifier<ViewState> _viewStateNotifier = ValueNotifier(ViewState.zero);
  StreamSubscription<PhotoViewControllerValue> _subscription;
  Size _photoViewChildSize;

  static const backgroundDecoration = BoxDecoration(color: Colors.transparent);
  static const maxScale = 2.0;

  ImageEntry get entry => widget.entry;

  VoidCallback get onTap => widget.onTap;

  @override
  void initState() {
    super.initState();
    _subscription = _photoViewController.outputStateStream.listen(_onViewChanged);
    if (entry.isVideo || (!entry.isSvg && entry.canDecode && useTile)) {
      _photoViewChildSize = entry.displaySize;
    }
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
      if (entry.width > 0 && entry.height > 0) {
        child = _buildVideoView();
      }
    } else if (entry.isSvg) {
      child = _buildSvgView();
    } else if (entry.canDecode) {
      if (useTile) {
        child = _buildTiledImageView();
      } else {
        child = _buildImageView();
      }
    }
    child ??= _buildError();

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
  bool get useTile => entry.canTile && (entry.width > 4096 || entry.height > 4096);

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
      imageSizedCallback: (size) {
        // do not directly update the `ViewState` notifier as this callback is called during build
        _photoViewChildSize = size;
      },
      controller: _photoViewController,
      maxScale: maxScale,
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
          // When the scale state is cycled to be in its `initial` state (i.e. `contained`), and the device is rotated,
          // `PhotoView` keeps the scale state as `contained`, but the controller does not update or notify the new scale value.
          // We cannot use `scaleStateChangedCallback` as a workaround, because the scale state is updated before animating the scale change,
          // so we keep receiving scale updates after the scale state update.
          // Instead we check the scale state here when the constraints change, so we can reset the obsolete scale value.
          if (_photoViewScaleStateController.scaleState == PhotoViewScaleState.initial) {
            final value = PhotoViewControllerValue(position: Offset.zero, scale: 0, rotation: 0, rotationFocusPoint: null);
            WidgetsBinding.instance.addPostFrameCallback((_) => _onViewChanged(value));
          }
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
      scaleStateController: _photoViewScaleStateController,
      maxScale: maxScale,
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
          colorFilter: colorFilter,
        ),
        placeholderBuilder: (context) => _loadingBuilder(context, fastThumbnailProvider),
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
      maxScale: maxScale,
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
    final viewState = ViewState(v.position, v.scale, _photoViewChildSize);
    _viewStateNotifier.value = viewState;
    ViewStateNotification(entry.uri, viewState).dispatch(context);
  }
}

class ViewState {
  final Offset position;
  final double scale;
  final Size size;

  static const ViewState zero = ViewState(Offset(0.0, 0.0), 0, null);

  const ViewState(this.position, this.scale, this.size);

  @override
  String toString() {
    return '$runtimeType#${shortHash(this)}{position=$position, scale=$scale, size=$size}';
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
