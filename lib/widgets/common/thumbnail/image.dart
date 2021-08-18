import 'dart:math';
import 'dart:ui';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/model/settings/entry_background.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/checkered_decoration.dart';
import 'package:aves/widgets/common/fx/transition_image.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/thumbnail/error.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailImage extends StatefulWidget {
  final AvesEntry entry;
  final double extent;
  final bool progressive;
  final BoxFit? fit;
  final bool showLoadingBackground;
  final ValueNotifier<bool>? cancellableNotifier;
  final Object? heroTag;

  const ThumbnailImage({
    Key? key,
    required this.entry,
    required this.extent,
    this.progressive = true,
    this.fit,
    this.showLoadingBackground = true,
    this.cancellableNotifier,
    this.heroTag,
  }) : super(key: key);

  @override
  _ThumbnailImageState createState() => _ThumbnailImageState();
}

class _ThumbnailImageState extends State<ThumbnailImage> {
  final _providers = <_ConditionalImageProvider>[];
  _ProviderStream? _currentProviderStream;
  ImageInfo? _lastImageInfo;
  Object? _lastException;
  late final ImageStreamListener _streamListener;
  late DisposableBuildContext<State<ThumbnailImage>> _scrollAwareContext;

  AvesEntry get entry => widget.entry;

  double get extent => widget.extent;

  @override
  void initState() {
    super.initState();
    _streamListener = ImageStreamListener(_onImageLoad, onError: _onError);
    _scrollAwareContext = DisposableBuildContext<State<ThumbnailImage>>(this);
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ThumbnailImage oldWidget) {
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

  void _registerWidget(ThumbnailImage widget) {
    widget.entry.imageChangeNotifier.addListener(_onImageChanged);
    _initProvider();
  }

  void _unregisterWidget(ThumbnailImage widget) {
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
      if (widget.progressive && !entry.isSvg)
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

  Color? _loadingBackgroundColor;

  Color get loadingBackgroundColor {
    if (_loadingBackgroundColor == null) {
      final rgb = 0x30 + entry.uri.hashCode % 0x20;
      _loadingBackgroundColor = Color.fromARGB(0xFF, rgb, rgb, rgb);
    }
    return _loadingBackgroundColor!;
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

    final fit = widget.fit ?? (entry.isSvg ? BoxFit.contain : BoxFit.cover);
    final imageInfo = _lastImageInfo;
    final image = imageInfo == null
        ? Container(
            color: widget.showLoadingBackground ? loadingBackgroundColor : Colors.transparent,
            width: extent,
            height: extent,
          )
        : Selector<Settings, EntryBackground>(
            selector: (context, s) => s.imageBackground,
            builder: (context, background, child) {
              final backgroundColor = background.isColor ? background.color : null;

              if (background == EntryBackground.checkered) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final availableSize = constraints.biggest;
                    final fitSize = applyBoxFit(fit, entry.displaySize, availableSize).destination;
                    final offset = (fitSize / 2 - availableSize / 2) as Offset;
                    final child = CustomPaint(
                      painter: CheckeredPainter(checkSize: extent / 8, offset: offset),
                      child: RawImage(
                        image: imageInfo.image,
                        debugImageLabel: imageInfo.debugLabel,
                        width: fitSize.width,
                        height: fitSize.height,
                        scale: imageInfo.scale,
                        fit: BoxFit.cover,
                      ),
                    );
                    // the thumbnail is centered for correct decoration sizing
                    // when constraints are tight during hero animation
                    return constraints.isTight ? Center(child: child) : child;
                  },
                );
              }

              return RawImage(
                image: imageInfo.image,
                debugImageLabel: imageInfo.debugLabel,
                width: extent,
                height: extent,
                scale: imageInfo.scale,
                color: backgroundColor,
                colorBlendMode: BlendMode.dstOver,
                fit: fit,
              );
            });

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

  Widget _buildError(BuildContext context, Object error, StackTrace? stackTrace) {
    final child = ErrorThumbnail(
      entry: entry,
      extent: extent,
      tooltip: error.toString(),
    );
    return widget.heroTag != null
        ? Hero(
            tag: widget.heroTag!,
            flightShuttleBuilder: (flight, animation, direction, fromHero, toHero) {
              return MediaQueryDataProvider(
                child: DefaultTextStyle(
                  style: DefaultTextStyle.of(toHero).style,
                  child: toHero.widget,
                ),
              );
            },
            transitionOnUserGestures: true,
            child: child,
          )
        : child;
  }

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
