import 'package:flutter/widgets.dart';

class AvesTransitions {
  static Widget formTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: child,
      ),
    );
  }
}
