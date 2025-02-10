import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/viewer/view_state.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/editor/transform/controller.dart';
import 'package:aves/widgets/editor/transform/painter.dart';
import 'package:aves/widgets/editor/transform/transformation.dart';
import 'package:aves/widgets/viewer/visual/error.dart';
import 'package:aves/widgets/viewer/visual/raster.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditorImage extends StatefulWidget {
  final AvesMagnifierController magnifierController;
  final TransformController transformController;
  final ValueNotifier<EditorAction?> actionNotifier;
  final ValueNotifier<EdgeInsets> marginNotifier;
  final ValueNotifier<ViewState> viewStateNotifier;
  final AvesEntry entry;

  const EditorImage({
    super.key,
    required this.magnifierController,
    required this.transformController,
    required this.actionNotifier,
    required this.marginNotifier,
    required this.viewStateNotifier,
    required this.entry,
  });

  @override
  State<EditorImage> createState() => _EditorImageState();
}

class _EditorImageState extends State<EditorImage> {
  final List<StreamSubscription> _subscriptions = [];
  final ValueNotifier<double> _scrimOpacityNotifier = ValueNotifier(0);

  AvesEntry get entry => widget.entry;

  TransformController get transformController => widget.transformController;

  ValueNotifier<ViewState> get viewStateNotifier => widget.viewStateNotifier;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant EditorImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(EditorImage widget) {
    widget.actionNotifier.addListener(_onActionChanged);
    _subscriptions.add(widget.magnifierController.stateStream.listen(_onViewStateChanged));
    _subscriptions.add(widget.magnifierController.scaleBoundariesStream.listen(_onViewScaleBoundariesChanged));
    _subscriptions.add(widget.transformController.activityStream.listen(_onTransformActivity));
  }

  void _unregisterWidget(EditorImage widget) {
    widget.actionNotifier.removeListener(_onActionChanged);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    return MagnifierGestureDetectorScope(
      axis: const [Axis.horizontal, Axis.vertical],
      child: StreamBuilder<Transformation>(
        stream: transformController.transformationStream,
        builder: (context, snapshot) {
          final transformation = (snapshot.data ?? Transformation.zero);
          final highlightRegionCorners = transformation.region.corners;
          final imageToUserMatrix = transformation.matrix;

          final mediaSize = entry.displaySize;
          final canvasSize = MatrixUtils.transformRect(imageToUserMatrix, Offset.zero & mediaSize).size;

          return ValueListenableBuilder<EdgeInsets>(
            valueListenable: widget.marginNotifier,
            builder: (context, margin, child) {
              return Transform(
                alignment: Alignment.center,
                transform: imageToUserMatrix,
                child: ValueListenableBuilder<EditorAction?>(
                  valueListenable: widget.actionNotifier,
                  builder: (context, action, child) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final viewportSize = margin.deflateSize(constraints.biggest);
                        final minScale = ScaleLevel(factor: ScaleLevel.scaleForContained(viewportSize, canvasSize));
                        return AvesMagnifier(
                          key: Key('${entry.uri}_${entry.pageId}_${entry.dateModifiedSecs}'),
                          controller: widget.magnifierController,
                          viewportPadding: margin,
                          contentSize: mediaSize,
                          allowOriginalScaleBeyondRange: false,
                          allowGestureScaleBeyondRange: false,
                          panInertia: _getActionPanInertia(action),
                          minScale: minScale,
                          maxScale: const ScaleLevel(factor: 1),
                          initialScale: minScale,
                          scaleStateCycle: defaultScaleStateCycle,
                          applyScale: false,
                          onScaleStart: (details, doubleTap, boundaries) {
                            transformController.activity = TransformActivity.pan;
                          },
                          onScaleEnd: (details) {
                            transformController.activity = TransformActivity.none;
                          },
                          child: child!,
                        );
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      RasterImageView(
                        entry: entry,
                        viewStateNotifier: viewStateNotifier,
                        errorBuilder: (context, error, stackTrace) => ErrorView(
                          entry: entry,
                          onTap: () {},
                        ),
                      ),
                      Positioned.fill(
                        child: ValueListenableBuilder<ViewState>(
                          valueListenable: viewStateNotifier,
                          builder: (context, viewState, child) {
                            final scale = viewState.scale ?? 1;
                            final highlightRegionPath = Path()..addPolygon(highlightRegionCorners.map((v) => v * scale).toList(), true);
                            return ValueListenableBuilder<double>(
                              valueListenable: _scrimOpacityNotifier,
                              builder: (context, opacity, child) {
                                return AnimatedOpacity(
                                  opacity: opacity,
                                  duration: context.read<DurationsData>().viewerOverlayAnimation,
                                  child: CustomPaint(
                                    painter: ScrimPainter(
                                      excludePath: highlightRegionPath,
                                      opacity: opacity,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onViewStateChanged(MagnifierState v) {
    viewStateNotifier.value = viewStateNotifier.value.copyWith(
      position: v.position,
      scale: v.scale,
    );
  }

  void _onViewScaleBoundariesChanged(ScaleBoundaries v) {
    viewStateNotifier.value = viewStateNotifier.value.copyWith(
      viewportSize: v.viewportSize,
      contentSize: v.contentSize,
    );
  }

  void _onActionChanged() => _updateScrim();

  void _onTransformActivity(TransformActivity activity) => _updateScrim();

  void _updateScrim() => _scrimOpacityNotifier.value = _getActionScrimOpacity(widget.actionNotifier.value, transformController.activity);

  static double _getActionPanInertia(EditorAction? action) {
    switch (action) {
      case EditorAction.transform:
        return 0;
      case null:
        return AvesMagnifier.defaultPanInertia;
    }
  }

  static double _getActionScrimOpacity(EditorAction? action, TransformActivity activity) {
    switch (action) {
      case EditorAction.transform:
        switch (activity) {
          case TransformActivity.none:
            return .9;
          case TransformActivity.pan:
          case TransformActivity.resize:
          case TransformActivity.straighten:
            return .6;
        }
      case null:
        return 0;
    }
  }
}
