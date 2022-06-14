import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/controller.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraViewerTransition on ViewerTransition {
  String getName(BuildContext context) {
    switch (this) {
      case ViewerTransition.fade:
        return context.l10n.viewerTransitionFade;
      case ViewerTransition.fadeZoomIn:
        return context.l10n.viewerTransitionFadeZoomIn;
      case ViewerTransition.parallax:
        return context.l10n.viewerTransitionParallax;
      case ViewerTransition.slide:
        return context.l10n.viewerTransitionSlide;
    }
  }

  TransitionBuilder builder(PageController pageController, int index) {
    switch (this) {
      case ViewerTransition.slide:
        return PageTransitionEffects.slide(pageController, index, parallax: false);
      case ViewerTransition.parallax:
        return PageTransitionEffects.slide(pageController, index, parallax: true);
      case ViewerTransition.fade:
        return PageTransitionEffects.fade(pageController, index, zoomIn: false);
      case ViewerTransition.fadeZoomIn:
        return PageTransitionEffects.fade(pageController, index, zoomIn: true);
    }
  }
}
