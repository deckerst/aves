import 'package:material_ui/material_ui.dart';

class _DirectPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

class const DirectPageTransitionsTheme() extends PageTransitionsTheme {
  @override
  Map<TargetPlatform, PageTransitionsBuilder> get builders => {
    TargetPlatform.android: _DirectPageTransitionsBuilder(),
  };
}

class DirectMaterialPageRoute<T>({
  super.settings,
  required WidgetBuilder builder,
}) extends PageRouteBuilder<T> {
  this : super(pageBuilder: (context, _, _) => builder(context));

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  RouteTransitionsBuilder get transitionsBuilder =>
      (_, _, _, child) => child;
}

// `MaterialPageRoute` cannot be extended when `opaque` is false
// `MaterialRouteTransitionMixin` does not respect `opaque` field
class TransparentMaterialPageRoute<T>({
  super.settings,
  required super.transitionDuration,
  required super.pageBuilder,
}) extends PageRouteBuilder<T> {
  @override
  bool get opaque => false;

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }
}
