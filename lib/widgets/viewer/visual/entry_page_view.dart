import 'dart:async';

import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/entry_background.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/thumbnail/raster.dart';
import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/magnifier.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:aves/widgets/viewer/hero.dart';
import 'package:aves/widgets/viewer/overlay/notifications.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:aves/widgets/viewer/visual/error.dart';
import 'package:aves/widgets/viewer/visual/raster.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:aves/widgets/viewer/visual/subtitle.dart';
import 'package:aves/widgets/viewer/visual/vector.dart';
import 'package:aves/widgets/viewer/visual/video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class EntryPageView extends StatefulWidget {
  final AvesEntry mainEntry, pageEntry;
  final Size? viewportSize;
  final VoidCallback? onDisposed;

  static const decorationCheckSize = 20.0;

  const EntryPageView({
    Key? key,
    required this.mainEntry,
    required this.pageEntry,
    this.viewportSize,
    this.onDisposed,
  }) : super(key: key);

  @override
  _EntryPageViewState createState() => _EntryPageViewState();
}

class _EntryPageViewState extends State<EntryPageView> {
  late MagnifierController _magnifierController;
  final ValueNotifier<ViewState> _viewStateNotifier = ValueNotifier(ViewState.zero);
  final List<StreamSubscription> _subscriptions = [];

  AvesEntry get mainEntry => widget.mainEntry;

  AvesEntry get entry => widget.pageEntry;

  Size? get viewportSize => widget.viewportSize;

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

    if (oldWidget.pageEntry.displaySize != widget.pageEntry.displaySize) {
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
              viewportSize: viewportSize!,
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
    _magnifierController.dispose();
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedBuilder(
      animation: entry.imageChangeNotifier,
      builder: (context, child) {
        Widget? child;
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
          onTap: _onTap,
        );
        return child;
      },
    );

    return Consumer<HeroInfo?>(
      builder: (context, info, child) => Hero(
        tag: info != null && info.entry == mainEntry ? hashValues(info.collectionId, mainEntry) : hashCode,
        transitionOnUserGestures: true,
        child: child!,
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
          onTap: _onTap,
        ),
      ),
    );
  }

  Widget _buildSvgView() {
    final background = settings.vectorBackground;
    final colorFilter = background.isColor ? ColorFilter.mode(background.color, BlendMode.dstOver) : null;

    var child = _buildMagnifier(
      maxScale: const ScaleLevel(factor: double.infinity),
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
    final videoController = context.read<VideoConductor>().getController(entry);
    if (videoController == null) return const SizedBox();
    return Stack(
      fit: StackFit.expand,
      children: [
        ValueListenableBuilder<double>(
            valueListenable: videoController.sarNotifier,
            builder: (context, sar, child) {
              return Stack(
                children: [
                  _buildMagnifier(
                    displaySize: entry.videoDisplaySize(sar),
                    child: VideoView(
                      entry: entry,
                      controller: videoController,
                    ),
                  ),
                  VideoSubtitles(
                    controller: videoController,
                  ),
                  if (settings.videoShowRawTimedText)
                    VideoSubtitles(
                      controller: videoController,
                      debugMode: true,
                    ),
                ],
              );
            }),
        // fade out image to ease transition with the player
        StreamBuilder<VideoStatus>(
          stream: videoController.statusStream,
          builder: (context, snapshot) {
            final showCover = !videoController.isReady;
            return IgnorePointer(
              ignoring: !showCover,
              child: AnimatedOpacity(
                opacity: showCover ? 1 : 0,
                curve: Curves.easeInCirc,
                duration: Durations.viewerVideoPlayerTransition,
                child: GestureDetector(
                  onTap: _onTap,
                  child: RasterImageThumbnail(
                    entry: entry,
                    extent: context.select<MediaQueryData, double>((mq) => mq.size.shortestSide),
                    fit: BoxFit.contain,
                    showLoadingBackground: false,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMagnifier({
    ScaleLevel maxScale = maxScale,
    ScaleStateCycle scaleStateCycle = defaultScaleStateCycle,
    bool applyScale = true,
    Size? displaySize,
    required Widget child,
  }) {
    return Magnifier(
      // key includes modified date to refresh when the image is modified by metadata (e.g. rotated)
      key: ValueKey('${entry.pageId}_${entry.dateModifiedSecs}'),
      controller: _magnifierController,
      childSize: displaySize ?? entry.displaySize,
      minScale: minScale,
      maxScale: maxScale,
      initialScale: initialScale,
      scaleStateCycle: scaleStateCycle,
      applyScale: applyScale,
      onTap: (c, d, s, o) => _onTap(),
      child: child,
    );
  }

  void _onTap() => ToggleOverlayNotification().dispatch(context);

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
