import 'dart:math';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/enums/entry_background.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/fx/checkered_decoration.dart';
import 'package:aves/widgets/common/fx/transition_image.dart';
import 'package:aves/widgets/common/grid/sections/mosaic/section_layout_builder.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/thumbnail/error.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThumbnailImage extends StatefulWidget {
  final AvesEntry entry;
  final double extent, devicePixelRatio;
  final bool isMosaic, progressive;
  final BoxFit? fit;
  final bool showLoadingBackground;
  final ValueNotifier<bool>? cancellableNotifier;
  final Object? heroTag;
  final HeroPlaceholderBuilder? heroPlaceholderBuilder;

  const ThumbnailImage({
    super.key,
    required this.entry,
    required this.extent,
    required this.devicePixelRatio,
    this.progressive = true,
    this.isMosaic = false,
    this.fit,
    this.showLoadingBackground = true,
    this.cancellableNotifier,
    this.heroTag,
    this.heroPlaceholderBuilder,
  });

  @override
  State<ThumbnailImage> createState() => _ThumbnailImageState();

  static Color computeLoadingBackgroundColor(int hashCode, Brightness brightness) {
    var rgb = 0x30 + hashCode % 0x20;
    if (brightness == Brightness.light) {
      rgb = 0xFF - rgb;
    }
    return Color.fromARGB(0xFF, rgb, rgb, rgb);
  }
}

class _ThumbnailImageState extends State<ThumbnailImage> {
  final _providers = <_ConditionalImageProvider>[];
  _ProviderStream? _currentProviderStream;
  ImageInfo? _lastImageInfo;
  Object? _lastException;
  late final ImageStreamListener _streamListener;

  AvesEntry get entry => widget.entry;

  double get extent => widget.extent;

  bool get isMosaic => widget.isMosaic;

  @override
  void initState() {
    super.initState();
    _streamListener = ImageStreamListener(_onImageLoad, onError: _onError);
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
    super.dispose();
  }

  void _registerWidget(ThumbnailImage widget) {
    // TODO TLAD [leak] `widget.entry.visualChangeNotifier`
    widget.entry.visualChangeNotifier.addListener(_onVisualChanged);
    _initProvider();
  }

  void _unregisterWidget(ThumbnailImage widget) {
    widget.entry.visualChangeNotifier.removeListener(_onVisualChanged);
    _pauseProvider();
    _currentProviderStream?.stopListening();
    _currentProviderStream = null;
    _replaceImage(null);
  }

  void _initProvider() {
    if (!entry.isDecodingSupported) return;

    _lastException = null;
    _providers.clear();

    final highQuality = entry.getThumbnail(extent: extent);
    ThumbnailProvider? lowQuality;
    if (widget.progressive && !entry.isSvg) {
      if (entry.isVideo) {
        // previously fetched thumbnail
        final cached = entry.bestCachedThumbnail;
        final lowQualityExtent = cached.key.extent;
        if (lowQualityExtent > 0 && lowQualityExtent != extent) {
          lowQuality = cached;
        }
      } else {
        // default platform thumbnail
        lowQuality = entry.getThumbnail();
      }
    }
    _providers.addAll([
      if (lowQuality != null)
        _ConditionalImageProvider(
          lowQuality,
        ),
      _ConditionalImageProvider(
        highQuality,
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
    if (!mounted) return;
    setState(() => _lastException = exception);
  }

  bool _needSizedProvider(ImageInfo? currentImageInfo) {
    if (currentImageInfo == null) return true;
    final currentImage = currentImageInfo.image;
    final sizedThreshold = extent * widget.devicePixelRatio;
    return sizedThreshold > min(currentImage.width, currentImage.height);
  }

  void _pauseProvider() async {
    if (widget.cancellableNotifier?.value ?? false) {
      final key = await _currentProviderStream?.provider.provider.obtainKey(ImageConfiguration.empty);
      if (key is ThumbnailProviderKey) {
        mediaFetchService.cancelThumbnail(key);
      }
    }
  }

  Color? _loadingBackgroundColor;

  Color loadingBackgroundColor(BuildContext context) {
    _loadingBackgroundColor ??= ThumbnailImage.computeLoadingBackgroundColor(entry.uri.hashCode, Theme.of(context).brightness);
    return _loadingBackgroundColor!;
  }

  @override
  Widget build(BuildContext context) {
    final animate = context.select<Settings, bool>((v) => v.animate);
    if (!entry.isDecodingSupported || _lastException != null) {
      return _buildError(context, animate);
    }

    // use `RawImage` instead of `Image`, using `ImageInfo` to check dimensions
    // and have more control when chaining image providers

    final thumbnailHeight = extent;
    final double thumbnailWidth;
    if (isMosaic) {
      thumbnailWidth = thumbnailHeight *
          entry.displayAspectRatio.clamp(
            MosaicSectionLayoutBuilder.minThumbnailAspectRatio,
            MosaicSectionLayoutBuilder.maxThumbnailAspectRatio,
          );
    } else {
      thumbnailWidth = extent;
    }
    final canHaveAlpha = entry.canHaveAlpha;

    final fit = widget.fit ?? (entry.isSvg ? BoxFit.contain : BoxFit.cover);
    final imageInfo = _lastImageInfo;
    Widget image = imageInfo == null
        ? Container(
            color: widget.showLoadingBackground ? loadingBackgroundColor(context) : Colors.transparent,
            width: thumbnailWidth,
            height: thumbnailHeight,
          )
        : Selector<Settings, EntryBackground>(
            selector: (context, s) => s.imageBackground,
            builder: (context, background, child) {
              // avoid background color filter or layer when the entry cannot be transparent
              final backgroundColor = canHaveAlpha && background.isColor ? background.color : null;

              if (canHaveAlpha && background == EntryBackground.checkered) {
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
                width: thumbnailWidth,
                height: thumbnailHeight,
                scale: imageInfo.scale,
                color: backgroundColor,
                colorBlendMode: BlendMode.dstOver,
                fit: fit,
              );
            },
          );

    final heroTag = widget.heroTag;
    if (animate && heroTag != null) {
      final background = settings.imageBackground;
      final backgroundColor = background.isColor ? background.color : null;
      image = Hero(
        tag: heroTag,
        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
          // as of Flutter v3.27.0-0.1.pre, the flight `animation` is incorrect when diverting a pop:
          // - diverting a push (t = 0 -> 1) with a pop (t = 1 -> 0) works as expected (t = 0 -> [0,1] -> 0)
          // - diverting a pop (t = 1 -> 0) with a push (t = 0 -> 1) finishes the pop (t = 1 -> [0,1] -> 0) instead of diverting (t = 1 -> [0,1] -> 1)
          Widget child = TransitionImage(
            image: entry.bestCachedThumbnail,
            animation: animation,
            thumbnailFit: BoxFit.cover,
            viewerFit: BoxFit.contain,
            background: backgroundColor,
          );
          if (!settings.viewerUseCutout) {
            child = SafeCutoutArea(
              animation: animation,
              child: child,
            );
          }
          return child;
        },
        placeholderBuilder: widget.heroPlaceholderBuilder,
        transitionOnUserGestures: true,
        child: image,
      );
    }

    return image;
  }

  Widget _buildError(BuildContext context, bool animate) {
    Widget child = ErrorThumbnail(
      entry: entry,
      extent: extent,
    );

    final heroTag = widget.heroTag;
    if (animate && heroTag != null) {
      child = Hero(
        tag: heroTag,
        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
          return MediaQueryDataProvider(
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(toHeroContext).style,
              child: toHeroContext.widget,
            ),
          );
        },
        transitionOnUserGestures: true,
        child: child,
      );
    }

    return child;
  }

  // when the entry image itself changed (e.g. after rotation)
  void _onVisualChanged() async {
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
