import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/magnifier/controller/controller.dart';
import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/magnifier.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_boundaries.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:aves/widgets/viewer/hero.dart';
import 'package:aves/widgets/viewer/overlay/notifications.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:aves/widgets/viewer/visual/conductor.dart';
import 'package:aves/widgets/viewer/visual/error.dart';
import 'package:aves/widgets/viewer/visual/raster.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:aves/widgets/viewer/visual/subtitle/subtitle.dart';
import 'package:aves/widgets/viewer/visual/vector.dart';
import 'package:aves/widgets/viewer/visual/video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryPageView extends StatefulWidget {
  final AvesEntry mainEntry, pageEntry;
  final VoidCallback? onDisposed;

  static const decorationCheckSize = 20.0;

  const EntryPageView({
    Key? key,
    required this.mainEntry,
    required this.pageEntry,
    this.onDisposed,
  }) : super(key: key);

  @override
  _EntryPageViewState createState() => _EntryPageViewState();
}

class _EntryPageViewState extends State<EntryPageView> {
  late ValueNotifier<ViewState> _viewStateNotifier;
  late MagnifierController _magnifierController;
  final List<StreamSubscription> _subscriptions = [];

  AvesEntry get mainEntry => widget.mainEntry;

  AvesEntry get entry => widget.pageEntry;

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

    if (oldWidget.pageEntry != widget.pageEntry) {
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
    _viewStateNotifier = context.read<ViewStateConductor>().getOrCreateController(entry);
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
        tag: info != null && info.entry == mainEntry ? hashValues(info.collectionId, mainEntry.uri) : hashCode,
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
    var child = _buildMagnifier(
      maxScale: const ScaleLevel(factor: 25),
      scaleStateCycle: _vectorScaleStateCycle,
      applyScale: false,
      child: VectorImageView(
        entry: entry,
        viewStateNotifier: _viewStateNotifier,
        errorBuilder: (context, error, stackTrace) => ErrorView(
          entry: entry,
          onTap: _onTap,
        ),
      ),
    );
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
                    viewStateNotifier: _viewStateNotifier,
                  ),
                  if (settings.videoShowRawTimedText)
                    VideoSubtitles(
                      controller: videoController,
                      viewStateNotifier: _viewStateNotifier,
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
                  child: ThumbnailImage(
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
      key: ValueKey('${entry.uri}_${entry.pageId}_${entry.dateModifiedSecs}'),
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

  void _onTap() => const ToggleOverlayNotification().dispatch(context);

  void _onViewStateChanged(MagnifierState v) {
    final current = _viewStateNotifier.value;
    final viewState = ViewState(v.position, v.scale, current.viewportSize);
    _viewStateNotifier.value = viewState;
  }

  void _onViewScaleBoundariesChanged(ScaleBoundaries v) {
    final current = _viewStateNotifier.value;
    final viewState = ViewState(current.position, current.scale, v.viewportSize);
    _viewStateNotifier.value = viewState;
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
