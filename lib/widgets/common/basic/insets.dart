import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// This widget should be added on top of Scaffolds with:
// - `resizeToAvoidBottomInset` set to false,
// - a vertically scrollable body.
// It will prevent the body from scrolling when a user swipe from bottom to use Android Q style navigation gestures.
class BottomGestureAreaProtector extends StatelessWidget {
  const BottomGestureAreaProtector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: context.select<MediaQueryData, double>((mq) => mq.systemGestureInsets.bottom),
      child: GestureDetector(
        // absorb vertical gestures only
        onVerticalDragDown: (details) {},
        behavior: HitTestBehavior.translucent,
      ),
    );
  }
}

// It will prevent the body from scrolling when a user swipe from edges to use Android Q style navigation gestures.
class SideGestureAreaProtector extends StatelessWidget {
  const SideGestureAreaProtector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Row(
        // `systemGestureInsets` are not directional
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(
            width: context.select<MediaQueryData, double>((mq) => mq.systemGestureInsets.left),
            child: GestureDetector(
              // absorb horizontal gestures only
              onHorizontalDragDown: (details) {},
              behavior: HitTestBehavior.translucent,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: context.select<MediaQueryData, double>((mq) => mq.systemGestureInsets.right),
            child: GestureDetector(
              // absorb horizontal gestures only
              onHorizontalDragDown: (details) {},
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ],
      ),
    );
  }
}

class GestureAreaProtectorStack extends StatelessWidget {
  final Widget child;

  const GestureAreaProtectorStack({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const BottomGestureAreaProtector(),
      ],
    );
  }
}

class BottomPaddingSliver extends StatelessWidget {
  const BottomPaddingSliver({Key? key}) : super(key: key);

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
