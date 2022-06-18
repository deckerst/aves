import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/controller.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraViewerTransition on ViewerTransition {
  String getName(BuildContext context) {
    switch (this) {
      case ViewerTransition.slide:
        return context.l10n.viewerTransitionSlide;
      case ViewerTransition.parallax:
        return context.l10n.viewerTransitionParallax;
      case ViewerTransition.fade:
        return context.l10n.viewerTransitionFade;
      case ViewerTransition.zoomIn:
        return context.l10n.viewerTransitionZoomIn;
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
      case ViewerTransition.zoomIn:
        return PageTransitionEffects.fade(pageController, index, zoomIn: true);
    }
  }
}
