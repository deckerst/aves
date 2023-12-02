import 'dart:math';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// This widget should be added on top of Scaffolds with:
// - `resizeToAvoidBottomInset` set to false,
// - a vertically scrollable body.
// It will prevent the body from scrolling when a user swipe from bottom to use Android 10 style navigation gestures.
class BottomGestureAreaProtector extends StatelessWidget {
  const BottomGestureAreaProtector({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: MediaQuery.systemGestureInsetsOf(context).bottom,
      child: GestureDetector(
        // absorb vertical gestures only
        onVerticalDragDown: (details) {},
        behavior: HitTestBehavior.translucent,
      ),
    );
  }
}

// It will prevent the body from scrolling when a user swipe from top to show the status bar when system UI is hidden.
class TopGestureAreaProtector extends StatelessWidget {
  const TopGestureAreaProtector({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      height: MediaQuery.systemGestureInsetsOf(context).top,
      child: GestureDetector(
        // absorb vertical gestures only
        onVerticalDragDown: (details) {},
        behavior: HitTestBehavior.translucent,
      ),
    );
  }
}

// It will prevent the body from scrolling when a user swipe from edges to use Android 10 style navigation gestures.
class SideGestureAreaProtector extends StatelessWidget {
  const SideGestureAreaProtector({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Row(
        // `systemGestureInsets` are not directional
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(
            width: MediaQuery.systemGestureInsetsOf(context).left,
            child: GestureDetector(
              // absorb horizontal gestures only
              onHorizontalDragDown: (details) {},
              behavior: HitTestBehavior.translucent,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: MediaQuery.systemGestureInsetsOf(context).right,
            child: GestureDetector(
              // absorb horizontal gestures only
              onHorizontalDragDown: (details) {},
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ],
      ),
    );
  }
}

class GestureAreaProtectorStack extends StatelessWidget {
  final Widget child;

  const GestureAreaProtectorStack({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const BottomGestureAreaProtector(),
      ],
    );
  }
}

class BottomPaddingSliver extends StatelessWidget {
  const BottomPaddingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<MediaQueryData, double>(
        selector: (context, mq) => mq.effectiveBottomPadding,
        builder: (context, mqPaddingBottom, child) {
          return SizedBox(height: mqPaddingBottom);
        },
      ),
    );
  }
}

class TvTileGridBottomPaddingSliver extends StatelessWidget {
  const TvTileGridBottomPaddingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: settings.useTvLayout ? context.select<TileExtentController, double>((controller) => controller.spacing) : 0,
      ),
    );
  }
}

// `MediaQuery.padding` matches cutout areas but also includes other system UI like the status bar
// so we cannot use `SafeArea` along `MediaQuery.removePadding()` to remove cutout areas
class SafeCutoutArea extends StatelessWidget {
  final Animation<double>? animation;
  final Widget child;

  const SafeCutoutArea({
    super.key,
    this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EdgeInsets>(
      valueListenable: AvesApp.cutoutInsetsNotifier,
      builder: (context, cutoutInsets, child) {
        return NullableValueListenableBuilder<double>(
          valueListenable: animation,
          builder: (context, value, child) {
            final double factor = value ?? 1.0;
            final effectiveInsets = cutoutInsets * factor;
            return Padding(
              padding: effectiveInsets,
              child: MediaQueryDataProvider(
                value: MediaQuery.of(context).removeCutoutInsets(effectiveInsets),
                child: child!,
              ),
            );
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

extension ExtraMediaQueryData on MediaQueryData {
  MediaQueryData removeCutoutInsets(EdgeInsets cutoutInsets) {
    return copyWith(
      padding: EdgeInsets.only(
        left: max(0.0, padding.left - cutoutInsets.left),
        top: max(0.0, padding.top - cutoutInsets.top),
        right: max(0.0, padding.right - cutoutInsets.right),
        bottom: max(0.0, padding.bottom - cutoutInsets.bottom),
      ),
      viewPadding: EdgeInsets.only(
        left: max(0.0, viewPadding.left - cutoutInsets.left),
        top: max(0.0, viewPadding.top - cutoutInsets.top),
        right: max(0.0, viewPadding.right - cutoutInsets.right),
        bottom: max(0.0, viewPadding.bottom - cutoutInsets.bottom),
      ),
    );
  }
}

class DirectionalSafeArea extends StatelessWidget {
  final bool start, top, end, bottom;
  final EdgeInsets minimum;
  final bool maintainBottomViewPadding;
  final Widget child;

  const DirectionalSafeArea({
    super.key,
    this.start = true,
    this.top = true,
    this.end = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = context.isRtl;
    return SafeArea(
      left: isRtl ? end : start,
      top: top,
      right: isRtl ? start : end,
      bottom: bottom,
      minimum: minimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }
}
