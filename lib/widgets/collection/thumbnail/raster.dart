import 'dart:math';
import 'dart:ui';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/services/services.dart';
import 'package:aves/widgets/collection/thumbnail/error.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/transition_image.dart';
import 'package:flutter/material.dart';

class RasterImageThumbnail extends StatefulWidget {
  final AvesEntry entry;
  final double extent;
  final BoxFit fit;
  final bool showLoadingBackground;
  final ValueNotifier<bool>? cancellableNotifier;
  final Object? heroTag;

  const RasterImageThumbnail({
    Key? key,
    required this.entry,
    required this.extent,
    this.fit = BoxFit.cover,
    this.showLoadingBackground = true,
    this.cancellableNotifier,
    this.heroTag,
  }) : super(key: key);

  @override
  _RasterImageThumbnailState createState() => _RasterImageThumbnailState();
}

class _RasterImageThumbnailState extends State<RasterImageThumbnail> {
  final _providers = <_ConditionalImageProvider>[];
  _ProviderStream? _currentProviderStream;
  ImageInfo? _lastImageInfo;
  Object? _lastException;
  late final ImageStreamListener _streamListener;
  late DisposableBuildContext<State<RasterImageThumbnail>> _scrollAwareContext;

  AvesEntry get entry => widget.entry;

  double get extent => widget.extent;

  @override
  void initState() {
    super.initState();
    _streamListener = ImageStreamListener(_onImageLoad, onError: _onError);
    _scrollAwareContext = DisposableBuildContext<State<RasterImageThumbnail>>(this);
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
    _scrollAwareContext.dispose();
    super.dispose();
  }

  void _registerWidget(RasterImageThumbnail widget) {
    widget.entry.imageChangeNotifier.addListener(_onImageChanged);
    _initProvider();
  }

  void _unregisterWidget(RasterImageThumbnail widget) {
    widget.entry.imageChangeNotifier.removeListener(_onImageChanged);
    _pauseProvider();
    _currentProviderStream?.stopListening();
    _currentProviderStream = null;
    _replaceImage(null);
  }

  void _initProvider() {
    if (!entry.canDecode) return;

    _lastException = null;
    _providers.clear();
    _providers.addAll([
      _ConditionalImageProvider(
        ScrollAwareImageProvider(
          context: _scrollAwareContext,
          imageProvider: entry.getThumbnail(),
        ),
      ),
      _ConditionalImageProvider(
        ScrollAwareImageProvider(
          context: _scrollAwareContext,
          imageProvider: entry.getThumbnail(extent: extent),
        ),
        _needSizedProvider,
      ),
    ]);
    _loadNextProvider();
  }

  void _loadNextProvider([ImageInfo? imageInfo]) {
    final nextIndex = _currentProviderStream == null ? 0 : (_providers.indexOf(_currentProviderStream!.provider) + 1);
    if (nextIndex < _providers.length) {
      final provider = _providers[nextIndex];
      if (provider.predicate?.call(imageInfo) ?? true) {
        _currentProviderStream?.stopListening();
        _currentProviderStream = _ProviderStream(provider, _streamListener);
        _currentProviderStream!.startListening();
      }
    }
  }

  void _onImageLoad(ImageInfo imageInfo, bool synchronousCall) {
    _replaceImage(imageInfo);
    _loadNextProvider(imageInfo);
  }

  void _replaceImage(ImageInfo? imageInfo) {
    _lastImageInfo?.dispose();
    _lastImageInfo = imageInfo;
    if (imageInfo != null) {
      setState(() {});
    }
  }

  void _onError(Object exception, StackTrace? stackTrace) {
    if (mounted) {
      setState(() => _lastException = exception);
    }
  }

  bool _needSizedProvider(ImageInfo? currentImageInfo) {
    if (currentImageInfo == null) return true;
    final currentImage = currentImageInfo.image;
    // directly uses `devicePixelRatio` as it never changes, to avoid visiting ancestors via `MediaQuery`
    final sizedThreshold = extent * window.devicePixelRatio;
    return sizedThreshold > min(currentImage.width, currentImage.height);
  }

  void _pauseProvider() async {
    if (widget.cancellableNotifier?.value ?? false) {
      final key = await _currentProviderStream?.provider.provider.obtainKey(ImageConfiguration.empty);
      if (key is ThumbnailProviderKey) {
        imageFileService.cancelThumbnail(key);
      }
    }
  }

  Color? _backgroundColor;

  Color get backgroundColor {
    if (_backgroundColor == null) {
      final rgb = 0x30 + entry.uri.hashCode % 0x20;
      _backgroundColor = Color.fromARGB(0xFF, rgb, rgb, rgb);
    }
    return _backgroundColor!;
  }

  @override
  Widget build(BuildContext context) {
    if (!entry.canDecode) {
      return _buildError(context, context.l10n.errorUnsupportedMimeType(entry.mimeType), null);
    } else if (_lastException != null) {
      return _buildError(context, _lastException.toString(), null);
    }

    // use `RawImage` instead of `Image`, using `ImageInfo` to check dimensions
    // and have more control when chaining image providers

    final imageInfo = _lastImageInfo;
    final image = imageInfo == null
        ? Container(
            color: widget.showLoadingBackground ? backgroundColor : Colors.transparent,
            width: extent,
            height: extent,
          )
        : RawImage(
            image: imageInfo.image,
            debugImageLabel: imageInfo.debugLabel,
            width: extent,
            height: extent,
            scale: imageInfo.scale,
            fit: widget.fit,
          );

    return widget.heroTag != null
        ? Hero(
            tag: widget.heroTag!,
            flightShuttleBuilder: (flight, animation, direction, fromHero, toHero) {
              return TransitionImage(
                image: entry.bestCachedThumbnail,
                animation: animation,
              );
            },
            transitionOnUserGestures: true,
            child: image,
          )
        : image;
  }

  Widget _buildError(BuildContext context, Object error, StackTrace? stackTrace) => ErrorThumbnail(
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

class _ConditionalImageProvider {
  final ImageProvider provider;
  final bool Function(ImageInfo?)? predicate;

  const _ConditionalImageProvider(this.provider, [this.predicate]);
}

class _ProviderStream {
  final _ConditionalImageProvider provider;
  final ImageStream _stream;
  final ImageStreamListener listener;

  _ProviderStream(this.provider, this.listener) : _stream = provider.provider.resolve(ImageConfiguration.empty);

  void startListening() => _stream.addListener(listener);

  void stopListening() => _stream.removeListener(listener);
}
