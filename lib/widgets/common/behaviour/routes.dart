import 'package:flutter/material.dart';

class DirectPageTransitionsTheme extends PageTransitionsTheme {
  const DirectPageTransitionsTheme();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}

class DirectMaterialPageRoute<T> extends PageRouteBuilder<T> {
  DirectMaterialPageRoute({
    RouteSettings? settings,
    required WidgetBuilder builder,
  }) : super(
          settings: settings,
          transitionDuration: Duration.zero,
          pageBuilder: (context, a, sa) => builder(context),
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

class TransparentMaterialPageRoute<T> extends PageRouteBuilder<T> {
  TransparentMaterialPageRoute({
    RouteSettings? settings,
    required RoutePageBuilder pageBuilder,
  }) : super(settings: settings, pageBuilder: pageBuilder);

  @override
  bool get opaque => false;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }
}
