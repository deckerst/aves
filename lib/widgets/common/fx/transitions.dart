import 'package:flutter/widgets.dart';

class AvesTransitions {
  static Widget formTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        alignment: const Alignment(-1, -1),
        child: child,
      ),
    );
  }
}
