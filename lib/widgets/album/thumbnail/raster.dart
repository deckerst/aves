import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';
import 'package:aves/widgets/common/transition_image.dart';
import 'package:flutter/material.dart';

class ThumbnailRasterImage extends StatefulWidget {
  final ImageEntry entry;
  final double extent;
  final ValueNotifier<bool> isScrollingNotifier;
  final Object heroTag;

  const ThumbnailRasterImage({
    Key key,
    @required this.entry,
    @required this.extent,
    this.isScrollingNotifier,
    this.heroTag,
  }) : super(key: key);

  @override
  _ThumbnailRasterImageState createState() => _ThumbnailRasterImageState();
}

class _ThumbnailRasterImageState extends State<ThumbnailRasterImage> {
  ThumbnailProvider _fastThumbnailProvider, _sizedThumbnailProvider;

  ImageEntry get entry => widget.entry;

  double get extent => widget.extent;

  Object get heroTag => widget.heroTag;

  // we standardize the thumbnail loading dimension by taking the nearest larger power of 2
  // so that there are less variants of the thumbnails to load and cache
  // it increases the chance of cache hit when loading similarly sized columns (e.g. on orientation change)
  double get requestExtent => pow(2, (log(extent) / log(2)).ceil()).toDouble();

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  @override
  void didUpdateWidget(ThumbnailRasterImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != entry) {
      _pauseProvider();
      _initProvider();
    }
  }

  @override
  void dispose() {
    _pauseProvider();
    super.dispose();
  }

  void _initProvider() {
    _fastThumbnailProvider = ThumbnailProvider(entry: entry);
    if (!entry.isVideo) {
      _sizedThumbnailProvider = ThumbnailProvider(entry: entry, extent: requestExtent);
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
    final fastImage = Image(
      image: _fastThumbnailProvider,
      width: extent,
      height: extent,
      fit: BoxFit.cover,
    );
    final image = _sizedThumbnailProvider == null
        ? fastImage
        : Image(
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => child == fastImage
                    ? child
                    : FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                child: frame == null ? fastImage : child,
              );
            },
            image: _sizedThumbnailProvider,
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
              if (!entry.isVideo && !entry.isSvg) {
                final imageProvider = UriImage(
                  uri: entry.uri,
                  mimeType: entry.mimeType,
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
}
