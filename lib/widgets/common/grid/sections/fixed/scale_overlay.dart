import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/material.dart';

class FixedExtentScaleOverlay extends StatelessWidget {
  final TileLayout tileLayout;
  final Offset tileCenter;
  final double xMin, xMax;
  final ValueNotifier<Size> scaledSizeNotifier;
  final Widget Function(Offset center, Size tileSize, Widget child) gridBuilder;
  final Widget Function(Size scaledTileSize) builder;

  FixedExtentScaleOverlay({
    super.key,
    required this.tileLayout,
    required this.tileCenter,
    required Rect contentRect,
    required this.scaledSizeNotifier,
    required this.gridBuilder,
    required this.builder,
  })  : xMin = contentRect.left,
        xMax = contentRect.right;

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: IgnorePointer(
        child: _OverlayBackground(
          gradientCenter: tileLayout == TileLayout.grid ? tileCenter : Offset(context.isRtl ? xMax : xMin, tileCenter.dy),
          child: ValueListenableBuilder<Size>(
            valueListenable: scaledSizeNotifier,
            builder: (context, scaledSize, child) {
              final width = scaledSize.width;
              final height = scaledSize.height;
              // keep scaled thumbnail within the screen
              var dx = .0;
              if (tileCenter.dx - width / 2 < xMin) {
                dx = xMin - (tileCenter.dx - width / 2);
              } else if (tileCenter.dx + width / 2 > xMax) {
                dx = xMax - (tileCenter.dx + width / 2);
              }
              final clampedCenter = tileCenter.translate(dx, 0);

              var child = builder(scaledSize);
              child = Stack(
                children: [
                  Positioned(
                    left: clampedCenter.dx - width / 2,
                    top: clampedCenter.dy - height / 2,
                    child: DefaultTextStyle(
                      style: const TextStyle(),
                      child: child,
                    ),
                  ),
                ],
              );
              child = gridBuilder(clampedCenter, scaledSize, child);
              return child;
            },
          ),
        ),
      ),
    );
  }
}

class _OverlayBackground extends StatefulWidget {
  final Offset gradientCenter;
  final Widget child;

  const _OverlayBackground({
    required this.gradientCenter,
    required this.child,
  });

  @override
  State<_OverlayBackground> createState() => _OverlayBackgroundState();
}

class _OverlayBackgroundState extends State<_OverlayBackground> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _initialized = true));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: _buildBackgroundDecoration(context),
      duration: ADurations.scalingGridBackgroundAnimation,
      child: widget.child,
    );
  }

  BoxDecoration _buildBackgroundDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientCenter = widget.gradientCenter;
    return _initialized
        ? BoxDecoration(
            gradient: RadialGradient(
              center: FractionalOffset.fromOffsetAndSize(gradientCenter, MediaQuery.sizeOf(context)),
              radius: 1,
              colors: isDark
                  ? const [
                      Colors.black,
                      Colors.black54,
                    ]
                  : const [
                      Colors.white,
                      Colors.white38,
                    ],
            ),
          )
        : BoxDecoration(
            // provide dummy gradient to lerp to the other one during animation
            gradient: RadialGradient(
              colors: isDark
                  ? const [
                      ColorUtils.transparentBlack,
                      ColorUtils.transparentBlack,
                    ]
                  : const [
                      ColorUtils.transparentWhite,
                      ColorUtils.transparentWhite,
                    ],
            ),
          );
  }
}
