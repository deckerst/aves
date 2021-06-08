import 'package:flutter/material.dart';

class InteractiveAppBarTitle extends StatelessWidget {
  final GestureTapCallback? onTap;
  final Widget child;

  const InteractiveAppBarTitle({
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
        padding: const EdgeInsets.symmetric(horizontal: NavigationToolbar.kMiddleSpacing),
        color: Colors.transparent,
        height: kToolbarHeight,
        child: child,
      ),
    );
  }
}
