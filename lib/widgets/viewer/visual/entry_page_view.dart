import 'dart:async';

import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/settings/entry_background.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/magnifier.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:aves/widgets/viewer/visual/error.dart';
import 'package:aves/widgets/viewer/visual/raster.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:aves/widgets/viewer/visual/vector.dart';
import 'package:aves/widgets/viewer/visual/video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuple/tuple.dart';

class EntryPageView extends StatefulWidget {
  final ImageEntry entry;
  final MultiPageInfo multiPageInfo;
  final int page;
  final Object heroTag;
  final MagnifierTapCallback onTap;
  final List<Tuple2<String, IjkMediaController>> videoControllers;
  final VoidCallback onDisposed;

  static const decorationCheckSize = 20.0;
  static const initialScale = ScaleLevel(ref: ScaleReference.contained);
  static const minScale = ScaleLevel(ref: ScaleReference.contained);
  static const maxScale = ScaleLevel(factor: 2.0);

  const EntryPageView({
    Key key,
    @required this.entry,
    this.multiPageInfo,
    this.page = 0,
    this.heroTag,
    @required this.onTap,
    @required this.videoControllers,
    this.onDisposed,
  }) : super(key: key);

  @override
  _EntryPageViewState createState() => _EntryPageViewState();
}

class _EntryPageViewState extends State<EntryPageView> {
  final MagnifierController _magnifierController = MagnifierController();
  final ValueNotifier<ViewState> _viewStateNotifier = ValueNotifier(ViewState.zero);
  final List<StreamSubscription> _subscriptions = [];

  ImageEntry get entry => widget.entry;

  MultiPageInfo get multiPageInfo => widget.multiPageInfo;

  int get page => widget.page;

  MagnifierTapCallback get onTap => widget.onTap;

  Size get pageDisplaySize => entry.getDisplaySize(multiPageInfo: multiPageInfo, page: page);

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
    child ??= ErrorView(onTap: () => onTap?.call(null));

    // no hero for videos, as a typical video first frame is different from its thumbnail
    return widget.heroTag != null && !entry.isVideo
        ? Hero(
            tag: widget.heroTag,
            transitionOnUserGestures: true,
            child: child,
          )
        : child;
  }

  Widget _buildRasterView() {
    return Magnifier(
      // key includes size and orientation to refresh when the image is rotated
      key: ValueKey('${page}_${entry.rotationDegrees}_${entry.isFlipped}_${entry.width}_${entry.height}_${entry.path}'),
      child: TiledImageView(
        entry: entry,
        multiPageInfo: multiPageInfo,
        page: page,
        viewStateNotifier: _viewStateNotifier,
        errorBuilder: (context, error, stackTrace) => ErrorView(onTap: () => onTap?.call(null)),
      ),
      childSize: pageDisplaySize,
      controller: _magnifierController,
      maxScale: EntryPageView.maxScale,
      minScale: EntryPageView.minScale,
      initialScale: EntryPageView.initialScale,
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
      childSize: pageDisplaySize,
      controller: _magnifierController,
      minScale: EntryPageView.minScale,
      initialScale: EntryPageView.initialScale,
      scaleStateCycle: _vectorScaleStateCycle,
      onTap: (c, d, s, childPosition) => onTap?.call(childPosition),
    );

    if (background == EntryBackground.checkered) {
      child = VectorViewCheckeredBackground(
        displaySize: pageDisplaySize,
        viewStateNotifier: _viewStateNotifier,
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
      childSize: pageDisplaySize,
      controller: _magnifierController,
      maxScale: EntryPageView.maxScale,
      minScale: EntryPageView.minScale,
      initialScale: EntryPageView.initialScale,
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

typedef MagnifierTapCallback = void Function(Offset childPosition);
