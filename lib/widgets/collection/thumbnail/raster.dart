import 'dart:math';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_image_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/thumbnail/error.dart';
import 'package:aves/widgets/common/fx/transition_image.dart';
import 'package:flutter/material.dart';

class ThumbnailRasterImage extends StatefulWidget {
  final ImageEntry entry;
  final double extent;
  final int page;
  final ValueNotifier<bool> isScrollingNotifier;
  final Object heroTag;

  const ThumbnailRasterImage({
    Key key,
    @required this.entry,
    @required this.extent,
    this.page = 0,
    this.isScrollingNotifier,
    this.heroTag,
  }) : super(key: key);

  @override
  _ThumbnailRasterImageState createState() => _ThumbnailRasterImageState();
}

class _ThumbnailRasterImageState extends State<ThumbnailRasterImage> {
  ThumbnailProvider _fastThumbnailProvider, _sizedThumbnailProvider;

  ImageEntry get entry => widget.entry;

  int get page => widget.page;

  double get extent => widget.extent;

  Object get heroTag => widget.heroTag;

  // we standardize the thumbnail loading dimension by taking the nearest larger power of 2
  // so that there are less variants of the thumbnails to load and cache
  // it increases the chance of cache hit when loading similarly sized columns (e.g. on orientation change)
  double get requestExtent => pow(2, (log(extent) / log(2)).ceil()).toDouble();

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ThumbnailRasterImage oldWidget) {
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

  void _registerWidget(ThumbnailRasterImage widget) {
    widget.entry.imageChangeNotifier.addListener(_onImageChanged);
    _initProvider();
  }

  void _unregisterWidget(ThumbnailRasterImage widget) {
    widget.entry.imageChangeNotifier.removeListener(_onImageChanged);
    _pauseProvider();
  }

  void _initProvider() {
    if (!entry.canDecode) return;

    _fastThumbnailProvider = ThumbnailProvider(
      ThumbnailProviderKey.fromEntry(entry, page: page),
    );
    if (!entry.isVideo) {
      _sizedThumbnailProvider = ThumbnailProvider(
        ThumbnailProviderKey.fromEntry(entry, page: page, extent: requestExtent),
      );
    }
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
    return heroTag == null
        ? image
        : Hero(
            tag: heroTag,
            flightShuttleBuilder: (flight, animation, direction, fromHero, toHero) {
              ImageProvider heroImageProvider = _fastThumbnailProvider;
              if (!entry.isVideo) {
                final imageProvider = UriImage(
                  uri: entry.uri,
                  mimeType: entry.mimeType,
                  page: page,
                  rotationDegrees: entry.rotationDegrees,
                  isFlipped: entry.isFlipped,
                  expectedContentLength: entry.sizeBytes,
                );
                if (imageCache.statusForKey(imageProvider).keepAlive) {
                  heroImageProvider = imageProvider;
                }
              }
              return TransitionImage(
                image: heroImageProvider,
                animation: animation,
              );
            },
            child: image,
          );
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
