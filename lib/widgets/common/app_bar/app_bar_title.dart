import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InteractiveAppBarTitle extends StatelessWidget {
  final GestureTapCallback? onTap;
  final Widget child;

  const InteractiveAppBarTitle({
    super.key,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // use a `Container` with a dummy color to make it expand
      // so that we can also detect taps around the title `Text`
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        color: Colors.transparent,
        height: kToolbarHeight * context.select<MediaQueryData, double>((mq) => mq.textScaleFactor),
        child: child,
      ),
    );
  }
}
