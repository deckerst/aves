import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/viewer/view_state.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/media_session_service.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/controls/controller.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves/widgets/viewer/hero.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/view/conductor.dart';
import 'package:aves/widgets/viewer/visual/error.dart';
import 'package:aves/widgets/viewer/visual/raster.dart';
import 'package:aves/widgets/viewer/visual/vector.dart';
import 'package:aves/widgets/viewer/visual/video/cover.dart';
import 'package:aves/widgets/viewer/visual/video/subtitle/subtitle.dart';
import 'package:aves/widgets/viewer/visual/video/swipe_action.dart';
import 'package:aves/widgets/viewer/visual/video/video_view.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:aves_model/aves_model.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryPageView extends StatefulWidget {
  final AvesEntry mainEntry, pageEntry;
  final ViewerController viewerController;
  final VoidCallback? onDisposed;

  static const decorationCheckSize = 20.0;
  static const rasterMaxScale = ScaleLevel(factor: 5);
  static const vectorMaxScale = ScaleLevel(factor: 25);

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

class _EntryPageViewState extends State<EntryPageView> with TickerProviderStateMixin {
  late ValueNotifier<ViewState> _viewStateNotifier;
  late AvesMagnifierController _magnifierController;
  final List<StreamSubscription> _subscriptions = [];
  final ValueNotifier<Widget?> _actionFeedbackChildNotifier = ValueNotifier(null);
  OverlayEntry? _actionFeedbackOverlayEntry;

  AvesEntry get mainEntry => widget.mainEntry;

  AvesEntry get entry => widget.pageEntry;

  ViewerController get viewerController => widget.viewerController;

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
    _actionFeedbackChildNotifier.dispose();
    super.dispose();
  }

  void _registerWidget(EntryPageView widget) {
    final entry = widget.pageEntry;
    _viewStateNotifier = context.read<ViewStateConductor>().getOrCreateController(entry).viewStateNotifier;
    _magnifierController = AvesMagnifierController();
    _subscriptions.add(_magnifierController.stateStream.listen(_onViewStateChanged));
    _subscriptions.add(_magnifierController.scaleBoundariesStream.listen(_onViewScaleBoundariesChanged));
    if (entry.isVideo) {
      _subscriptions.add(mediaSessionService.mediaCommands.listen(_onMediaCommand));
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
          } else if (entry.isDecodingSupported) {
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

    if (!settings.viewerUseCutout) {
      child = SafeCutoutArea(
        child: ClipRect(
          child: child,
        ),
      );
    }

    final animate = context.select<Settings, bool>((v) => v.animate);
    if (animate) {
      child = Consumer<EntryHeroInfo?>(
        builder: (context, info, child) => Hero(
          tag: info != null && info.entry == mainEntry ? info.tag : hashCode,
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
      maxScale: EntryPageView.vectorMaxScale,
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

    return ValueListenableBuilder<double?>(
      valueListenable: videoController.sarNotifier,
      builder: (context, sar, child) {
        final videoDisplaySize = entry.videoDisplaySize(sar);
        final isPureVideo = entry.isPureVideo;

        return Selector<Settings, (bool, bool, bool)>(
          selector: (context, s) => (
            isPureVideo && s.videoGestureDoubleTapTogglePlay,
            isPureVideo && s.videoGestureSideDoubleTapSeek,
            isPureVideo && s.videoGestureVerticalDragBrightnessVolume,
          ),
          builder: (context, s, child) {
            final (playGesture, seekGesture, useVerticalDragGesture) = s;
            final useTapGesture = playGesture || seekGesture;

            MagnifierDoubleTapCallback? onDoubleTap;
            MagnifierGestureScaleStartCallback? onScaleStart;
            MagnifierGestureScaleUpdateCallback? onScaleUpdate;
            MagnifierGestureScaleEndCallback? onScaleEnd;

            if (useTapGesture) {
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
                  entry: entry,
                  action: action,
                ).dispatch(context);
              }

              onDoubleTap = (alignment) {
                final x = alignment.x;
                if (seekGesture) {
                  final sideRatio = _getSideRatio();
                  if (sideRatio != null) {
                    if (x < sideRatio) {
                      _applyAction(EntryAction.videoReplay10);
                      return true;
                    } else if (x > 1 - sideRatio) {
                      _applyAction(EntryAction.videoSkip10);
                      return true;
                    }
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
              };
            }

            if (useVerticalDragGesture) {
              SwipeAction? swipeAction;
              var move = Offset.zero;
              var dropped = false;
              double? startValue;
              ValueNotifier<double?>? valueNotifier;

              onScaleStart = (details, doubleTap, boundaries) {
                dropped = details.pointerCount > 1 || doubleTap;
                if (dropped) return;

                startValue = null;
                valueNotifier = ValueNotifier<double?>(null);
                final alignmentX = details.focalPoint.dx / boundaries.viewportSize.width;
                final action = alignmentX > .5 ? SwipeAction.volume : SwipeAction.brightness;
                action.get().then((v) => startValue = v);
                swipeAction = action;
                move = Offset.zero;
                _actionFeedbackOverlayEntry = OverlayEntry(
                  builder: (context) => SwipeActionFeedback(
                    action: action,
                    valueNotifier: valueNotifier!,
                  ),
                );
                Overlay.of(context).insert(_actionFeedbackOverlayEntry!);
              };
              onScaleUpdate = (details) {
                if (valueNotifier == null) return false;

                move += details.focalPointDelta;
                dropped |= details.pointerCount > 1;
                if (valueNotifier!.value == null) {
                  dropped |= MagnifierGestureRecognizer.isXPan(move);
                }
                if (dropped) return false;

                final _startValue = startValue;
                if (_startValue != null) {
                  final double value = (_startValue - move.dy / SwipeActionFeedback.height).clamp(0, 1);
                  valueNotifier!.value = value;
                  swipeAction?.set(value);
                }
                return true;
              };
              onScaleEnd = (details) {
                valueNotifier?.dispose();

                _actionFeedbackOverlayEntry
                  ?..remove()
                  ..dispose();
                _actionFeedbackOverlayEntry = null;
              };
            }

            Widget videoChild = Stack(
              children: [
                _buildMagnifier(
                  displaySize: videoDisplaySize,
                  onScaleStart: onScaleStart,
                  onScaleUpdate: onScaleUpdate,
                  onScaleEnd: onScaleEnd,
                  onDoubleTap: onDoubleTap,
                  child: VideoView(
                    entry: entry,
                    controller: videoController,
                  ),
                ),
                VideoSubtitles(
                  entry: entry,
                  controller: videoController,
                  viewStateNotifier: _viewStateNotifier,
                ),
                if (useTapGesture)
                  ValueListenableBuilder<Widget?>(
                    valueListenable: _actionFeedbackChildNotifier,
                    builder: (context, feedbackChild, child) => ActionFeedback(
                      child: feedbackChild,
                    ),
                  ),
              ],
            );
            if (useVerticalDragGesture) {
              final scope = MagnifierGestureDetectorScope.maybeOf(context);
              if (scope != null) {
                videoChild = scope.copyWith(
                  acceptPointerEvent: MagnifierGestureRecognizer.isYPan,
                  child: videoChild,
                );
              }
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                videoChild,
                VideoCover(
                  mainEntry: mainEntry,
                  pageEntry: entry,
                  magnifierController: _magnifierController,
                  videoController: videoController,
                  videoDisplaySize: videoDisplaySize,
                  onTap: _onTap,
                  magnifierBuilder: (coverController, coverSize, videoCoverUriImage) => _buildMagnifier(
                    controller: coverController,
                    displaySize: coverSize,
                    onDoubleTap: onDoubleTap,
                    child: Image(
                      image: videoCoverUriImage,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMagnifier({
    AvesMagnifierController? controller,
    Size? displaySize,
    ScaleLevel maxScale = EntryPageView.rasterMaxScale,
    ScaleStateCycle scaleStateCycle = defaultScaleStateCycle,
    bool applyScale = true,
    MagnifierGestureScaleStartCallback? onScaleStart,
    MagnifierGestureScaleUpdateCallback? onScaleUpdate,
    MagnifierGestureScaleEndCallback? onScaleEnd,
    MagnifierDoubleTapCallback? onDoubleTap,
    required Widget child,
  }) {
    final isWallpaperMode = context.read<ValueNotifier<AppMode>>().value == AppMode.setWallpaper;
    final minScale = isWallpaperMode ? const ScaleLevel(ref: ScaleReference.covered) : const ScaleLevel(ref: ScaleReference.contained);

    return AvesMagnifier(
      // key includes modified date to refresh when the image is modified by metadata (e.g. rotated)
      key: Key('${entry.uri}_${entry.pageId}_${entry.dateModifiedMillis}'),
      controller: controller ?? _magnifierController,
      contentSize: displaySize ?? entry.displaySize,
      allowOriginalScaleBeyondRange: !isWallpaperMode,
      allowDoubleTap: _allowDoubleTap,
      minScale: minScale,
      maxScale: maxScale,
      initialScale: viewerController.initialScale,
      scaleStateCycle: scaleStateCycle,
      applyScale: applyScale,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
      onFling: _onFling,
      onTap: (c, s, a, p) {
        if (c.mounted) {
          _onTap(alignment: a);
        }
      },
      onDoubleTap: onDoubleTap,
      child: child,
    );
  }

  void _onFling(AxisDirection direction) {
    const animate = true;
    switch (direction) {
      case AxisDirection.left:
        (context.isRtl ? const ShowNextEntryNotification(animate: animate) : const ShowPreviousEntryNotification(animate: animate)).dispatch(context);
      case AxisDirection.right:
        (context.isRtl ? const ShowPreviousEntryNotification(animate: animate) : const ShowNextEntryNotification(animate: animate)).dispatch(context);
      case AxisDirection.up:
        PopVisualNotification().dispatch(context);
      case AxisDirection.down:
        ShowInfoPageNotification().dispatch(context);
    }
  }

  Notification? _handleSideSingleTap(Alignment? alignment) {
    if (settings.viewerGestureSideTapNext && alignment != null) {
      final x = alignment.x;
      final sideRatio = _getSideRatio();
      if (sideRatio != null) {
        const animate = false;
        if (x < sideRatio) {
          return context.isRtl ? const ShowNextEntryNotification(animate: animate) : const ShowPreviousEntryNotification(animate: animate);
        } else if (x > 1 - sideRatio) {
          return context.isRtl ? const ShowPreviousEntryNotification(animate: animate) : const ShowNextEntryNotification(animate: animate);
        }
      }
    }
    return null;
  }

  void _onTap({Alignment? alignment}) => (_handleSideSingleTap(alignment) ?? const ToggleOverlayNotification()).dispatch(context);

  // side gesture handling by precedence:
  // - seek in video by side double tap (if enabled)
  // - go to previous/next entry by side single tap (if enabled)
  // - zoom in/out by double tap
  bool _allowDoubleTap(Alignment alignment) {
    if (entry.isVideo && settings.videoGestureSideDoubleTapSeek) {
      return true;
    }
    final actionNotification = _handleSideSingleTap(alignment);
    return actionNotification == null;
  }

  void _onMediaCommand(MediaCommandEvent event) {
    final videoController = context.read<VideoConductor>().getController(entry);
    if (videoController == null) return;

    switch (event.command) {
      case MediaCommand.play:
        videoController.play();
      case MediaCommand.pause:
        videoController.pause();
      case MediaCommand.skipToNext:
        ShowNextVideoNotification().dispatch(context);
      case MediaCommand.skipToPrevious:
        ShowPreviousVideoNotification().dispatch(context);
      case MediaCommand.stop:
        videoController.pause();
      case MediaCommand.seek:
        if (event is MediaSeekCommandEvent) {
          videoController.seekTo(event.position);
        }
    }
  }

  void _onViewStateChanged(MagnifierState v) {
    if (!mounted) return;
    _viewStateNotifier.value = _viewStateNotifier.value.copyWith(
      position: v.position,
      scale: v.scale,
    );
  }

  void _onViewScaleBoundariesChanged(ScaleBoundaries v) {
    _viewStateNotifier.value = _viewStateNotifier.value.copyWith(
      viewportSize: v.viewportSize,
      contentSize: v.contentSize,
    );
  }

  double? _getSideRatio() {
    if (!mounted) return null;
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    return isPortrait ? 1 / 6 : 1 / 8;
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
