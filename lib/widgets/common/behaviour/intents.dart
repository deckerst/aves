import 'package:flutter/widgets.dart';

class VerticalScrollIntent extends Intent {
  const VerticalScrollIntent({
    required this.type,
  });

  const VerticalScrollIntent.up() : type = VerticalScrollDirection.up;

  const VerticalScrollIntent.down() : type = VerticalScrollDirection.down;

  final VerticalScrollDirection type;
}

enum VerticalScrollDirection {
  up,
  down,
}

class VerticalScrollIntentAction extends CallbackAction<VerticalScrollIntent> {
  VerticalScrollIntentAction({
    required ScrollController scrollController,
  }) : super(onInvoke: (intent) => _onScrollIntent(intent, scrollController));

  static void _onScrollIntent(
    VerticalScrollIntent intent,
    ScrollController scrollController,
  ) {
    late int factor;
    switch (intent.type) {
      case VerticalScrollDirection.up:
        factor = -1;
        break;
      case VerticalScrollDirection.down:
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
