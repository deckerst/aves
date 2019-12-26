import 'package:flutter/material.dart';

class TransparentMaterialPageRoute<T> extends PageRouteBuilder<T> {
  TransparentMaterialPageRoute({
    @required RoutePageBuilder pageBuilder,
  }) : super(pageBuilder: pageBuilder);

  @override
  bool get opaque => false;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }
}
