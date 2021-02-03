import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/thumbnail/error.dart';
import 'package:aves/widgets/common/fx/transition_image.dart';
import 'package:flutter/material.dart';

class RasterImageThumbnail extends StatefulWidget {
  final AvesEntry entry;
  final double extent;
  final ValueNotifier<bool> isScrollingNotifier;
  final Object heroTag;

  const RasterImageThumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    this.isScrollingNotifier,
    this.heroTag,
  }) : super(key: key);

  @override
  _RasterImageThumbnailState createState() => _RasterImageThumbnailState();
}

class _RasterImageThumbnailState extends State<RasterImageThumbnail> {
  ThumbnailProvider _fastThumbnailProvider, _sizedThumbnailProvider;

  AvesEntry get entry => widget.entry;

  double get extent => widget.extent;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant RasterImageThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != entry) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(RasterImageThumbnail widget) {
    widget.entry.imageChangeNotifier.addListener(_onImageChanged);
    _initProvider();
  }

  void _unregisterWidget(RasterImageThumbnail widget) {
    widget.entry.imageChangeNotifier.removeListener(_onImageChanged);
    _pauseProvider();
  }

  void _initProvider() {
    if (!entry.canDecode) return;

    _fastThumbnailProvider = entry.getThumbnail();
    _sizedThumbnailProvider = entry.getThumbnail(extent: extent);
  }

  void _pauseProvider() {
    final isScrolling = widget.isScrollingNotifier?.value ?? false;
    // when the user is scrolling faster than we can retrieve the thumbnails,
    // the retrieval task queue can pile up for thumbnails that got disposed
    // in this case we pause the image retrieval task to get it out of the queue
    if (isScrolling) {
      _fastThumbnailProvider?.pause();
      _sizedThumbnailProvider?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!entry.canDecode) {
      return _buildError(context, '${entry.mimeType} not supported', null);
    }

    final fastImage = Image(
      key: ValueKey('LQ'),
      image: _fastThumbnailProvider,
      errorBuilder: _buildError,
      width: extent,
      height: extent,
      fit: BoxFit.cover,
    );
    final image = _sizedThumbnailProvider == null
        ? fastImage
        : Image(
            key: ValueKey('HQ'),
            image: _sizedThumbnailProvider,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedSwitcher(
                duration: Durations.thumbnailTransition,
                transitionBuilder: (child, animation) {
                  var shouldFade = true;
                  if (child is Image && child.image == _fastThumbnailProvider) {
                    // directly show LQ thumbnail, only fade when switching from LQ to HQ
                    shouldFade = false;
                  }
                  return shouldFade
                      ? FadeTransition(
                          opacity: animation,
                          child: child,
                        )
                      : child;
                },
                child: frame == null ? fastImage : child,
              );
            },
            errorBuilder: _buildError,
            width: extent,
            height: extent,
            fit: BoxFit.cover,
          );
    return widget.heroTag != null
        ? Hero(
            tag: widget.heroTag,
            flightShuttleBuilder: (flight, animation, direction, fromHero, toHero) {
              return TransitionImage(
                image: entry.getBestThumbnail(extent),
                animation: animation,
              );
            },
            transitionOnUserGestures: true,
            child: image,
          )
        : image;
  }

  Widget _buildError(BuildContext context, Object error, StackTrace stackTrace) => ErrorThumbnail(
        entry: entry,
        extent: extent,
        tooltip: error.toString(),
      );

  // when the entry image itself changed (e.g. after rotation)
  void _onImageChanged() async {
    // rebuild to refresh the thumbnails
    _pauseProvider();
    _initProvider();
    setState(() {});
  }
}
