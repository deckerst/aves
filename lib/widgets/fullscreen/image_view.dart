import 'dart:async';
import 'dart:math';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/entry_background.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/fx/checkered_decoration.dart';
import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/magnifier.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:aves/widgets/fullscreen/tiled_view.dart';
import 'package:aves/widgets/fullscreen/video_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuple/tuple.dart';

class ImageView extends StatefulWidget {
  final ImageEntry entry;
  final Object heroTag;
  final MagnifierTapCallback onTap;
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
  final MagnifierController _magnifierController = MagnifierController();
  final ValueNotifier<ViewState> _viewStateNotifier = ValueNotifier(ViewState.zero);
  final List<StreamSubscription> _subscriptions = [];

  static const initialScale = ScaleLevel(ref: ScaleReference.contained);
  static const minScale = ScaleLevel(ref: ScaleReference.contained);
  static const maxScale = ScaleLevel(factor: 2.0);

  ImageEntry get entry => widget.entry;

  MagnifierTapCallback get onTap => widget.onTap;

  static const decorationCheckSize = 20.0;

  @override
  void initState() {
    super.initState();
    _subscriptions.add(_magnifierController.stateStream.listen(_onViewStateChanged));
    _subscriptions.add(_magnifierController.scaleBoundariesStream.listen(_onViewScaleBoundariesChanged));
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
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
      child = _buildRasterView();
    }
    child ??= ErrorChild(onTap: () => onTap?.call(null));

    // no hero for videos, as a typical video first frame is different from its thumbnail
    return widget.heroTag != null && !entry.isVideo
        ? Hero(
            tag: widget.heroTag,
            transitionOnUserGestures: true,
            child: child,
          )
        : child;
  }

  ImageProvider get fastThumbnailProvider => ThumbnailProvider(ThumbnailProviderKey.fromEntry(entry));

  // this loading builder shows a transition image until the final image is ready
  // if the image is already in the cache it will show the final image, otherwise the thumbnail
  // in any case, we should use `Center` + `AspectRatio` + `BoxFit.fill` so that the transition image
  // is laid the same way as the final image when `contained`
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

  Widget _buildRasterView() {
    return Magnifier(
      // key includes size and orientation to refresh when the image is rotated
      key: ValueKey('${entry.rotationDegrees}_${entry.isFlipped}_${entry.width}_${entry.height}_${entry.path}'),
      child: TiledImageView(
        entry: entry,
        viewStateNotifier: _viewStateNotifier,
        baseChild: _loadingBuilder(context, fastThumbnailProvider),
        errorBuilder: (context, error, stackTrace) => ErrorChild(onTap: () => onTap?.call(null)),
      ),
      childSize: entry.displaySize,
      controller: _magnifierController,
      maxScale: maxScale,
      minScale: minScale,
      initialScale: initialScale,
      onTap: (c, d, s, childPosition) => onTap?.call(childPosition),
      applyScale: false,
    );
  }

  Widget _buildSvgView() {
    final background = settings.vectorBackground;
    final colorFilter = background.isColor ? ColorFilter.mode(background.color, BlendMode.dstOver) : null;

    Widget child = Magnifier(
      child: SvgPicture(
        UriPicture(
          uri: entry.uri,
          mimeType: entry.mimeType,
          colorFilter: colorFilter,
        ),
      ),
      childSize: entry.displaySize,
      controller: _magnifierController,
      minScale: minScale,
      initialScale: initialScale,
      scaleStateCycle: _vectorScaleStateCycle,
      onTap: (c, d, s, childPosition) => onTap?.call(childPosition),
    );

    if (background == EntryBackground.checkered) {
      child = ValueListenableBuilder<ViewState>(
        valueListenable: _viewStateNotifier,
        builder: (context, viewState, child) {
          final viewportSize = viewState.viewportSize;
          if (viewportSize == null) return child;

          final side = viewportSize.shortestSide;
          final checkSize = side / ((side / decorationCheckSize).round());

          final viewSize = entry.displaySize * viewState.scale;
          final decorationSize = Size(min(viewSize.width, viewportSize.width), min(viewSize.height, viewportSize.height));
          final offset = Offset(decorationSize.width - viewportSize.width, decorationSize.height - viewportSize.height) / 2;

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                width: decorationSize.width,
                height: decorationSize.height,
                child: DecoratedBox(
                  decoration: CheckeredDecoration(
                    checkSize: checkSize,
                    offset: offset,
                  ),
                ),
              ),
              child,
            ],
          );
        },
        child: child,
      );
    }
    return child;
  }

  Widget _buildVideoView() {
    final videoController = widget.videoControllers.firstWhere((kv) => kv.item1 == entry.uri, orElse: () => null)?.item2;
    return Magnifier(
      child: videoController != null
          ? AvesVideo(
              entry: entry,
              controller: videoController,
            )
          : SizedBox(),
      childSize: entry.displaySize,
      controller: _magnifierController,
      maxScale: maxScale,
      minScale: minScale,
      initialScale: initialScale,
      onTap: (c, d, s, childPosition) => onTap?.call(childPosition),
    );
  }

  void _onViewStateChanged(MagnifierState v) {
    final current = _viewStateNotifier.value;
    final viewState = ViewState(v.position, v.scale, current.viewportSize);
    _viewStateNotifier.value = viewState;
    ViewStateNotification(entry.uri, viewState).dispatch(context);
  }

  void _onViewScaleBoundariesChanged(ScaleBoundaries v) {
    final current = _viewStateNotifier.value;
    final viewState = ViewState(current.position, current.scale, v.viewportSize);
    _viewStateNotifier.value = viewState;
    ViewStateNotification(entry.uri, viewState).dispatch(context);
  }

  static ScaleState _vectorScaleStateCycle(ScaleState actual) {
    switch (actual) {
      case ScaleState.initial:
        return ScaleState.covering;
      default:
        return ScaleState.initial;
    }
  }
}

class ViewState {
  final Offset position;
  final double scale;
  final Size viewportSize;

  static const ViewState zero = ViewState(Offset.zero, 0, null);

  const ViewState(this.position, this.scale, this.viewportSize);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{position=$position, scale=$scale, viewportSize=$viewportSize}';
}

class ViewStateNotification extends Notification {
  final String uri;
  final ViewState viewState;

  const ViewStateNotification(this.uri, this.viewState);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, viewState=$viewState}';
}

class ErrorChild extends StatelessWidget {
  final VoidCallback onTap;

  const ErrorChild({@required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
  }
}

typedef MagnifierTapCallback = void Function(Offset childPosition);
