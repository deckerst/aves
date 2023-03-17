import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/widgets/viewer/controls/controller.dart';
import 'package:flutter/widgets.dart';

extension ExtraViewerTransition on ViewerTransition {
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
      case ViewerTransition.none:
        return PageTransitionEffects.none(pageController, index);
    }
  }
}
