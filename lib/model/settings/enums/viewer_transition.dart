import 'dart:math';

import 'package:aves/widgets/viewer/controls/transitions.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
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
      case ViewerTransition.random:
        return _ViewerTransitionRandomizer.getBuilder(pageController, index);
    }
  }
}

class _ViewerTransitionRandomizer {
  static const options = [
    ViewerTransition.slide,
    ViewerTransition.parallax,
    ViewerTransition.fade,
    ViewerTransition.zoomIn,
  ];

  static final List<(int, ViewerTransition)> _indexedTransitions = [];

  static TransitionBuilder getBuilder(
    PageController pageController,
    int index,
  ) =>
      (context, child) {
        final negative = pageController.hasClients && pageController.position.haveDimensions && (pageController.page! - index).isNegative;
        final transition = _getTransition(negative ? index - 1 : index);
        final builder = transition.builder(pageController, index);
        return builder(context, child);
      };

  static ViewerTransition _getTransition(int transitionIndex) {
    var indexedTransition = _indexedTransitions.firstWhereOrNull((v) => v.$1 == transitionIndex);
    if (indexedTransition != null) {
      _indexedTransitions.remove(indexedTransition);
    } else {
      indexedTransition = (transitionIndex, options[Random().nextInt(options.length)]);
    }
    _indexedTransitions.insert(0, indexedTransition);
    while (_indexedTransitions.length > 3) {
      _indexedTransitions.removeLast();
    }

    final (_, transition) = indexedTransition;
    return transition;
  }
}
