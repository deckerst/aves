import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:aves/widgets/viewer/controller.dart';
import 'package:aves/widgets/viewer/hero.dart';
import 'package:aves/widgets/viewer/notifications.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:aves/widgets/viewer/visual/conductor.dart';
import 'package:aves/widgets/viewer/visual/error.dart';
import 'package:aves/widgets/viewer/visual/raster.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:aves/widgets/viewer/visual/subtitle/subtitle.dart';
import 'package:aves/widgets/viewer/visual/vector.dart';
import 'package:aves/widgets/viewer/visual/video.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:collection/collection.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class EntryPageView extends StatefulWidget {
  final AvesEntry mainEntry, pageEntry;
  final ViewerController viewerController;
  final VoidCallback? onDisposed;

  static const decorationCheckSize = 20.0;

  const EntryPageView({
    super.key,
    required this.mainEntry,
    required this.pageEntry,
    required this.viewerController,
    this.onDisposed,
  });

  @override
  State<EntryPageView> createState() => _EntryPageViewState();
}

class _EntryPageViewState extends State<EntryPageView> with SingleTickerProviderStateMixin {
  late ValueNotifier<ViewState> _viewStateNotifier;
  late AvesMagnifierController _magnifierController;
  final List<StreamSubscription> _subscriptions = [];
  ImageStream? _videoCoverStream;
  late ImageStreamListener _videoCoverStreamListener;
  final ValueNotifier<ImageInfo?> _videoCoverInfoNotifier = ValueNotifier(null);
  final ValueNotifier<Widget?> _actionFeedbackChildNotifier = ValueNotifier(null);

  AvesMagnifierController? _dismissedCoverMagnifierController;

  AvesMagnifierController get dismissedCoverMagnifierController {
    _dismissedCoverMagnifierController ??= AvesMagnifierController();
    return _dismissedCoverMagnifierController!;
  }

  AvesEntry get mainEntry => widget.mainEntry;

  AvesEntry get entry => widget.pageEntry;

  ViewerController get viewerController => widget.viewerController;

  // use the high res photo as cover for the video part of a motion photo
  ImageProvider get videoCoverUriImage => mainEntry.isMotionPhoto ? mainEntry.uriImage : entry.uriImage;

  static const rasterMaxScale = ScaleLevel(factor: 5);
  static const vectorMaxScale = ScaleLevel(factor: 25);

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
    _magnifierController = AvesMagnifierController();
    _subscriptions.add(_magnifierController.stateStream.listen(_onViewStateChanged));
    _subscriptions.add(_magnifierController.scaleBoundariesStream.listen(_onViewScaleBoundariesChanged));
    if (entry.isVideo) {
      _videoCoverStreamListener = ImageStreamListener((image, _) => _videoCoverInfoNotifier.value = image);
      _videoCoverStream = videoCoverUriImage.resolve(ImageConfiguration.empty);
      _videoCoverStream!.addListener(_videoCoverStreamListener);
    }
    viewerController.startAutopilotAnimation(
        vsync: this,
        onUpdate: ({required scaleLevel}) {
          final boundaries = _magnifierController.scaleBoundaries;
          if (boundaries != null) {
            final scale = boundaries.scaleForLevel(scaleLevel);
            _magnifierController.update(scale: scale, source: ChangeSource.animation);
          }
        });
  }

  void _unregisterWidget(EntryPageView oldWidget) {
    viewerController.stopAutopilotAnimation(vsync: this);
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
      animation: entry.visualChangeNotifier,
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
    return _buildMagnifier(
      maxScale: vectorMaxScale,
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
  }

  Widget _buildVideoView() {
    final videoController = context.read<VideoConductor>().getController(entry);
    if (videoController == null) return const SizedBox();

    return ValueListenableBuilder<double>(
      valueListenable: videoController.sarNotifier,
      builder: (context, sar, child) {
        final videoDisplaySize = entry.videoDisplaySize(sar);

        return Selector<Settings, Tuple2<bool, bool>>(
          selector: (context, s) => Tuple2(s.videoGestureDoubleTapTogglePlay, s.videoGestureSideDoubleTapSeek),
          builder: (context, s, child) {
            final playGesture = s.item1;
            final seekGesture = s.item2;
            final useActionGesture = playGesture || seekGesture;

            void _applyAction(EntryAction action, {IconData? Function()? icon}) {
              _actionFeedbackChildNotifier.value = DecoratedIcon(
                icon?.call() ?? action.getIconData(),
                size: 48,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 4,
                  )
                ],
              );
              VideoActionNotification(
                controller: videoController,
                action: action,
              ).dispatch(context);
            }

            MagnifierDoubleTapCallback? _onDoubleTap = useActionGesture
                ? (alignment) {
                    final x = alignment.x;
                    if (seekGesture) {
                      if (x < sideRatio) {
                        _applyAction(EntryAction.videoReplay10);
                        return true;
                      } else if (x > 1 - sideRatio) {
                        _applyAction(EntryAction.videoSkip10);
                        return true;
                      }
                    }
                    if (playGesture) {
                      _applyAction(
                        EntryAction.videoTogglePlay,
                        icon: () => videoController.isPlaying ? AIcons.pause : AIcons.play,
                      );
                      return true;
                    }
                    return false;
                  }
                : null;

            return Stack(
              fit: StackFit.expand,
              children: [
                Stack(
                  children: [
                    _buildMagnifier(
                      displaySize: videoDisplaySize,
                      onDoubleTap: _onDoubleTap,
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
                    if (useActionGesture)
                      ValueListenableBuilder<Widget?>(
                        valueListenable: _actionFeedbackChildNotifier,
                        builder: (context, feedbackChild, child) => ActionFeedback(
                          child: feedbackChild,
                        ),
                      ),
                  ],
                ),
                _buildVideoCover(
                  videoController: videoController,
                  videoDisplaySize: videoDisplaySize,
                  onDoubleTap: _onDoubleTap,
                ),
              ],
            );
          },
        );
      },
    );
  }

  StreamBuilder<VideoStatus> _buildVideoCover({
    required AvesVideoController videoController,
    required Size videoDisplaySize,
    required MagnifierDoubleTapCallback? onDoubleTap,
  }) {
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
            onEnd: () {
              // while cover is fading out, the same controller is used for both the cover and the video,
              // and both fire scale boundaries events, so we make sure that in the end
              // the scale boundaries from the video are used after the cover is gone
              final boundaries = _magnifierController.scaleBoundaries;
              if (boundaries != null) {
                _magnifierController.setScaleBoundaries(
                  boundaries.copyWith(
                    childSize: videoDisplaySize,
                  ),
                );
              }
            },
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
                    onDoubleTap: onDoubleTap,
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
    AvesMagnifierController? controller,
    Size? displaySize,
    ScaleLevel maxScale = rasterMaxScale,
    ScaleStateCycle scaleStateCycle = defaultScaleStateCycle,
    bool applyScale = true,
    MagnifierDoubleTapCallback? onDoubleTap,
    required Widget child,
  }) {
    final isWallpaperMode = context.read<ValueNotifier<AppMode>>().value == AppMode.setWallpaper;
    final minScale = isWallpaperMode ? const ScaleLevel(ref: ScaleReference.covered) : const ScaleLevel(ref: ScaleReference.contained);

    return AvesMagnifier(
      // key includes modified date to refresh when the image is modified by metadata (e.g. rotated)
      key: Key('${entry.uri}_${entry.pageId}_${entry.dateModifiedSecs}'),
      controller: controller ?? _magnifierController,
      childSize: displaySize ?? entry.displaySize,
      allowOriginalScaleBeyondRange: !isWallpaperMode,
      minScale: minScale,
      maxScale: maxScale,
      initialScale: viewerController.initialScale,
      scaleStateCycle: scaleStateCycle,
      applyScale: applyScale,
      onTap: (c, s, a, p) => _onTap(alignment: a),
      onDoubleTap: onDoubleTap,
      child: child,
    );
  }

  void _onTap({Alignment? alignment}) {
    if (settings.viewerGestureSideTapNext && alignment != null) {
      final x = alignment.x;
      if (x < sideRatio) {
        JumpToPreviousEntryNotification().dispatch(context);
        return;
      } else if (x > 1 - sideRatio) {
        JumpToNextEntryNotification().dispatch(context);
        return;
      }
    }
    const ToggleOverlayNotification().dispatch(context);
  }

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

  double get sideRatio {
    switch (context.read<MediaQueryData>().orientation) {
      case Orientation.portrait:
        return 1 / 5;
      case Orientation.landscape:
        return 1 / 8;
    }
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
