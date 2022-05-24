import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvesAppBar extends StatelessWidget {
  final double contentHeight;
  final Widget leading;
  final Widget title;
  final List<Widget> actions;
  final Widget? bottom;
  final Object? transitionKey;

  static const leadingHeroTag = 'appbar-leading';
  static const titleHeroTag = 'appbar-title';

  const AvesAppBar({
    super.key,
    required this.contentHeight,
    required this.leading,
    required this.title,
    required this.actions,
    this.bottom,
    this.transitionKey,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MediaQueryData, double>(
      selector: (context, mq) => mq.padding.top,
      builder: (context, mqPaddingTop, child) {
        return SliverPersistentHeader(
          floating: true,
          pinned: false,
          delegate: _SliverAppBarDelegate(
            height: mqPaddingTop + appBarHeightForContentHeight(contentHeight),
            child: SafeArea(
              bottom: false,
              child: AvesFloatingBar(
                builder: (context, backgroundColor, child) => Material(
                  color: backgroundColor,
                  textStyle: Theme.of(context).appBarTheme.titleTextStyle,
                  child: child,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: kToolbarHeight,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Hero(
                              tag: leadingHeroTag,
                              flightShuttleBuilder: _flightShuttleBuilder,
                              transitionOnUserGestures: true,
                              child: leading,
                            ),
                          ),
                          Expanded(
                            child: Hero(
                              tag: titleHeroTag,
                              flightShuttleBuilder: _flightShuttleBuilder,
                              transitionOnUserGestures: true,
                              child: AnimatedSwitcher(
                                duration: context.read<DurationsData>().iconAnimation,
                                child: Row(
                                  key: ValueKey(transitionKey),
                                  children: [
                                    Expanded(child: title),
                                    ...actions,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (bottom != null) bottom!,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHero,
    BuildContext toHero,
  ) {
    final pushing = direction == HeroFlightDirection.push;
    Widget popBuilder(context, child) => Opacity(opacity: 1 - animation.value, child: child);
    Widget pushBuilder(context, child) => Opacity(opacity: animation.value, child: child);
    return Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(toHero).style,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: pushing ? popBuilder : pushBuilder,
              child: fromHero.widget,
            ),
            AnimatedBuilder(
              animation: animation,
              builder: pushing ? pushBuilder : popBuilder,
              child: toHero.widget,
            ),
          ],
        ),
      ),
    );
  }

  static double appBarHeightForContentHeight(double contentHeight) => AvesFloatingBar.margin.vertical + contentHeight;
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _SliverAppBarDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) => true;
}

class AvesFloatingBar extends StatefulWidget {
  final Widget Function(BuildContext context, Color backgroundColor, Widget? child) builder;
  final Widget? child;

  static const margin = EdgeInsets.all(8);
  static const borderRadius = BorderRadius.all(Radius.circular(8));

  const AvesFloatingBar({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  State<AvesFloatingBar> createState() => _AvesFloatingBarState();
}

class _AvesFloatingBarState extends State<AvesFloatingBar> with RouteAware {
  // prevent expensive blurring when the current page is hidden
  final ValueNotifier<bool> _isBlurAllowedNotifier = ValueNotifier(true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      AvesApp.pageRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AvesApp.pageRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => _isBlurAllowedNotifier.value = true;

  @override
  void didPushNext() => _isBlurAllowedNotifier.value = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.appBarTheme.backgroundColor!;
    return ValueListenableBuilder<bool>(
      valueListenable: _isBlurAllowedNotifier,
      builder: (context, isBlurAllowed, child) {
        final blurred = isBlurAllowed && context.select<Settings, bool>((s) => s.enableOverlayBlurEffect);
        return Container(
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: theme.dividerColor,
            ),
            borderRadius: AvesFloatingBar.borderRadius,
          ),
          margin: AvesFloatingBar.margin,
          child: BlurredRRect(
            enabled: blurred,
            borderRadius: AvesFloatingBar.borderRadius,
            child: widget.builder(
              context,
              blurred ? backgroundColor.withOpacity(.85) : backgroundColor,
              widget.child,
            ),
          ),
        );
      },
    );
  }
}
