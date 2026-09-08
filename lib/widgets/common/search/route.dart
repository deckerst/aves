import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/search/delegate.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

// adapted from Flutter `_SearchBody` in `/material/search.dart`
enum SearchBody { suggestions, results }

// adapted from Flutter `_SearchPageRoute` in `/material/search.dart`
class SearchPageRoute<T> extends PageRoute<T> {
  new({
    required this.delegate,
    this.background,
  }) : super(settings: RouteSettings(name: delegate.routeName)) {
    assert(
      delegate.route == null,
      'The ${delegate.runtimeType} instance is currently used by another active '
      'search. Please close that search by calling close() on the SearchDelegate '
      'before opening another search with the same delegate instance.',
    );
    delegate.route = this;
  }

  @override
  void dispose() {
    // `delegate` is always created by the caller at route creation time,
    // so it should always be disposed when the route is disposed
    delegate.dispose();
    super.dispose();
  }

  final AvesSearchDelegate delegate;

  // When `PredictiveBackPageTransitionsBuilder` is the transition used for page N-1,
  // N-1 slides away and page N-2 (if any) briefly flashes, while the search page is fading in.
  // So we apply an opaque background color if provided, to hide pages below.
  // This differs from `barrierColor`, which fades in.
  final Color? background;

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
    final animate = context.read<Settings>().animate;
    return animate
        ? Container(
            color: background,
            // a simple fade is usually more fitting for a search page
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          )
        : child;
  }

  @override
  Animation<double> createAnimation() {
    final Animation<double> animation = super.createAnimation();
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
