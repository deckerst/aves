import 'dart:async';

import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
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
import 'package:collection/collection.dart';
import 'package:decorated_icon/decorated_icon.dart';
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
  State<EntryPageView> createState() => _EntryPageViewState();
}

class _EntryPageViewState extends State<EntryPageView> {
  late ValueNotifier<ViewState> _viewStateNotifier;
  late MagnifierController _magnifierController;
  final List<StreamSubscription> _subscriptions = [];
  ImageStream? _videoCoverStream;
  late ImageStreamListener _videoCoverStreamListener;
  final ValueNotifier<ImageInfo?> _videoCoverInfoNotifier = ValueNotifier(null);
  final ValueNotifier<Widget?> _actionFeedbackChildNotifier = ValueNotifier(null);

  MagnifierController? _dismissedCoverMagnifierController;

  MagnifierController get dismissedCoverMagnifierController {
    _dismissedCoverMagnifierController ??= MagnifierController();
    return _dismissedCoverMagnifierController!;
  }

  AvesEntry get mainEntry => widget.mainEntry;

  AvesEntry get entry => widget.pageEntry;

  // use the high res photo as cover for the video part of a motion photo
  ImageProvider get videoCoverUriImage => mainEntry.isMotionPhoto ? mainEntry.uriImage : entry.uriImage;

  static const initialScale = ScaleLevel(ref: ScaleReference.contained);
  static const minScale = ScaleLevel(ref: ScaleReference.contained);
  static const maxScale = ScaleLevel(factor: 2.0);

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant EntryPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pageEntry != widget.pageEntry) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    widget.onDisposed?.call();
    super.dispose();
  }

  void _registerWidget(EntryPageView widget) {
    final entry = widget.pageEntry;
    _viewStateNotifier = context.read<ViewStateConductor>().getOrCreateController(entry);
    _magnifierController = MagnifierController();
    _subscriptions.add(_magnifierController.stateStream.listen(_onViewStateChanged));
    _subscriptions.add(_magnifierController.scaleBoundariesStream.listen(_onViewScaleBoundariesChanged));
    if (entry.isVideo) {
      _videoCoverStreamListener = ImageStreamListener((image, _) => _videoCoverInfoNotifier.value = image);
      _videoCoverStream = videoCoverUriImage.resolve(ImageConfiguration.empty);
      _videoCoverStream!.addListener(_videoCoverStreamListener);
    }
  }

  void _unregisterWidget(EntryPageView oldWidget) {
    _videoCoverStream?.removeListener(_videoCoverStreamListener);
    _videoCoverStream = null;
    _videoCoverInfoNotifier.value = null;
    _magnifierController.dispose();
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedBuilder(
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

    final animate = context.select<Settings, bool>((v) => v.accessibilityAnimations.animate);
    if (animate) {
      child = Consumer<HeroInfo?>(
        builder: (context, info, child) => Hero(
          tag: info != null && info.entry == mainEntry ? Object.hashAll([info.collectionId, mainEntry.id]) : hashCode,
          transitionOnUserGestures: true,
          child: child!,
        ),
        child: child,
      );
    }
    return child;
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

    Positioned _buildDoubleTapDetector(AlignmentGeometry alignment, VideoAction action) {
      return Positioned.fill(
        child: FractionallySizedBox(
          alignment: alignment,
          widthFactor: .25,
          child: GestureDetector(
            onDoubleTap: () {
              _actionFeedbackChildNotifier.value = DecoratedIcon(
                action.getIconData(),
                shadows: Constants.embossShadows,
                size: 48,
              );
              VideoGestureNotification(
                controller: videoController,
                action: action,
              ).dispatch(context);
            },
          ),
        ),
      );
    }

    return ValueListenableBuilder<double>(
      valueListenable: videoController.sarNotifier,
      builder: (context, sar, child) {
        final videoDisplaySize = entry.videoDisplaySize(sar);
        return Stack(
          fit: StackFit.expand,
          children: [
            Stack(
              children: [
                _buildMagnifier(
                  displaySize: videoDisplaySize,
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
                if (settings.videoGestureSideDoubleTapSeek) ...[
                  _buildDoubleTapDetector(Alignment.centerLeft, VideoAction.replay10),
                  _buildDoubleTapDetector(Alignment.centerRight, VideoAction.skip10),
                  ValueListenableBuilder<Widget?>(
                    valueListenable: _actionFeedbackChildNotifier,
                    builder: (context, feedbackChild, child) => ActionFeedback(
                      child: feedbackChild,
                    ),
                  ),
                ],
              ],
            ),
            _buildVideoCover(videoController, videoDisplaySize),
          ],
        );
      },
    );
  }

  StreamBuilder<VideoStatus> _buildVideoCover(AvesVideoController videoController, Size videoDisplaySize) {
    // fade out image to ease transition with the player
    return StreamBuilder<VideoStatus>(
      stream: videoController.statusStream,
      builder: (context, snapshot) {
        final showCover = !videoController.isReady;
        return IgnorePointer(
          ignoring: !showCover,
          child: AnimatedOpacity(
            opacity: showCover ? 1 : 0,
            curve: Curves.easeInCirc,
            duration: Durations.viewerVideoPlayerTransition,
            child: ValueListenableBuilder<ImageInfo?>(
              valueListenable: _videoCoverInfoNotifier,
              builder: (context, videoCoverInfo, child) {
                if (videoCoverInfo != null) {
                  // full cover image may have a different size and different aspect ratio
                  final coverSize = Size(
                    videoCoverInfo.image.width.toDouble(),
                    videoCoverInfo.image.height.toDouble(),
                  );
                  // when the cover is the same size as the video itself
                  // (which is often the case when the cover is not embedded but just a frame),
                  // we can reuse the same magnifier and preserve its state when switching from cover to video
                  final coverController = showCover || coverSize == videoDisplaySize ? _magnifierController : dismissedCoverMagnifierController;
                  return _buildMagnifier(
                    controller: coverController,
                    displaySize: coverSize,
                    child: Image(
                      image: videoCoverUriImage,
                    ),
                  );
                }

                // default to cached thumbnail, if any
                final extent = entry.cachedThumbnails.firstOrNull?.key.extent;
                if (extent != null && extent > 0) {
                  return GestureDetector(
                    onTap: _onTap,
                    child: ThumbnailImage(
                      entry: entry,
                      extent: extent,
                      fit: BoxFit.contain,
                      showLoadingBackground: false,
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMagnifier({
    MagnifierController? controller,
    Size? displaySize,
    ScaleLevel maxScale = maxScale,
    ScaleStateCycle scaleStateCycle = defaultScaleStateCycle,
    bool applyScale = true,
    required Widget child,
  }) {
    return Magnifier(
      // key includes modified date to refresh when the image is modified by metadata (e.g. rotated)
      key: ValueKey('${entry.uri}_${entry.pageId}_${entry.dateModifiedSecs}'),
      controller: controller ?? _magnifierController,
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
    _viewStateNotifier.value = _viewStateNotifier.value.copyWith(
      position: v.position,
      scale: v.scale,
    );
  }

  void _onViewScaleBoundariesChanged(ScaleBoundaries v) {
    _viewStateNotifier.value = _viewStateNotifier.value.copyWith(
      viewportSize: v.viewportSize,
      contentSize: v.childSize,
    );
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
