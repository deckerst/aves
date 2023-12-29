import 'package:flutter/widgets.dart';

class PageTransitionEffects {
  static TransitionBuilder fade(
    PageController pageController,
    int index, {
    required bool zoomIn,
  }) =>
      (context, child) {
        double opacity = 0;
        double dx = 0;
        double scale = 1;
        if (pageController.hasClients && pageController.position.haveDimensions) {
          final position = (pageController.page! - index).clamp(-1.0, 1.0);
          final width = pageController.position.viewportDimension;
          opacity = (1 - position.abs()).clamp(0, 1);
          dx = position * width;
          if (zoomIn) {
            scale = 1 + position;
          }
        }
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
  }) =>
      (context, child) {
        double dx = 0;
        if (pageController.hasClients && pageController.position.haveDimensions) {
          final position = (pageController.page! - index).clamp(-1.0, 1.0);
          final width = pageController.position.viewportDimension;
          if (parallax) {
            dx = position * width / 2;
          }
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
  ) =>
      (context, child) {
        double opacity = 0;
        double dx = 0;
        if (pageController.hasClients && pageController.position.haveDimensions) {
          final position = (pageController.page! - index).clamp(-1.0, 1.0);
          final width = pageController.position.viewportDimension;
          opacity = (1 - position.abs()).roundToDouble().clamp(0, 1);
          dx = position * width;
        }
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: child,
          ),
        );
      };
}
