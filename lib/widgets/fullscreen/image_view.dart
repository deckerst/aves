import 'dart:async';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/magnifier.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/magnifier/scale/scalestate_controller.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:aves/widgets/fullscreen/tiled_view.dart';
import 'package:aves/widgets/fullscreen/video_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
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
  final MagnifierScaleStateController _magnifierScaleStateController = MagnifierScaleStateController();
  final ValueNotifier<ViewState> _viewStateNotifier = ValueNotifier(ViewState.zero);
  StreamSubscription<MagnifierState> _subscription;
  Size _magnifierChildSize;

  static const initialScale = ScaleLevel(ref: ScaleReference.contained);
  static const minScale = ScaleLevel(ref: ScaleReference.contained);
  static const maxScale = ScaleLevel(factor: 2.0);

  ImageEntry get entry => widget.entry;

  MagnifierTapCallback get onTap => widget.onTap;

  @override
  void initState() {
    super.initState();
    _subscription = _magnifierController.outputStateStream.listen(_onViewChanged);
    _magnifierChildSize = entry.displaySize;
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
      child: Selector<MediaQueryData, Size>(
        selector: (context, mq) => mq.size,
        builder: (context, mqSize, child) {
          // When the scale state is cycled to be in its `initial` state (i.e. `contained`), and the device is rotated,
          // `Magnifier` keeps the scale state as `contained`, but the controller does not update or notify the new scale value.
          // We cannot monitor scale state changes as a workaround, because the scale state is updated before animating the scale,
          // so we keep receiving scale updates after the scale state update.
          // Instead we check the scale state here when the constraints change, so we can reset the obsolete scale value.
          if (_magnifierScaleStateController.scaleState.state == ScaleState.initial) {
            final value = MagnifierState(position: Offset.zero, scale: 0, source: ChangeSource.internal);
            WidgetsBinding.instance.addPostFrameCallback((_) => _onViewChanged(value));
          }
          return TiledImageView(
            entry: entry,
            viewportSize: mqSize,
            viewStateNotifier: _viewStateNotifier,
            baseChild: _loadingBuilder(context, fastThumbnailProvider),
            errorBuilder: (context, error, stackTrace) => ErrorChild(onTap: () => onTap?.call(null)),
          );
        },
      ),
      childSize: entry.displaySize,
      controller: _magnifierController,
      scaleStateController: _magnifierScaleStateController,
      maxScale: maxScale,
      minScale: minScale,
      initialScale: initialScale,
      onTap: (c, d, s, childPosition) => onTap?.call(childPosition),
      applyScale: false,
    );
  }

  Widget _buildSvgView() {
    final colorFilter = ColorFilter.mode(Color(settings.svgBackground), BlendMode.dstOver);
    return Magnifier(
      child: SvgPicture(
        UriPicture(
          uri: entry.uri,
          mimeType: entry.mimeType,
          colorFilter: colorFilter,
        ),
      ),
      controller: _magnifierController,
      minScale: minScale,
      initialScale: initialScale,
      onTap: (c, d, s, childPosition) => onTap?.call(childPosition),
    );
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

  void _onViewChanged(MagnifierState v) {
    final viewState = ViewState(v.position, v.scale, _magnifierChildSize);
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
  String toString() => '$runtimeType#${shortHash(this)}{position=$position, scale=$scale, size=$size}';
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
