import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// This widget should be added on top of Scaffolds with:
// - `resizeToAvoidBottomInset` set to false,
// - a vertically scrollable body.
// It will prevent the body from scrolling when a user swipe from bottom to use Android Q style navigation gestures.
class BottomGestureAreaProtector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<MediaQueryData, double>(
      selector: (c, mq) => mq.systemGestureInsets.bottom,
      builder: (c, systemGestureBottom, child) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: systemGestureBottom,
          child: AbsorbPointer(),
        );
      },
    );
  }
}

class GestureAreaProtectorStack extends StatelessWidget {
  final Widget child;

  const GestureAreaProtectorStack({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        BottomGestureAreaProtector(),
      ],
    );
  }
}

class BottomPaddingSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<MediaQueryData, double>(
        selector: (context, mq) => mq.effectiveBottomPadding,
        builder: (context, mqPaddingBottom, child) {
          return SizedBox(height: mqPaddingBottom);
        },
      ),
    );
  }
}
