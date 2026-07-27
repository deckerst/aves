import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class PageTransitionEffects {
  static TransitionBuilder fade(
    PageController pageController,
    int index, {
    required bool zoomIn,
  }) => (context, child) {
    double opacity = 0;
    double dx = 0;
    double scale = 1;
    _applyTransitionPosition(pageController, index, (position, width) {
      opacity = (1 - position.abs()).clamp(0, 1);
      dx = position * width * (context.isRtl ? -1 : 1);
      if (zoomIn) {
        scale = 1 + position;
      }
    });
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      ),
    );
  };

  static TransitionBuilder slide(
    PageController pageController,
    int index, {
    required bool parallax,
  }) => (context, child) {
    double dx = 0;
    if (parallax) {
      _applyTransitionPosition(pageController, index, (position, width) {
        dx = position * width / 2 * (context.isRtl ? -1 : 1);
      });
    }
    return ClipRect(
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: child,
      ),
    );
  };

  static TransitionBuilder none(
    PageController pageController,
    int index,
  ) => (context, child) {
    double opacity = 0;
    double dx = 0;
    _applyTransitionPosition(pageController, index, (position, width) {
      opacity = (1 - position.abs()).roundToDouble().clamp(0, 1);
      dx = position * width * (context.isRtl ? -1 : 1);
    });
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: child,
      ),
    );
  };

  static void _applyTransitionPosition(
    PageController pageController,
    int index,
    void Function(double position, double width) apply,
  ) {
    if (!pageController.hasClients) {
      debugPrint('failed to compute transition for child at index=$index because page controller has no clients');
      return;
    }

    final page = pageController.page;
    if (page == null) {
      debugPrint('failed to compute transition for child at index=$index because page controller page is null');
      return;
    }

    final controllerPosition = pageController.position;
    if (!controllerPosition.hasViewportDimension) {
      debugPrint('failed to compute transition for child at index=$index because page controller position has no viewport dimensions');
      return;
    }

    final position = (page - index).clamp(-1.0, 1.0);
    final width = controllerPosition.viewportDimension;
    apply(position, width);
  }
}
