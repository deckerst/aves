import 'package:flutter/widgets.dart';

class ScrollControllerAction extends CallbackAction<ScrollIntent> {
  ScrollControllerAction({
    required ScrollController scrollController,
  }) : super(onInvoke: (intent) => _onScrollIntent(intent, scrollController));

  static void _onScrollIntent(
    ScrollIntent intent,
    ScrollController scrollController,
  ) {
    late int factor;
    switch (intent.direction) {
      case AxisDirection.up:
      case AxisDirection.left:
        factor = -1;
        break;
      case AxisDirection.down:
      case AxisDirection.right:
        factor = 1;
        break;
    }
    scrollController.animateTo(
      scrollController.offset + factor * 150,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }
}
