import 'package:aves/widgets/common/search/delegate.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:flutter/material.dart';

// adapted from Flutter `_SearchBody` in `/material/search.dart`
enum SearchBody { suggestions, results }

// adapted from Flutter `_SearchPageRoute` in `/material/search.dart`
class SearchPageRoute<T> extends PageRoute<T> {
  SearchPageRoute({
    required this.delegate,
  }) : super(settings: RouteSettings(name: delegate.routeName)) {
    assert(
      delegate.route == null,
      'The ${delegate.runtimeType} instance is currently used by another active '
      'search. Please close that search by calling close() on the SearchDelegate '
      'before openening another search with the same delegate instance.',
    );
    delegate.route = this;
  }

  final AvesSearchDelegate delegate;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => false;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // a simple fade is usually more fitting for a search page,
    // instead of the `pageTransitionsTheme` used by the rest of the app
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Animation<double> createAnimation() {
    final animation = super.createAnimation();
    delegate.proxyAnimation.parent = animation;
    return animation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SearchPage(
      delegate: delegate,
      animation: animation,
    );
  }

  @override
  void didComplete(T? result) {
    super.didComplete(result);
    assert(delegate.route == this);
    delegate.route = null;
    delegate.currentBody = null;
  }
}
