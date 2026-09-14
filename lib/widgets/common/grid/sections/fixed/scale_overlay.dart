import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:material_ui/material_ui.dart';

class const FixedExtentScaleOverlay({
  super.key,
  required final TileLayout tileLayout,
  required final Offset tileCenter,
  required final Rect contentRect,
  required final ValueNotifier<Size> scaledSizeNotifier,
  required final Widget Function(Offset center, Size tileSize, Widget child) gridBuilder,
  required final Widget Function(Size scaledTileSize) builder,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final xMin = contentRect.left;
    final xMax = contentRect.right;
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

class const _OverlayBackground({
  required final Offset gradientCenter,
  required final Widget child,
}) extends StatefulWidget {
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
    final isDark = Theme.of(context).isDark;
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
