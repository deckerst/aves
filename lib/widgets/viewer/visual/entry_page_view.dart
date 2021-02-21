import 'dart:async';

import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/settings/entry_background.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/magnifier.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:aves/widgets/viewer/hero.dart';
import 'package:aves/widgets/viewer/visual/error.dart';
import 'package:aves/widgets/viewer/visual/raster.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:aves/widgets/viewer/visual/vector.dart';
import 'package:aves/widgets/viewer/visual/video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class EntryPageView extends StatefulWidget {
  final AvesEntry mainEntry;
  final AvesEntry entry;
  final SinglePageInfo page;
  final Size viewportSize;
  final MagnifierTapCallback onTap;
  final List<Tuple2<String, IjkMediaController>> videoControllers;
  final VoidCallback onDisposed;

  static const decorationCheckSize = 20.0;

  EntryPageView({
    Key key,
    this.mainEntry,
    this.page,
    this.viewportSize,
    @required this.onTap,
    @required this.videoControllers,
    this.onDisposed,
  })  : entry = mainEntry.getPageEntry(page) ?? mainEntry,
        super(key: key);

  @override
  _EntryPageViewState createState() => _EntryPageViewState();
}

class _EntryPageViewState extends State<EntryPageView> {
  MagnifierController _magnifierController;
  final ValueNotifier<ViewState> _viewStateNotifier = ValueNotifier(ViewState.zero);
  final List<StreamSubscription> _subscriptions = [];

  AvesEntry get mainEntry => widget.mainEntry;

  AvesEntry get entry => widget.entry;

  Size get viewportSize => widget.viewportSize;

  MagnifierTapCallback get onTap => widget.onTap;

  static const initialScale = ScaleLevel(ref: ScaleReference.contained);
  static const minScale = ScaleLevel(ref: ScaleReference.contained);
  static const maxScale = ScaleLevel(factor: 2.0);

  @override
  void initState() {
    super.initState();
    _registerWidget();
  }

  @override
  void didUpdateWidget(covariant EntryPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.entry.displaySize != entry.displaySize) {
      // do not reset the magnifier view state unless page dimensions change,
      // in effect locking the zoom & position when browsing entry pages of the same size
      _unregisterWidget();
      _registerWidget();
    }
  }

  @override
  void dispose() {
    _unregisterWidget();
    widget.onDisposed?.call();
    super.dispose();
  }

  void _registerWidget() {
    // try to initialize the view state to match magnifier initial state
    _viewStateNotifier.value = viewportSize != null
        ? ViewState(
            Offset.zero,
            ScaleBoundaries(
              minScale: minScale,
              maxScale: maxScale,
              initialScale: initialScale,
              viewportSize: viewportSize,
              childSize: entry.displaySize,
            ).initialScale,
            viewportSize,
          )
        : ViewState.zero;

    _magnifierController = MagnifierController();
    _subscriptions.add(_magnifierController.stateStream.listen(_onViewStateChanged));
    _subscriptions.add(_magnifierController.scaleBoundariesStream.listen(_onViewScaleBoundariesChanged));
  }

  void _unregisterWidget() {
    _magnifierController?.dispose();
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedBuilder(
      animation: entry.imageChangeNotifier,
      builder: (context, child) {
        Widget child;
        if (entry.isSvg) {
          child = _buildSvgView();
        } else if (!entry.displaySize.isEmpty) {
          if (entry.isVideo) {
            child = _buildVideoView();
          } else if (entry.canDecode) {
            child = _buildRasterView();
          }
        }
        child ??= ErrorView(
          entry: entry,
          onTap: () => onTap?.call(null),
        );
        return child;
      },
    );

    return Consumer<HeroInfo>(
      builder: (context, info, child) => Hero(
        tag: info?.entry == mainEntry ? hashValues(info.collectionId, mainEntry) : hashCode,
        transitionOnUserGestures: true,
        child: child,
      ),
      child: child,
    );
  }

  Widget _buildRasterView() {
    return _buildMagnifier(
      applyScale: false,
      child: RasterImageView(
        entry: entry,
        viewStateNotifier: _viewStateNotifier,
        errorBuilder: (context, error, stackTrace) => ErrorView(
          entry: entry,
          onTap: () => onTap?.call(null),
        ),
      ),
    );
  }

  Widget _buildSvgView() {
    final background = settings.vectorBackground;
    final colorFilter = background.isColor ? ColorFilter.mode(background.color, BlendMode.dstOver) : null;

    var child = _buildMagnifier(
      maxScale: ScaleLevel(factor: double.infinity),
      scaleStateCycle: _vectorScaleStateCycle,
      child: SvgPicture(
        UriPicture(
          uri: entry.uri,
          mimeType: entry.mimeType,
          colorFilter: colorFilter,
        ),
      ),
    );

    if (background == EntryBackground.checkered) {
      child = VectorViewCheckeredBackground(
        displaySize: entry.displaySize,
        viewStateNotifier: _viewStateNotifier,
        child: child,
      );
    }
    return child;
  }

  Widget _buildVideoView() {
    final videoController = widget.videoControllers.firstWhere((kv) => kv.item1 == entry.uri, orElse: () => null)?.item2;
    if (videoController == null) return SizedBox();
    return _buildMagnifier(
      child: VideoView(
        entry: entry,
        controller: videoController,
      ),
    );
  }

  Widget _buildMagnifier({
    ScaleLevel maxScale = maxScale,
    ScaleStateCycle scaleStateCycle = defaultScaleStateCycle,
    bool applyScale = true,
    @required Widget child,
  }) {
    return Magnifier(
      // key includes modified date to refresh when the image is modified by metadata (e.g. rotated)
      key: ValueKey('${entry.pageId}_${entry.dateModifiedSecs}'),
      controller: _magnifierController,
      childSize: entry.displaySize,
      minScale: minScale,
      maxScale: maxScale,
      initialScale: initialScale,
      scaleStateCycle: scaleStateCycle,
      applyScale: applyScale,
      onTap: (c, d, s, childPosition) => onTap?.call(childPosition),
      child: child,
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
