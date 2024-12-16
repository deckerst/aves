import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/grid/sections/mosaic/scale_grid.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/material.dart';

typedef MosaicItemBuilder = Widget Function(int index, double targetExtent);

class MosaicScaleOverlay extends StatelessWidget {
  final Rect contentRect;
  final double spacing, extentMax;
  final ValueNotifier<Size> scaledSizeNotifier;
  final MosaicItemBuilder itemBuilder;

  const MosaicScaleOverlay({
    super.key,
    required this.contentRect,
    required this.spacing,
    required this.extentMax,
    required this.scaledSizeNotifier,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: IgnorePointer(
        child: _OverlayBackground(
          child: ValueListenableBuilder<Size>(
            valueListenable: scaledSizeNotifier,
            builder: (context, scaledSize, child) {
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;
              Widget _buildBar(double width, Color color) => ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: Container(
                      color: color,
                      width: width,
                      height: 4,
                    ),
                  );
              return SafeArea(
                left: false,
                right: false,
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildBar(extentMax, colorScheme.onSurface.withValues(alpha: .2)),
                          _buildBar(scaledSize.width, colorScheme.primary),
                        ],
                      ),
                    ),
                    Expanded(
                      child: MosaicGrid(
                        contentRect: contentRect,
                        tileSize: scaledSize,
                        spacing: spacing,
                        builder: itemBuilder,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OverlayBackground extends StatefulWidget {
  final Widget child;

  const _OverlayBackground({
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
    final isDark = Theme.of(context).isDark;
    return _initialized
        ? BoxDecoration(
            color: isDark ? Colors.black87 : const Color(0xDDFFFFFF),
          )
        : BoxDecoration(
            color: isDark ? ColorUtils.transparentBlack : ColorUtils.transparentWhite,
          );
  }
}
