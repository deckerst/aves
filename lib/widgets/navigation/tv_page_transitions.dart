import 'package:flutter/material.dart';

class TvPageTransitionsBuilder extends PageTransitionsBuilder {
  const TvPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double>? secondaryAnimation,
    Widget child,
  ) {
    return _TvPageTransition(routeAnimation: animation, child: child);
  }
}

class _TvPageTransition extends StatelessWidget {
  final Animation<double> _opacityAnimation;
  final Widget child;

  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  _TvPageTransition({
    required Animation<double> routeAnimation,
    required this.child,
  }) : _opacityAnimation = routeAnimation.drive(_easeInTween);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: child,
    );
  }
}
